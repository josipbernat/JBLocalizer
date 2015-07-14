//
//  JBPostProcessStringsOperation.m
//  JBLocalizer
//
//  Created by Josip Bernat on 7/9/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBPostProcessStringsOperation.h"

@interface JBPostProcessStringsOperation ()

@property (strong, nonatomic) NSDictionary *strings;
@property (nonatomic, copy) void(^completionHandler)(NSString * __nullable);

@end

@implementation JBPostProcessStringsOperation

#pragma mark - Initialization
/**
 *  Postprocess given strings for printing suitable format.
 *
 *  @param strings    NSDictionary containing strings. String must be key and value must be an array of files who contains given word.
 *  @param completion Callback block object called once operation finishes with execution. It has one parameter, a string suitable for writing strings in file.
 *
 *  @return Newly created instance.
 */
+ (nonnull instancetype)processStrings:(NSDictionary * __nonnull)strings
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
    
    @autoreleasepool {

        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        result[kKeyShared] = [[NSMutableArray alloc] init];
        
        [self.strings enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *obj, BOOL *stop) {
            
            if (obj.count > 1) {
                NSMutableArray *mutArray = result[kKeyShared];
                [mutArray addObject:key];
            }
            else if (obj.count == 1) {
                NSMutableArray *array = result[[obj firstObject]];
                if (!array) {
                    array = [[NSMutableArray alloc] init];
                    result[[obj firstObject]] = array;
                }
                [array addObject:key];
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
        [result enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *obj, BOOL *stop) {
            
            // Continue here...
            [string appendString:kFileCommentFormat(key)];
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
