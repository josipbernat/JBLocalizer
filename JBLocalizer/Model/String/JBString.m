//
//  JBString.m
//  JBLocalizer
//
//  Created by Josip Bernat on 7/15/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBString.h"

@implementation JBString

#pragma mark - Initialization

+ (instancetype)stringWithString:(NSString *)string comment:(NSString *)comment file:(JBFile *)file {

    NSParameterAssert(string);
    
    JBString *instance = [[self alloc] init];
    instance.string = string;
    instance.comment = (comment && comment.length ? comment : nil);
    instance.files = [[NSMutableSet alloc] init];
    if (file) {
        [instance.files addObject:file];
    }
    
    return instance;
}

- (instancetype)init {

    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - Comparison

- (BOOL)isEqual:(id)object {
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    if (_comment || [object comment]) {
        return ([_string isEqualToString:[object string]] && [_comment isEqualToString:[object comment]]);
    }
    else {
        return ([_string isEqualToString:[object string]]);
    }
}

- (NSUInteger)hash {
    return [_string hash] ^ [_comment hash];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    
    JBString *string = [[[self class] alloc] init];
    string.string = [self.string copyWithZone:zone];
    string.comment = [self.comment copyWithZone:zone];
    string.files = [self.files copyWithZone:zone];
    
    return string;
}

@end
