//
//  GroupsShelf.m
//  GroupsShelf
//
//  Created by pkolchanov on 17.02.2025.
//
//

#import "GroupsShelf.h"

typedef enum {
    positionLeft,
    positionRight,
} GroupPosition;

@implementation GroupsShelf {
    BOOL _hasRegisteredObservers;
}

- (instancetype) init {
    self = [super initWithWindowNibName:[self windowNibName]];
    if (self) {
        [self window];
        _hasRegisteredObservers = NO;
        _compositesDictionary = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle bundleForClass:[self class]] pathForResource:@"composites" ofType:@"plist"]];
    }
    return self;
}

- (NSUInteger)interfaceVersion {
    // Distinguishes the API verison the plugin was built for. Return 1.
    return 1;
}

- (NSNibName)windowNibName{
    return @"GroupsShelfWindow";
}

- (NSString *)title {
    return @"Groups Shelf";
}

- (NSString *)keyEquivalent {
    return @"";
}

- (void)awakeFromNib {
    // TODO: move to ShelfWindow
    NSWindow * _Nullable window = [self window];
    [window setLevel:NSFloatingWindowLevel];
    [window setHidesOnDeactivate:YES];
    [window setStyleMask:NSWindowStyleMaskBorderless|NSWindowStyleMaskResizable|NSWindowStyleMaskClosable];
    [window setBackgroundColor:[NSColor clearColor]];
    [window setMovableByWindowBackground:YES];
    [window setOpaque:NO];
    [[[window contentView] layer] setBackgroundColor: [[NSColor windowBackgroundColor] CGColor]];
    [[[window contentView] layer] setCornerRadius:10];
    [[self glyphCollectionView] registerClass:[GroupsShelfItem class]
                        forItemWithIdentifier:@"GroupsShelfItem"];
    [[self groupsArrayController] addObserver:self forKeyPath:@"selectedObjects" options:1 context:nil];
    
    FixGroupsPanelViewController *fixGroupsViewController = [[FixGroupsPanelViewController alloc] initWithNibName:@"FixGroupsPanelViewController" bundle:[NSBundle bundleForClass:[self class]]];
    [self setFixGroupsPanelViewController:fixGroupsViewController];
    [[self contentViewController] addChildViewController:fixGroupsViewController];
    [[self fixGroupsView] addSubview:[fixGroupsViewController view]];
}


- (void)loadPlugin {
    NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:[self title] action:@selector(showPluginWindow:) keyEquivalent:[self keyEquivalent]];
    newMenuItem.target = self;
    NSMenu *submenu = [[mainMenu itemWithTag:17] submenu];
    [submenu addItem:newMenuItem];
}


-(void)showPluginWindow:(id)sender{
    NSLog(@"showPluginWindow");
    [self showWindow:nil];
    [self setupObservers];
    [self updateKerningData];
}

// MARK: -IB

- (IBAction)toggleFixPanel:(id)sender {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
           context.duration = 0.2;
        context.timingFunction =  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
           self.fixGroupsHeightConstraint.animator.constant = [[self fixGroupsHeightConstraint] constant] == 0 ? 150 : 0;
       } completionHandler:nil];
}

- (IBAction)renameSelectedGroupAction:(id)sender {
    [self renameSelectedGroup:[[self selectedGroupTextField] stringValue]];
}

- (IBAction)showOptionsMenu:(id)sender {
    NSLog(@"Show Options");
    // Create a menu item
    NSMenu *menu = [[NSMenu alloc] init];
    
    NSMenuItem *addMissingCompositesItem = [[NSMenuItem alloc] initWithTitle:@"Add missing composites"
                                                             action:@selector(addMissingComposites:)
                                                      keyEquivalent:@""];
    [addMissingCompositesItem setTarget:self];
    [menu addItem:addMissingCompositesItem];
    
    NSMenuItem *removeGroupItem = [[NSMenuItem alloc] initWithTitle:@"Remove group"
                                                             action:@selector(removeSelectedGroup:)
                                                      keyEquivalent:@""];
    
    [removeGroupItem setTarget:self];
    [menu addItem:removeGroupItem];
    
    NSEvent *event = [NSApp currentEvent];
    NSView *view = [[NSApp mainWindow] contentView];
    [NSMenu popUpContextMenu:menu withEvent:event forView:view];
}

