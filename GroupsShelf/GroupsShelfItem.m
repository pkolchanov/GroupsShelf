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

    
    view.layer.cornerRadius = 5;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [[NSColor windowBackgroundColor] CGColor];
    [view addSubview:[self label]];
    self.view = view;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    [[[self view] layer] setBackgroundColor: [[(GSGlyph *)representedObject color] CGColor]];
    if ( [(GSGlyph *)representedObject name] != nil){
        [[self label] setStringValue:[(GSGlyph *)representedObject name]];
    }

}


@end
