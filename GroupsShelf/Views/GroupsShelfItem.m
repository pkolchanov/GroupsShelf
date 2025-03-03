//
//  GroupsShelfItem.m
//  GroupsShelf
//
//  Created by pkolchanov on 18.02.2025.
//

#import "GroupsShelfItem.h"

@implementation GroupsShelfItem
- (void)loadView {
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    view.autoresizesSubviews = YES;
    view.wantsLayer = YES;
    view.layer.backgroundColor = [[NSColor lightGrayColor] CGColor];

    [self setLabel:[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)]];
    [[self label] setAlignment:NSTextAlignmentCenter];
    [[self label] setBezeled:NO];
    [[self label] setEditable:NO];
    [[self label] setDrawsBackground:NO];
    [[self label] setAutoresizingMask:NSViewWidthSizable];
    [view addSubview:[self label]];
    
    view.layer.cornerRadius = 5;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [[NSColor whiteColor] CGColor];
    
    [self setImg:[[NSImageView alloc] initWithFrame:NSMakeRect(10, 20, 80, 80)]];
    [view addSubview:[self img]];
    
    self.view = view;
}

- (void)setRepresentedObject:(id)representedObject {
 
    [super setRepresentedObject:representedObject];
    [self updateSelectionColor];
    GSGlyph * glyph = representedObject;
    if ( [glyph name] != nil){
        [[self label] setStringValue:[glyph name]];
    }
    
    // Florian Pircher's Guten Tag method
    // https://github.com/florianpircher/GutenTag
    
    GSApplication *app = NSApp;
    GSDocument *document = [app currentFontDocument];
    GSFont *font = [document font];
    CGFloat upm = (CGFloat)font.unitsPerEm;
    
    GSFontMaster * _Nullable master = [document selectedFontMaster];
    GSLayer *layer = [glyph layerForId:[master id]];
    NSBezierPath *path = [layer drawBezierPath];
    
    CGFloat viewSize = [[self img] frame].size.width;
    CGFloat inset = 10;
    CGFloat fontSize = viewSize - 2.0 * inset;
    CGFloat offset = upm / (fontSize / inset);
 
    NSSize size = [[self img] frame].size;
    NSImage *image = [NSImage imageWithSize:size flipped:NO drawingHandler:^BOOL(NSRect drawRect) {
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform scaleBy:fontSize / upm];
        CGFloat dx = (upm - layer.width) / 2.0 + offset;
        CGFloat dy = -[master descenderForLayer:layer] + offset;
        [transform translateXBy:dx yBy:dy];
        [path transformUsingAffineTransform:transform];
        [NSColor.textColor set];
        [path fill];
        
        return YES;
    }];
  
    [[self img] setImage:image];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self updateSelectionColor];
}

-(void)updateSelectionColor{
    GSGlyph * glyph = [self representedObject];
    NSColor *color = [self isSelected] ? [NSColor selectedTextBackgroundColor] : [[glyph color] colorWithAlphaComponent:0.5] ;
    [[[self view] layer] setBackgroundColor: [color CGColor]];
}

@end
