//
//  ViewController.m
//  JBLocalizerApp
//
//  Created by Josip Bernat on 7/8/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "ViewController.h"
#import <JBLocalizer/JBLocalizer.h>
#import <Cocoa/Cocoa.h>

@interface ViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSScrollView *tableSuperView;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTableColumn *columnView;
@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet NSTextField *instructionLabel;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSString *projectPath;
@property (nonatomic, strong) JBFile *selectedFile;

@end

@implementation ViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];
    
    [self.tableView  setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
    [self.columnView setResizingMask:NSTableColumnAutoresizingMask];
    [self.tableView sizeLastColumnToFit];
    
    self.tableSuperView.hidden = YES;
    self.nextButton.hidden = YES;
    self.instructionLabel.hidden = YES;
}

#pragma mark - Button Selectors

- (IBAction)onOpenFile:(id)sender {

    [self __openFileDialog];
}

- (IBAction)onNext:(id)sender {
    
    self.selectedFile = nil;
    
    for (JBFile *file in self.items) {
        if (file.selected) {
            self.selectedFile = file;
            break;
        }
    }
    
    if (self.selectedFile) {
        [self __loadLocalizableFilesInRootFile:self.selectedFile];
    }
}

#pragma mark - Open File

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

#pragma mark - Save File

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

#pragma mark - Error Handling

- (void)__presentErrorAlertView:(NSError *)error {

    if (![NSThread isMainThread]) {
        __weak id this = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongThis = this;
            [strongThis __presentErrorAlertView:error];
        });
        return;
    }
    
    NSLog(@"Error: %@", error);
}

#pragma mark - File Processing

- (void)__processProjectAtPath:(NSString *)path {
    NSParameterAssert(path);
    
    self.tableSuperView.hidden = NO;
    self.nextButton.hidden = NO;
    self.instructionLabel.hidden = NO;
    
    self.projectPath = path;
    
    __weak id this = self;
    [[JBFileController sharedController] loadProjectRootFiles:[path stringByDeletingLastPathComponent]
                                                   completion:^(NSArray *items, NSError *error) {
                                                       
                                                       __strong typeof(self) strongThis = this;
                                                       if (error) {
                                                           [strongThis __presentErrorAlertView:error];
                                                       }
                                                       else {

                                                           strongThis.items = items;
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               [strongThis.tableView reloadData];
                                                           });
                                                       }
                                                   }];
}

- (void)__loadLocalizableFilesInRootFile:(JBFile *)file {

    __weak id this = self;
    [[JBFileController sharedController] loadProjectFiles:self.projectPath
                                            rootDirectory:[file name]
                                               completion:^(NSDictionary *result, NSError *error) {
                                                   
                                                   __strong typeof(self) strongThis = this;
                                                   if (error) {
                                                       [strongThis __presentErrorAlertView:error];
                                                   }
                                                   else {
                                                       [strongThis __processLocalizableStringsInFolders:result file:file];
                                                   }
                                               }];
}

- (void)__processLocalizableStringsInFolders:(NSDictionary *)result file:(JBFile *)file {

    __weak id this = self;
    [[JBFileController sharedController] loadAndProcessLocalizableStringsInFiles:result[[file name]]
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

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.items.count;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    if ([tableColumn isEqualTo:self.columnView]) {
        
        NSButtonCell *aCell = cell;
        
        JBFile *file = self.items[row];
        aCell.title = file.name;
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    if (![tableColumn isEqualTo:self.columnView]) {
        return nil;
    }
    
    JBFile *file = self.items[row];
    return @(file.selected);
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn *)column row:(NSInteger)row {
    
    JBFile *file = self.items[row];
    file.selected = [value boolValue];
    
    [tableView reloadData];
}

@end
