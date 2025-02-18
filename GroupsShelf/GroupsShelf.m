//
//  GroupsShelf.m
//  GroupsShelf
//
//  Created by pkolchanov on 17.02.2025.
//
//

#import "GroupsShelf.h"

@implementation GroupsShelf {
    BOOL _hasRegisteredObservers;
}

- (instancetype) init {
    self = [super initWithWindowNibName:[self windowNibName]];
    if (self) {
        [self window];
        _hasRegisteredObservers = NO;
    }
    return self;
}

- (NSUInteger)interfaceVersion {
	// Distinguishes the API verison the plugin was built for. Return 1.
	return 1;
}

- (NSNibName)windowNibName{
    return @"GroupsShelfWindow";
}

- (NSString *)title {
    return @"Groups Shelf";
}

- (NSString *)keyEquivalent {
    return @"";
}

- (void)awakeFromNib {
    [[self window] setLevel:NSFloatingWindowLevel];
    [[self window] setTitle:[self title]];
}


- (void)loadPlugin {
    NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:[self title] action:@selector(showPluginWindow:) keyEquivalent:[self keyEquivalent]];
    newMenuItem.target = self;
    NSMenu *submenu = [[mainMenu itemWithTag:17] submenu];
    [submenu addItem:newMenuItem];
}

-(void)showPluginWindow:(id)sender{
    NSLog(@"showPluginWindow");
    [self showWindow:nil];
    [self setupObservers];
}

-(void)update{
    MGOrderedDictionary *a =[[[self currentFont] kerningLTR] objectForKey:[[self currentFontMaster] id]];
    [[self groupsArrayController] setContent:[a allKeys]];
}

-(GSFont *)currentFont{
    GSApplication *app = NSApp;
    GSDocument *document = [app currentFontDocument];
    NSWindowController<GSWindowControllerProtocol> *windowController = [document windowController];

    GSFont *font = [document font];
    return font;
}

-(GSFontMaster *)currentFontMaster{
    GSApplication *app = NSApp;
    GSDocument *document = [app currentFontDocument];

    return [document selectedFontMaster];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (context == @"Document") {
        NSLog(@"observed change of keypath %@", keyPath);
        [self update];
    }
}


-(void) removeObservers{
    NSLog(@"removeObservers");
    if (_hasRegisteredObservers){
        [NSApp removeObserver:self forKeyPath:@"mainWindow.windowController.document"];
        _hasRegisteredObservers = NO;
    }
}

-(void) setupObservers{
    if (!_hasRegisteredObservers){
        [NSApp addObserver:self forKeyPath:@"mainWindow.windowController.document" options:1 context:@"Document"];
        _hasRegisteredObservers = YES;
    }
  
}

- (BOOL)windowShouldClose:(id)window {
    if (self.window == window) {
        [self removeObservers];
    }
    return YES;
}

@end
