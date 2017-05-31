//
//  Constant.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/4/20.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

/*
 设备
*/
static NSString *DeviceType                = @"iOS";    //设备类型


/*
 消息类型
*/
static NSString *Message_Normal                = @"normal";   //普通消息类型(文本,语音,图片,视频,文件,提示语,撤回等..)
static NSString *Message_Login                  = @"login";    //登录
static NSString *Message_Repeal                = @"repeal";   //撤回消息
static NSString *Message_Validate              = @"validate"; //验证消息
static NSString *Message_System               = @"system";   //系统消息
static NSString *Message_NormalReceipt     = @"normalReceipt";//发送普通消息回执
static NSString *Message_LoginReceipt       = @"loginReceipt"; //登录成功回执
static NSString *Message_InvalidReceipt      = @"invalidReceipt";//消息发送失败回执
static NSString *Message_RepealReceipt     = @"repealReceipt"; //撤回消息回执


/*
  消息内容类型
 */
static NSString *Content_Text            = @"text";   //文本,表情消息
static NSString *Content_Audio          = @"audio";   //语音消息
static NSString *Content_Picture        = @"picture";   //图片消息
static NSString *Content_Video          = @"video";   //视频消息
static NSString *Content_File             = @"file";   //文件消息
static NSString *Content_Tip             = @"tip";   //提示消息(欢迎XX加入群 , XX撤回了一条消息等)


/*
   icon图片名
 */
static NSString *defaulUserIcon           = @"userhead";   //文本,表情消息


/*
   标题
 */
static NSString *ChatlistTitle           = @"聊天列表";   //聊天列表标题

/*
  聊天通知
 */
static NSString *ChatKeyboardResign = @"ChatKeyboardShouldResignFirstResponder"; //键盘失去第一响应者


/*
 enum
 */

//长按消息操作类型
typedef NS_ENUM(NSInteger,LongpressSelectHandleType){
    LongpressSelectHandleTypeBack     =  0<<0, //撤回
    LongpressSelectHandleTypeDelete   =  1<<0, //删除
    LongpressSelectHandleTypeTransmit =  2<<0  //转发
};



#endif /* Constant_h */
