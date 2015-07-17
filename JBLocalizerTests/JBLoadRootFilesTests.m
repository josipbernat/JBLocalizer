//
//  JBLoadRootFilesTests.m
//  JBLocalizer
//
//  Created by Josip Bernat on 7/17/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "JBLoadRootFilesOperation.h"
#import "JBTestDefines.h"
#import "JBFile.h"

@interface JBLoadRootFilesTests : XCTestCase

@end

@implementation JBLoadRootFilesTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRootDirectoryExists {

    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing wheter JBLoadRootFilesOperation can find root directory"];
    
    JBLoadRootFilesOperation *operation = [JBLoadRootFilesOperation loadRootDirectories:kProjectRoot
                                                                             completion:^(NSArray *result, NSError *error) {
                                                                                 
                                                                                 if (!error) {
                                                                                     XCTAssert(YES, @"JBLoadRootFilesOperation did found root directory");
                                                                                     [expectation fulfill];
                                                                                 }
                                                                                 else {
                                                                                     XCTFail(@"JBLoadRootFilesOperation didn't find root directory: %@", error);
                                                                                     [expectation fulfill];
                                                                                 }
                                                                             }];
    [operation execute];
    
    [self waitForExpectationsWithTimeout:5.0f handler:^(NSError *error) {
        if(error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testLoadRootFiles {

    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing wheter JBLoadRootFilesOperation will load correct files."];
    
    JBLoadRootFilesOperation *operation = [JBLoadRootFilesOperation loadRootDirectories:kProjectRoot
                                                                             completion:^(NSArray *result, NSError *error) {
                                                                                 
                                                                                 if (error) {
                                                                                     XCTFail(@"JBLoadRootFilesOperation didn't load correct files: %@", error);
                                                                                     [expectation fulfill];
                                                                                 }
                                                                                 XCTAssertEqual(result.count, 2);
                                                                                 
                                                                                 NSMutableArray *testArray = [NSMutableArray array];
                                                                                 JBFile *file1 = [JBFile fileWithName:@"TestApplication"
                                                                                                                 path:[kProjectRoot stringByAppendingPathComponent:@"TestApplication"]
                                                                                                            directory:YES];
                                                                                 [testArray addObject:file1];
                                                                                 
                                                                                 JBFile *file2 = [JBFile fileWithName:@"TestApplicationTests"
                                                                                                                 path:[kProjectRoot stringByAppendingPathComponent:@"TestApplicationTests"]
                                                                                                            directory:YES];
                                                                                 [testArray addObject:file2];
                                                                                 
                                                                                 XCTAssertEqualObjects(result, testArray);
                                                                                 [expectation fulfill];
                                                                             }];
    [operation execute];

    [self waitForExpectationsWithTimeout:5.0f handler:^(NSError *error) {
        if(error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

@end
