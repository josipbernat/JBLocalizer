//
//  JBPostProcessStringsOperation.m
//  JBLocalizer
//
//  Created by Josip Bernat on 7/9/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBPostProcessStringsOperation.h"
#import "JBString.h"
#import "JBFile.h"

@interface JBPostProcessStringsOperation ()

@property (strong, nonatomic) NSArray *strings;
@property (readwrite, nonatomic) JBStringFormattingType formatting;
@property (nonatomic, copy) void(^completionHandler)(NSString * __nullable);

@end

@implementation JBPostProcessStringsOperation

#pragma mark - Initialization

+ (nonnull instancetype)processStrings:(NSArray * __nonnull)strings
                            formatting:(JBStringFormattingType)type
                            completion:( void(^ __nullable )(NSString * __nullable))completion {
    
    NSParameterAssert(strings);
    
    JBPostProcessStringsOperation *operation = [[self alloc] init];
    operation.strings = strings;
    operation.formatting = type;
    operation.completionHandler = completion;
    
    return operation;
}

#pragma mark - Execution

static NSString *kKeyShared = @"Shared";
#define kFileCommentFormat(__NAME__) [NSString stringWithFormat:@"/**\n * %@\n */", (__NAME__)]
#define kKeyValueFormatWithoutComment(__KEY__) [NSString stringWithFormat:@"\"%@\" = \"%@\";", (__KEY__), (__KEY__)]
#define kKeyValueFormatComment(__COMMENT__, __KEY__) [NSString stringWithFormat:@"// %@\n\"%@\" = \"%@\";", (__COMMENT__), (__KEY__), (__KEY__)]

- (void)execute {
    
    if ([self isCancelled]) {
        return;
    }
    
    @autoreleasepool {

        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        JBFile *sharedFile = [JBFile fileWithName:kKeyShared path:kKeyShared directory:NO];
        result[sharedFile] = [[NSMutableArray alloc] init];
        
        [self.strings enumerateObjectsUsingBlock:^(JBString *string, NSUInteger idx, BOOL *stop) {
            
            if ([string.string isEqualToString:@"Back"]) {
                NSLog(@"Stop");
            }
            
            if (string.files.count > 1) {
                NSMutableArray *mutArray = result[sharedFile];
                [mutArray addObject:string];
            }
            else if (string.files.count == 1) {
                
                JBFile *key = [string.files anyObject];
                NSMutableSet *set = result[key];
                if (!set) {
                    set = [[NSMutableSet alloc] init];
                    result[key] = set;
                }
                [set addObject:string];
            }
            else {
                NSAssert(NO, @"String doesn't belong to any file!");
            }
        }];
        
        NSMutableDictionary *sharedDict = result[kKeyShared];
        if (!sharedDict.count) {
            [result removeObjectForKey:kKeyShared];
        }
        
        BOOL enableComments = (self.formatting == JBStringFormattingTypeDefault ? YES : NO);
        
        NSMutableString *string = [[NSMutableString alloc] init];
        [result enumerateKeysAndObjectsUsingBlock:^(JBFile *key, NSArray *obj, BOOL *stop) {
            NSAssert([key isKindOfClass:[JBFile class]], @"key must be JBFile class");
            
            [string appendString:kFileCommentFormat(key.name)];
            [obj enumerateObjectsUsingBlock:^(JBString *value, NSUInteger idx, BOOL *stop) {
                NSAssert([value isKindOfClass:[JBString class]], @"value must be JBString class");
                
                [string appendString:@"\n"];
                if (enableComments && value.comment && value.comment.length) {
                    [string appendString:kKeyValueFormatComment(value.comment, value.string)];
                }
                else {
                    [string appendString:kKeyValueFormatWithoutComment(value.string)];
                }
            }];
            [string appendString:@"\n\n"];
        }];
        
        if (self.completionHandler) {
            self.completionHandler(string);
        }
    }
}

@end
