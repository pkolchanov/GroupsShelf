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
#import <GlyphsCore/GSFont.h>
#import <GlyphsCore/GSFontMaster.h>
#import <GlyphsCore/GSGlyph.h>
#import <GlyphsCore/GSLayer.h>
#import <GlyphsCore/GSWindowControllerProtocol.h>
#import <GlyphsCore/GSGlyphEditViewProtocol.h>
#import <GlyphsCore/GSGlyphViewControllerProtocol.h>
#import <GlyphsCore/MGOrderedDictionary.h>

#import "MockHeaders.h"
#import "GroupsShelfItem.h"

@class FixGroupsPanelViewController;

@interface GroupsShelf : NSWindowController <GlyphsPlugin>

@property (strong) IBOutlet NSArrayController *groupsArrayController;
@property (strong) IBOutlet NSArrayController *glyphsArrayController;
@property (weak) IBOutlet NSCollectionView *glyphCollectionView;
@property (weak) IBOutlet NSSegmentedControl *groupPositoinSegmented;
@property (weak) IBOutlet NSTextField *selectedGroupTextField;
@property (weak) IBOutlet NSView *fixGroupsView;
@property (weak) IBOutlet NSLayoutConstraint *fixGroupsHeightConstraint;

@property NSDictionary *compositesDictionary;
@property FixGroupsPanelViewController *fixGroupsPanelViewController;

- (IBAction)selectGroupTab:(id)sender;
- (IBAction)addGlyphsToGroup:(id)sender;
- (IBAction)removeGlyphsFromGroup:(id)sender;
- (IBAction)showOptionsMenu:(id)sender;
- (IBAction)renameSelectedGroupAction:(id)sender;
- (IBAction)toggleFixPanel:(id)sender;
- (IBAction)closeWindowAction:(id)sender;

-(void)updateAllGroupsWithLeftPrefix:(NSString*)leftPrefx rightPrefix:(NSString*)rightPrefix;
@end
