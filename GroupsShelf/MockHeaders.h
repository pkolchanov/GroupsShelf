//
//  MockHeaders.h
//  GroupsShelf
//
//  Created by pkolchanov on 19.02.2025.
//

#ifndef MockHeaders_h
#define MockHeaders_h
#import <GlyphsCore/GSGlyphEditViewProtocol.h>
#import <GlyphsCore/GSGlyphViewControllerProtocol.h>

@interface GSApplication : NSApplication
@property (weak, nonatomic, nullable) GSDocument *currentFontDocument;
@end

@interface GSDocument : NSDocument
@property (nonatomic, retain) GSFont *font;
@property (weak, nonatomic, nullable) NSWindowController<GSWindowControllerProtocol> *windowController;
@property (nonatomic, nullable) GSFontMaster *selectedFontMaster;
@end


#endif /* MockHeaders_h */
