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
    NSMutableArray *missingCandidates = [[NSMutableArray alloc] init];
    for (GSGlyph*g in [[GlyphsAccessors currentFont] glyphs]){
        NSString * groupId = position == positionLeft ? [g leftKerningGroupId] : [g rightKerningGroupId];
        if (groupId == nil){
            [missingCandidates addObject:g];
        }
    }
    for (GSGlyph *g in missingCandidates){
        NSString *parentName = [[self compositesDictionary] valueForKey:[g name]];
        if (parentName != nil){
            GSGlyph *parentGlyph = [[GlyphsAccessors currentFont] glyphForName:parentName];
            if (parentGlyph != nil){
                NSLog(@"Going to steal kerning group from %@ to %@", [g name], parentName);
                NSString *parentGroupId = position == positionLeft ? [parentGlyph leftKerningGroupId] : [parentGlyph rightKerningGroupId];
                if (onlyForGroupId != nil){
                    if (![onlyForGroupId isEqualToString:parentGroupId]){
                        NSLog(@"Skipping %@ to %@", [g name], parentName);
                        continue;
                    }
                }
                position == positionLeft ? [g setLeftKerningGroupId:parentGroupId] : [g setRightKerningGroupId:parentGroupId];
            }
        }
    }
}
@end
