//
//  JBStringTests.m
//  JBLocalizer
//
//  Created by Josip Bernat on 7/17/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "JBString.h"
#import "JBFile.h"
#import "JBTestDefines.h"

@interface JBStringTests : XCTestCase

@end

@implementation JBStringTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#define kTestFileObject [JBFile fileWithName:kTestFile path:kTestFilePath directory:NO]

- (void)testInitializationPass {
    
    JBFile *file = kTestFileObject;
    
    JBString *string = [JBString stringWithString:kTestString1
                                          comment:kTestComment1
                                             file:file];
    
    XCTAssertEqualObjects(string.string, kTestString1);
    XCTAssertEqualObjects(string.comment, kTestComment1);
    XCTAssertEqual([string.files containsObject:file], YES);
}

- (void)testInitializationInvalidStringException {
    
    void (^expressionBlock)() = ^{
        
        JBFile *file = kTestFileObject;
        [JBString stringWithString:nil comment:kTestComment1 file:file];
    };
    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testEqualPass {
    
    JBFile *file = kTestFileObject;
    
    JBString *string1 = [JBString stringWithString:kTestString1 comment:kTestComment1 file:file];
    JBString *string2 = [JBString stringWithString:kTestString1 comment:kTestComment1 file:file];
    
    XCTAssertEqualObjects(string1, string2);
}

- (void)testEqualFailBecauseOfString {
    
    JBFile *file = kTestFileObject;
    
    JBString *string1 = [JBString stringWithString:kTestString1 comment:kTestComment1 file:file];
    JBString *string2 = [JBString stringWithString:kTestString2 comment:kTestComment1 file:file];
    
    XCTAssertNotEqualObjects(string1, string2);
}

- (void)testEqualFailBecauseOfComment {
    
    JBFile *file = kTestFileObject;
    
    JBString *string1 = [JBString stringWithString:kTestString1 comment:kTestComment1 file:file];
    JBString *string2 = [JBString stringWithString:kTestString1 comment:nil file:file];
    
    XCTAssertNotEqualObjects(string1, string2);
}

@end
