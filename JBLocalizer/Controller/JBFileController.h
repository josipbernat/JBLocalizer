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
/**
 *  Loads project and parses project files.
 *
 *  @param projectPath A file path where project is saved.
 */
- (void)loadProjectFiles:(NSString * __nonnull)projectPath
              completion:(void(^ __nullable )(NSDictionary * __nullable, NSError * __nullable))completion;

#pragma mark - File Content
- (void)loadLocalizableStringsInFiles:(NSArray * __nonnull)files
                           completion:(void(^ __nullable )(NSDictionary * __nullable, NSError * __nullable))completion;

@end
