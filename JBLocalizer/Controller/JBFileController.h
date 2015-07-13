//
//  JBFileController.h
//  JBLocalizer
//
//  Created by Josip Bernat on 6/12/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JBFileController : NSObject

#pragma mark - Shared Instance
/**
 *  Checks for shared instance and creates one if does not exist.
 *
 *  @return Controllers shared instance.
 */
+ (nonnull instancetype)sharedController;

#pragma mark - Project

- (void)loadProjectRootFiles:(NSString * __nonnull)projectPath
                  completion:(void(^ __nullable )(NSArray * __nullable, NSError * __nullable))completion;

/**
 *  Loads project and parses project files.
 *
 *  @param projectPath A file path where project is saved.
 */
- (void)loadProjectFiles:(NSString * __nonnull)projectPath
           rootDirectory:(NSString * __nonnull)rootDirectory
              completion:(void(^ __nullable )(NSDictionary * __nullable, NSError * __nullable))completion;

#pragma mark - File Content
/**
 *  Loads NSLocalizedString strings in given files. Suitable if you want your own formatting.
 *
 *  @param files      An array of file paths.
 *  @param completion Callback block object called once loading is finished. It has two parameters but only one is not nil at given time. If load is finished with success it will contain dictionary where key is string and value is an array of classes where it is contained. Otherwise NSError object will have failure reason.
 */
- (void)loadLocalizableStringsInFiles:(NSArray * __nonnull)files
                           completion:(void(^ __nullable )(NSDictionary * __nullable, NSError * __nullable))completion;

/**
 *  Loads NSLocalizedString strings in given files and processes them to output format.
 *
 *  @param files      An array of file paths.
 *  @param completion Callback block object called once loading is finished. It has two parameters but only one is not nil at given time. If load is finished with success it will contain formatted string object with localizable strings. Otherwise NSError object will have failure reason.
 */
- (void)loadAndProcessLocalizableStringsInFiles:(NSArray * __nonnull)files
                                     completion:(void(^ __nullable )(NSString * __nullable, NSError * __nullable))completion;

@end
