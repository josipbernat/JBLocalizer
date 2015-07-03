//
//  JBLoadRootFilesOperation.m
//  JBLocalizer
//
//  Created by Josip Bernat on 6/23/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBLoadRootFilesOperation.h"

#define kIgnoringNames @[@".DS_Store", @".git", @".gitignore", @".xcassets", @"Podfile", @"Podfile.lock", @"Pods", @".xcodeproj", @".xcworkspace", @" "]

@implementation JBLoadRootFilesOperation

+ (NSArray *)rootDirectoriesInPath:(NSString *)path error:(NSError * __autoreleasing *)error {
    
    NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:error];
    if (error) {
        return nil;
    }
    
    NSMutableArray *items = [NSMutableArray array];
    NSArray *ignoringNames = kIgnoringNames;
    
    for (NSString *item in content) {
        
        BOOL contains = NO;
        for (NSString *ignore in ignoringNames) {
            if ([item containsString:ignore]) {
                contains = YES;
                break;
            }
        }
        if (!contains) {
            [items addObject:item];
        }
    }
    return items;
}

@end
