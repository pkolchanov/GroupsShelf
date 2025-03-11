//
//  KerningService.m
//  GroupsShelf
//
//  Created by pkolchanov on 09.03.2025.
//

#import "KerningService.h"

@implementation KerningService

+(NSArray<NSString*> *)currentFontGroupsForPosition:(GroupPosition)position{
    GSFont *currentFont = [GlyphsAccessors currentFont];
    if (currentFont == nil){
        return @[];
    }
    NSMutableOrderedSet<NSString*> *allKeys = [[NSMutableOrderedSet alloc] init];
    for (GSGlyph *g in [currentFont glyphs]){
        NSString *group = [self groupNameFromGroupId:[self kerningGroupIdOfAGlyph:g forPosition:position]];
        if (group != nil){
            [allKeys addObject:group];
        }
    }
    return [allKeys array];
}

+(NSArray<GSGlyph*>*)glyphsOfAGroupId:(NSString*)groupId position:(GroupPosition)position{
    GSFont *currentFont = [GlyphsAccessors currentFont];
    NSMutableArray<GSGlyph*> *glyphsOfCurrentGroup = [[NSMutableArray alloc] init];
  
    for (GSGlyph *g in [currentFont glyphs]){
        NSString *glyphId = [self kerningGroupIdOfAGlyph:g forPosition:position];
        if ([glyphId isEqualToString:groupId]){
            [glyphsOfCurrentGroup addObject:g];
        }
    }
    return glyphsOfCurrentGroup;
}

+(NSString*)groupNameFromGroupId:(NSString*)group{
    group = [group stringByReplacingOccurrencesOfString:@"@MMK_R_" withString:@""];;
    group = [group stringByReplacingOccurrencesOfString:@"@MMK_L_" withString:@""];;
    return group;
}

+(NSString*)kerningGroupIdFromName:(NSString*)groupName forPosition:(GroupPosition)position{
    NSString *prefix = position == positionLeft ? @"@MMK_R_" : @"@MMK_L_";
    return [prefix stringByAppendingString:groupName];
}

+(NSString*)kerningGroupIdOfAGlyph:(GSGlyph*)g forPosition:(GroupPosition)position{
    NSString *group = position == positionLeft ? [g leftKerningGroupId] : [g rightKerningGroupId];
    return group;
}

+(NSDictionary* _Nullable )kernPairsToUpdate:(GSFontMaster*) m groupName:(NSString*)groupFullName position:(GroupPosition)position{
    MGOrderedDictionary *pairsDict = [[[GlyphsAccessors currentFont] kerningLTR] valueForKey:[m id]];
    if (position == positionRight){
        MGOrderedDictionary *resDict = [pairsDict objectForKey:groupFullName];
        return [resDict copy];
    }
    if (position == positionLeft){
        NSMutableDictionary *toUpdate = [[NSMutableDictionary alloc] init];
        for (NSString *firstGroup in pairsDict) {
            MGOrderedDictionary *innerDict = [pairsDict objectForKey:firstGroup];
            NSNumber *innerVal = [innerDict objectForKey:groupFullName];
            if (innerVal != nil){
                [toUpdate setValue:innerVal forKey:firstGroup];
            }
        }
        return toUpdate;
    }
    return nil;
}

+(void)find:(NSString*)searchString andReplaceWith:(NSString*)replace incluceLeftGroups:(BOOL) includeLeft inclureRightGroups:(BOOL)includeRight useRegex:(BOOL)useRegex{
  
    void (^processPosition)(GroupPosition) = ^(GroupPosition position) {
       NSArray<NSString *> *groups = [self currentFontGroupsForPosition:position];
       for (NSString *groupName in groups) {
           NSString *groupID = [self kerningGroupIdFromName:groupName forPosition:position];
           NSString *newName;
           if (useRegex) {
              NSError *error = nil;
              NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchString options:0 error:&error];
              if (error) {
                  NSLog(@"Invalid regex pattern: %@", error.localizedDescription);
                  continue;
              }
              newName = [regex stringByReplacingMatchesInString:groupName options:0 range:NSMakeRange(0, groupName.length) withTemplate:replace];
           } else {
               newName = [groupName stringByReplacingOccurrencesOfString:searchString withString:replace];
           }
           if ([newName isEqualToString:@""]){
               //TODO: newName already exists
               continue;
           }
           NSString *newID = [self kerningGroupIdFromName:newName forPosition:position];

           [self renameGroupWithId:groupID toNewId:newID position:position];
       }
    };

    if (includeLeft) {
       processPosition(positionLeft);
    }
    if (includeRight) {
       processPosition(positionRight);
    }
}

