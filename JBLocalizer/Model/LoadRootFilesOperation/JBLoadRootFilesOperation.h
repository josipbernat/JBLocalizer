//
//  JBLoadRootFilesOperation.h
//  JBLocalizer
//
//  Created by Josip Bernat on 6/23/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBOperation.h"

@interface JBLoadRootFilesOperation : JBOperation

#pragma mark - Paths
/**
 *  Checks given file directory and finds corresponding source file directories.
 *
 *  @param path  File path in file system.
 *  @param error An error pointer.
 *
 *  @return An array of directory names, otherwise nil.
 */
+ (nullable NSArray *)rootDirectoriesInPath:(NSString * __nonnull)path error:(NSError  * __nullable  __autoreleasing * __nullable)error;

@end
