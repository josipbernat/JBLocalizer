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
#import "JBLoadFileStringsOperation.h"
#import "JBPostProcessStringsOperation.h"
#import "JBLoadRootFilesOperation.h"
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

#pragma mark - Project

- (void)loadProjectRootFiles:(NSString * __nonnull)projectPath
                  completion:(void(^ __nullable )(NSArray * __nullable, NSError * __nullable))completion {
    NSParameterAssert(projectPath);
    
    JBLoadRootFilesOperation *operation = [JBLoadRootFilesOperation loadRootDirectories:projectPath
                                                                             completion:completion];
    [self.queue addOperation:operation];

}

- (void)loadProjectFiles:(NSString * __nonnull)projectPath
       filterDirectories:(NSArray * __nonnull)filter
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
                           completion:(void(^ __nullable )(NSArray * __nullable, NSError * __nullable))completion {

    NSParameterAssert(files);
    
    __block NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    __block NSInteger counter = 0;
    __block NSInteger count = files.count;
    __block NSError *anError = nil;
    
    for (JBFile *file in files) {
        
        void (^handler)(NSArray *, NSError *) = ^(NSArray *strings, NSError *error) {
        
            counter++;
            if (strings && strings.count) {
                
                for (JBString *string in strings) {
                    NSAssert([string isKindOfClass:[JBString class]], @"String must be JBString");
                    
                    NSUInteger index = [resultArray indexOfObject:string];
                    if (index != NSNotFound) {
                        JBString *savedString = resultArray[index];
                        [savedString.files addObjectsFromArray:[string.files allObjects]];
                    }
                    else {
                        [resultArray addObject:string];
                    }
                }
            }
            else if (error && !anError) {
                anError = error;
            }
            
            if (counter == count) {
                
                if (completion) {
                    completion(resultArray, anError);
                }
            }
        };
        
        JBLoadFileStringsOperation *operation = [JBLoadFileStringsOperation loadStringsInFile:file
                                                                                   completion:handler];
        [self.queue addOperation:operation];
    }
}

- (void)loadAndProcessLocalizableStringsInFiles:(NSArray * __nonnull)files
                                     completion:(void(^ __nullable )(NSString * __nullable, NSError * __nullable))completion {
    
    __weak id this = self;
    [self loadLocalizableStringsInFiles:files
                             completion:^(NSArray * strings, NSError * error) {
                                 
                                 if (error) {
                                     if (completion) {
                                         completion(nil, error);
                                     }
                                     return;
                                 }
                                 
                                 __strong typeof(self) strongThis = this;
                                 JBPostProcessStringsOperation *operation = [JBPostProcessStringsOperation processStrings:strings
                                                                                                               completion:^(NSString *result) {
                                                                                                                   
                                                                                                                   if (completion) {
                                                                                                                       completion(result, nil);
                                                                                                                   }
                                                                                                               }];
                                 [strongThis.queue addOperation:operation];
                             }];
}

@end
