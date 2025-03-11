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
    return @"Groups Shelf";
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

- (IBAction)toggleRenamePanel:(id)sender {
    float newHeight = [[self renameGroupsHeightConstraint] constant] == 0 ? 150 : 0;
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
    for (GSGlyph *g in [GlyphsAccessors curentFontSelectedGlyphs]){
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
