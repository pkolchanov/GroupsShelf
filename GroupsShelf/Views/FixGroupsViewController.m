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

#define Loc(key) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:nil]

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCompositesService:[[CompositesService alloc] init]];
    
    // Localization
    [[self removeGroupsWithoutEmptyPairsButton] setTitle:Loc(@"Remove Groups without kern pairs")];
    [[self addMissingCompositesButton] setTitle:Loc(@"Add missing composites")];
    [(NSButton *)[self.view viewWithTag:105] setTitle:Loc(@"Fix Groups")];
}

- (IBAction)fixGroupsAction:(id)sender {
    if ([[self removeGroupsWithoutEmptyPairsButton] state] == NSControlStateValueOn){
        [KerningService removeEmptyGroups];
    }
    if ([[self addMissingCompositesButton] state] == NSControlStateValueOn){
        [[self compositesService] addMissingCompositesForAllGroups];
    }
    [[self parent] updateKerningData];
}
@end
