//
//  GroupsShelf.m
//  GroupsShelf
//
//  Created by pkolchanov on 17.02.2025.
//
//

#import "GroupsShelf.h"
#import "RenameGroupsViewController.h"
#import "FixGroupsViewController.h"

#define Loc(key) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:nil]

@implementation GroupsShelf {
    BOOL _hasRegisteredObservers;
}

- (instancetype) init {
    self = [super initWithWindowNibName:[self windowNibName]];
    if (self) {
        [self window];
        _hasRegisteredObservers = NO;
        _compositesService = [[CompositesService alloc] init];
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
    return Loc(@"Groups Shelf");
}

- (NSString *)keyEquivalent {
    return @"";
}

- (void)setupWindow {
    NSWindow * _Nullable window = [self window];
    [window setLevel:NSFloatingWindowLevel];
    [window setHidesOnDeactivate:YES];
    [window setStyleMask:NSWindowStyleMaskBorderless|NSWindowStyleMaskResizable|NSWindowStyleMaskClosable];
    [window setBackgroundColor:[NSColor clearColor]];
    [window setMovableByWindowBackground:YES];
    [window setOpaque:NO];
    [[window contentView] setValue:[NSColor windowBackgroundColor] forKey:@"backgroundColor"];
    [[[window contentView] layer] setCornerRadius:10];
}

- (void)setupRenameGroupsPanel {
    RenameGroupsViewController *renameGroupsViewController = [[RenameGroupsViewController alloc] initWithNibName:@"RenameGroupsViewController" bundle:[NSBundle bundleForClass:[self class]]];
    [renameGroupsViewController setParent:self];
    [self setRenameGroupsViewController:renameGroupsViewController];
    [[self contentViewController] addChildViewController:renameGroupsViewController];
    [[self renameGroupsView] addSubview:[renameGroupsViewController view]];
    [[self renameGroupsHeightConstraint] setConstant:0];
}

- (void)setupFixGroupsPanel {
    FixGroupsViewController *fixGroupsViewController = [[FixGroupsViewController alloc] initWithNibName:@"FixGroupsViewController" bundle:[NSBundle bundleForClass:[self class]]];
    [fixGroupsViewController setParent:self];
    [self setFixGroupsViewController:fixGroupsViewController];
    [[self contentViewController] addChildViewController:fixGroupsViewController];
    [[self fixGroupsView] addSubview:[fixGroupsViewController view]];
    [[self fixGroupsHeightConstraint] setConstant:0];
}

- (void)awakeFromNib {
    [self setupWindow];
    [self setupRenameGroupsPanel];
    [self setupFixGroupsPanel];
    [[self glyphCollectionView] registerClass:[GroupsShelfItem class]
                        forItemWithIdentifier:@"GroupsShelfItem"];
    [[self groupsArrayController] addObserver:self forKeyPath:@"selectedObjects" options:1 context:nil];
    
    // Localization
    [[self window] setTitle:Loc(@"Groups Shelf")];
    [[self searchField] setPlaceholderString:Loc(@"Search Groups")];
    [[self groupPositoinSegmented] setLabel:Loc(@"Left") forSegment:0];
    [[self groupPositoinSegmented] setLabel:Loc(@"Right") forSegment:1];
    [[self groupPositoinSegmented] setLabel:Loc(@"Top") forSegment:2];
    [[self groupPositoinSegmented] setLabel:Loc(@"Bottom") forSegment:3];

    // Set labels using tags
    [(NSTextField *)[[self window].contentView viewWithTag:101] setStringValue:Loc(@"Rename Groups")];
    [(NSTextField *)[[self window].contentView viewWithTag:102] setStringValue:Loc(@"Fix Groups")];
    
    // Tooltips (I'll add tags 103 and 104 to buttons in XIB)
    [(NSButton *)[[self window].contentView viewWithTag:103] setToolTip:Loc(@"Add glyphs to the group")];
    [(NSButton *)[[self window].contentView viewWithTag:104] setToolTip:Loc(@"Remove glyphs from the group")];
}


- (void)loadPlugin {
    NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:[self title] action:@selector(showPluginWindow:) keyEquivalent:[self keyEquivalent]];
    newMenuItem.target = self;
    NSMenu *submenu = [[mainMenu itemWithTag:17] submenu];
    [submenu addItem:newMenuItem];
}


-(void)showPluginWindow:(id)sender{
    [self showWindow:nil];
    [self setupObservers];
    [self updateKerningData];
}

// MARK: -IB

- (IBAction)toggleRenamePanel:(id)sender {
    float newHeight = [[self renameGroupsHeightConstraint] constant] == 0 ? 185 : 0;
    [self updatePanelHeight:[self renameGroupsHeightConstraint] toNewHeight:newHeight];
   
}

- (IBAction)toggleFixGroupsPanel:(id)sender {
    float newHeight = [[self fixGroupsHeightConstraint] constant] == 0 ? 90 : 0;
    [self updatePanelHeight:[self fixGroupsHeightConstraint] toNewHeight:newHeight];
}

-(void)updatePanelHeight:(NSLayoutConstraint*)heightConstraint toNewHeight:(float)height{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
           context.duration = 0.2;
        context.timingFunction =  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        heightConstraint.animator.constant = height;
       } completionHandler:nil];
}

- (IBAction)renameSelectedGroupAction:(id)sender {
    [self renameSelectedGroup:[[self selectedGroupTextField] stringValue]];
}

