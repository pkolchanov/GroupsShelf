//
//  GlyphsAccessors.h
//  GroupsShelf
//
//  Created by pkolchanov on 09.03.2025.
//

#import <Foundation/Foundation.h>
#import <GlyphsCore/GSGlyph.h>
#import <GlyphsCore/GSLayer.h>
#import <GlyphsCore/GSComponent.h>
#import <GlyphsCore/GSProxyShapes.h>

#import "MockHeaders.h"
NS_ASSUME_NONNULL_BEGIN

@interface GlyphsAccessors : NSObject
+(GSDocument*)currentDocument;
+(GSFont *)currentFont;
+(GSFontMaster *)currentFontMaster;
+ (NSArray<GSGlyph *> *)curentFontSelectedGlyphs;
@end

NS_ASSUME_NONNULL_END
