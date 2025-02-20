//
//  GroupIdFormatter.m
//  GroupsShelf
//
//  Created by pkolchanov on 20.02.2025.
//

#import "GroupIdFormatter.h"

@implementation GroupIdFormatter
- (NSString *)stringForObjectValue:(id)obj{
    if (![obj isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *p1 = [obj stringByReplacingOccurrencesOfString:@"MMK_L_" withString:@""];
    return [p1  stringByReplacingOccurrencesOfString:@"MMK_R_" withString:@""];
}
@end
