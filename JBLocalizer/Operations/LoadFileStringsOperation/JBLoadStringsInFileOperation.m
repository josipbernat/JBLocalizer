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
@property (readwrite, nonatomic) BOOL includeComments;
@property (nonatomic, copy) void(^completionHandler)(NSArray * __nullable, NSError * __nullable);

@end

@implementation JBLoadStringsInFileOperation

#pragma mark - Initialization

+ (nonnull instancetype)file:(JBFile * __nonnull)file
             includeComments:(BOOL)includeComments
                  completion:( void(^ __nullable )(NSArray * __nullable, NSError * __nullable))completion {

    NSParameterAssert(file);
    
    JBLoadStringsInFileOperation *operation = [[self alloc] init];
    operation.file = file;
    operation.includeComments = includeComments;
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
        BOOL includeComments = self.includeComments;
        NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
        
        __weak id this = self;
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
                                     __strong typeof(self) strongThis = this;
                                     JBString *stringValue = [strongThis __processComponents:componentes
                                                                                        objC:isObjC
                                                                                       swift:isSwift
                                                                                    comments:includeComments
                                                                                excludingSet:whitespaceSet];
                                     
                                     if (stringValue) {
                                         [stringsSet addObject:stringValue];
                                     }
                                 }
        }];
        
        if (self.completionHandler) {
            self.completionHandler([stringsSet allObjects], nil);
        }
    }
}

- (JBString *)__processComponents:(NSArray *)components
                             objC:(BOOL)isObjC
                            swift:(BOOL)isSwift
                         comments:(BOOL)comments
                     excludingSet:(NSCharacterSet *)set {

    __block BOOL isValidString = YES;
    __block NSString *localizableString = nil;
    __block NSString *comment = nil;
    __block NSUInteger count = components.count;
    
    [components enumerateObjectsUsingBlock:^(NSString *component, NSUInteger idx, BOOL *stop) {
        NSAssert([component isKindOfClass:[NSString class]], @"Obj must be NSString");
        
        if (idx && !comments) {
            *stop = YES;
        }
        
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
        
        
        NSString *trimmedString = [stringValue stringByTrimmingCharactersInSet:set];
        if ([trimmedString isEqualToString:@""]) {
            stringValue = nil;
        }
        
        if (stringValue.length && isValidString) {
            
            if (idx == 0) {
                localizableString = stringValue;
            }
            else if (idx == count - 1 && comments) {
                comment = stringValue;
            }
        }
    }];
    
    
    if (localizableString) {
        return [JBString stringWithString:localizableString comment:comment file:self.file];
    }
    return nil;
}

@end