- (IBAction)removeGlyphsFromGroup:(id)sender {
    // TODO: bind glyphCollectionView indexes to glyphsArrayController indexes
    NSIndexSet *selectedIndexes = [[self glyphCollectionView] selectionIndexes];
    for (GSGlyph *g in [[[self glyphsArrayController] arrangedObjects] objectsAtIndexes:selectedIndexes]){
        NSLog(@"To remove %@", [g name]);
        [self selectedGroupPosition] == positionLeft ? [g setLeftKerningGroup:nil] :  [g setRightKerningGroup:nil];
    }
    [self updateGlyphData];
}

- (IBAction)addGlyphsToGroup:(id)sender {
    NSString * selectedGroup = [[[self groupsArrayController] selectedObjects] firstObject];
    for (GSGlyph *g in [self curentFontSelectedGlyphs]){
        NSLog(@"To add %@", [g name]);
        NSLog(@"Group %@", selectedGroup);
        [self selectedGroupPosition] == positionLeft ? [g setLeftKerningGroup:selectedGroup] :  [g setRightKerningGroup:selectedGroup];
    }
    [self updateGlyphData];
}

- (IBAction)selectGroupTab:(id)sender {
    [self updateKerningData];
}


- (IBAction)closeWindowAction:(id)sender {
    [[self window] close];
}

-(GroupPosition)selectedGroupPosition{
    return  [[self groupPositoinSegmented] selectedTag] == 0 ? positionLeft : positionRight;
}



// MARK: -Glyphs Accessors

-(GSDocument*)currentDocument{
    GSApplication *app = NSApp;
    GSDocument *document = [app currentFontDocument];
    return document;
}

-(GSFont *)currentFont{
    GSDocument *document = [self currentDocument];
    GSFont *font = [document font];
    return font;
}

-(GSFontMaster *)currentFontMaster{
    GSApplication *app = NSApp;
    GSDocument *document = [app currentFontDocument];
    
    return [document selectedFontMaster];
}

- (NSArray<GSGlyph *> *)curentFontSelectedGlyphs {
    GSDocument *document = [self currentDocument];
    NSWindowController<GSWindowControllerProtocol> *windowController = [document windowController];
    NSLog(@"%@", windowController);
    if (windowController == nil) return @[];
    
    NSArray<GSLayer *> *layers = windowController.selectedLayers;
    NSMutableArray<GSGlyph *> *glyphs = [NSMutableArray new];
    
    for (GSLayer *layer in layers) {
        GSGlyph *glyph = layer.parent;
        [glyphs addObject:glyph];
    }
    
    return glyphs;
}
// MARK: -Groups Naming

-(NSString*)shortNameOfGroup:(NSString*)group{
    group = [group stringByReplacingOccurrencesOfString:@"@MMK_R_" withString:@""];;
    group = [group stringByReplacingOccurrencesOfString:@"@MMK_L_" withString:@""];;
    return group;
}

-(NSString*)fullNameOfShortGroup:(NSString*)group{
    GroupPosition currentPosition = [self selectedGroupPosition];
    NSString *prefix = currentPosition == positionLeft ? @"@MMK_R_" : @"@MMK_L_";
    return [prefix stringByAppendingString:group];
}

-(NSString*)kerningGroupOfAGlyph:(GSGlyph*)g{
    GroupPosition currentPosition = [self selectedGroupPosition];
    NSString *group = currentPosition == positionLeft ? [g leftKerningGroupId] : [g rightKerningGroupId];
    return group;
}

-(NSString*)shortKeringGroupOfGlyph:(GSGlyph*)g{
    NSString *group = [self kerningGroupOfAGlyph:g];
    return [self shortNameOfGroup:group];
}

// MARK: -Interface Updates

-(void)updateKerningData{
    NSLog(@"Update kerning groups");
    
    [[self groupsArrayController] setContent:[self currentFontGroups]];
}

-(void)updateGlyphData{
    NSLog(@"updateGlyphData!");
    NSString *currentGroup = [[[self groupsArrayController] selectedObjects] firstObject];
    [[self glyphsArrayController] setContent:[self currentGroupGlyphs]];
    [[self selectedGroupTextField] setStringValue:currentGroup == nil ? @"" :currentGroup];
}

