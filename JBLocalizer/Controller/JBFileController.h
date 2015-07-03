//
//  JBFileController.h
//  JBLocalizer
//
//  Created by Josip Bernat on 6/12/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XcodeEditor/XcodeEditor.h"

@interface JBFileController : NSObject

#pragma mark - Shared Instance
/**
 *  Checks for shared instance and creates one if does not exist.
 *
 *  @return Controllers shared instance.
 */
+ (instancetype)sharedController;

#pragma mark - Project
/**
 *  Loads project and parses project files.
 *
 *  @param projectPath A file path where project is saved.
 */
- (void)loadProjectFiles:(NSString *)projectPath;
@end