- (IBAction)showOptionsMenu:(id)sender {
    // Create a menu item
    NSMenu *menu = [[NSMenu alloc] init];
    
    NSMenuItem *addMissingCompositesItem = [[NSMenuItem alloc] initWithTitle:Loc(@"Add missing composites")
                                                              action:@selector(addMissingComposites:)
                                                       keyEquivalent:@""];
    [addMissingCompositesItem setTarget:self];
    [menu addItem:addMissingCompositesItem];
    
    NSMenuItem *removeGroupItem = [[NSMenuItem alloc] initWithTitle:Loc(@"Remove group")
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
        switch ( [self selectedGroupPosition]) {
            case positionLeft:
                [g setLeftKerningGroup:nil];
                break;
            case positionRight:
                [g setRightKerningGroup:nil];
                break;
            case positionTop:
                [g setTopKerningGroup:nil];
                break;
            case positionBottom:
                [g setBottomKerningGroup:nil];
                break;
            default:
                break;
        }
    }
    [self updateGlyphData];
}

- (IBAction)addGlyphsToGroup:(id)sender {
    NSString * selectedGroup = [[[self groupsArrayController] selectedObjects] firstObject];
    for (GSGlyph *g in [GlyphsAccessors curentFontSelectedGlyphs]){
        NSLog(@"To add %@", [g name]);
        NSLog(@"Group %@", selectedGroup);
        switch ( [self selectedGroupPosition]) {
            case positionLeft:
                [g setLeftKerningGroup:selectedGroup];
                break;
            case positionRight:
                [g setRightKerningGroup:selectedGroup];
                break;
            case positionTop:
                [g setTopKerningGroup:selectedGroup];
                break;
            case positionBottom:
                [g setBottomKerningGroup:selectedGroup];
                break;
            default:
                break;
        }
    }
    [self updateGlyphData];
}

- (IBAction)selectGroupTab:(id)sender {
    [self updateKerningData];
}

- (IBAction)closeWindowAction:(id)sender {
    if ([self windowShouldClose:[self window]]) {
        [[self window] close];
    }
}

-(GroupPosition)selectedGroupPosition{
    switch ([[self groupPositoinSegmented] selectedSegment]) {
        case 0:
            return positionLeft;
        case 1:
            return positionRight;
        case 2:
            return positionTop;
        case 3:
            return positionBottom;
        default:
            break;
    }
    return positionLeft;
}


// MARK: -Interface Updates

-(void)updateKerningData{
    GroupPosition position = [self selectedGroupPosition];
    
    NSArray *groups = [KerningService currentFontGroupsForPosition:position];
    [[self groupsArrayController] setContent:groups];
}

-(void)updateGlyphData{
    NSString *currentGroup = [[[self groupsArrayController] selectedObjects] firstObject];
    [[self glyphsArrayController] setContent:[self currentGroupGlyphs]];
    [[self selectedGroupTextField] setStringValue:currentGroup == nil ? @"" :currentGroup];
}

-(NSArray<NSString*> *)currentFontGroups{
    GroupPosition currentPosition = [self selectedGroupPosition];
    return [KerningService currentFontGroupsForPosition:currentPosition];
}

-(NSArray<GSGlyph*> *)currentGroupGlyphs{
    NSString *currentGroupName = [[[self groupsArrayController] selectedObjects] firstObject];
    if (currentGroupName == nil){
        return @[];
    }
    NSString *currentGroupId = [KerningService kerningGroupIdFromName:currentGroupName forPosition:[self selectedGroupPosition]];
    return [KerningService glyphsOfAGroupId:currentGroupId position:[self selectedGroupPosition]];
}

// MARK: -Renaming

-(void)renameSelectedGroup:(NSString*)newName{
    GroupPosition selectedPosition = [self selectedGroupPosition];
    NSString *currentGroupName = [[[self groupsArrayController] selectedObjects] firstObject];
    NSString *currentGroupId = [KerningService kerningGroupIdFromName:currentGroupName forPosition:selectedPosition];
    NSString *newId = [KerningService kerningGroupIdFromName:newName forPosition:selectedPosition];
    [KerningService renameGroupWithId:currentGroupId toNewId:newId position:selectedPosition];
 
    [self updateKerningData];
}

-(void)removeSelectedGroup:(id)sender{
    GroupPosition selectedPosition = [self selectedGroupPosition];
    NSString *currentGroupName =  [[[self groupsArrayController] selectedObjects] firstObject];
    NSString *currentGroupId = [KerningService kerningGroupIdFromName:currentGroupName forPosition:[self selectedGroupPosition]];
    
    [KerningService removeGroupWithId:currentGroupId  position:selectedPosition];
    [self updateKerningData];
}

-(void)addMissingComposites:(id)sender{
    NSString *currentGroupName = [[[self groupsArrayController] selectedObjects] firstObject];
    NSString *currentGroupId = [KerningService kerningGroupIdFromName:currentGroupName forPosition:[self selectedGroupPosition]];
    GroupPosition currentPosition = [self selectedGroupPosition];
  
    [[self compositesService] addMissingCompositesForPosition:currentPosition onlyForGroupId:currentGroupId];
    [self updateGlyphData];
}

// MARK: -Observers
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqual: @"selectedObjects"]){
        [self updateGlyphData];
        return;
    }
    
}


-(void) removeObservers{
    if (_hasRegisteredObservers){
        [NSNotificationCenter.defaultCenter removeObserver:self];
        _hasRegisteredObservers = NO;
    }
}

-(void)interfaceDidUpdate{
    [self updateKerningData];
}

-(void)docDidActivated{
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
    [self removeObservers];
}


@end
