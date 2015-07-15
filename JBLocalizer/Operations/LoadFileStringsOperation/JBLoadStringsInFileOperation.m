//
//  JBLoadFileStringsOperation.m
//  JBLocalizer
//
//  Created by Josip Bernat on 7/9/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBLoadStringsInFileOperation.h"
#import "JBString.h"
#import "JBFile.h"

@interface JBLoadStringsInFileOperation ()

@property (strong, nonatomic) JBFile *file;
@property (nonatomic, copy) void(^completionHandler)(NSArray * __nullable, NSError * __nullable);

@end

@implementation JBLoadStringsInFileOperation

#pragma mark - Initialization

+ (nonnull instancetype)file:(JBFile * __nonnull)file
                  completion:( void(^ __nullable )(NSArray * __nullable, NSError * __nullable))completion {

    NSParameterAssert(file);
    
    JBLoadStringsInFileOperation *operation = [[self alloc] init];
    operation.file = file;
    operation.completionHandler = completion;
    
    return operation;
}

#pragma mark - Execution

- (void)execute {
    
    if ([self isCancelled]) {
        return;
    }
    
    @autoreleasepool {
    
        NSError *fileOpenError = nil;
        NSString *fileContent = [[NSString alloc] initWithContentsOfFile:self.file.path
                                                                encoding:NSUTF8StringEncoding
                                                                   error:&fileOpenError];
        if (fileOpenError || !fileContent) {
            if (self.completionHandler) {
                self.completionHandler(nil, fileOpenError);
            }
            return;
        }

        NSMutableSet *stringsSet = [[NSMutableSet alloc] init];
        
        NSError *regexError = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(NSLocalizedString\\(.*?\\))"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&regexError];
        
        BOOL isObjC = [[self.file.path lastPathComponent] hasSuffix:@".m"];
        BOOL isSwift = [[self.file.path lastPathComponent] hasSuffix:@".swift"];
        NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
        
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
                                     
                                     NSString *localizableString = nil;
                                     NSString *comment = nil;
                                     NSUInteger count = componentes.count;
                                     
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
                                             
                                             if ([stringValue hasPrefix:@"comment:"]) {
                                                 stringValue = [stringValue stringByReplacingOccurrencesOfString:@"comment:" withString:@""];
                                             }
                                             else if ([stringValue hasPrefix:@" comment:"]) {
                                                 stringValue = [stringValue stringByReplacingOccurrencesOfString:@" comment:" withString:@""];
                                             }
                                         }
                                         
                                         if ([stringValue hasSuffix:@"\""]) {
                                             stringValue = [stringValue stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                         }
                                         
                                         
                                         NSString *trimmedString = [stringValue stringByTrimmingCharactersInSet:whitespaceSet];
                                         if ([trimmedString isEqualToString:@""]) {
                                             stringValue = nil;
                                         }
                                         
                                         if (stringValue.length && isValidString) {
                                             
                                             if (index == 0) {
                                                 localizableString = stringValue;
                                             }
                                             else if (index == count - 1) {
                                                 comment = stringValue;
                                             }
                                         }
                                         index++;
                                     }
                                     
                                     if (localizableString) {
                                         if ([localizableString isEqualToString:@"Block list"]) {
                                             NSLog(@"Stop1");
                                         }
                                         [stringsSet addObject:[JBString stringWithString:localizableString comment:comment file:self.file]];
                                     }
                                 }
        }];
        
        if (self.completionHandler) {
            self.completionHandler([stringsSet allObjects], nil);
        }
    }
}

@end
