//
//  ChatUtil.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatUtil.h"
#import "ChatModel.h"
#import "ChatAlbumModel.h"
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
        
        CGFloat picHeight = currentChatmodel.content.picSize.height;
        CGFloat picWidth  = currentChatmodel.content.picSize.width;
        //宽大于高
        if (picWidth > picHeight) {
        
            //极宽极低固定50高
            if (100*(picHeight/picWidth)<=50) {
                height = 50;
            }else{
                height = 135 *(picHeight/picWidth);
            }
        //宽小于高
        }else if (picWidth < picHeight){
            
            height = 130;
        //宽高相等
        }else{
            height = 120;
        }
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
+ (ChatModel *)creatMessageModel:(ChatModel *)config
{
    ChatModel *messageModel    = [[ChatModel alloc]init];
    ChatContentModel *content   = [[ChatContentModel alloc]init];
    messageModel.content          = content;
    messageModel.fromUserID     = [Account account].myUserID;
    messageModel.toUserID         = config.toUserID;
    messageModel.messageType  = @"normal";
    messageModel.chatType        = config.chatType;
    messageModel.deviceType     = @"iOS";
    messageModel.versionCode   = TCP_VersionCode;
    messageModel.byMyself        = @1;
    messageModel.isSend           = @0;
    messageModel.isRead           = @0;
    messageModel.beatID            = TCP_beatBody;
    messageModel.fromPortrait    = [Account account].portrait;
    messageModel.toNickName    = config.toNickName;
    messageModel.groupID          = config.groupID;
    messageModel.noDisturb       = config.noDisturb;
    return messageModel;
}

#pragma mark - 创建聊天资源缓存
+ (void)creatLocalCacheSource:(ChatAlbumModel *)albumModel chat:(ChatModel *)chatModel
{
    NSString *basePath = nil;
    if (hashEqual(chatModel.chatType, @"userChat")) {
        basePath = [ChatCache_Path stringByAppendingPathComponent:chatModel.toUserID];
    }else{
        basePath = [ChatCache_Path stringByAppendingPathComponent:chatModel.groupID];
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL exist = [manager fileExistsAtPath:basePath];
    if (!exist) {
        [manager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    //////////////////资源缓存
    //压缩比
    CGFloat compressScale = 1;
    NSData *smallAlbumData = nil;
    NSData *albumData = nil;
    //用户选择了原图
    if (albumModel.isOrignal) {
        
        //压缩过的小图缓存 (用户界面展示,节省资源)
        if (albumModel.orignalData.length/1024.0) { //小于3M的
            
            compressScale = 0.1;  //压缩10倍
        }else{  //大于3M
            
            compressScale = 0.05; //压缩20倍
        }
        UIImage *image = [UIImage imageWithData:albumModel.orignalData];
        //小图data
        smallAlbumData = UIImageJPEGRepresentation(image, compressScale);
        //原图data
        albumData        = albumModel.orignalData;
        
    //默认选择,未选择原图
    }else{
        
        //压缩过的小图缓存 (用户界面展示,节省资源)
        if (albumModel.normalData.length/1024.0) { //小于3M的
            
            compressScale = 0.1;  //压缩10倍
        }else{  //大于3M
            
            compressScale = 0.05; //压缩20倍
        }
        
        UIImage *image = [UIImage imageWithData:albumModel.normalData];
        //小图data
        smallAlbumData = UIImageJPEGRepresentation(image, compressScale);
        //原图data
        albumData        = albumModel.normalData;
    }
    //小图缓存路径
    NSString *smallDetailPath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",@"small",albumModel.name]];
    //原图缓存路径
    NSString *detailPath = [basePath stringByAppendingPathComponent:albumModel.name];
    //小图写入缓存
    [smallAlbumData writeToFile:smallDetailPath atomically:YES];
    //原图写入缓存
    [albumData writeToFile:detailPath atomically:YES];
}

@end
