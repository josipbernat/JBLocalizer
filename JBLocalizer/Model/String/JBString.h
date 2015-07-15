//
//  JBString.h
//  JBLocalizer
//
//  Created by Josip Bernat on 7/15/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JBFile;

@interface JBString : NSObject <NSCopying>

@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSMutableSet *files;

#pragma mark - Initialization
/**
 *  Creates new instance of JBString.
 *
 *  @param string  String which it actually represents. Must not be nil.
 *  @param comment Comment which engineer lefted.
 *  @param file    File to which string belongs.
 *
 *  @return Instance of JBString.
 */
+ (instancetype)stringWithString:(NSString *)string comment:(NSString *)comment file:(JBFile *)file;

@end
