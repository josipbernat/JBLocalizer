//
//  JBLoadFileStringsOperation.m
//  JBLocalizer
//
//  Created by Josip Bernat on 7/9/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBLoadFileStringsOperation.h"

@interface JBLoadFileStringsOperation ()

@property (strong, nonatomic) NSString *filePath;
@property (nonatomic, copy) void(^completionHandler)(NSArray * __nullable, NSError * __nullable);

@end

@implementation JBLoadFileStringsOperation

#pragma mark - Initialization

+ (nonnull instancetype)loadStringsInFile:(NSString * __nonnull)file
                               completion:( void(^ __nullable )(NSArray * __nullable, NSError * __nullable))completion {

    NSParameterAssert(file);
    
    JBLoadFileStringsOperation *operation = [[self alloc] init];
    operation.filePath = file;
    operation.completionHandler = completion;
    
    return operation;
}

#pragma mark - Execution

- (void)execute {
    
    @autoreleasepool {
    
        NSError *fileOpenError = nil;
        NSString *fileContent = [[NSString alloc] initWithContentsOfFile:self.filePath
                                                                encoding:NSUTF8StringEncoding
                                                                   error:&fileOpenError];
        
        if (fileOpenError) {
            if (self.completionHandler) {
                self.completionHandler(nil, fileOpenError);
            }
            return;
        }
        
        if ([self.filePath containsString:@"CSAlertViewController"]) {
            NSLog(@"Stop");
        }
        
        NSMutableArray *strings = [[NSMutableArray alloc] init];
        [fileContent enumerateSubstringsInRange:NSMakeRange(0, fileContent.length)
                                        options:NSStringEnumerationByLines
                                     usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                         
                                         if ([substring containsString:@"NSLocalizedString("]) {
                                             [strings addObject:substring];
                                         }
                                     }];
        
        if (self.completionHandler) {
            self.completionHandler(strings, nil);
        }
    }
}

@end
