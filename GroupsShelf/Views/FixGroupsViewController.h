//
//  FixGroupsViewController.h
//  GroupsShelf
//
//  Created by pkolchanov on 10.03.2025.
//

#import <Cocoa/Cocoa.h>
#import "KerningService.h"
#import "CompositesService.h"
@class GroupsShelf;
NS_ASSUME_NONNULL_BEGIN

@interface FixGroupsViewController : NSViewController
@property (weak) IBOutlet NSButton *removeGroupsWithoutEmptyPairsButton;
@property (weak) IBOutlet NSButton *addMissingCompositesButton;

@property (weak)GroupsShelf *parent;
@property CompositesService *compositesService;

- (IBAction)fixGroupsAction:(id)sender;
@end

NS_ASSUME_NONNULL_END
