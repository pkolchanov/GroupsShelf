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

- (IBAction)showOptionsMenu:(id)sender {
    NSLog(@"Show Options");
    // Create a menu item
    NSMenu *menu = [[NSMenu alloc] init];
    NSMenuItem *removeGroupItem = [[NSMenuItem alloc] initWithTitle:@"Remove group"
                                                      action:@selector(removeSelectedGroup:)
                                             keyEquivalent:@""];
    [removeGroupItem setTarget:self];
    [menu addItem:removeGroupItem];
    
    NSMenuItem *renameItem = [[NSMenuItem alloc] initWithTitle:@"Rename group"
                                                             action:@selector(addXYZtoGroupName:)
                                             keyEquivalent:@""];
    [renameItem setTarget:self];
    [menu addItem:renameItem];
    

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
    NSString * stripedGroup = [selectedGroup stringByReplacingOccurrencesOfString:@"@" withString:@""];
    for (GSGlyph *g in [self curentFontSelectedGlyphs]){
        NSLog(@"To add %@", [g name]);
        NSLog(@"Group %@", selectedGroup);
        [self selectedGroupTab] == tabLeft ? [g setLeftKerningGroup:stripedGroup] :  [g setRightKerningGroup:stripedGroup];
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

-(void)removeSelectedGroup:(id)sender{
    // TODO: kerning pairs?
    for (GSGlyph *g in [self currentGroupGlyphs]){
        [self selectedGroupTab] == tabLeft ? [g setLeftKerningGroup:nil] :  [g setRightKerningGroup:nil];
    }
    [self updateKerningData];
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

// MARK: -Interface Updates

-(void)updateKerningData{
    NSLog(@"Update kerning groups");

    [[self groupsArrayController] setContent:[self currentFontGroups]];
    [self updateGlyphData];
}

-(void)updateGlyphData{
    NSLog(@"updateGlyphData!");
    [[self glyphsArrayController] setContent:[self currentGroupGlyphs]];
}

-(NSString*)kerngingGroupForGlyph:(GSGlyph*)g{
    ActiveLRTab activeTab = [self selectedGroupTab];
    NSString *glyphId = activeTab == tabLeft ? [g leftKerningGroupId] : [g rightKerningGroupId];
    NSString *prefix = activeTab == tabLeft ? @"MMK_R_" : @"MMK_L_";
    return [glyphId stringByReplacingOccurrencesOfString:prefix withString:@""];;
}

-(NSArray<NSString*> *)currentFontGroups{
    GSFont *currentFont = [self currentFont];
    if (currentFont == nil){
        return @[];
    }
    
    NSMutableOrderedSet<NSString*> *allKeys = [[NSMutableOrderedSet alloc] init];
    for (GSGlyph *g in [currentFont glyphs]){
        NSString * group =  [self kerngingGroupForGlyph:g];
        
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
        NSString * group = [self kerngingGroupForGlyph:g];
        if ([group isEqualToString:currentGroup]){
            [glyphsOfCurrentGroup addObject:g];
        }
    }
    return glyphsOfCurrentGroup;
}

-(void)addXYZtoGroupName:(id)sender{
    NSString *currentGroupName =  [[[self groupsArrayController] selectedObjects] firstObject];
    NSString *prefix = [self selectedGroupTab] == tabLeft ? @"@MMK_R_" : @"@MMK_L_";
    NSString *currentGroupFullName = [currentGroupName stringByReplacingOccurrencesOfString:@"@" withString:prefix];
    NSString *newName = [currentGroupFullName stringByAppendingString:@"XYZ"];
    for (GSFontMaster *m in [[self currentFont] fontMasters]){
        [[self currentFont] kerningLTR];
        MGOrderedDictionary *pairsDict = [[[self currentFont] kerningLTR] valueForKey:[m id]];
        if (pairsDict == nil){
            continue;
        }
        NSLog(@"%@", [m name]);
       
        if ([self selectedGroupTab] == tabRight){
            NSLog(@"TAB RIGHT");
            MGOrderedDictionary *resDict = [pairsDict objectForKey:currentGroupFullName];
            NSLog(@"%@ %@", currentGroupFullName, resDict);
            NSMutableArray *copyOfRes = [resDict copy];
            for (NSString *otherGroup in copyOfRes) {
                
                NSNumber *val = [resDict objectForKey:otherGroup];
                NSLog(@"%@ %f", otherGroup, [val floatValue]);
                [[self currentFont] setKerningForFontMasterID:[m id] leftKey:newName rightKey:otherGroup value:[val floatValue] direction:GSWritingDirectionLeftToRight ];
                [[self currentFont] removeKerningForFontMasterID:[m id] leftKey:currentGroupFullName rightKey:otherGroup direction:GSWritingDirectionLeftToRight];
            }
            
        }
        
        if ([self selectedGroupTab] == tabLeft){
            NSLog(@"TAB LEFT");
            NSMutableDictionary *toUpdate = [[NSMutableDictionary alloc] init];
            for (NSString *firstGroup in pairsDict) {
                MGOrderedDictionary *innerDict = [pairsDict objectForKey:firstGroup];
                NSNumber *innerVal = [innerDict objectForKey:currentGroupFullName];
                if (innerVal != nil){
                    NSLog(@"%@ %@ %@", firstGroup, currentGroupName, innerVal);
                    [toUpdate setValue:innerVal forKey:firstGroup];
                }
            }
            for (NSString *firstGroup in toUpdate) {
                NSNumber *innerVal = [toUpdate objectForKey:firstGroup];
                [[self currentFont] setKerningForFontMasterID:[m id] leftKey:firstGroup rightKey:newName value:[innerVal floatValue] direction:GSWritingDirectionLeftToRight ];
                [[self currentFont] removeKerningForFontMasterID:[m id] leftKey:firstGroup rightKey:currentGroupFullName direction:GSWritingDirectionLeftToRight];
            }
            
            
        }
        
    }
    [self updateKerningData];
}

// MARK: -Observers
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath  isEqual: @"selectedObjects"]){
        NSLog(@"observed change of selection");
        [self updateGlyphData];
        return;
    }
    else if (context == @"Document") {
        NSLog(@"observed change of keypath %@", keyPath);
        [self updateKerningData];
    }
    
}


-(void) removeObservers{
    NSLog(@"removeObservers");
    if (_hasRegisteredObservers){
        [NSApp removeObserver:self forKeyPath:@"mainWindow.windowController.document"];
        [NSNotificationCenter.defaultCenter removeObserver:self];
        _hasRegisteredObservers = NO;
    }
}

-(void) setupObservers{
    if (!_hasRegisteredObservers){
        // TODO: too many updates
        [NSApp addObserver:self forKeyPath:@"mainWindow.windowController.document" options:1 context:@"Document"];
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(updateKerningData)
                                                   name:@"GSUpdateInterface"
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
