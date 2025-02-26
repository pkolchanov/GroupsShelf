//
//  GroupsShelf.h
//  GroupsShelf
//
//  Created by pkolchanov on 17.02.2025.
//
//

#import <Cocoa/Cocoa.h>

#import <GlyphsCore/GlyphsPluginProtocol.h>
#import <GlyphsCore/GSFont.h>
#import <GlyphsCore/GSFontMaster.h>
#import <GlyphsCore/GSGlyph.h>
#import <GlyphsCore/GSLayer.h>
#import <GlyphsCore/GSWindowControllerProtocol.h>
#import <GlyphsCore/GSGlyphEditViewProtocol.h>
#import <GlyphsCore/GSGlyphViewControllerProtocol.h>
#import "MockHeaders.h"
#import "GroupsShelfItem.h"

@interface GroupsShelf : NSWindowController <GlyphsPlugin>
- (IBAction)closeWindowAction:(id)sender;
@property (strong) IBOutlet NSArrayController *groupsArrayController;
@property (strong) IBOutlet NSArrayController *glyphsArrayController;
@property (weak) IBOutlet NSCollectionView *glyphCollectionView;
@property (weak) IBOutlet NSSegmentedControl *groupPositoinSegmented;
- (IBAction)selectGroupTab:(id)sender;
- (IBAction)addGlyphsToGroup:(id)sender;
- (IBAction)removeGlyphsFromGroup:(id)sender;
- (IBAction)showOptionsMenu:(id)sender;

@end
