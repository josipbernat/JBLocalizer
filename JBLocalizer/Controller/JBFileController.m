//
//  JBFileController.m
//  JBLocalizer
//
//  Created by Josip Bernat on 6/12/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBFileController.h"
#import "JBLoadSourceFilesOperation.h"
//#import "XcodeEditor/XcodeEditor.h"

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

- (void)loadProjectFiles:(NSString *)projectPath {
    NSParameterAssert(projectPath);
    
    XCProject *project = [XCProject projectWithFilePath:projectPath];

    JBLoadSourceFilesOperation *operation = [JBLoadSourceFilesOperation loadProjectSourceFiles:project
                                                                                 rootDirectory:@"SpikaEnterprise"
                                                                                    completion:^(NSDictionary * result, NSError * error) {
                                                                                        
                                                                                        NSLog(@"Result: %@", result);
                                                                                        NSLog(@"Error: %@", error);
                                                                                    }];
    
    [self.queue addOperation:operation];
}

@end
