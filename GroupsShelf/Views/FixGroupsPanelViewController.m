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

- (IBAction)fixGroupsAction:(id)sender {
    NSString *leftPrefix = [[self leftGroupPrefixField] stringValue];
    NSString *rightPrefix = [[self rightGroupPrefixField] stringValue];
    [[self parent] updateAllGroupsWithLeftPrefix:leftPrefix rightPrefix:rightPrefix];
}
@end
