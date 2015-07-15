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
@property (nonatomic, copy) void(^completionHandler)(NSString * __nullable);

@end

@implementation JBPostProcessStringsOperation

#pragma mark - Initialization

+ (nonnull instancetype)processStrings:(NSArray * __nonnull)strings
                            completion:( void(^ __nullable )(NSString * __nullable))completion {
    
    NSParameterAssert(strings);
    
    JBPostProcessStringsOperation *operation = [[self alloc] init];
    operation.strings = strings;
    operation.completionHandler = completion;
    
    return operation;
}

#pragma mark - Execution

static NSString *kKeyShared = @"Shared";
#define kFileCommentFormat(__NAME__) [NSString stringWithFormat:@"/**\n * %@\n */", (__NAME__)]
#define kKeyValueFormat(__KEY__) [NSString stringWithFormat:@"\"%@\" = \"%@\";", (__KEY__), (__KEY__)]

- (void)execute {
    
    if ([self isCancelled]) {
        return;
    }
    
    @autoreleasepool {

        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        result[kKeyShared] = [[NSMutableArray alloc] init];
        
        [self.strings enumerateObjectsUsingBlock:^(JBString *string, NSUInteger idx, BOOL *stop) {
        
            if (string.files.count > 1) {
                NSMutableArray *mutArray = result[kKeyShared];
                [mutArray addObject:string.string];
            }
            else if (string.files.count == 1) {
                NSMutableArray *array = result[[string.files anyObject]];
                if (!array) {
                    array = [[NSMutableArray alloc] init];
                    result[[string.files anyObject]] = array;
                }
                [array addObject:string.string];
            }
            else {
                NSAssert(NO, @"String doesn't belong to any file!");
            }
        }];
        
        NSMutableDictionary *sharedDict = result[kKeyShared];
        if (!sharedDict.count) {
            [result removeObjectForKey:kKeyShared];
        }
        
        NSMutableString *string = [[NSMutableString alloc] init];
        [result enumerateKeysAndObjectsUsingBlock:^(JBFile *key, NSArray *obj, BOOL *stop) {
            
            // Continue here...
            [string appendString:kFileCommentFormat(key.name)];
            [obj enumerateObjectsUsingBlock:^(NSString *value, NSUInteger idx, BOOL *stop) {
                [string appendString:@"\n"];
                [string appendString:kKeyValueFormat(value)];
            }];
            [string appendString:@"\n\n"];
        }];
        
        if (self.completionHandler) {
            self.completionHandler(string);
        }
    }
}

@end