-(NSArray<NSString*> *)currentFontGroups{
    GSFont *currentFont = [self currentFont];
    if (currentFont == nil){
        return @[];
    }
    
    NSMutableOrderedSet<NSString*> *allKeys = [[NSMutableOrderedSet alloc] init];
    for (GSGlyph *g in [currentFont glyphs]){
        NSString * group =  [self shortKeringGroupOfGlyph:g];
        
        if (group != nil){
            [allKeys addObject:group];
        }
    }
    return [allKeys array];
}

-(NSArray<GSGlyph*> *)currentGroupGlyphs{
    GSFont *currentFont = [self currentFont];
    NSString *currentGroup = [[[self groupsArrayController] selectedObjects] firstObject];
    NSMutableArray<GSGlyph*> *glyphsOfCurrentGroup = [[NSMutableArray alloc] init];
  
    for (GSGlyph *g in [currentFont glyphs]){
        NSString * group = [self shortKeringGroupOfGlyph:g];
        if ([group isEqualToString:currentGroup]){
            [glyphsOfCurrentGroup addObject:g];
        }
    }
    return glyphsOfCurrentGroup;
}

// MARK: -Renaming
-( NSDictionary* _Nullable )kernPairsToUpdate:(GSFontMaster*) m{
    NSString *currentGroupName = [[[self groupsArrayController] selectedObjects] firstObject];
    NSString *currentGroupFullName = [self fullNameOfShortGroup:currentGroupName];
    
    MGOrderedDictionary *pairsDict = [[[self currentFont] kerningLTR] valueForKey:[m id]];
    if ([self selectedGroupPosition] == positionRight){
        MGOrderedDictionary *resDict = [pairsDict objectForKey:currentGroupFullName];
        return [resDict copy];
    }
    if ([self selectedGroupPosition] == positionLeft){
        NSMutableDictionary *toUpdate = [[NSMutableDictionary alloc] init];
        for (NSString *firstGroup in pairsDict) {
            MGOrderedDictionary *innerDict = [pairsDict objectForKey:firstGroup];
            NSNumber *innerVal = [innerDict objectForKey:currentGroupFullName];
            if (innerVal != nil){
                [toUpdate setValue:innerVal forKey:firstGroup];
            }
        }
        return toUpdate;
    }
    return nil;
}

-(void)renameSelectedGroup:(NSString*)newName{
    GSFont *currentFont = [self currentFont];
    NSString *currentGroupName =  [[[self groupsArrayController] selectedObjects] firstObject];
    NSString *currentGroupFullName = [self fullNameOfShortGroup:currentGroupName];
    newName = [self fullNameOfShortGroup:newName];
    for (GSFontMaster *m in [[self currentFont] fontMasters]){
        NSDictionary *kernPairsToUpdate = [self kernPairsToUpdate:m];
        for (NSString *otherGroup in kernPairsToUpdate) {
            NSNumber *val = [kernPairsToUpdate objectForKey:otherGroup];
             BOOL isRightPosition = ([self selectedGroupPosition] == positionRight);
             
             NSString *leftKey = isRightPosition ? newName : otherGroup;
             NSString *rightKey = isRightPosition ? otherGroup : newName;
             NSString *oldRightKey = isRightPosition ? otherGroup : currentGroupFullName;
             NSString *oldLeftKey = isRightPosition ? currentGroupFullName : otherGroup;

     
             [self setKerningForFontMasterID:[m id] leftKey:leftKey rightKey:rightKey value:val];
             [self removeKerningForFontMasterID:[m id] leftKey:oldLeftKey rightKey:oldRightKey];
        }
    }
    for (GSGlyph *g in [self currentGroupGlyphs]){
        NSString *strippedNewName = [self shortNameOfGroup:newName];
        [self selectedGroupPosition] == positionLeft ? [g setLeftKerningGroup:strippedNewName] :  [g setRightKerningGroup:strippedNewName];
    }
    [self updateKerningData];
}


