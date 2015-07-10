//
//  JBLocalizerAppTests.m
//  JBLocalizerAppTests
//
//  Created by Josip Bernat on 7/8/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
//#import <JBLocalizer/JBFileController.h>
#import <JBLocalizer/JBLocalizer.h>

@interface JBLocalizerAppTests : XCTestCase

@end

@implementation JBLocalizerAppTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    
    [[JBFileController sharedController] loadProjectFiles:@"/Users/josipbernat/Documents/Posao/iOS_projects/onetime/SpikaEnterprise.xcodeproj"
                                               completion:^(NSDictionary * result, NSError * error) {
                                                   
                                                   if(error) {
                                                       NSLog(@"error is: %@", error);
                                                   }
                                                   else {
                                                       
                                                       [[JBFileController sharedController] loadAndProcessLocalizableStringsInFiles:result[@"SpikaEnterprise"]
                                                                                                                         completion:^(NSString * result1, NSError * error1) {
                                                                                                                            
                                                                                                                             if(error1) {
                                                                                                                                 NSLog(@"error is: %@", error1);
                                                                                                                             }
                                                                                                                             else {
                                                                                                                                 NSLog(@"Result: %@", result1);
                                                                                                                                 
                                                                                                                                 XCTAssert(YES, @"Pass");
                                                                                                                                 [expectation fulfill];
                                                                                                                             }
                                                                                                                         }];
//                                                       XCTAssert(YES, @"Pass");
//                                                       [expectation fulfill];
                                                   }
                                               }];
    
    [self waitForExpectationsWithTimeout:105.0f handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
