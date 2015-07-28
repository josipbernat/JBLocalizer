//
//  JBFileController.m
//  JBLocalizer
//
//  Created by Josip Bernat on 6/12/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBFileController.h"
#import "XcodeEditor/XcodeEditor.h"
#import "JBLoadSourceFilesOperation.h"
#import "JBLoadStringsInFileOperation.h"
#import "JBPostProcessStringsOperation.h"
#import "JBLoadRootFilesOperation.h"
#import "JBFindProjectFileOperation.h"
#import "JBString.h"

@interface JBFileController ()

@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation JBFileController

#pragma mark - Shared Instance

+ (instancetype)sharedController {
    
    static JBFileController *controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[self alloc] init];
    });
    return controller;
}

#pragma mark - Initialization

- (instancetype)init {

    if (self = [super init]) {
        
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

#pragma mark - Canceling

- (void)reset {
    [self.queue cancelAllOperations];
}

#pragma Project Directory

- (void)loadPossibleProjectFilesInPath:(NSString * __nonnull)path
                            completion:(void(^ __nullable )(NSArray * __nullable, NSError * __nullable))completion {
    NSParameterAssert(path);
    
    JBFindProjectFileOperation *operation = [JBFindProjectFileOperation findProjectFile:path
                                                                             completion:completion];
    [self.queue addOperation:operation];
}

#pragma mark - Project

- (BOOL)projectExistsAtPath:(NSString * __nonnull)path {

    XCProject *project = [XCProject projectWithFilePath:path];
    if (!project) {
        return NO;
    }
    return YES;
}

- (nullable NSArray *)targetNamesInProjectAtPath:(NSString * __nonnull)projectPath {

    XCProject *project = [XCProject projectWithFilePath:projectPath];
    if (!project) {
        return nil;
    }
    
    NSMutableArray *items = [NSMutableArray array];
    for (XCTarget *target in project.targets) {
        [items addObject:[target.name lowercaseString]];
    }
    return items;
}

- (void)loadProjectRootFiles:(NSString * __nonnull)projectPath
                  completion:(void(^ __nullable )(NSArray * __nullable, NSError * __nullable))completion {
    NSParameterAssert(projectPath);
    
    JBLoadRootFilesOperation *operation = [JBLoadRootFilesOperation loadRootDirectories:projectPath
                                                                             completion:completion];
    [self.queue addOperation:operation];

}

- (void)loadProjectFiles:(NSString * __nonnull)projectPath
       filterDirectories:(NSArray * __nullable)filter
              completion:(void(^ __nullable )(NSDictionary * __nullable, NSError * __nullable))completion {
    NSParameterAssert(projectPath);
    
    XCProject *project = [XCProject projectWithFilePath:projectPath];

    JBLoadSourceFilesOperation *operation = [JBLoadSourceFilesOperation loadProjectSourceFiles:project
                                                                             filterDirectories:filter
                                                                                    completion:completion];
    
    [self.queue addOperation:operation];
}

#pragma mark - File Content

- (void)loadLocalizableStringsInFiles:(NSArray * __nonnull)files
                           formatting:(JBStringFormattingType)formatting
                           completion:(void(^ __nullable )(NSArray * __nullable, NSError * __nullable))completion {

    NSParameterAssert(files);
    
    __block NSMutableDictionary *resultArray = [[NSMutableDictionary alloc] init];
    __block NSInteger counter = 0;
    __block NSInteger count = files.count;
    __block NSError *anError = nil;
    
    if (!files.count) {
        if (completion) {
            completion([NSArray array], nil);
        }
        return;
    }
    
    for (JBFile *file in files) {
        
        void (^handler)(NSArray *, NSError *) = ^(NSArray *strings, NSError *error) {
        
            counter++;
            if (strings && strings.count) {
                
                for (JBString *string in strings) {
                    NSAssert([string isKindOfClass:[JBString class]], @"String must be JBString");
                    
                    JBString *savedString = resultArray[string];
                    if (savedString) {
                        [savedString.files addObjectsFromArray:[string.files allObjects]];
                    }
                    else {
                        resultArray[string] = string;
                    }
                }
            }
            else if (error && !anError) {
                anError = error;
            }
            
            if (counter == count) {
                
                if (completion) {
                    completion(resultArray.allValues, anError);
                }
            }
        };
        
        JBLoadStringsInFileOperation *operation = [JBLoadStringsInFileOperation file:file
                                                                     includeComments:(formatting == JBStringFormattingTypeDefault)
                                                                          completion:handler];
        [self.queue addOperation:operation];
    }
}

- (void)loadAndProcessLocalizableStringsInFiles:(NSArray * __nonnull)files
                                     formatting:(JBStringFormattingType)formatting
                                     completion:(void(^ __nullable )(NSString * __nullable, NSError * __nullable))completion {
    
    __weak id this = self;
    [self loadLocalizableStringsInFiles:files
                             formatting:formatting
                             completion:^(NSArray * strings, NSError * error) {
                                 
                                 if (error) {
                                     if (completion) {
                                         completion(nil, error);
                                     }
                                     return;
                                 }
                                 
                                 if (!strings.count) {
                                     
                                     if (completion) {
                                         completion(@"", nil);
                                     }
                                     return;
                                 }
                                 
                                 __strong typeof(self) strongThis = this;
                                 JBPostProcessStringsOperation *operation = [JBPostProcessStringsOperation processStrings:strings
                                                                                                               formatting:formatting
                                                                                                               completion:^(NSString *result) {
                                                                                                                   
                                                                                                                   if (completion) {
                                                                                                                       completion(result, nil);
                                                                                                                   }
                                                                                                               }];
                                 [strongThis.queue addOperation:operation];
                             }];
}

@end
