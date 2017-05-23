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

//创建消息模型
+ (ChatModel *)creatMessageModel:(ChatModel *)config;

//创建本地资源缓存 , 图片写入本地
+ (void)creatLocalCacheSource:(ChatAlbumModel *)albumModel chat:(ChatModel *)chatModel;

@end
