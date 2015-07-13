//
//  JBOperation.m
//  JBLocalizer
//
//  Created by Josip Bernat on 6/23/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBOperation.h"

@implementation JBOperation {
    
    BOOL _finished;
    BOOL _executing;
    BOOL _canceled;
}

#pragma mark - Initialization

- (id)init {
    
    self = [super init];
    if (self) {
        _canceled = NO;
        _finished = NO;
        _executing = NO;
    }
    return self;
}

#pragma mark - Execution

- (void)execute {
    [self doesNotRecognizeSelector:_cmd];
}

- (void)start {
    
    _executing = YES;
    _finished = NO;
    
    [self execute];
    
    _finished = YES;
    _executing = NO;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isCancelled {
    return _canceled;
}

- (void)cancel {
    _canceled = YES;
}


@end
