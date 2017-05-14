//
//  ChatUtil.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChatModel;

@interface ChatUtil : NSObject

//消息高度计算
+ (CGFloat)heightForMessage:(ChatModel *)currentChatmodel premodel:(ChatModel *)premodel;

@end
