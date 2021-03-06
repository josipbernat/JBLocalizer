//
//  JBLoadFileStringsOperation.h
//  JBLocalizer
//
//  Created by Josip Bernat on 7/9/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBOperation.h"

@class JBFile;

@interface JBLoadStringsInFileOperation : JBOperation

#pragma mark - Initialization
/**
 *  Creates new instance of an operation.
 *
 *  @param file            Path of file you want to parse.
 *  @param includeComments Boolean value determening wheter should include comments or not.
 *  @param completion      Callback block object called once operation finishes with execution. It has two parameters but only one is not nil at given time. If operation finishes successfully will contain an array of strings, otherwise NSError object will have failure reason.
 *
 *  @return Newly created instance.
*/
+ (nonnull instancetype)file:(JBFile * __nonnull)file
             includeComments:(BOOL)includeComments
                  completion:( void(^ __nullable )(NSArray * __nullable, NSError * __nullable))completion;

@end
