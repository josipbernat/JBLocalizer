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

#pragma mark - Project

- (void)loadProjectFiles:(NSString *)projectPath
              completion:(void(^ __nullable )(NSDictionary * __nullable, NSError * __nullable))completion {
    NSParameterAssert(projectPath);
    
    XCProject *project = [XCProject projectWithFilePath:projectPath];

    JBLoadSourceFilesOperation *operation = [JBLoadSourceFilesOperation loadProjectSourceFiles:project
                                                                                 rootDirectory:@"SpikaEnterprise"
                                                                                    completion:^(NSDictionary * result, NSError * error) {
                                                                                        
                                                                                        if (completion) {
                                                                                            completion(result, error);
                                                                                        }
                                                                                    }];
    
    [self.queue addOperation:operation];
}

#pragma mark - File Content

- (void)loadLocalizableStringsInFiles:(NSArray * __nonnull)files
                           completion:(void(^ __nullable )(NSDictionary * __nullable, NSError * __nullable))completion {

    NSParameterAssert(files);
    
    __block NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    __block NSInteger counter = 0;
    __block NSInteger count = files.count;
    __block NSError *anError = nil;
    
    for (NSString *file in files) {
        
        void (^handler)(NSArray *, NSError *) = ^(NSArray *strings, NSError *error){
        
            counter++;
            if (strings && strings.count) {
                
                NSString *fileName = [file lastPathComponent];
                for (NSString *string in strings) {
                    
                    if (dict[string]) {
                        NSMutableArray *array = dict[string];
                        [array addObject:fileName];
                    }
                    else {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObject:fileName];
                        dict[string] = array;
                    }
                }
            }
            else if (error && !anError) {
                anError = error;
            }
            
            if (counter == count) {
                
                if (completion) {
                    completion(dict, anError);
                }
            }
        };
        
        JBLoadFileStringsOperation *operation = [JBLoadFileStringsOperation loadStringsInFile:file
                                                                                   completion:handler];
        [self.queue addOperation:operation];
    }
}

@end
