//
//  ChatModel.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/4/14.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatModel.h"

@implementation ChatModel

- (instancetype)init
{
    if (self = [super init]) {
        
        _senTime = getTime(); //初始化时赋值时间戳
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}


NS_INLINE NSString * getTime(){
    long time = [[NSDate date]timeIntervalSince1970]*1000; //精确到毫秒
    return [NSString stringWithFormat:@"%ld",time];
}

@end

@implementation ChatContentModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}

@end
