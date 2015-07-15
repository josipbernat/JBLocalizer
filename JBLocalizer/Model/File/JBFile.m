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

#pragma mark - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"Name: %@, directory: %@, path: %@", _name, _directory ? @"Yes" : @"No", _path];
}

#pragma mark - Comparison

- (BOOL)isEqual:(id)object {
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    JBFile *anObject = object;
    return ([_name isEqualToString:[anObject name]] &&
            [_path isEqualToString:[anObject path]] &&
            _directory == [anObject directory]);
}

- (NSUInteger)hash {
    return [_name hash] ^ [_path hash];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {

    JBFile *file = [[[self class] alloc] init];
    file.name = [self.name copyWithZone:zone];
    file.path = [self.path copyWithZone:zone];
    file.directory = self.directory;
    
    return file;
}

@end
