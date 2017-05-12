//
//  ChatModel.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/4/14.
//  Copyright © 2017年 mengyao. All rights reserved.
//
#import "ChatModel.h"
    
@implementation ChatModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (instancetype)init
{
    if (self = [super init]) {
        self.senTime = getSendTime();
    }
    return self;
}

NS_INLINE NSString *getSendTime() {
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    return [NSString stringWithFormat:@"%llu",recordTime];
}

@end


@implementation ChatContentModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
}




@end
