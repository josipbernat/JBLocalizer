//
//  JBFileTests.m
//  JBLocalizer
//
//  Created by Josip Bernat on 7/17/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "JBFile.h"
#import "JBTestDefines.h"

@interface JBFileTests : XCTestCase

@end

@implementation JBFileTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitializationPass {

    JBFile *file = [JBFile fileWithName:@"TestFile"
                                   path:[kProjectRoot stringByAppendingPathComponent:@"TestFile"]
                              directory:YES];
    
    XCTAssertEqualObjects(file.name, @"TestFile");
    XCTAssertEqualObjects(file.path, [kProjectRoot stringByAppendingPathComponent:@"TestFile"]);
    XCTAssertEqual(file.directory, YES);
    XCTAssertEqual(file.selected, NO);
}

- (void)testInitializationInvalidNameException {

    void (^expressionBlock)() = ^{
        [JBFile fileWithName:nil
                        path:[kProjectRoot stringByAppendingPathComponent:@"TestFile"]
                   directory:YES];
    };
    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitializationInvalidPathException {
    
    void (^expressionBlock)() = ^{
        [JBFile fileWithName:@"TestFile"
                        path:nil
                   directory:YES];
    };
    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testEqualPass {

    JBFile *file1 = [JBFile fileWithName:@"TestFile"
                                   path:[kProjectRoot stringByAppendingPathComponent:@"TestFile"]
                              directory:YES];
    
    JBFile *file2 = [JBFile fileWithName:@"TestFile"
                                    path:[kProjectRoot stringByAppendingPathComponent:@"TestFile"]
                               directory:YES];
    
    XCTAssertEqualObjects(file1, file2);
}

- (void)testEqualFailBecauseOfName {
    
    JBFile *file1 = [JBFile fileWithName:@"TestFile"
                                    path:[kProjectRoot stringByAppendingPathComponent:@"TestFile"]
                               directory:YES];
    
    JBFile *file2 = [JBFile fileWithName:@"TestFile1"
                                    path:[kProjectRoot stringByAppendingPathComponent:@"TestFile"]
                               directory:YES];
    
    XCTAssertNotEqualObjects(file1, file2);
}

- (void)testEqualFailBecauseOfPath {
    
    JBFile *file1 = [JBFile fileWithName:@"TestFile"
                                    path:[kProjectRoot stringByAppendingPathComponent:@"TestFile"]
                               directory:YES];
    
    JBFile *file2 = [JBFile fileWithName:@"TestFile"
                                    path:[kProjectRoot stringByAppendingPathComponent:@"TestFile1"]
                               directory:YES];
    
    XCTAssertNotEqualObjects(file1, file2);
}

- (void)testEqualFailBecauseOfDirectory {
    
    JBFile *file1 = [JBFile fileWithName:@"TestFile"
                                    path:[kProjectRoot stringByAppendingPathComponent:@"TestFile"]
                               directory:YES];
    
    JBFile *file2 = [JBFile fileWithName:@"TestFile"
                                    path:[kProjectRoot stringByAppendingPathComponent:@"TestFile"]
                               directory:NO];
    
    XCTAssertNotEqualObjects(file1, file2);
}

@end
