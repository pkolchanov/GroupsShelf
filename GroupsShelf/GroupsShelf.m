//
//  GroupsShelf.m
//  GroupsShelf
//
//  Created by pkolchanov on 17.02.2025.
//
//

#import "GroupsShelf.h"

@implementation GroupsShelf

- (instancetype) init {
    self = [super initWithWindowNibName:[self windowNibName]];
    if (self) {
        [self window];
    }
    return self;
}

- (NSUInteger)interfaceVersion {
	// Distinguishes the API verison the plugin was built for. Return 1.
	return 1;
}

- (NSNibName)windowNibName{
    return @"GroupsShelfWindow";
}

- (NSString *)title {
    return @"Groups Shelf";
}

- (NSString *)keyEquivalent {
    return @"";
}

- (void)awakeFromNib {
    [[self window] setLevel:NSFloatingWindowLevel];
    [[self window] setTitle:[self title]];
}


- (void)loadPlugin {
    NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:[self title] action:@selector(showPluginWindow:) keyEquivalent:[self keyEquivalent]];
    newMenuItem.target = self;
    NSMenu *submenu = [[mainMenu itemWithTag:17] submenu];
    [submenu addItem:newMenuItem];
}

-(void) showPluginWindow:(id)sender{
    NSLog(@"showPluginWindow");
    [self showWindow:nil];
}

@end
