//
//  FixGroupsPanelViewController.m
//  GroupsShelf
//
//  Created by pkolchanov on 04.03.2025.
//

#import "FixGroupsPanelViewController.h"

@interface FixGroupsPanelViewController ()

@end

@implementation FixGroupsPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)fixGroupsAction:(id)sender {
    [[self leftGroupPrefixField] stringValue];
    [[self rightGroupPrefixField] stringValue];
    
}
@end
