//
//  JBLoadSourceFilesTests.m
//  JBLocalizer
//
//  Created by Josip Bernat on 7/17/15.
//  Copyright (c) 2015 Josip Bernat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "JBLoadSourceFilesOperation.h"
#import "JBFileController.h"
#import "JBTestDefines.h"
#import "XcodeEditor/XcodeEditor.h"
#import "JBFile.h"

@interface JBLoadSourceFilesTests : XCTestCase

@end

@implementation JBLoadSourceFilesTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testProjectExists {
    
    if ([[JBFileController sharedController] projectExistsAtPath:kProjectPath]) {
        XCTAssert(YES, @"Project exists at given path");
    }
    else {
        XCTFail(@"Project doesn't exist at given path: %@", kProjectPath);
    }
}

#define kSourceFilesContent @[@"ViewControllerWith1UniqueString.m", @"ViewControllerWithManyUniqueStrings.m", \
@"ViewControllerWithoutStrings.m", @"ViewControllerWithSharedAndUniqueString.m", @"ViewControllerWithSharedString1.m", \
@"ViewControllerWithSharedString2.m", @"AppDelegate.m", @"main.m"]

- (void)testCorrectLoadingOfFilesInTestApplicationDirectory {

    XCProject *project = [XCProject projectWithFilePath:kProjectPath];
    XCTAssertNotNil(project);
    
    JBFile *file = [JBFile fileWithName:@"TestApplication"
                                   path:[kProjectRoot stringByAppendingPathComponent:@"TestApplication"]
                              directory:YES];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing wheter JBLoadSourceFilesTests will load source files correctly or not."];
    
    JBLoadSourceFilesOperation *operation = [JBLoadSourceFilesOperation loadProjectSourceFiles:project
                                                                             filterDirectories:@[file]
                                                                                    completion:^(NSDictionary *result, NSError *error) {
                                                                                        
                                                                                        if (error) {
                                                                                            XCTFail(@"JBLoadSourceFilesTests didn't load source files: %@", error);
                                                                                            [expectation fulfill];
                                                                                        }
                                                                                        NSArray *content = result[file];
                                                                                        XCTAssertEqual(content.count, 8);
                                                                                        
                                                                                        NSArray *testSource = kSourceFilesContent;
                                                                                        
                                                                                        for (JBFile *file in content) {
                                                                                            XCTAssertEqual([file isKindOfClass:[JBFile class]], YES, @"File must be JBFile");
                                                                                            
                                                                                            XCTAssertEqual([testSource containsObject:file.name], YES, @"Source files doesn't containt file");
                                                                                        }
                                                                                        
                                                                                        XCTAssert(YES, @"JBLoadSourceFilesTests did load all files successfully");
                                                                                        [expectation fulfill];
                                                                                    }];
    [operation execute];
    
    [self waitForExpectationsWithTimeout:5.0f handler:^(NSError *error) {
        if(error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

// Implement Error handling inside operation

@end
