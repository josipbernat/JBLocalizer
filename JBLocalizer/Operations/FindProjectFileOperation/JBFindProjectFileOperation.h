//
//  JBFindProjectFileOperation.h
//  JBLocalizer
//
//  Created by Josip Bernat on 7/28/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBOperation.h"

@interface JBFindProjectFileOperation : JBOperation

#pragma mark - Initialization
/**
 *  Creates new instance of an operation.
 *
 *  @param directory  Path to possible project directory in file system.
 *  @param completion Callback block object called once operation finishes with execution. It has two parameters but only one is not nil at given time. If operation finishes successfully will contain an array of possible project files as JBFile object. Otherwise NSError object will have failure reason.
 *
 *  @return Newly created instance.
 */
+ (nonnull instancetype)findProjectFile:(NSString  * __nonnull )directory
                             completion:( void(^ __nullable )(NSArray * __nullable, NSError * __nullable))completion;

@end
