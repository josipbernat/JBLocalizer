//
//  ViewController.m
//  JBLocalizerApp
//
//  Created by Josip Bernat on 7/8/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBContentViewController.h"
#import <JBLocalizer/JBLocalizer.h>
#import <Cocoa/Cocoa.h>

@interface JBContentViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSView *tablePickerContainerView;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTableColumn *columnView;
@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet NSTextField *instructionLabel;
@property (weak) IBOutlet NSButton *commentsButton;
@property (weak) IBOutlet NSView *selectProjectContainer;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSString *projectPath;
@property (nonatomic, strong) JBFile *selectedFile;

@end

@implementation JBContentViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];
        
    [_tableView  setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
    [_columnView setResizingMask:NSTableColumnAutoresizingMask];
    [_tableView sizeLastColumnToFit];
    
    _selectProjectContainer.hidden = NO;
    _tablePickerContainerView.hidden = YES;
}

#pragma mark - Button Selectors

- (IBAction)openDocument:(id)sender {
    [self onOpenFile:sender];
}

- (IBAction)onOpenFile:(id)sender {

    [self __openFileDialog];
}

- (IBAction)onNext:(id)sender {
    
    self.selectedFile = nil;
    
    for (JBFile *file in _items) {
        if (file.selected) {
            self.selectedFile = file;
            break;
        }
    }
    
    if (_selectedFile) {
        [self __loadLocalizableFilesInRootFile:_selectedFile];
    }
}

- (IBAction)onCancel:(id)sender {

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = NSLocalizedString(@"Are you sure you want to cancel?", nil);
    [alert addButtonWithTitle:NSLocalizedString(@"Yes", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"No", nil)];
    
    NSModalResponse response = [alert runModal];
    if (response == NSAlertFirstButtonReturn) {
        [self __reset];
    }
}

- (void)__reset {

    [[JBFileController sharedController] reset];
    
    _selectProjectContainer.hidden = NO;
    _tablePickerContainerView.hidden = YES;
    [_commentsButton setState:NSOnState];
    [_nextButton setEnabled:NO];
    
    self.selectedFile = nil;
    self.projectPath = nil;
    self.items = nil;
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
        
        [self __reset];
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
    
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert addButtonWithTitle:NSLocalizedString(@"Ok", nil)];
    
    [alert runModal];
}

- (void)__presentErrorAlertViewWithMessage:(NSString *)message {
    
    if (![NSThread isMainThread]) {
        __weak id this = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongThis = this;
            [strongThis __presentErrorAlertViewWithMessage:message];
        });
        return;
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = message;
    [alert addButtonWithTitle:NSLocalizedString(@"Ok", nil)];
    
    [alert runModal];
}

#pragma mark - File Processing

- (void)__processProjectAtPath:(NSString *)path {
    NSParameterAssert(path);
    
    _selectProjectContainer.hidden = YES;
    _tablePickerContainerView.hidden = NO;
    
    self.projectPath = path;
    
    NSArray *targetNames = [[JBFileController sharedController] targetNamesInProjectAtPath:path];
    
    __weak id this = self;
    [[JBFileController sharedController] loadProjectRootFiles:[path stringByDeletingLastPathComponent]
                                                   completion:^(NSArray *items, NSError *error) {
                                                       
                                                       __strong typeof(self) strongThis = this;
                                                       if (error) {
                                                           [strongThis __presentErrorAlertView:error];
                                                       }
                                                       else {

                                                           strongThis.items = items;
                                                           for (JBFile *file in items) {
                                                               if ([targetNames containsObject:file.name] && ![file.name hasSuffix:@"Tests"]) {
                                                                   file.selected = YES;
                                                               }
                                                           }
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               [strongThis.tableView reloadData];
                                                           });
                                                       }
                                                   }];
}

- (void)__loadLocalizableFilesInRootFile:(JBFile *)file {

    __weak id this = self;
    [[JBFileController sharedController] loadProjectFiles:self.projectPath
                                        filterDirectories:@[file]
                                               completion:^(NSDictionary *result, NSError *error) {
                                                  
                                                   __strong typeof(self) strongThis = this;
                                                   if (error) {
                                                       [strongThis __presentErrorAlertView:error];
                                                   }
                                                   else {
                                                       if (result.count) {
                                                           [strongThis __processLocalizableStringsInFolders:result file:file];
                                                       }
                                                       else {
                                                           [strongThis __presentErrorAlertViewWithMessage:NSLocalizedString(@"Selected folder contains zero Objective-C or Swift files", nil)];
                                                       }
                                                   }
                                               }];
}

- (void)__processLocalizableStringsInFolders:(NSDictionary *)result file:(JBFile *)file {

    __weak id this = self;
    [[JBFileController sharedController] loadAndProcessLocalizableStringsInFiles:result[file]
                                                                      formatting:([self.commentsButton state] == NSOnState ? JBStringFormattingTypeDefault : JBStringFormattingTypeWithoutComments)
                                                                      completion:^(NSString *strings, NSError *error) {
                                                                          
                                                                          __strong typeof(self) strongThis = this;
                                                                          if (error) {
                                                                              // Present error.
                                                                          }
                                                                          else {
                                                                              if (strings.length) {
                                                                                  [strongThis __presentSaveFileDialog:strings];
                                                                              }
                                                                              else {
                                                                                  [strongThis __presentErrorAlertViewWithMessage:NSLocalizedString(@"Selected folder contains zero files using NSLocalizedString", nil)];
                                                                              }
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
    
    BOOL hasSelectedFile = file.selected;
    
    if (!hasSelectedFile) {
        
        for (JBFile *otherFile in self.items) {
            if (otherFile.selected) {
                hasSelectedFile = YES;
                break;
            }
        }
    }

    [tableView reloadData];
    [_nextButton setEnabled:hasSelectedFile];
}

@end