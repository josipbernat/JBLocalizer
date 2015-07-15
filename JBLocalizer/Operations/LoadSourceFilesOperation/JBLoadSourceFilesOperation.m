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
#import "JBFile.h"

@interface JBLoadSourceFilesOperation ()

@property (nonatomic, strong) XCProject *project;
@property (nonatomic, strong) NSArray *filter;
@property (nonatomic, copy) void(^completionHandler)(NSDictionary * __nullable, NSError * __nullable);

@end

@implementation JBLoadSourceFilesOperation

#pragma mark - Initialization

+ (nonnull instancetype)loadProjectSourceFiles:(XCProject  * __nonnull )project
                             filterDirectories:(NSArray *)filter
                                    completion:( void(^ __nullable )(NSDictionary * __nullable, NSError * __nullable))completion {

    JBLoadSourceFilesOperation *operation = [[self alloc] init];
    operation.project = project;
    operation.filter = filter;
    operation.completionHandler = completion;
    
    return operation;
}

#pragma mark - Execution

- (void)execute {
    
    if ([self isCancelled]) {
        return;
    }

    @autoreleasepool {

        if (self.filter && self.filter.count) {
            
            __block NSError *error = nil;
            __block NSMutableDictionary *allItems = [[NSMutableDictionary alloc] init];
            
            [self.filter enumerateObjectsUsingBlock:^(JBFile *obj, NSUInteger idx, BOOL *stop) {
                NSAssert([obj isKindOfClass:[JBFile class]], @"obj must be JBFile class");
                NSAssert(obj.directory, @"Given file must be directory");
                
                NSArray *items = [self sourceFilesInDirectory:obj.path error:&error];
                if (error) {
                    *stop = YES;
                    
                    if (self.completionHandler) {
                        self.completionHandler(nil, error);
                    }
                }
                if (items) {
                    allItems[obj] = items;
                }
                else {
                    allItems[obj] = [NSArray array];
                }
            }];
            
            if (self.completionHandler) {
                self.completionHandler(allItems, error);
            }
        }
        else {
            
            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
            NSString *projectFolder = [self.project.filePath stringByDeletingLastPathComponent];
            
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
                NSString *pathExtension = [file pathExtension];
                if ([pathExtension isEqualToString:@"m"] || [pathExtension isEqualToString:@"mm"] ||
                    [pathExtension isEqualToString:@"swift"]) {
                    
                    JBFile *aFile = [JBFile fileWithName:[file lastPathComponent]
                                                    path:[path stringByAppendingPathComponent:file]
                                               directory:NO];
                    [array addObject:aFile];
                }
            }
        }
    }
    
    return array;
}


@end
