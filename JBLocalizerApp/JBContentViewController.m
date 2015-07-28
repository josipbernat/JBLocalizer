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

typedef NS_ENUM(NSInteger, kContentFlow) {
    
    kContentFlowStart = 0,
    kContentFlowSelectProject,
    kContentFlowSelectTarget
};

@interface JBContentViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSView *tablePickerContainerView;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *instructionLabel;
@property (weak) IBOutlet NSTableColumn *columnView;
@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet NSButton *cancelButton;
@property (weak) IBOutlet NSButton *commentsCheckBox;
@property (weak) IBOutlet NSView *selectProjectContainer;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSString *projectPath;
@property (nonatomic, strong) JBFile *selectedFile;
@property (nonatomic, readwrite) kContentFlow currentFlow;

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
    
    if (!_selectedFile) {
        return;
    }
    
    if (_currentFlow == kContentFlowSelectProject) {
        [self __processProjectAtPath:_selectedFile.path];
    }
    else if (_currentFlow == kContentFlowSelectTarget) {
        [self __loadLocalizableFilesInRootFile:_selectedFile];
    }
    else {
        NSAssert(NO, @"Not allowed flow state");
    }
    
    [self __toogleContentFlow];
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
    
    self.selectedFile = nil;
    self.projectPath = nil;
    self.items = nil;
    
    _currentFlow = kContentFlowStart;
    [self setShowLoader:NO];
    [self __toogleContentFlow];
}

#pragma mark - Interface

- (void)__toogleContentFlow {

    if (![NSThread isMainThread]) {
        __weak id this = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongThis = this;
            [strongThis __toogleContentFlow];
        });
        return;
    }
    
    if (_currentFlow == kContentFlowStart) {
        
        _selectProjectContainer.hidden = NO;
        _tablePickerContainerView.hidden = YES;
        
        _commentsCheckBox.state = NSOnState;
        _commentsCheckBox.hidden = YES;
        
        _nextButton.hidden = YES;
        _cancelButton.hidden = YES;
        
        [_tableView reloadData];
    }
    else if (_currentFlow == kContentFlowSelectProject) {
    
        _selectProjectContainer.hidden = YES;
        _tablePickerContainerView.hidden = NO;
        
        _instructionLabel.stringValue = NSLocalizedString(@"Choose desired Xcode project", nil);
        _columnView.title = NSLocalizedString(@"Project files", nil);
        
        _commentsCheckBox.hidden = YES;
        
        _nextButton.hidden = NO;
        _nextButton.enabled = YES;
        
        _cancelButton.hidden = NO;
        _cancelButton.enabled = YES;
    }
    else if (_currentFlow == kContentFlowSelectTarget) {
    
        _selectProjectContainer.hidden = YES;
        _tablePickerContainerView.hidden = NO;
        
        _instructionLabel.stringValue = NSLocalizedString(@"Select folder with project source files", nil);
        _columnView.title = NSLocalizedString(@"Root folders", nil);
        
        _commentsCheckBox.hidden = NO;
        _nextButton.hidden = NO;
        _cancelButton.hidden = NO;
        _cancelButton.enabled = YES;
    }
}

- (void)setShowLoader:(BOOL)show {

    if (![NSThread isMainThread]) {
        __weak id this = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongThis = this;
            [strongThis setShowLoader:show];
        });
        return;
    }
    
    _selectProjectContainer.hidden = !show;
    _tablePickerContainerView.hidden = !show;
}

#pragma mark - Open File

- (void)__openFileDialog {

    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowsMultipleSelection = NO;
    panel.canChooseDirectories = YES;
    panel.canChooseFiles = NO;
    panel.title = NSLocalizedString(@"Select", nil);
    
    if ([panel runModal] == NSModalResponseOK) {
        
        NSArray *files = [panel URLs];
        // Because we only want to process one project at the time.
        if (files.count) {
            
            [panel close];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self __procesDirectorySelectedAtPath:[[files firstObject] path]];
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

- (void)__presentErrorAlertView:(NSError *)error resetUI:(BOOL)reset {

    if (![NSThread isMainThread]) {
        __weak id this = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongThis = this;
            [strongThis __presentErrorAlertView:error resetUI:reset];
        });
        return;
    }
    
    if (reset) {
        [self __reset];
    }
    
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert addButtonWithTitle:NSLocalizedString(@"Ok", nil)];
    
    [alert runModal];
}

