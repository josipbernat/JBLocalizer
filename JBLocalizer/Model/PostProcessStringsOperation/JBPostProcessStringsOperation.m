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

static NSString *shared = @"Shared";

- (void)execute {
    
    @autoreleasepool {

        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        result[shared] = [[NSMutableArray alloc] init];
        
        [self.strings enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *obj, BOOL *stop) {
            
            if (obj.count > 1) {
                result[shared] = key;
            }
            else if (obj.count == 1) {
                result[[obj firstObject]] = key;
            }
            else {
                NSAssert(NO, @"String doesn't belong to any file!");
            }
        }];
        
        NSMutableString *string = [[NSMutableString alloc] init];
        [result enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            // Continue here...
        }];
    }
}

@end