-(void)removeSelectedGroup:(id)sender{
    NSString *currentGroupName =  [[[self groupsArrayController] selectedObjects] firstObject];
    NSString *currentGroupFullName = [self fullNameOfShortGroup:currentGroupName];
    
    for (GSFontMaster *m in [[self currentFont] fontMasters]){
        NSDictionary *kernPairsToUpdate = [self kernPairsToUpdate:m];
        for (NSString *otherGroup in kernPairsToUpdate) {
             BOOL isRightTab = ([self selectedGroupPosition] == positionRight);
             NSString *oldRightKey = isRightTab ? otherGroup : currentGroupFullName;
             NSString *oldLeftKey = isRightTab ? currentGroupFullName : otherGroup;

            [self removeKerningForFontMasterID:[m id] leftKey:oldLeftKey rightKey:oldRightKey];
        }
    }
    for (GSGlyph *g in [self currentGroupGlyphs]){
        [self selectedGroupPosition] == positionLeft ? [g setLeftKerningGroup:nil] :  [g setRightKerningGroup:nil];
    }
    [self updateKerningData];
}

- (void)setKerningForFontMasterID:(id)fontMasterID leftKey:(id)leftKey rightKey:(id)rightKey value:(NSNumber*)value{
    MGOrderedDictionary *pairsDict = [[[self currentFont] kerningLTR] valueForKey:fontMasterID];
    MGOrderedDictionary *innerDict = [pairsDict objectForKey:leftKey];

    if (innerDict == nil) {
        innerDict = [[MGOrderedDictionary alloc] initWithCapacity:0];
        [pairsDict setObject:innerDict forKey:leftKey];
    }

    [innerDict setValue:value forKey:rightKey];
}

- (void)removeKerningForFontMasterID:(NSString *)fontMasterID leftKey:(NSString *)leftKey rightKey:(NSString *)rightKey{
    MGOrderedDictionary *pairsDict = [[[self currentFont] kerningLTR] valueForKey:fontMasterID];
    MGOrderedDictionary *innerDict = [pairsDict objectForKey:leftKey];
    if (innerDict == nil) {
        return;
    }

    [innerDict removeObjectForKey:rightKey];
}


-(void)addMissingComposites:(id)sender{
    NSString *selectedGroup = [[[self groupsArrayController] selectedObjects] firstObject];
    GroupPosition currentPosition = [self selectedGroupPosition];
    
    NSMutableArray *missingCandidates = [[NSMutableArray alloc] init];
    for (GSGlyph*g in [[self currentFont] glyphs]){
        NSString * groupId = currentPosition == positionLeft ? [g leftKerningGroupId] : [g rightKerningGroupId];
        if (groupId == nil){
            [missingCandidates addObject:g];
        }
    }
    
    NSMutableSet *currentGroupNames = [[NSMutableSet alloc] init];
    for (GSGlyph*g in [self currentGroupGlyphs]){
        [currentGroupNames addObject:[g name]];
    }
    for (GSGlyph *g in missingCandidates){
        NSString *parentName = [[self compositesDictionary] valueForKey:[g name]];
        if (parentName != nil && [currentGroupNames containsObject:parentName]){
            currentPosition == positionLeft ? [g setLeftKerningGroup:selectedGroup] : [g setRightKerningGroup:selectedGroup];
        }
    }
    [self updateGlyphData];
}
// MARK: -Observers
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqual: @"selectedObjects"]){
        NSLog(@"observed change of selection");
        [self updateGlyphData];
        return;
    }
    
}


-(void) removeObservers{
    // TODO: does it work?
    NSLog(@"removeObservers");
    if (_hasRegisteredObservers){
        [NSNotificationCenter.defaultCenter removeObserver:self];
        _hasRegisteredObservers = NO;
    }
}

-(void)interfaceDidUpdate{
    NSLog(@"intrface did update!");
    [self updateKerningData];
}

-(void)docDidActivated{
    NSLog(@"docDidActivated");
    [self updateKerningData];
}


-(void) setupObservers{
    if (!_hasRegisteredObservers){
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(interfaceDidUpdate)
                                                   name:@"GSUpdateInterface"
                                                 object:nil];
       [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(docDidActivated)
                                                   name:@"GSDocumentActivateNotification"
                                                 object:nil];
        _hasRegisteredObservers = YES;
    }
  
}

- (BOOL)windowShouldClose:(id)window {
    if (self.window == window) {
        [self removeObservers];
    }
    return YES;
}
- (void)dealloc
{
    [[self groupsArrayController] removeObserver:self forKeyPath:@"selectedObjects"];
}

@end
