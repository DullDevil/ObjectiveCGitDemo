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
    NSString *_gitPath;
}

@end

@implementation GitDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_clone {
    NSError* error = nil;
    [IVELocalFileManager deleteDataWithRelativePath:@"clone"];
    NSString *path = [IVELocalFileManager createDirectoryWithRelativePath:@"clone"];
    
    GTRepository *repo = [GTRepository cloneFromURL:[NSURL URLWithString:@"https://github.com/DullDevil/RSADemo"] toWorkingDirectory:[NSURL fileURLWithPath:path] options:nil error:&error transferProgressBlock:^(const git_transfer_progress * _Nonnull progress, BOOL * _Nonnull stop) {
        
    }];
    NSString *des = [NSString stringWithFormat:@"clone失败: \n %@",error];
    NSAssert(repo, des);
}

- (void)test_initRepo {
    _gitPath = [IVELocalFileManager createDirectoryWithRelativePath:@"gitTest"];
    NSError* error = nil;
    _repo = [[GTRepository alloc] initWithURL:[NSURL fileURLWithPath:_gitPath] error:&error];
    if (!_repo) {
        _repo = [GTRepository initializeEmptyRepositoryAtFileURL:[NSURL fileURLWithPath:_gitPath] options:nil error:&error];
    }
    NSString *des = [NSString stringWithFormat:@"创建repo失败: \n %@",error];
    NSAssert(_repo,des);
}


- (void)test_commit {
    [self test_initRepo];
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    dataFormatter.dateFormat = @"YYYY-MM-DD HH:mm:ss";
    NSString *string  = [dataFormatter stringFromDate:[NSDate date]];
    string = [NSString stringWithFormat:@"commit from objectiveGit %@",string];
    
    NSError *error = nil;
    NSString *fileName = @"localTest.md";
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",_gitPath,fileName];
    [string writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    

    NSString *des = [NSString stringWithFormat:@"写入数据失败: \n %@",error];
    NSAssert(error == nil,des);
    
    GTReference *ref = [_repo headReferenceWithError:&error];
    des = [NSString stringWithFormat:@"获取ref失败: \n %@",error];
    NSAssert(error == nil,des);
    
    NSMutableArray *parents = [NSMutableArray array];
    // 如果是第一次提交的话不需要 parents
    if (ref) {
        [parents addObject:ref.resolvedTarget];
    }
    GTIndex *index = [_repo indexWithError:&error];
    des = [NSString stringWithFormat:@"获取index失败: \n %@",error];
    NSAssert(error == nil,des);
    
    [index addFile:fileName error:&error];
    des = [NSString stringWithFormat:@"添加文件失败: \n %@",error];
    NSAssert(error == nil,des);
    
    [index write:&error];
    des = [NSString stringWithFormat:@"写入文件失败: \n %@",error];
    NSAssert(error == nil,des);
    
    GTTree *tree = [index writeTree:&error];
    des = [NSString stringWithFormat:@"读取tree失败: \n %@",error];
    NSAssert(error == nil,des);
    
    GTSignature *sign = [[GTSignature alloc] initWithName:@"Test" email:@"441473064@qq.com" time:[NSDate date]];
    [_repo createCommitWithTree:tree message:string author:sign committer:sign parents:parents updatingReferenceNamed:@"HEAD" error:&error];
    des = [NSString stringWithFormat:@"提交失败: \n %@",error];
    NSAssert(error == nil,des);
}
- (void)test_log {
    [self test_initRepo];
    GTReference *ref = [_repo headReferenceWithError:NULL];
    // 这里可以一层一层往上查
    GTCommit *headCommit =  [_repo lookUpObjectByOID:ref.OID error:NULL];
    for (NSInteger i = 0; i < ref.reflog.entryCount; i ++) {
        GTReflogEntry *entry = [ref.reflog entryAtIndex:i];
        NSLog(@"\n commit \n %@ \n Author:  %@  \n Date: %@ \n \n %@ \n \n ",entry.updatedOID,entry.committer.name,entry.committer.time,entry.message);
    }
}

- (void)test_addRemote {
    [self test_initRepo];
    GTConfiguration *conf = [_repo configurationWithError:NULL];
    NSError *error = nil;
    if (conf.remotes.count == 0) {
        [GTRemote createRemoteWithName:@"origin" URLString:@"http://admin@localhost:2018/r/Test.git" inRepository:_repo error:&error];
    }
    NSString *des = [NSString stringWithFormat:@"添加remote失败: \n %@",error];
    NSAssert(conf.remotes.count > 0,des);
}
- (void)test_fetchRemote {
    [self test_initRepo];
    NSError *error = nil;
    GTConfiguration *conf = [_repo configurationWithError:NULL];
    NSAssert(conf.remotes.count > 0, @"没有remote");
    
    GTRemote *firstRemote = [conf.remotes firstObject];
    NSDictionary *remoteOptions = [self remoteOptions];
    [_repo fetchRemote:firstRemote withOptions:remoteOptions error:&error progress:^(const git_transfer_progress * _Nonnull stats, BOOL * _Nonnull stop) {
        NSLog(@"%d/%d",stats->received_objects,stats->total_objects);
    }];
    NSString *des = [NSString stringWithFormat:@"抓取失败: \n %@",error];
    NSAssert(error == nil,des);
}


- (void)test_mergeRemoteToLocal {
    [self test_initRepo];
    NSError *error = nil;
    GTConfiguration *conf = [_repo configurationWithError:NULL];
    NSAssert(conf.remotes.count > 0, @"没有remote");
    
    NSArray *branchs = [_repo remoteBranchesWithError:&error];
    NSAssert(branchs.count > 0, @"未找到相应分支");
    
    GTBranch *firstBaranch = [branchs firstObject];
    
    BOOL r = [_repo mergeBranchIntoCurrentBranch:firstBaranch withError:&error];
    NSString *des = [NSString stringWithFormat:@"合并失败: \n %@",error];
    NSAssert(r, des);
}


- (void)test_pushRemote {
    [self test_initRepo];
    GTConfiguration *conf = [_repo configurationWithError:NULL];
    NSError *error = nil;
    NSAssert(conf.remotes.count > 0, @"没有remote");
    
    GTRemote *remote = [conf.remotes firstObject];

    NSDictionary *pushOptions = [self remoteOptions];
    
    GTBranch *curretntBarch = [_repo currentBranchWithError:&error];
    BOOL r = [_repo pushBranch:curretntBarch toRemote:remote withOptions:pushOptions error:&error progress:^(unsigned int current, unsigned int total, size_t bytes, BOOL * _Nonnull stop) {
        NSLog(@"%d/%d",current,total);
    }];
    NSString *des = [NSString stringWithFormat:@"推送失败: \n %@",error];
    NSAssert(r, des);
}

- (NSDictionary *)remoteOptions {
    GTCredentialProvider *provider = [GTCredentialProvider providerWithBlock:^GTCredential * _Nullable(GTCredentialType type, NSString * _Nonnull URL, NSString * _Nonnull userName) {
        GTCredential *cre = [GTCredential credentialWithUserName:@"admin" password:@"admin" error:NULL];
        return cre;
    }];
    
    NSDictionary *remoteOptions = @{GTRepositoryRemoteOptionsCredentialProvider: provider };
    
    return remoteOptions;
}
@end
