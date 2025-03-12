//
//  GlyphsAccessors.m
//  GroupsShelf
//
//  Created by pkolchanov on 09.03.2025.
//

#import "GlyphsAccessors.h"

@implementation GlyphsAccessors

+(GSDocument*)currentDocument{
    GSApplication *app = NSApp;
    GSDocument *document = [app currentFontDocument];
    return document;
}

+(GSFont *)currentFont{
    GSDocument *document = [self currentDocument];
    GSFont *font = [document font];
    return font;
}

+(GSFontMaster *)currentFontMaster{
    GSApplication *app = NSApp;
    GSDocument *document = [app currentFontDocument];
    
    return [document selectedFontMaster];
}

+ (NSArray<GSGlyph *> *)curentFontSelectedGlyphs {
    GSDocument *document = [self currentDocument];
    NSWindowController<GSWindowControllerProtocol> *windowController = [document windowController];
    if (windowController == nil) return @[];
    
    NSArray<GSLayer *> *layers = windowController.selectedLayers;
    NSMutableArray<GSGlyph *> *glyphs = [NSMutableArray new];
    
    for (GSLayer *layer in layers) {
        GSGlyph *glyph = layer.parent;
        [glyphs addObject:glyph];
    }
    
    return glyphs;
}
@end
