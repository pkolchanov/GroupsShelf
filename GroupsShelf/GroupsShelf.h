//
//  GroupsShelf.h
//  GroupsShelf
//
//  Created by pkolchanov on 17.02.2025.
//
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import <GlyphsCore/GlyphsPluginProtocol.h>

#import "MockHeaders.h"
#import "GroupsShelfItem.h"
#import "GlyphsAccessors.h"
#import "KerningService.h"

@class RenameGroupsViewController;
@class FixGroupsViewController;

@interface GroupsShelf : NSWindowController <GlyphsPlugin>

@property (strong) IBOutlet NSArrayController *groupsArrayController;
@property (strong) IBOutlet NSArrayController *glyphsArrayController;
@property (weak) IBOutlet NSCollectionView *glyphCollectionView;
@property (weak) IBOutlet NSSegmentedControl *groupPositoinSegmented;
@property (weak) IBOutlet NSTextField *selectedGroupTextField;
@property (weak) IBOutlet NSView *renameGroupsView;
@property (weak) IBOutlet NSView *fixGroupsView;
@property (weak) IBOutlet NSLayoutConstraint *renameGroupsHeightConstraint;
@property (weak) IBOutlet NSLayoutConstraint *fixGroupsHeightConstraint;

@property NSDictionary *compositesDictionary;
@property RenameGroupsViewController *renameGroupsViewController;
@property FixGroupsViewController *fixGroupsViewController;

- (IBAction)selectGroupTab:(id)sender;
- (IBAction)addGlyphsToGroup:(id)sender;
- (IBAction)removeGlyphsFromGroup:(id)sender;
- (IBAction)showOptionsMenu:(id)sender;
- (IBAction)renameSelectedGroupAction:(id)sender;
- (IBAction)toggleRenamePanel:(id)sender;
- (IBAction)toggleFixGroupsPanel:(id)sender;
- (IBAction)closeWindowAction:(id)sender;

-(void)updateKerningData;
@end
