//
//  ChatUtil.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChatModel,ChatAlbumModel;

@interface ChatUtil : NSObject

//消息高度计算
+ (CGFloat)heightForMessage:(ChatModel *)currentChatmodel premodel:(ChatModel *)premodel;

//初始化文本消息模型
+ (ChatModel *)initTextMessage:(NSString *)text config:(ChatModel *)config;
//初始化语音消息模型
+ (ChatModel *)initAudioMessage:(ChatAlbumModel *)audio config:(ChatModel *)config;
//初始化图片消息模型
+ (NSArray<ChatModel *> *)initPicMessage:(NSArray<ChatAlbumModel *> *)pics config:(ChatModel *)config;
//初始化视频消息模型
+ (ChatModel *)initVideoMessage:(ChatAlbumModel *)video config:(ChatModel *)config;

@end
