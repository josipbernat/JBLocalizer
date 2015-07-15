//
//  JBFile.h
//  JBLocalizer
//
//  Created by Josip Bernat on 7/13/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JBFile : NSObject <NSCopying>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, readwrite) BOOL directory;
@property (nonatomic, readwrite) BOOL selected;

#pragma mark - Initialization
/**
 *  Creates new instance of JBFile.
 *
 *  @param name Name of the file.
 *  @param path Path in file system.
 *  @param directory Boolean value determening wheter file is directory or not.
 *
 *  @return Newly created instance
 */
+ (instancetype)fileWithName:(NSString *)name path:(NSString *)path directory:(BOOL)directory;

@end
