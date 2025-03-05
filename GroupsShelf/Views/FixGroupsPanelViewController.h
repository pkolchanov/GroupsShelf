//
//  FixGroupsPanelViewController.h
//  GroupsShelf
//
//  Created by pkolchanov on 04.03.2025.
//

#import <Cocoa/Cocoa.h>
@class GroupsShelf;
NS_ASSUME_NONNULL_BEGIN

@interface FixGroupsPanelViewController : NSViewController
@property (weak) IBOutlet NSTextField *rightGroupPrefixField;
@property (weak) IBOutlet NSButton *addMissingCompositesCheckbox;
@property (weak) IBOutlet NSButton *removeEmptyGroupsCheckbox;
- (IBAction)fixGroupsAction:(id)sender;
@property (weak) IBOutlet NSTextField *leftGroupPrefixField;
@property (weak)GroupsShelf *parent;
@end

NS_ASSUME_NONNULL_END
