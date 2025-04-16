//
//  CompositesService.m
//  GroupsShelf
//
//  Created by pkolchanov on 11.03.2025.
//

#import "CompositesService.h"

@implementation CompositesService
- (instancetype)init
{
    self = [super init];
    if (self) {
        _compositesDictionary = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle bundleForClass:[self class]] pathForResource:@"composites" ofType:@"plist"]];
    }
    return self;
}


- (void)addMissingCompositesForAllGroups {
    [self addMissingCompositesForPosition:positionLeft onlyForGroupId:nil];
    [self addMissingCompositesForPosition:positionRight onlyForGroupId:nil];
}

-(void)addMissingCompositesForPosition:(GroupPosition)position onlyForGroupId:(NSString*)onlyForGroupId{
    // Call order matters
    [self stealKerningFromSameGlyphs:position onlyForGroupId:onlyForGroupId];
    [self stealKerningFromComposites:position onlyForGroupId:onlyForGroupId];
}

-(void)stealKerningFromSameGlyphs:(GroupPosition)position onlyForGroupId:(NSString*)onlyForGroupId{
    NSMutableArray *missingCandidates = [self missingCandindatesForPosition:position];
    for (GSGlyph *g in missingCandidates){
        GSLayer* currentMasterLayer = [g layerForId:[[GlyphsAccessors currentFontMaster] id]];
        if ([currentMasterLayer countOfComponents] == 1 && [currentMasterLayer countOfShapes] == 1 ){
            GSComponent *component = [[currentMasterLayer components] objectAtIndex:0];
            NSAffineTransformStruct st = [[component transform] transformStruct];
            if(st.m11 == 1 && st.m12 == 0 && st.m21 == 0 && st.m22 == 1 && st.tX == 0 && st.tY == 0){
                [self stealKerningGroupFrom:[component component] to:g position:position onlyForGroupId:onlyForGroupId];
            }
        }
    }
}

-(void)stealKerningFromComposites:(GroupPosition)position onlyForGroupId:(NSString*)onlyForGroupId{
    NSMutableArray *missingCandidates = [self missingCandindatesForPosition:position];
    for (GSGlyph *g in missingCandidates){
        NSString *parentName = [self parentName:g];
        if (parentName != nil){
            GSGlyph *parentGlyph = [[GlyphsAccessors currentFont] glyphForName:parentName];
            if (parentGlyph != nil){
                [self stealKerningGroupFrom:parentGlyph to:g position:position onlyForGroupId:onlyForGroupId];
            }
        }
    }
}

-(NSString*)parentName:(GSGlyph *)g{
    NSString * name = [g name];
    
    NSError *error = nil;
    NSRegularExpression *ssRegex = [NSRegularExpression regularExpressionWithPattern:@"\\.ss\\d+" options:0 error:&error];
    if (error) {
        NSLog(@"Regex error: %@", error);
        return @"";
    }
    
    NSTextCheckingResult *ssMatchReuslt = [ssRegex firstMatchInString:name options:0 range:NSMakeRange(0, [name length])];
    if (!ssMatchReuslt) {
        return [[self compositesDictionary] valueForKey:name];
    }
    
    NSString *ss = [name substringWithRange:[ssMatchReuslt range]];
    name = [name stringByReplacingCharactersInRange:[ssMatchReuslt range] withString:@""];
    NSString *parentName = [[self compositesDictionary] valueForKey:name];
    if (![ss isEqualToString:@""]){
        parentName = [parentName stringByAppendingString:ss];
    }
    return parentName;
}

-(void)stealKerningGroupFrom:(GSGlyph*)fromGlyph to:(GSGlyph*)toGlyph position:(GroupPosition)position onlyForGroupId:(NSString*)onlyForGroupId{
    NSString *parentGroupId = position == positionLeft ? [fromGlyph leftKerningGroupId] : [fromGlyph rightKerningGroupId];
    if (onlyForGroupId != nil && ![onlyForGroupId isEqualToString:parentGroupId]){
        return;
    }
    NSLog(@"Going to steal kerning group from %@ to %@", [fromGlyph name], [toGlyph name]);
    position == positionLeft ? [toGlyph setLeftKerningGroupId:parentGroupId] : [toGlyph setRightKerningGroupId:parentGroupId];
}

-(NSMutableArray<GSGlyph*>*)missingCandindatesForPosition:(GroupPosition)position{
    NSMutableArray *missingCandidates = [[NSMutableArray alloc] init];
    for (GSGlyph*g in [[GlyphsAccessors currentFont] glyphs]){
        NSString * groupId = position == positionLeft ? [g leftKerningGroupId] : [g rightKerningGroupId];
        if (groupId == nil){
            [missingCandidates addObject:g];
        }
    }
    return missingCandidates;
}
@end
