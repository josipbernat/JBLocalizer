//
//  ViewController.m
//  JBLocalizerApp
//
//  Created by Josip Bernat on 7/8/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "ViewController.h"
#import <JBLocalizer/JBLocalizer.h>

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - Open File

- (IBAction)onOpenFile:(id)sender {

    [self __openFileDialog];
}

- (void)__openFileDialog {

    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[@"xcodeproj"]];
    [panel setAllowsMultipleSelection:NO];
    
    if ([panel runModal] == NSModalResponseOK) {
        
        NSArray *files = [panel URLs];
        // Because we only want to process one project at the time.
        if (files.count) {
            
            [panel close];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self __processProjectAtPath:[[files firstObject] path]];
            });
        }
    }
}

#pragma mark - File Processing

- (void)__processProjectAtPath:(NSString *)path {
    
    __weak id this = self;
    [[JBFileController sharedController] loadProjectFiles:path
                                               completion:^(NSDictionary *result, NSError *error) {
                                                   
                                                   __strong typeof(self) strongThis = this;
                                                   if (error) {
                                                       // Present error.
                                                   }
                                                   else {
                                                       [strongThis __processLocalizableStringsInFolders:result];
                                                   }
                                               }];
}

- (void)__processLocalizableStringsInFolders:(NSDictionary *)result {

    __weak id this = self;
    [[JBFileController sharedController] loadAndProcessLocalizableStringsInFiles:result[@"SpikaEnterprise"]
                                                                      completion:^(NSString *strings, NSError *error) {
                                                                          
                                                                          __strong typeof(self) strongThis = this;
                                                                          if (error) {
                                                                              // Present error.
                                                                          }
                                                                          else {
                                                                              [strongThis __presentSaveFileDialog:strings];
                                                                          }
                                                                      }];
}

- (void)__presentSaveFileDialog:(NSString *)resultToSave {
    
    if (![NSThread isMainThread]) {
        __weak id this = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongThis = this;
            [strongThis __presentSaveFileDialog:resultToSave];
        });
        return;
    }

    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:@"Localizable.strings"];
    [panel setAllowedFileTypes:@[@"strings"]];
    [panel setAllowsOtherFileTypes:NO];

    if ([panel runModal] == NSModalResponseOK) {
    
        NSURL *fileURL = [panel URL];
        NSError *writeError = nil;
        [resultToSave writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
    }
}

@end
