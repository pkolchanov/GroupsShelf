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
    view.wantsLayer = YES;
    view.layer.backgroundColor = [[NSColor lightGrayColor] CGColor];

    [self setLabel:[[NSTextField alloc] initWithFrame:NSMakeRect(10, 10, 80, 30)]];
    [[self label] setAlignment:NSTextAlignmentCenter];
    [[self label] setBezeled:NO];
    [[self label] setEditable:NO];
    [[self label] setDrawsBackground:NO];
    [view addSubview:[self label]];
    
    view.layer.cornerRadius = 5;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [[NSColor windowBackgroundColor] CGColor];
   
    
    [self setImg:[[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)]];
    [view addSubview:[self img]];
    
    self.view = view;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    GSGlyph * glyph = representedObject;
    [[[self view] layer] setBackgroundColor: [[(GSGlyph *)representedObject color] CGColor]];
    if ( [glyph name] != nil){
        [[self label] setStringValue:[glyph name]];
    }
    
    GSApplication *app = NSApp;
    GSDocument *document = [app currentFontDocument];
    GSFont *font = [document font];
    CGFloat upm = (CGFloat)font.unitsPerEm;
    
    GSLayer *layer = [glyph layerForId:[[document selectedFontMaster] id]];
    NSBezierPath *path = [layer drawBezierPath];
  
    
    NSSize size = [[self view] frame].size;
 
    NSImage *image = [NSImage imageWithSize:size flipped:NO drawingHandler:^BOOL(NSRect drawRect) {
       
      
        // draw glyph
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform scaleBy:size.height / upm];
//        CGFloat dx = (upm - layer.width) / 2.0 + offset;
//        CGFloat dy = -[master descenderForLayer:layer] + offset;
//        [transform translateXBy:dx yBy:dy];
        [path transformUsingAffineTransform:transform];
//        [roundedRectPath setClip];
        [NSColor.textColor set];
        [path fill];
        
        return YES;
    }];
  
    [[self img] setImage:image];
}


@end
