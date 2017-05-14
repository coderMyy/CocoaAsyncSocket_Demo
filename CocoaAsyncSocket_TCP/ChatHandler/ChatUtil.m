//
//  ChatUtil.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatUtil.h"
#import "ChatModel.h"

@implementation ChatUtil

+ (void)shouldShowTime:(ChatModel *)currentmodel premodel:(ChatModel *)premodel
{
    if (!premodel) {
         currentmodel.showTime = !premodel;
    }
    //取最后两个时间戳比较时间
    NSInteger length = (currentmodel.sendTime.longLongValue-premodel.sendTime.longLongValue)/1000; //socket处时间戳多了三位
    
    if (length>60) {
        
       currentmodel.showTime = YES;
    }else{
        currentmodel.showTime = NO;
    }
}

#pragma mark - 消息高度计算
+ (CGFloat)heightForMessage:(ChatModel *)currentChatmodel premodel:(ChatModel *)premodel
{
    //是否显示时间
    [self shouldShowTime:currentChatmodel premodel:premodel];
    
    CGFloat height = 0.f;
    //文本,表情
    if (hashEqual(currentChatmodel.contenType, Content_Text)) {
        
        return currentChatmodel.messageHeight = currentChatmodel.shouldShowTime ? height + 40 : height;
        //语音
    }else if (hashEqual(currentChatmodel.contenType, Content_Audio)){
        
        return currentChatmodel.messageHeight = currentChatmodel.shouldShowTime ? height + 40 : height;
        //图片
    }else if (hashEqual(currentChatmodel.contenType, Content_Picture)){
        
        return currentChatmodel.messageHeight = currentChatmodel.shouldShowTime ? height + 40 : height;
        //视频
    }else if (hashEqual(currentChatmodel.contenType, Content_Video)){
        
        return currentChatmodel.messageHeight = currentChatmodel.shouldShowTime ? height + 40 : height;
        //文件
    }else if (hashEqual(currentChatmodel.contenType, Content_File)){
        
        return currentChatmodel.messageHeight = currentChatmodel.shouldShowTime ? height + 40 : height;
        //提示语
    }else{
        
        return currentChatmodel.messageHeight = currentChatmodel.shouldShowTime ? height + 40 : height;;
    }
}


@end
