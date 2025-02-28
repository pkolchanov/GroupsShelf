//
//  GroupsShelf.m
//  GroupsShelf
//
//  Created by pkolchanov on 17.02.2025.
//
//

#import "GroupsShelf.h"

typedef enum {
    tabLeft,
    tabRight,
} ActiveLRTab;

@implementation GroupsShelf {
    BOOL _hasRegisteredObservers;
}

- (instancetype) init {
    self = [super initWithWindowNibName:[self windowNibName]];
    if (self) {
        [self window];
        _hasRegisteredObservers = NO;
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

- (IBAction)renameSelectedGroupAction:(id)sender {
    [self renameSelectedGroup:[[self selectedGroupTextField] stringValue]];
}

- (IBAction)showOptionsMenu:(id)sender {
    NSLog(@"Show Options");
    // Create a menu item
    NSMenu *menu = [[NSMenu alloc] init];
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
        [self selectedGroupTab] == tabLeft ? [g setLeftKerningGroup:nil] :  [g setRightKerningGroup:nil];
    }
    [self updateGlyphData];
}

- (IBAction)addGlyphsToGroup:(id)sender {
    NSString * selectedGroup = [[[self groupsArrayController] selectedObjects] firstObject];
    for (GSGlyph *g in [self curentFontSelectedGlyphs]){
        NSLog(@"To add %@", [g name]);
        NSLog(@"Group %@", selectedGroup);
        [self selectedGroupTab] == tabLeft ? [g setLeftKerningGroup:selectedGroup] :  [g setRightKerningGroup:selectedGroup];
    }
    [self updateGlyphData];
}

- (IBAction)selectGroupTab:(id)sender {
    [self updateKerningData];
}


- (IBAction)closeWindowAction:(id)sender {
    [[self window] close];
}

-(ActiveLRTab)selectedGroupTab{
    return  [[self groupPositoinSegmented] selectedTag] == 0 ? tabLeft : tabRight;
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
    ActiveLRTab activeTab = [self selectedGroupTab];
    NSString *prefix = activeTab == tabLeft ? @"@MMK_R_" : @"@MMK_L_";
    return [prefix stringByAppendingString:group];
}

-(NSString*)kerningGroupOfAGlyph:(GSGlyph*)g{
    ActiveLRTab activeTab = [self selectedGroupTab];
    NSString *group = activeTab == tabLeft ? [g leftKerningGroupId] : [g rightKerningGroupId];
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
    [[self selectedGroupTextField] setStringValue:currentGroup];
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
    if ([self selectedGroupTab] == tabRight){
        MGOrderedDictionary *resDict = [pairsDict objectForKey:currentGroupFullName];
        return [resDict copy];
    }
    if ([self selectedGroupTab] == tabLeft){
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
             BOOL isRightTab = ([self selectedGroupTab] == tabRight);
             
             NSString *leftKey = isRightTab ? newName : otherGroup;
             NSString *rightKey = isRightTab ? otherGroup : newName;
             NSString *oldRightKey = isRightTab ? otherGroup : currentGroupFullName;
             NSString *oldLeftKey = isRightTab ? currentGroupFullName : otherGroup;

             [currentFont setKerningForFontMasterID:[m id]
                                            leftKey:leftKey
                                           rightKey:rightKey
                                              value:[val floatValue]
                                          direction:GSWritingDirectionLeftToRight];

             [currentFont removeKerningForFontMasterID:[m id]
                                               leftKey:oldLeftKey
                                              rightKey:oldRightKey
                                             direction:GSWritingDirectionLeftToRight];
        }
    }
    for (GSGlyph *g in [self currentGroupGlyphs]){
        NSString *strippedNewName = [self shortNameOfGroup:newName];
        [self selectedGroupTab] == tabLeft ? [g setLeftKerningGroup:strippedNewName] :  [g setRightKerningGroup:strippedNewName];
    }
    [self updateKerningData];
}


-(void)removeSelectedGroup:(id)sender{
    GSFont *currentFont = [self currentFont];
    NSString *currentGroupName =  [[[self groupsArrayController] selectedObjects] firstObject];
    NSString *currentGroupFullName = [self fullNameOfShortGroup:currentGroupName];
    
    for (GSFontMaster *m in [[self currentFont] fontMasters]){
        NSDictionary *kernPairsToUpdate = [self kernPairsToUpdate:m];
        for (NSString *otherGroup in kernPairsToUpdate) {
            NSNumber *val = [kernPairsToUpdate objectForKey:otherGroup];
             BOOL isRightTab = ([self selectedGroupTab] == tabRight);
             NSString *oldRightKey = isRightTab ? otherGroup : currentGroupFullName;
             NSString *oldLeftKey = isRightTab ? currentGroupFullName : otherGroup;

             [currentFont removeKerningForFontMasterID:[m id]
                                               leftKey:oldLeftKey
                                              rightKey:oldRightKey
                                             direction:GSWritingDirectionLeftToRight];
        }
    }
    for (GSGlyph *g in [self currentGroupGlyphs]){
        [self selectedGroupTab] == tabLeft ? [g setLeftKerningGroup:nil] :  [g setRightKerningGroup:nil];
    }
    [self updateKerningData];
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
