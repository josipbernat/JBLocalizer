//
//  JBFile.m
//  JBLocalizer
//
//  Created by Josip Bernat on 7/13/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBFile.h"

@implementation JBFile

#pragma mark - Initialization

+ (instancetype)fileWithName:(NSString *)name path:(NSString *)path directory:(BOOL)directory {

    JBFile *file = [[self alloc] init];
    file.name = name;
    file.path = path;
    file.directory = directory;
    
    return file;
}

@end
