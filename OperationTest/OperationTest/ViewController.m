//
//  ViewController.m
//  OperationTest
//
//  Created by 王磊 on 2017/3/31.
//  Copyright © 2017年 wanglei. All rights reserved.
//

#import "ViewController.h"
#import "TestOperation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self operationQueueAddDependency];
}

- (void)operationQueueAddDependency
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 1000; i ++) {
            NSLog(@"===%d", i);
        }
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"end");
    }];
    
    [op2 addDependency:op1];
    [queue addOperation:op2];
    [queue addOperation:op1];
}

- (void)operationQueue
{
    TestOperation *testOp = [[TestOperation alloc] init];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        NSLog(@"blockQueue");
    }];
    [queue addOperation:testOp];
    
    [queue setMaxConcurrentOperationCount:3];
}

- (void)customOperaion
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        TestOperation *testOp = [[TestOperation alloc] init];
        [testOp start];
    });

}

- (void)blockOperation
{
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"blockOp == %@", [NSThread currentThread]);
    }];
    [blockOp addExecutionBlock:^{
        NSLog(@"blockOp1 == %@", [NSThread currentThread]);
    }];
    [blockOp addExecutionBlock:^{
        NSLog(@"blockOp2 == %@", [NSThread currentThread]);
    }];
    [blockOp start];
}

- (void)invocationOperation
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(respondsToOperation) object:nil];
        [operation start];
    });
}

- (void)respondsToOperation
{
    NSLog(@"invocationOpearation == %@", [NSThread currentThread]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
