//
//  JBLoadSourceFilesOperation.h
//  JBLocalizer
//
//  Created by Josip Bernat on 6/23/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import "JBOperation.h"

@class XCProject;

@interface JBLoadSourceFilesOperation : JBOperation

#pragma mark - Initialization
/**
 *  Creates new instance of an operation.
 *
 *  @param project    A projext object to be used for searching project files.
 *  @param root       An optional root project file. If nil operation will iterate through all available directories inside project root path.
 *  @param completion Callback block object called once operation finishes with execution. It has two parameters but only one is not nil at given time. If operation finishes successfully will contain a dictionary where key is name of root folder and value is array of file paths, otherwise NSError object will have failure reason.
 *
 *  @return Newly created instance.
 */
+ (nonnull instancetype)loadProjectSourceFiles:(XCProject  * __nonnull )project
                             filterDirectories:(NSArray * __nullable)filter
                                    completion:( void(^ __nullable )(NSDictionary * __nullable, NSError * __nullable))completion;

@end
