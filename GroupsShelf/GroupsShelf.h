//
//  GroupsShelf.h
//  GroupsShelf
//
//  Created by pkolchanov on 17.02.2025.
//
//

#import <Cocoa/Cocoa.h>

#import <GlyphsCore/GlyphsPluginProtocol.h>
#import <GlyphsCore/GSFontMaster.h>
#import <GlyphsCore/GSGlyph.h>
#import <GlyphsCore/GSLayer.h>
#import <GlyphsCore/GSWindowControllerProtocol.h>
#import <GlyphsCore/GSGlyphEditViewProtocol.h>
#import <GlyphsCore/GSGlyphViewControllerProtocol.h>

@interface GroupsShelf : NSWindowController <GlyphsPlugin>
@end

@interface GSApplication : NSApplication
@property (weak, nonatomic, nullable) GSDocument *currentFontDocument;
@end

@interface GSDocument : NSDocument
@property (nonatomic, retain) GSFont *font;
@property (weak, nonatomic, nullable) NSWindowController<GSWindowControllerProtocol> *windowController;
@end
