//
//  ChatModel.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/4/14.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger) {
    
    SocketConnectStatus_UnConnected       = 0<<0,//未连接状态
    SocketConnectStatus_Connected         = 1<<0,//连接状态
    SocketConnectStatus_DisconnectByUser  = 2<<0,//主动断开连接
    SocketConnectStatus_Unknow            = 3<<0 //未知
    
}SocketConnectStatus;

typedef NS_ENUM(NSInteger){
    
    ChatMessageType_Login            = 0<<0,
    ChatMessageType_Normal           = 1<<0, //正常消息,文字,图片,语音,文件,撤回,提示语等..
    ChatMessageType_Validate         = 2<<0, //验证消息,添加好友,申请入群等..
    ChatMessageType_System           = 3<<0, //系统消息 ,xxx退出群,xxx加入群等..
    ChatMessageType_NormalReceipt    = 4<<0, //发送消息回执
    ChatMessageType_LoginReceipt     = 5<<0, //登录回执
    ChatMessageType_InvalidReceipt   = 6<<0, //消息发送失败回执
    ChatMessageType_RepealReceipt    = 7<<0, //撤回消息回执
    ChatMessageContentType_Unknow    = 8<<0   // 未知消息类型
    
}ChatMessageType;

typedef NS_ENUM(NSInteger){
    
    ChatMessageContentType_Text       = 0<<0, //普通文本消息,表情..
    ChatMessageContentType_Audio      = 1<<0, //语音消息
    ChatMessageContentType_Picture    = 2<<0, //图片消息
    ChatMessageContentType_Video      = 3<<0, //视频消息
    ChatMessageContentType_File       = 4<<0, //文件消息
    ChatMessageContentType_Repeal     = 5<<0, //撤回消息
    ChatMessageContentType_Tip        = 6<<0,  //提示消息,例如: 你俩还不是好友,需要验证.. 以上为打招呼内容.. xxx退出群 , 加入群...
    
}ChatMessageContentType;

@class ChatContentModel;

@interface ChatModel : NSObject

@property (nonatomic, copy) NSString *groupID; //群ID

@property (nonatomic, copy) NSString *userID;  //好友ID

@property (nonatomic, copy) NSString *fromUserID; //消息发送者ID

@property (nonatomic, copy) NSArray<NSString *> *atToUserIDs; // @目标ID

@property (nonatomic, copy) NSString *messageType; //消息类型

@property (nonatomic, copy) NSString *contenType; //内容类型

@property (nonatomic, copy) NSString *chatType;  //聊天类型 , 群聊,单聊

@property (nonatomic, copy) NSString *deviceType; //设备类型

@property (nonatomic, copy) NSString *versionCode; //TCP版本码

@property (nonatomic, copy) NSString *messageID; //消息ID

@property (nonatomic, strong) NSNumber *byMyself; //消息是否为本人所发

@property (nonatomic, copy) NSNumber *isSend;  //是否已经发送成功

@property (nonatomic, strong) NSNumber *isRead; //是否已读

@property (nonatomic, copy) NSString *senTime; //时间戳

@property (nonatomic, copy) NSString *beatID; //心跳标识

@property (nonatomic, copy) NSString *portrait; //头像url

@property (nonatomic, copy) NSString *groupName; //群名称

@property (nonatomic, copy) NSString *nickName; //好友昵称

@property (nonatomic, strong) NSNumber *noDisturb; //免打扰状态

@property (nonatomic, copy) ChatContentModel *content; //内容

@end


@interface ChatContentModel :NSObject

@property (nonatomic, copy) NSString *text; //文本

@property (nonatomic, strong) NSNumber *videoDuration; //语音时长

@property (nonatomic, copy) NSString *videoSize;  //视频大小

@property (nonatomic, copy) NSString *bigPicAdress; //图片大图地址

@property (nonatomic, strong) NSString *fileSize; //文件大小

@property (nonatomic, copy) NSString *fileType; //文件类型

@property (nonatomic, copy) NSString *fileIconAdress; //文件缩略图地址

@end


