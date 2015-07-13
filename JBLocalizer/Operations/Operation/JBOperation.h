//
//  JBOperation.h
//  JBLocalizer
//
//  Created by Josip Bernat on 6/23/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JBOperation : NSOperation

#pragma mark - Execution
/**
 *  Invokes operation job. This is a method where you want to make your job. You must override this method in your subclass and do not call super.
 */
- (void)execute;

@end
