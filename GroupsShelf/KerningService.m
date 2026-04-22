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
        NSString *group = nil;
        switch (position) {
            case positionLeft: group = [g leftKerningGroup]; break;
            case positionRight: group = [g rightKerningGroup]; break;
            case positionTop: group = [g topKerningGroup]; break;
            case positionBottom: group = [g bottomKerningGroup]; break;
        }
        if (group != nil){
            [allKeys addObject:group];
        }
    }
    return [allKeys array];
}

+(NSArray<GSGlyph*>*)glyphsOfAGroupId:(NSString*)groupId position:(GroupPosition)position{
    GSFont *currentFont = [GlyphsAccessors currentFont];
    NSMutableArray<GSGlyph*> *glyphsOfCurrentGroup = [[NSMutableArray alloc] init];
    NSString *groupName = [self groupNameFromGroupId:groupId];
  
    for (GSGlyph *g in [currentFont glyphs]){
        NSString *glyphGroupName = nil;
        switch (position) {
            case positionLeft: glyphGroupName = [g leftKerningGroup]; break;
            case positionRight: glyphGroupName = [g rightKerningGroup]; break;
            case positionTop: glyphGroupName = [g topKerningGroup]; break;
            case positionBottom: glyphGroupName = [g bottomKerningGroup]; break;
        }
        if ([glyphGroupName isEqualToString:groupName]){
            [glyphsOfCurrentGroup addObject:g];
        }
    }
    return glyphsOfCurrentGroup;
}

+(NSString*)groupNameFromGroupId:(NSString*)group{
    group = [group stringByReplacingOccurrencesOfString:@"@MMK_R_" withString:@""];
    group = [group stringByReplacingOccurrencesOfString:@"@MMK_L_" withString:@""];
    group = [group stringByReplacingOccurrencesOfString:@"@MMK_T_" withString:@""];
    group = [group stringByReplacingOccurrencesOfString:@"@MMK_B_" withString:@""];
    return group;
}

+(NSString*)kerningGroupIdFromName:(NSString*)groupName forPosition:(GroupPosition)position{
    NSString *prefix = @"";
    switch (position) {
        case positionLeft: prefix = @"@MMK_R_"; break;
        case positionRight: prefix = @"@MMK_L_"; break;
        case positionTop: prefix = @"@MMK_B_"; break;
        case positionBottom: prefix = @"@MMK_T_"; break;
    }
    return [prefix stringByAppendingString:groupName];
}


