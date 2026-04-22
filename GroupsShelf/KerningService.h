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
    positionTop,
    positionBottom,
} GroupPosition;

@interface KerningService : NSObject
+(NSString*)groupNameFromGroupId:(NSString*)group;
+(NSString*)kerningGroupIdFromName:(NSString*)groupName forPosition:(GroupPosition)position;

+(NSArray<NSString*> *)currentFontGroupsForPosition:(GroupPosition)position;
+(NSArray<GSGlyph*>*)glyphsOfAGroupId:(NSString*)groupId position:(GroupPosition)position;
+(NSDictionary* _Nullable )kernPairsToUpdate:(GSFontMaster*) m groupName:(NSString*)groupFullName position:(GroupPosition)position;
+(void)find:(NSString*)searchString andReplaceWith:(NSString*)replace includeLeftGroups:(BOOL) includeLeft includeRightGroups:(BOOL)includeRight
includeTopGroups:(BOOL) includeTop includeBottomGroups:(BOOL)includeBottom useRegex:(BOOL)useRegex;
+(void)renameGroupWithId:(NSString*)groupId toNewId:(NSString*)newId position:(GroupPosition)position;
+(void)setKerningForFontMasterID:(id)fontMasterID leftKey:(id)leftKey rightKey:(id)rightKey value:(NSNumber*)value position:(GroupPosition)position;
+(void)removeKerningForFontMasterID:(NSString *)fontMasterID leftKey:(NSString *)leftKey rightKey:(NSString *)rightKey position:(GroupPosition)position;
+(void)removeGroupWithId:(NSString*)groupId position:(GroupPosition)position;
+(void)removeEmptyGroups;
@end

NS_ASSUME_NONNULL_END