+(void)renameGroupWithId:(NSString*)groupId toNewId:(NSString*)newId position:(GroupPosition)position{
    if ([groupId isEqualToString:newId]){
        return;
    }
    BOOL isLeftPosition = (position == positionLeft);
    
    for (GSFontMaster *m in [[GlyphsAccessors currentFont] fontMasters]){
        NSDictionary *kernPairsToUpdate = [self kernPairsToUpdate:m groupName:groupId position:position];
        for (NSString *otherGroup in kernPairsToUpdate) {
            NSNumber *val = [kernPairsToUpdate objectForKey:otherGroup];
    
            NSString *leftKey = isLeftPosition ? otherGroup : newId;
            NSString *rightKey = isLeftPosition ? newId : otherGroup;
            NSString *oldLeftKey = isLeftPosition ? otherGroup : groupId;
            NSString *oldRightKey = isLeftPosition ? groupId : otherGroup;
     
            [self setKerningForFontMasterID:[m id] leftKey:leftKey rightKey:rightKey value:val];
            [self removeKerningForFontMasterID:[m id] leftKey:oldLeftKey rightKey:oldRightKey];
        }
    }
    for (GSGlyph*g in [self glyphsOfAGroupId:groupId position:position]){
        isLeftPosition ? [g setLeftKerningGroupId:newId] : [g setRightKerningGroupId:newId];
    }
}


+ (void)setKerningForFontMasterID:(id)fontMasterID leftKey:(id)leftKey rightKey:(id)rightKey value:(NSNumber*)value{
    MGOrderedDictionary *pairsDict = [[[GlyphsAccessors currentFont] kerningLTR] valueForKey:fontMasterID];
    MGOrderedDictionary *innerDict = [pairsDict objectForKey:leftKey];

    if (innerDict == nil) {
        innerDict = [[MGOrderedDictionary alloc] initWithCapacity:0];
        [pairsDict setObject:innerDict forKey:leftKey];
    }

    [innerDict setValue:value forKey:rightKey];
}

+ (void)removeGroupWithId:(nonnull NSString *)groupId position:(GroupPosition)position{
    BOOL isLeftPosition = (position == positionLeft);
    for (GSFontMaster *m in [[GlyphsAccessors currentFont] fontMasters]){
        NSDictionary *kernPairsToUpdate = [KerningService kernPairsToUpdate:m groupName:groupId position:position];
        
        for (NSString *otherGroup in kernPairsToUpdate) {
            NSString *oldRightKey = isLeftPosition ? groupId : otherGroup;
            NSString *oldLeftKey = isLeftPosition ? otherGroup : groupId;

            [KerningService removeKerningForFontMasterID:[m id] leftKey:oldLeftKey rightKey:oldRightKey];
        }
    }
    for (GSGlyph*g in [self glyphsOfAGroupId:groupId position:position]){
        isLeftPosition ? [g setLeftKerningGroupId:nil] : [g setRightKerningGroupId:nil];
    }
}


+ (void)removeKerningForFontMasterID:(NSString *)fontMasterID leftKey:(NSString *)leftKey rightKey:(NSString *)rightKey{
    MGOrderedDictionary *pairsDict = [[[GlyphsAccessors currentFont] kerningLTR] valueForKey:fontMasterID];
    MGOrderedDictionary *innerDict = [pairsDict objectForKey:leftKey];
    if (innerDict == nil) {
        return;
    }
    [innerDict removeObjectForKey:rightKey];
}

+ (void)removeEmptyGroups {
    void (^processPosition)(GroupPosition) = ^(GroupPosition position) {
        NSArray<NSString *> *groups = [self currentFontGroupsForPosition:position];
        
        for (NSString *groupName in groups) {
            NSString *groupId = [self kerningGroupIdFromName:groupName forPosition:position];
            BOOL groupHasKerningPairs = NO;
            for (GSFontMaster *m in [[GlyphsAccessors currentFont] fontMasters]){
                NSDictionary *kernPairsToUpdate = [self kernPairsToUpdate:m groupName:groupId position:position];
                if ([kernPairsToUpdate count] >0){
                    groupHasKerningPairs = YES;
                    break;
                }
            }
            if (!groupHasKerningPairs){
                [self removeGroupWithId:groupId position:position];
            }
        }
    };
    processPosition(positionLeft);
    processPosition(positionRight);
}

@end