- (void)__presentErrorAlertViewWithMessage:(NSString *)message resetUI:(BOOL)reset {
    
    if (![NSThread isMainThread]) {
        __weak id this = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongThis = this;
            [strongThis __presentErrorAlertViewWithMessage:message resetUI:reset];
        });
        return;
    }
    
    if (reset) {
        [self __reset];
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = message;
    [alert addButtonWithTitle:NSLocalizedString(@"Ok", nil)];
    
    [alert runModal];
}

#pragma mark - Project Selection

- (void)__procesDirectorySelectedAtPath:(NSString *)path {

    [self setShowLoader:YES];
    
    __weak id this = self;
    [[JBFileController sharedController] loadPossibleProjectFilesInPath:path
                                                             completion:^(NSArray *results, NSError *error) {
                                                                 
                                                                 __strong typeof(self) strongThis = this;
                                                                 if (error) {
                                                                     [strongThis __presentErrorAlertView:error resetUI:YES];
                                                                     return;
                                                                 }
                                                                 else if (!results.count) {
                                                                     [strongThis __presentErrorAlertViewWithMessage:NSLocalizedString(@"Selected filed doesn't contain any Xcode project file", nil) resetUI:YES];
                                                                     return;
                                                                 }
                                                                 strongThis.currentFlow = kContentFlowSelectProject;
                                                                 [strongThis __toogleContentFlow];
                                                                 
                                                                 // Preselect first file
                                                                 JBFile *file = results[0];
                                                                 file.selected = YES;
                                                                 
                                                                 strongThis.items = results;
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     [strongThis.tableView reloadData];
                                                                 });
                                                             }];
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
                                                           [strongThis __presentErrorAlertView:error resetUI:YES];
                                                           return;
                                                       }

                                                       strongThis.items = items;
                                                       BOOL hasSelectedFile = NO;
                                                       
                                                       for (JBFile *file in items) {
                                                           if ([targetNames containsObject:[file.name lowercaseString]] && ![file.name hasSuffix:@"Tests"]) {
                                                               file.selected = YES;
                                                               hasSelectedFile = YES;
                                                               break;
                                                           }
                                                       }
                                                       
                                                       strongThis.currentFlow = kContentFlowSelectTarget;
                                                       [strongThis __toogleContentFlow];
                                                       
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           strongThis.nextButton.enabled = hasSelectedFile;
                                                           [strongThis.tableView reloadData];
                                                       });
                                                   }];
}

- (void)__loadLocalizableFilesInRootFile:(JBFile *)file {

    __weak id this = self;
    [[JBFileController sharedController] loadProjectFiles:self.projectPath
                                        filterDirectories:@[file]
                                               completion:^(NSDictionary *result, NSError *error) {
                                                  
                                                   __strong typeof(self) strongThis = this;
                                                   if (error) {
                                                       [strongThis __presentErrorAlertView:error resetUI:YES];
                                                   }
                                                   else {
                                                       if (result.count) {
                                                           [strongThis __processLocalizableStringsInFolders:result file:file];
                                                       }
                                                       else {
                                                           [strongThis __presentErrorAlertViewWithMessage:NSLocalizedString(@"Selected folder doesn't contain any Objective-C or Swift files", nil) resetUI:NO];
                                                       }
                                                   }
                                               }];
}

- (void)__processLocalizableStringsInFolders:(NSDictionary *)result file:(JBFile *)file {

    __weak id this = self;
    [[JBFileController sharedController] loadAndProcessLocalizableStringsInFiles:result[file]
                                                                      formatting:([self.commentsCheckBox state] == NSOnState ? JBStringFormattingTypeDefault : JBStringFormattingTypeWithoutComments)
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
                                                                                  [strongThis __presentErrorAlertViewWithMessage:NSLocalizedString(@"Source files in selected folder doesn't contain NSLocalizedString", nil) resetUI:NO];
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
    
    for (JBFile *otherFile in self.items) {
        if (![otherFile isEqual:file]) {
            otherFile.selected = NO;
        }
    }

    [tableView reloadData];
    [_nextButton setEnabled:file.selected];
}

@end
