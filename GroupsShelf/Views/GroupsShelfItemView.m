//
//  GroupsShelfItemView.m
//  GroupsShelf
//
//  Created by pkolchanov on 11.03.2025.
//

#import "GroupsShelfItemView.h"

@implementation GroupsShelfItemView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
- (void)viewDidChangeEffectiveAppearance{
    [super viewDidChangeEffectiveAppearance];
    // Bug fix: for some reason [NSAppearance currentDrawingAppearance] returns an oudtated value causing wrong colors
    [[self effectiveAppearance] performAsCurrentDrawingAppearance:^(){
        self.layer.borderColor = [[NSColor textBackgroundColor] CGColor];
    }];
}

@end
