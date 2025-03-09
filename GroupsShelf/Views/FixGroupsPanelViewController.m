//
//  FixGroupsPanelViewController.m
//  GroupsShelf
//
//  Created by pkolchanov on 04.03.2025.
//

#import "FixGroupsPanelViewController.h"
#import "GroupsShelf.h"

@implementation FixGroupsPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)renameGroupsActtion:(id)sender {
    NSString *findString = [[self findTextField] stringValue];
    NSString *replaceString = [[self replaceTextField] stringValue];
    BOOL left = [[self includeLeftGroupCheckbox] state] == NSControlStateValueOn;
    BOOL right = [[self includeRightGroupCheckbox] state] == NSControlStateValueOn;
    BOOL useRegex = [[self useRegexCheckbox] state] == NSControlStateValueOn;
    [KerningService find:findString andReplaceWith:replaceString incluceLeftGroups:left inclureRightGroups:right useRegex:useRegex];
    [[self parent] updateKerningData];
}
@end
