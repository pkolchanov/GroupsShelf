//
//  BorderlessSearchFieldCell.m
//  GroupsShelf
//
//  Created by pkolchanov on 28.02.2025.
//

#import "BorderlessSearchFieldCell.h"

@implementation BorderlessSearchFieldCell
- (void)selectWithFrame:(NSRect)rect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)delegate start:(NSInteger)selStart length:(NSInteger)selLength {
    // Cocoa bug
    // https://stackoverflow.com/questions/38921355/osx-cocoa-nssearchfield-clear-button-not-responding-to-click#38970763
    
    NSRect newRect = rect;
    if (![self isBordered] || [self isBezeled]) {
        CGFloat cancelButtonWidth = NSWidth([self cancelButtonRectForBounds:rect]);
        CGFloat searchButtonWidth = NSWidth([self searchButtonRectForBounds:rect]);
        newRect.size.width -= (cancelButtonWidth + searchButtonWidth);
        newRect.origin.x += searchButtonWidth;
    }
    [super selectWithFrame:newRect inView:controlView editor:textObj delegate:delegate start:selStart length:selLength];
}
@end
