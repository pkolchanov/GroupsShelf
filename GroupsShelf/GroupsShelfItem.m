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

    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 10, 80, 30)];
    label.bezeled = NO;
    label.drawsBackground = NO;
    label.editable = NO;
    label.stringValue = @"Item";
    label.alignment = NSTextAlignmentCenter;
    view.layer.cornerRadius = 5;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [[NSColor windowBackgroundColor] CGColor];
    [view addSubview:label];
    self.view = view;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    if ([representedObject isKindOfClass:[NSColor class]]) {
//        NSColor *color = representedObject[@"color"];
        self.view.layer.backgroundColor = [representedObject CGColor];
    }
}


@end
