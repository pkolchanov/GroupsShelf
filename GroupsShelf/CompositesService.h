//
//  CompositesService.h
//  GroupsShelf
//
//  Created by pkolchanov on 11.03.2025.
//

#import <Foundation/Foundation.h>
#import "KerningService.h"
NS_ASSUME_NONNULL_BEGIN

@interface CompositesService : NSObject
@property NSDictionary *compositesDictionary;
-(void)addMissingCompositesForAllGroups;
-(void)addMissingCompositesForPosition:(GroupPosition)position onlyForGroupId:(NSString* __nullable)onlyForGroupId;
@end

NS_ASSUME_NONNULL_END
