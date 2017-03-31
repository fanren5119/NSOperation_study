##一、NSOperation简介
NSOperation是OC中多线程技术的一种,是对GCD的OC包装.它包含NSOperationQueue（队列）和NSOperation（操作）两方面；
##二、NSOperation使用
NSOperation本身是一个抽象类，它的使用可以通过以下几种方式  
### 1.NSInvocationOpeartion
NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(respondsToOperation) object:nil];
        [operation start];  
此任务在执行的时候，系统不会开辟一个新的线程去执行，任务会在当前线程同步执行
###2.NSBlockOperation
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"blockOp0 == %@", [NSThread currentThread]);
    }];
    [blockOp addExecutionBlock:^{
        NSLog(@"blockOp1 == %@", [NSThread currentThread]);
    }];
    blockOp0也是在当前线程中同步执行，而blockOp1是在新线程中执行的。也就是说：当NSBlockOperation封装的操作数大于1的时候，就会执行异步操作
###3.自定义NSOperation
* 子类化NSOperation
* 子类中重写main方法，在main方法中执行任务
* 创建对象，调用start方法，让你自定义的任务跑在当前线程中。  

##三、NSOperationQueue的使用
NSOperation的start方法默认是同步执行任务，这样的使用并不多见，只有将NSOperation与NSOperationQueue进行结合，才会发挥这种多线程的最大功效。当NSoperation被添加到NSOperationQueue中后，就会全自动地执行异步操作。
###1.NSOperationQueue的种类
* 自带主队列[NSOperationQueue mainQueue]:添加到主队列中的任务都会在主线程中执行
* 自己创建队列（非主队列）[[NSOperationQueue alloc] init]:这种队列同时包含串行、并发的功能，添加到非主队列的任务会自动放到子线程中执行；

###2.向NSOperationQueue中添加操作
* 直接添加:[queue addOperation:operation]
* 使用block添加，block内容会被包装成operation对象添加到队列  
    [queue addOperationWithBlock:^{
        
    }]; 操作一旦被添加到队列中，就会自动异步执行;

###3.设置最大并发数
    [queue setMaxConcurrentOperationCount:3];
    当并发数为1的是偶，就变成了串行执行任务
###4.NSOperationQueue的暂停、恢复和取消
* 取消  
    *  NSOperation有一个cancel方法可以取消单个操作
    *  NSOperationQueue的cancelAllOperations相当于队列中的每个operation调用了cancel方法，会取消队列里面全部的操作
    *  不能取消正在进行中的任务，队列调用了cancelAllOperation后会等当前正在进行中的任务执行完毕后取消后面的操作；
* 挂起和回复
    *  isSuspended：判断是否挂起
    *  setSuspended：YES表示挂起，NO表示恢复；
    *  和取消功能相似，同样不能挂起正在进行中的操作，队列会等当前操作结束后将后面的操作暂停  

因此，我们在自定义NSOperation的时候需要注意，最好经常通过判断isCancelled方法检测操作是否被取消，以响应外部可能进行的取消操作；

###4.添加依赖和监听
* 通过设置操作间的依赖，可以确定这些操作的执行顺序；  
    [op3 addDependency:op1];  
    [op3 addDependency:op2];  
    表示op3会在op1和op2都执行完毕后才执行；  
    添加依赖的时候要注意防止添加循环依赖，此外，我们还可以在不同队列的operation之间添加依赖
* 监听
    *  op.completeBlock可以监听一个操作执行完毕的时刻，这个block里面可以添加一些我们需要的操作；
    *  这个block里面的操作仍然是在子线程中执行，但不一定和被监听的操作是在同一个线程；

###5.线程间通信
    有时我们在自行车中执行完一些操作的时候，需要回到主线程中去更新UI，因此需要从当前线程回到主线程  
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        //子线程中
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //回到主线程
        }];
    }];
