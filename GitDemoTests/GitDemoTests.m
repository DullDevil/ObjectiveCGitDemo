//
//  GitDemoTests.m
//  GitDemoTests
//
//  Created by 张桂杨 on 2017/12/8.
//  Copyright © 2017年 DD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ObjectiveGit/ObjectiveGit.h>
#import "IVELocalFileManager.h"

@interface GitDemoTests : XCTestCase {
    GTRepository *_repo;
}

@end

@implementation GitDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSString *gitPath = [IVELocalFileManager createDirectoryWithRelativePath:@"gitTest1"];
    NSError* error = nil;
    _repo = [[GTRepository alloc] initWithURL:[NSURL fileURLWithPath:gitPath] error:&error];
    if (!_repo) {
        _repo = [GTRepository initializeEmptyRepositoryAtFileURL:[NSURL fileURLWithPath:gitPath] options:nil error:&error];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_log {
    NSError *error;
    NSArray *braches = [_repo localBranchesWithError:&error];
    
}

@end
