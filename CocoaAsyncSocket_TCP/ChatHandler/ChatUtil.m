//
//  ChatUtil.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatUtil.h"
#import "ChatModel.h"
#import "MYCoreTextLabel.h"

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
        MYCoreTextLabel *coreLabel = [[MYCoreTextLabel alloc]init];
        coreLabel.textFont = FontSet(14);
        coreLabel.lineSpacing = 6;
        coreLabel.imageSize =CGSizeMake(24, 24);
        [coreLabel setText:currentChatmodel.content.text customLinks:nil keywords:nil];
        CGSize labelSize = [coreLabel sizeThatFits:CGSizeMake(SCREEN_WITDTH - 145, MAXFLOAT)];
        height = 5 + 10 + labelSize.height + 10;
        //验证是否群聊
        [self groupChatConfig:currentChatmodel];
        return currentChatmodel.messageHeight += currentChatmodel.shouldShowTime ? height + 50 : height + 15;
        //语音
    }else if (hashEqual(currentChatmodel.contenType, Content_Audio)){
        
        return currentChatmodel.messageHeight += currentChatmodel.shouldShowTime ? height + 50 : height + 15;
        //图片
    }else if (hashEqual(currentChatmodel.contenType, Content_Picture)){
        
        return currentChatmodel.messageHeight += currentChatmodel.shouldShowTime ? height + 50 : height + 15;
        //视频
    }else if (hashEqual(currentChatmodel.contenType, Content_Video)){
        
        return currentChatmodel.messageHeight += currentChatmodel.shouldShowTime ? height + 50 : height + 15;
        //文件
    }else if (hashEqual(currentChatmodel.contenType, Content_File)){
        
        return currentChatmodel.messageHeight += currentChatmodel.shouldShowTime ? height + 50 : height + 15;
        //提示语
    }else{
        
        return currentChatmodel.messageHeight += currentChatmodel.shouldShowTime ? height + 50 : height + 15;
    }
}

//群聊特殊布局
+ (void)groupChatConfig:(ChatModel *)chatModel
{
    if (hashEqual(chatModel.chatType, @"groupChat")&&!chatModel.byMyself.integerValue) {
        chatModel.messageHeight += 16;
    }
}


#pragma marl - 创建发送消息模型
+ (ChatModel *)creatMessageModel
{
    ChatModel *messageModel = [[ChatModel alloc]init];
    ChatContentModel *content = [[ChatContentModel alloc]init];
    messageModel.content = content;
    messageModel.fromUserID = [Account account].myUserID;
    messageModel.toUserID     = nil;
    messageModel.messageType = @"normal";
    messageModel.deviceType = @"iOS";
    messageModel.versionCode = TCP_VersionCode;
    messageModel.byMyself    = @1;
    messageModel.isSend       = @1;
    messageModel.isRead       = @0;
    messageModel.beatID       = TCP_beatBody;
    messageModel.fromPortrait   = [Account account].portrait;
    messageModel.toNickName = nil;
    messageModel.noDisturb  = nil;
    
    return messageModel;
}


@end
