//
//  JBLoadSourceFilesOperation.m
//  JBLocalizer
//
//  Created by Josip Bernat on 6/23/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBLoadSourceFilesOperation.h"
#import "XcodeEditor/XcodeEditor.h"
#import <XcodeEditor/XCProject.h>
#import "JBLoadRootFilesOperation.h"

@interface JBLoadSourceFilesOperation ()

@property (nonatomic, strong) XCProject *project;
@property (nonatomic, strong) NSString *root;
@property (nonatomic, copy) void(^completionHandler)(NSDictionary * __nullable, NSError * __nullable);

@end

@implementation JBLoadSourceFilesOperation

#pragma mark - Initialization

+ (nonnull instancetype)loadProjectSourceFiles:(XCProject  * __nonnull )project
                                 rootDirectory:(NSString * __nullable)root
                                    completion:( void(^ __nullable )(NSDictionary * __nullable, NSError * __nullable))completion {

    JBLoadSourceFilesOperation *operation = [[self alloc] init];
    operation.project = project;
    operation.root = root;
    operation.completionHandler = completion;
    
    return operation;
}

#pragma mark - Execution

- (void)execute {

    @autoreleasepool {
        
        NSString *projectFolder = [self.project.filePath stringByDeletingLastPathComponent];
        NSMutableDictionary *result = nil;
        
        if (self.root) {
            
            NSError *error = nil;
            NSString *targetDirectory = [projectFolder stringByAppendingPathComponent:self.root];
            
            NSArray *items = [self sourceFilesInDirectory:targetDirectory error:&error];
            
            if (items) {
                
                result = [[NSMutableDictionary alloc] init];
                result[self.root] = items;
            }
            
            if (self.completionHandler) {
                self.completionHandler(result, error);
            }
        }
        else {
            
            result = [[NSMutableDictionary alloc] init];
            
            NSError *error = nil;
            NSArray *rootContent = [JBLoadRootFilesOperation rootDirectoriesInPath:projectFolder error:&error];
            
            if (error) {
                if (self.completionHandler) {
                    self.completionHandler(nil, error);
                }
                return;
            }
            
            NSString *targetDirectory = nil;
            for (NSString *item in rootContent) {
                
                targetDirectory = [projectFolder stringByAppendingPathComponent:item];
                
                NSArray *items = [self sourceFilesInDirectory:targetDirectory error:&error];
                
                if (items) {
                    result[item] = items;
                }
                else if (error) {
                    if (self.completionHandler) {
                        self.completionHandler(nil, error);
                    }
                    return;
                }
            }
            
            if (self.completionHandler) {
                self.completionHandler(result, error);
            }
        }
    }
}

- (NSArray *)sourceFilesInDirectory:(NSString *)path error:(NSError * __autoreleasing *)error {
    
    NSMutableArray *array = [NSMutableArray array];
    NSError *anError = nil;
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&anError];
    
    if (anError) {
//        error = &anError;
        return nil;
    }
    
    for (NSString *file in directoryContent) {
        BOOL isDirectory = NO;
        NSString *filePath = [path stringByAppendingPathComponent:file];
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        if (exists) {
            if (isDirectory) {
                NSError *error2 = nil;
                NSArray *directoryArray = [self sourceFilesInDirectory:filePath error:&error2];
                if (error2) {
                    return nil;
                }
                
                if (directoryArray && directoryArray.count) {
                    [array addObjectsFromArray:directoryArray];
                }
            }
            else {
                if ([[file pathExtension] isEqualToString:@"m"] || [[file pathExtension] isEqualToString:@"mm"] ||
                    [[file pathExtension] isEqualToString:@"swift"]) {
                    
                    [array addObject:filePath];
                }
            }
        }
    }
    
    return array;
}


@end
