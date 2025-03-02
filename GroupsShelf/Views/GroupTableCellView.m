//
//  GroupTableCellCiew.m
//  GroupsShelf
//
//  Created by pkolchanov on 21.02.2025.
//

#import "GroupTableCellView.h"

@implementation GroupTableCellView

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
    [super setBackgroundStyle:backgroundStyle];

    if (self.textField) {
        if (backgroundStyle == NSBackgroundStyleEmphasized) {
            self.textField.textColor = [NSColor whiteColor]; // Change text color when selected
        } else {
            self.textField.textColor = [NSColor colorNamed:@"kerningBlue" bundle:[NSBundle bundleForClass:[self class]]];
        }
    }
}

@end
