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
        if (fileOpenError || !fileContent) {
            if (self.completionHandler) {
                self.completionHandler(nil, fileOpenError);
            }
            return;
        }

        NSMutableArray *strings = [[NSMutableArray alloc] init];
        
        NSError *regexError = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(NSLocalizedString\\(.*?\\))"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&regexError];
        
        BOOL isObjC = [[self.filePath lastPathComponent] hasSuffix:@".m"];
        BOOL isSwift = [[self.filePath lastPathComponent] hasSuffix:@".swift"];
        
        [regex enumerateMatchesInString:fileContent
                                options:0
                                  range:NSMakeRange(0, fileContent.length)
                             usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){

                                 if (match.numberOfRanges) {

                                     NSString *value = [fileContent substringWithRange:[match rangeAtIndex:1]];
                                     
                                     if ([value hasPrefix:@"NSLocalizedString("]) {
                                         value = [value stringByReplacingOccurrencesOfString:@"NSLocalizedString(" withString:@""];
                                     }
                                     if ([value hasSuffix:@")"]) {
                                         value = [value stringByReplacingOccurrencesOfString:@")" withString:@""];
                                     }
                                     
                                     NSArray *componentes = [value componentsSeparatedByString:@","];
                                     NSUInteger index = 0;
                                     BOOL isValidString = YES;
                                     
                                     for (NSString *component in componentes) {
                                         
                                         NSString *stringValue = component;
                                         
                                         if (isObjC) {
                                             if ([stringValue hasPrefix:@"@\""]) {
                                                 stringValue = [stringValue stringByReplacingOccurrencesOfString:@"@\"" withString:@""];
                                             }
                                             else if ([stringValue hasPrefix:@" @\""]) {
                                                 stringValue = [stringValue stringByReplacingOccurrencesOfString:@" @\"" withString:@""];
                                             }
                                             else {
                                                 isValidString = NO;
                                             }
                                         }
                                         else if (isSwift) {
                                         
                                             if ([stringValue hasPrefix:@"\""]) {
                                                 stringValue = [stringValue stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                             }
                                             else if ([stringValue hasPrefix:@" \""]) {
                                                 stringValue = [stringValue stringByReplacingOccurrencesOfString:@" \"" withString:@""];
                                             }
                                         }
                                         
                                         if ([stringValue hasSuffix:@"\""]) {
                                             stringValue = [stringValue stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                         }
                                         
                                         if (stringValue.length && isValidString) {
                                             
                                             if (index == 0) {
                                                 [strings addObject:stringValue];
                                             }
                                             else if (index == 1) {
                                                 // Maybe add table or comment?
                                             }
                                         }
                                         index++;
                                     }
                                 }
        }];
        
        if (self.completionHandler) {
            self.completionHandler(strings, nil);
        }
    }
}

@end