+(NSDictionary* _Nullable )kernPairsToUpdate:(GSFontMaster*) m groupName:(NSString*)groupFullName position:(GroupPosition)position{
    BOOL isVertical = (position == positionTop || position == positionBottom);
    MGOrderedDictionary *allPairs = isVertical ? [[GlyphsAccessors currentFont] kerningVertical] : [[GlyphsAccessors currentFont] kerningLTR];
    MGOrderedDictionary *pairsDict = [allPairs valueForKey:[m id]];
    
    if (position == positionRight || position == positionBottom){ // 1st glyph
        MGOrderedDictionary *resDict = [pairsDict objectForKey:groupFullName];
        return [resDict copy];
    }
    if (position == positionLeft || position == positionTop){ // 2nd glyph
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

+(void)find:(NSString*)searchString andReplaceWith:(NSString*)replace includeLeftGroups:(BOOL) includeLeft includeRightGroups:(BOOL)includeRight
   includeTopGroups:(BOOL) includeTop includeBottomGroups:(BOOL)includeBottom
   useRegex:(BOOL)useRegex{
  
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
    if (includeTop){
        processPosition(positionTop);
    }
    if (includeBottom){
        processPosition(positionBottom);
    }
}

+(void)renameGroupWithId:(NSString*)groupId toNewId:(NSString*)newId position:(GroupPosition)position{
    if ([groupId isEqualToString:newId]){
        return;
    }
    BOOL isFirstGlyph = (position == positionRight || position == positionBottom);
    
    for (GSFontMaster *m in [[GlyphsAccessors currentFont] fontMasters]){
        NSDictionary *kernPairsToUpdate = [self kernPairsToUpdate:m groupName:groupId position:position];
        for (NSString *otherGroup in kernPairsToUpdate) {
            NSNumber *val = [kernPairsToUpdate objectForKey:otherGroup];
    
            NSString *key1 = isFirstGlyph ? newId : otherGroup;
            NSString *key2 = isFirstGlyph ? otherGroup : newId;
            NSString *oldKey1 = isFirstGlyph ? groupId : otherGroup;
            NSString *oldKey2 = isFirstGlyph ? otherGroup : groupId;
      
            [self setKerningForFontMasterID:[m id] leftKey:key1 rightKey:key2 value:val position:position];
            [self removeKerningForFontMasterID:[m id] leftKey:oldKey1 rightKey:oldKey2 position:position];
        }
    }
    for (GSGlyph*g in [self glyphsOfAGroupId:groupId position:position]){
        switch (position) {
            case positionLeft: [g setLeftKerningGroupId:newId]; break;
            case positionRight: [g setRightKerningGroupId:newId]; break;
            case positionTop: [g setTopKerningGroupId:newId]; break;
            case positionBottom: [g setBottomKerningGroupId:newId]; break;
        }
    }
}


+ (void)setKerningForFontMasterID:(id)fontMasterID leftKey:(id)leftKey rightKey:(id)rightKey value:(NSNumber*)value position:(GroupPosition)position{
    BOOL isVertical = (position == positionTop || position == positionBottom);
    MGOrderedDictionary *allPairs = isVertical ? [[GlyphsAccessors currentFont] kerningVertical] : [[GlyphsAccessors currentFont] kerningLTR];
    MGOrderedDictionary *pairsDict = [allPairs valueForKey:fontMasterID];
    MGOrderedDictionary *innerDict = [pairsDict objectForKey:leftKey];

    if (innerDict == nil) {
        innerDict = [[MGOrderedDictionary alloc] initWithCapacity:0];
        [pairsDict setObject:innerDict forKey:leftKey];
    }

    [innerDict setValue:value forKey:rightKey];
}

+ (void)removeGroupWithId:(nonnull NSString *)groupId position:(GroupPosition)position{
    BOOL isFirstGlyph = (position == positionRight || position == positionBottom);
    for (GSFontMaster *m in [[GlyphsAccessors currentFont] fontMasters]){
        NSDictionary *kernPairsToUpdate = [KerningService kernPairsToUpdate:m groupName:groupId position:position];
        
        for (NSString *otherGroup in kernPairsToUpdate) {
            NSString *key1 = isFirstGlyph ? groupId : otherGroup;
            NSString *key2 = isFirstGlyph ? otherGroup : groupId;

            [KerningService removeKerningForFontMasterID:[m id] leftKey:key1 rightKey:key2 position:position];
        }
    }
    for (GSGlyph*g in [self glyphsOfAGroupId:groupId position:position]){
        switch (position) {
            case positionLeft: [g setLeftKerningGroupId:nil]; break;
            case positionRight: [g setRightKerningGroupId:nil]; break;
            case positionTop: [g setTopKerningGroupId:nil]; break;
            case positionBottom: [g setBottomKerningGroupId:nil]; break;
        }
    }
}


+ (void)removeKerningForFontMasterID:(NSString *)fontMasterID leftKey:(NSString *)leftKey rightKey:(NSString *)rightKey position:(GroupPosition)position{
    BOOL isVertical = (position == positionTop || position == positionBottom);
    MGOrderedDictionary *allPairs = isVertical ? [[GlyphsAccessors currentFont] kerningVertical] : [[GlyphsAccessors currentFont] kerningLTR];
    MGOrderedDictionary *pairsDict = [allPairs valueForKey:fontMasterID];
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
    processPosition(positionTop);
    processPosition(positionBottom);
}

@end
