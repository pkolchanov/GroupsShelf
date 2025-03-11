//
//  FixGroupsViewController.m
//  GroupsShelf
//
//  Created by pkolchanov on 10.03.2025.
//

#import "FixGroupsViewController.h"
#import "GroupsShelf.h"

@interface FixGroupsViewController ()

@end

@implementation FixGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)fixGroupsAction:(id)sender {
    if ([[self removeGroupsWithoutEmptyPairsButton] state] == NSControlStateValueOn){
        [KerningService removeEmptyGroups];
    }
    if ([[self addMissingCompositesButton] state] == NSControlStateValueOn){
        [[self parent] addMissingCompositesForAllGroups];
    }
    [[self parent] updateKerningData];
}
@end
