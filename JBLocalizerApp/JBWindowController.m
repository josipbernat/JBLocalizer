//
//  JBWindow.m
//  JBLocalizer
//
//  Created by Josip Bernat on 7/16/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBWindowController.h"

@interface JBWindowController ()

@end

@implementation JBWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [self.window makeFirstResponder:self.contentViewController];
}

- (void)openDocument:(id)sender {

    if ([self.contentViewController respondsToSelector:@selector(openDocument:)]) {
        [self.contentViewController performSelector:@selector(openDocument:) withObject:sender];
    }
}

- (void)clearRecentDocuments:(id)sender {

}

@end
