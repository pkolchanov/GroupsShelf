//
//  GroupsShelfItem.h
//  GroupsShelf
//
//  Created by pkolchanov on 18.02.2025.
//

#import <Cocoa/Cocoa.h>
#import <GlyphsCore/GSGlyph.h>
#import <GlyphsCore/GSLayer.h>
#import <GlyphsCore/GSFontMaster.h>
#import "MockHeaders.h"
NS_ASSUME_NONNULL_BEGIN

@interface GroupsShelfItem : NSCollectionViewItem
@property (nonatomic, strong) NSTextField *label;
@property (nonatomic, strong) NSImageView *img;
@end


NS_ASSUME_NONNULL_END
