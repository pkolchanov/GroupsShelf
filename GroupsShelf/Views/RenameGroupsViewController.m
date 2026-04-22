//
//  FixGroupsPanelViewController.m
//  GroupsShelf
//
//  Created by pkolchanov on 04.03.2025.
//

#import "RenameGroupsViewController.h"
#import "GroupsShelf.h"

@implementation RenameGroupsViewController

#define Loc(key) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:nil]

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Localization
    [[self includeLeftGroupCheckbox] setTitle:Loc(@"Left Groups")];
    [[self includeRightGroupCheckbox] setTitle:Loc(@"Right Groups")];
    [[self includeTopGroupCheckbox] setTitle:Loc(@"Top Groups")];
    [[self includeBottomGroupCheckbox] setTitle:Loc(@"Bottom Groups")];
    [[self useRegexCheckbox] setTitle:Loc(@"Match using regular expressions")];
    
    [(NSTextField *)[self.view viewWithTag:106] setStringValue:Loc(@"Find")];
    [(NSTextField *)[self.view viewWithTag:107] setStringValue:Loc(@"Replace with")];
    [(NSButton *)[self.view viewWithTag:108] setTitle:Loc(@"Rename Groups")];
}

- (IBAction)renameGroupsActtion:(id)sender {
    NSString *findString = [[self findTextField] stringValue];
    NSString *replaceString = [[self replaceTextField] stringValue];
    BOOL left = [[self includeLeftGroupCheckbox] state] == NSControlStateValueOn;
    BOOL right = [[self includeRightGroupCheckbox] state] == NSControlStateValueOn;
    BOOL top = [[self includeTopGroupCheckbox] state] == NSControlStateValueOn;
    BOOL bottom = [[self includeBottomGroupCheckbox] state] == NSControlStateValueOn;
    
    BOOL useRegex = [[self useRegexCheckbox] state] == NSControlStateValueOn;
    [KerningService find:findString andReplaceWith:replaceString includeLeftGroups:left includeRightGroups:right includeTopGroups:top includeBottomGroups:bottom useRegex:useRegex];
    [[self parent] updateKerningData];
}
@end
