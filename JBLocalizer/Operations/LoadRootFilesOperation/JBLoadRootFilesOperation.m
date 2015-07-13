//
//  JBLoadRootFilesOperation.m
//  JBLocalizer
//
//  Created by Josip Bernat on 6/23/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBLoadRootFilesOperation.h"
#import <XcodeEditor/XCProject.h>
#import "JBFile.h"

#define kIgnoringNames @[@".DS_Store", @".git", @".gitignore", @".xcassets", @"Podfile", @"Podfile.lock", @"Pods", @".xcodeproj", @".xcworkspace", @" "]

@interface JBLoadRootFilesOperation ()

@property (nonatomic, strong) NSString *projectPath;
@property (nonatomic, copy) void(^completionHandler)(NSArray * __nullable, NSError * __nullable);

@end

@implementation JBLoadRootFilesOperation

#pragma mark - Initialization

+ (nonnull instancetype)loadRootDirectories:(NSString  * __nonnull )projectPath
                                 completion:( void(^ __nullable )(NSArray * __nullable, NSError * __nullable))completion {

    NSParameterAssert(projectPath);
    
    JBLoadRootFilesOperation *operation = [[self alloc] init];
    operation.projectPath = projectPath;
    operation.completionHandler = completion;
    
    return operation;
}

#pragma mark - Execution

- (void)execute {

    NSError *error = nil;
    NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.projectPath error:&error];
    
    if (error) {
        if (self.completionHandler) {
            self.completionHandler(nil, error);
        }
    }
    
    NSMutableArray *items = [NSMutableArray array];
    NSArray *ignoringNames = kIgnoringNames;
    
    for (NSString *item in content) {
        
        BOOL contains = NO;
        for (NSString *ignore in ignoringNames) {
            if ([item containsString:ignore]) {
                contains = YES;
                break;
            }
        }
        if (!contains) {
            [items addObject:[JBFile fileWithName:item
                                             path:[self.projectPath stringByAppendingPathComponent:item]
                                        directory:YES]];
        }
    }

    if (self.completionHandler) {
        self.completionHandler(items, nil);
    }
}

+ (NSArray *)rootDirectoriesInPath:(NSString *)path error:(NSError * __autoreleasing *)error {
    
    NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:error];
    if (error) {
        return nil;
    }
    
    NSMutableArray *items = [NSMutableArray array];
    NSArray *ignoringNames = kIgnoringNames;
    
    for (NSString *item in content) {
        
        BOOL contains = NO;
        for (NSString *ignore in ignoringNames) {
            if ([item containsString:ignore]) {
                contains = YES;
                break;
            }
        }
        if (!contains) {
            [items addObject:item];
        }
    }
    return items;
}

@end
