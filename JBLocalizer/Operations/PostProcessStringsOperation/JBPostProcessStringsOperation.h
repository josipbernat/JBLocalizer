//
//  JBPostProcessStringsOperation.h
//  JBLocalizer
//
//  Created by Josip Bernat on 7/9/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBOperation.h"
#import "JBPostProcessStringsDefines.h"

@interface JBPostProcessStringsOperation : JBOperation

#pragma mark - Initialization
/**
 *  Postprocess given strings for printing suitable format.
 *
 *  @param strings    Dictionary containing strings. String must be key and value must be an array of files who contains given word.
 *  @param type       Type of desired formatting.
 *  @param completion Callback block object called once operation finishes with execution. It has one parameter, a string suitable for writing strings in file.
 *
 *  @return Newly created instance.
*/
+ (nonnull instancetype)processStrings:(NSArray * __nonnull)strings
                            formatting:(JBStringFormattingType)type
                            completion:( void(^ __nullable )(NSString * __nullable))completion;

@end
