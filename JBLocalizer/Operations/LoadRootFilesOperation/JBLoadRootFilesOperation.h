//
//  JBLoadRootFilesOperation.h
//  JBLocalizer
//
//  Created by Josip Bernat on 6/23/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBOperation.h"

@interface JBLoadRootFilesOperation : JBOperation

#pragma mark - Initialization
/**
 *  Creates new instance of an operation.
 *
 *  @param projectPath    Path to project in file system.
 *  @param completion Callback block object called once operation finishes with execution. It has two parameters but only one is not nil at given time. If operation finishes successfully will contain an array of possible root directories to parse. Otherwise NSError object will have failure reason.
 *
 *  @return Newly created instance.
 */
+ (nonnull instancetype)loadRootDirectories:(NSString  * __nonnull )projectPath
                                 completion:( void(^ __nullable )(NSArray * __nullable, NSError * __nullable))completion;

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
