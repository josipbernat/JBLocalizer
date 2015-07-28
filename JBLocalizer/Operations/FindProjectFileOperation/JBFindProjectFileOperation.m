//
//  JBFindProjectFileOperation.m
//  JBLocalizer
//
//  Created by Josip Bernat on 7/28/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBFindProjectFileOperation.h"
#import <XcodeEditor/XCProject.h>
#import "JBFile.h"

NSString * const kProjectExtension  = @".xcodeproj";

@interface JBFindProjectFileOperation ()

@property (strong, nonatomic) NSString *directory;
@property (nonatomic, copy) void(^completionHandler)(NSArray * __nullable, NSError * __nullable);

@end

@implementation JBFindProjectFileOperation

#pragma mark - Initialization

+ (nonnull instancetype)findProjectFile:(NSString  * __nonnull )directory
                             completion:( void(^ __nullable )(NSArray * __nullable, NSError * __nullable))completion {

    JBFindProjectFileOperation *operation = [[self alloc] init];
    operation.directory = directory;
    operation.completionHandler = completion;
    
    return operation;
}

#pragma mark - Execution

- (void)execute {
    
    if ([self isCancelled]) {
        return;
    }
    
    @autoreleasepool {
    
        NSError *error = nil;
        NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.directory]
                                                         includingPropertiesForKeys:[NSArray array]
                                                                            options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                              error:&error];
        
        if (error) {
            if (self.completionHandler) {
                self.completionHandler(nil, error);
            }
            return;
        }
        
        NSMutableArray *items = [NSMutableArray array];

        for (NSURL *fileURL in content) {
            
            NSString *item = [fileURL path];
            if ([item hasSuffix:kProjectExtension]) {
             
                XCProject *project = [XCProject projectWithFilePath:item];
                if (project) {
                    [items addObject:[JBFile fileWithName:[item lastPathComponent]
                                                     path:project.filePath
                                                directory:NO]];
                }
            }
        }
        
        if (self.completionHandler) {
            self.completionHandler(items, nil);
        }

    }
}

@end
