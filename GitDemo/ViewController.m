//
//  ViewController.m
//  GitDemo
//
//  Created by 张桂杨 on 2017/12/6.
//  Copyright © 2017年 DD. All rights reserved.
//

#import "ViewController.h"
#import <ObjectiveGit/ObjectiveGit.h>
#import "IVELocalFileManager.h"

@interface ViewController () {
    
    GTRepository *rep;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *gitPath = [IVELocalFileManager createDirectoryWithRelativePath:@"gitTest1"];
    NSError* error = nil;
    rep = [[GTRepository alloc] initWithURL:[NSURL fileURLWithPath:gitPath] error:&error];
    if (!rep) {
        rep = [GTRepository initializeEmptyRepositoryAtFileURL:[NSURL fileURLWithPath:gitPath] options:nil error:&error];
    }
    
    [rep enumerateFileStatusWithOptions:nil error:NULL usingBlock:^(GTStatusDelta * _Nullable headToIndex, GTStatusDelta * _Nullable indexToWorkingDirectory, BOOL * _Nonnull stop) {
        NSLog(@"--%td",indexToWorkingDirectory.status);
    }];
    
    

}
- (void) creatRepo {
    NSString *gitPath = [IVELocalFileManager createDirectoryWithRelativePath:@"gitTest"];
    NSError* error = nil;
    
    [GTRepository cloneFromURL:[NSURL URLWithString:@"https://github.com/DullDevil/RSADemo"] toWorkingDirectory:[NSURL URLWithString:gitPath] options:@{GTRepositoryCloneOptionsTransportFlags: @YES} error:&error transferProgressBlock:^(const git_transfer_progress * _Nonnull progress, BOOL * _Nonnull stop) {
        NSLog(@"-=-=-=- %d",progress->received_objects);
    }];
 
}

- (IBAction)clone:(id)sender {
    NSError* error = nil;

    GTIndex *index = [rep indexWithError:NULL];
    
    [index addFile:@"test" error:&error];
    NSLog(@"error - %@",error);
    
    [index write:&error];
    
    NSLog(@"error - %@",error);
    GTTree *tree = [index writeTree:&error];
    
    NSLog(@"error - %@",error);
    GTSignature *sign = [[GTSignature alloc] initWithName:@"name" email:@"441473064@qq.com" time:[NSDate date]];
    [rep createCommitWithTree:tree message:@"test12342" author:sign committer:sign parents:nil updatingReferenceNamed:@"HEAD" error:&error];
    NSLog(@"error - %@",error);

    [rep enumerateFileStatusWithOptions:nil error:NULL usingBlock:^(GTStatusDelta * _Nullable headToIndex, GTStatusDelta * _Nullable indexToWorkingDirectory, BOOL * _Nonnull stop) {
        NSLog(@"--%td",indexToWorkingDirectory.status);
    }];
    

}

@end
