//
//  JBLocalizerTests.m
//  JBLocalizerTests
//
//  Created by Josip Bernat on 7/17/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "JBFileController.h"
#import "JBTestDefines.h"

@interface JBFileControllerTests : XCTestCase

@end

@implementation JBFileControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Project Tests

- (void)testProjectExists {
    
    if ([[JBFileController sharedController] projectExistsAtPath:kProjectPath]) {
        XCTAssert(YES, @"Project exists at given path");
    }
    else {
        XCTFail(@"Project doesn't exist at given path: %@", kProjectPath);
    }
}

- (void)testLoadingRootFiles {

    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];

    [[JBFileController sharedController] loadProjectFiles:@"/Users/josipbernat/Documents/Private/Progs/JBLocalizer23/JBLocalizerTests/TestProject/TestApplication/TestApplication/SpikaEnterprise.xcodeproj"
                                        filterDirectories:nil
                                               completion:^(NSDictionary *dictionary, NSError *error) {
                                                   
                                                   XCTAssert(YES, @"Pass");
                                                   [expectation fulfill];
                                               }];
    
    [self waitForExpectationsWithTimeout:105.0f handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];

}

@end
