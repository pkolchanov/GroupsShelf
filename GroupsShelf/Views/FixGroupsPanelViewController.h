//
//  FixGroupsPanelViewController.h
//  GroupsShelf
//
//  Created by pkolchanov on 04.03.2025.
//

#import <Cocoa/Cocoa.h>
#import "KerningService.h"
@class GroupsShelf;
NS_ASSUME_NONNULL_BEGIN

@interface FixGroupsPanelViewController : NSViewController
@property (weak) IBOutlet NSTextField *findTextField;
@property (weak) IBOutlet NSTextField *replaceTextField;
@property (weak) IBOutlet NSButton *includeLeftGroupCheckbox;
@property (weak) IBOutlet NSButton *includeRightGroupCheckbox;
@property (weak) IBOutlet NSButton *useRegexCheckbox;
- (IBAction)renameGroupsActtion:(id)sender;

@property (weak)GroupsShelf *parent;
@end

NS_ASSUME_NONNULL_END
