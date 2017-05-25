//
//  ChatKeyboard.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/15.
//  Copyright © 2017年 mengyao. All rights reserved.
//
#define CTKEYBOARD_DEFAULTHEIGHT   273

@class ChatModel,ChatAlbumModel;

#import <UIKit/UIKit.h>

//普通文本/表情消息发送回调
typedef void(^ChatTextMessageSendBlock)(NSString *text);
//语音消息发送回调
typedef void(^ChatAudioMesssageSendBlock)(ChatAlbumModel *audio);
//图片消息发送回调
typedef void(^ChatPictureMessageSendBlock)(NSArray<ChatAlbumModel *>* images);
//视频消息发送回调
typedef void(^ChatVideoMessageSendBlock)(ChatAlbumModel *videoModel);

@interface ChatKeyboard : UIView

//仅声明,消除警告
- (void)systemKeyboardWillShow:(NSNotification *)note;
//发送消息回调
- (void)textCallback:(ChatTextMessageSendBlock)textCallback audioCallback:(ChatAudioMesssageSendBlock)audioCallback picCallback:(ChatPictureMessageSendBlock)picCallback videoCallback:(ChatVideoMessageSendBlock)videoCallback target:(id)target ;

@end
