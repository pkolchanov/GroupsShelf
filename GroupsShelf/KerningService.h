//
//  KerningService.h
//  GroupsShelf
//
//  Created by pkolchanov on 09.03.2025.
//

#import <Foundation/Foundation.h>
#import "GlyphsAccessors.h"
#import <GlyphsCore/GSFontMaster.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    positionLeft,
    positionRight,
} GroupPosition;

@interface KerningService : NSObject

+(NSArray<NSString*> *)currentFontGroupsForPosition:(GroupPosition)position;
+(NSArray<GSGlyph*>*)glyphsOfAGroupId:(NSString*)groupId position:(GroupPosition)position;
+(NSString*)groupNameFromGroupId:(NSString*)group;
+(NSString*)kerningGroupIdFromName:(NSString*)groupName forPosition:(GroupPosition)position;
+(NSString*)kerningGroupIdOfAGlyph:(GSGlyph*)g forPosition:(GroupPosition)position;
+(NSDictionary* _Nullable )kernPairsToUpdate:(GSFontMaster*) m groupName:(NSString*)groupFullName position:(GroupPosition)position;

+(void)find:(NSString*)searchString andReplaceWith:(NSString*)replace incluceLeftGroups:(BOOL) includeLeft inclureRightGroups:(BOOL)includeRight useRegex:(BOOL)useRegex;
+(void)renameGroupWithId:(NSString*)groupId toNewId:(NSString*)newId position:(GroupPosition)position;
+(void)setKerningForFontMasterID:(id)fontMasterID leftKey:(id)leftKey rightKey:(id)rightKey value:(NSNumber*)value;
+(void)removeGroupWithId:(NSString*)groupId position:(GroupPosition)position;

@end

NS_ASSUME_NONNULL_END
