//
//  ZFTestSocketViewController.m
//  newupop
//
//  Created by FANS on 2020/12/4.
//  Copyright © 2020 中付支付. All rights reserved.
//

#import "ZFTestSocketViewController.h"

@interface ZFTestSocketViewController ()

@property (nonatomic ,strong)dispatch_queue_t queue;
@property (nonatomic ,strong)NSMutableDictionary *heartbeatDic;
@end

@implementation ZFTestSocketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    __weak typeof(self) weakself = self;
    dispatchTimer(self, 5, ^(dispatch_source_t timer) {
        dispatch_sync(weakself.queue, ^{
            
        });
    });
    
}

////开启一个定时器
void dispatchTimer(id target,double timeInterval,void(^handler)(dispatch_source_t timer)) {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), (uint64_t)(timeInterval*NSEC_PER_SEC), 0);
    __weak __typeof(target) weaktarget = target;
    dispatch_source_set_event_handler(timer, ^{
        if (!weaktarget) {
            dispatch_source_cancel(timer);
        } else {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (handler) handler(timer);
//            });
            if (handler) handler(timer);
        }
        dispatch_resume(timer);
    });
}

@end
