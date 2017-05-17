//
//  ChatRecordCover.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/17.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatRecordCover.h"

@interface ChatRecordCover ()

@property (nonatomic, strong) dispatch_source_t recordTimer;

@end

@implementation ChatRecordCover

//初始化录音蒙板
+ (instancetype)chatRecordCover
{
    return [[self alloc]init];
}


//开始录音
+ (void)beginRecord
{
    
}

//取消录音
+ (void)cancelRecord
{
    
}

//录音结束
+ (void)stopRecord
{
    
}




- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc
{
    dispatch_source_cancel(_recordTimer);
}


@end
