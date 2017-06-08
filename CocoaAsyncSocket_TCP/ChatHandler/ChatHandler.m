//
//  ChatHandler.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/4/14.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatHandler.h"
#import "GCDAsyncSocket.h"

//自动重连次数
NSInteger autoConnectCount = TCP_AutoConnectCount;

@interface ChatHandler ()<GCDAsyncSocketDelegate>
//初始化聊天
@property (strong , nonatomic) GCDAsyncSocket *chatSocket;
//所有的代理
@property (nonatomic, strong) NSMutableArray *delegates;
//心跳定时器
@property (nonatomic, strong) dispatch_source_t beatTimer;
//发送心跳次数
@property (nonatomic, assign) NSInteger senBeatCount;

@end

@implementation ChatHandler

- (dispatch_source_t)beatTimer
{
    if (!_beatTimer) {
        _beatTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_beatTimer, DISPATCH_TIME_NOW, TCP_BeatDuration * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_beatTimer, ^{
            
            //发送心跳 +1
            _senBeatCount ++ ;
            //超过3次未收到服务器心跳 , 置为未连接状态
            if (_senBeatCount>TCP_MaxBeatMissCount) {
                //更新连接状态
                _connectStatus = SocketConnectStatus_UnConnected;
            }else{
                //发送心跳
                NSData *beatData = [[NSData alloc]initWithBase64EncodedString:[TCP_beatBody stringByAppendingString:@"\n"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                [_chatSocket writeData:beatData withTimeout:-1 tag:9999];
                NSLog(@"------------------发送了心跳------------------");
            }
        });
    }
    return _beatTimer;
}

- (NSMutableArray *)delegates
{
    
    if (!_delegates) {
        _delegates = [NSMutableArray array];
    }
    return _delegates;
}

#pragma mark - 初始化聊天handler单例
+ (instancetype)shareInstance
{
    static ChatHandler *handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[ChatHandler alloc]init];
    });
    return handler;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        //将handler设置成接收TCP信息的代理
        _chatSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        //设置默认关闭读取
        [_chatSocket setAutoDisconnectOnClosedReadStream:NO];
        //默认状态未连接
        _connectStatus = SocketConnectStatus_UnConnected;
    }
    return self;
}



#pragma mark - 连接服务器端口
- (void)connectServerHost
{
    NSError *error = nil;
    [_chatSocket connectToHost:@"此处填写服务器IP" onPort:8080 error:&error];
    if (error) {
        NSLog(@"----------------连接服务器失败----------------");
    }else{
        NSLog(@"----------------连接服务器成功----------------");
    }
}


#pragma mark - 添加代理
- (void)addDelegate:(id<ChatHandlerDelegate>)delegate delegateQueue:(dispatch_queue_t)queue
{
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}



#pragma mark - 移除代理
- (void)removeDelegate:(id<ChatHandlerDelegate>)delegate
{
    [self.delegates removeObject:delegate];
}


#pragma mark - 发送消息
- (void)sendMessage:(ChatModel *)chatModel timeOut:(NSUInteger)timeOut tag:(long)tag
{
    //将模型转换为json字符串
    NSString *messageJson = chatModel.mj_JSONString;
    //以"\n"分割此条消息 , 支持的分割方式有很多种例如\r\n、\r、\n、空字符串,不支持自定义分隔符,具体的需要和服务器协商分包方式 , 这里以\n分包
    /*
     如不进行分包,那么服务器如果在短时间里收到多条消息 , 那么就会出现粘包的现象 , 无法识别哪些数据为单独的一条消息 .
     对于普通文本消息来讲 , 这里的处理已经基本上足够 . 但是如果是图片进行了分割发送,就会形成多个包 , 那么这里的做法就显得并不健全,严谨来讲,应该设置包头,把该条消息的外信息放置于包头中,例如图片信息,该包长度等,服务器收到后,进行相应的分包,拼接处理.
     */
    messageJson           = [messageJson stringByAppendingString:@"\n"];
    //base64编码成data
    NSData  *messageData  = [[NSData alloc]initWithBase64EncodedString:messageJson options:NSDataBase64DecodingIgnoreUnknownCharacters];
    //写入数据
    [_chatSocket writeData:messageData withTimeout:1 tag:1];
}


#pragma mark - 主动断开连接
- (void)executeDisconnectServer
{
    //更新sokect连接状态
    _connectStatus = SocketConnectStatus_UnConnected;
    [self disconnect];
}

#pragma mark - 连接中断
- (void)serverInterruption
{
    //更新soceket连接状态
    _connectStatus = SocketConnectStatus_UnConnected;
    [self disconnect];
}

- (void)disconnect
{
    //断开连接
    [_chatSocket disconnect];
    //关闭心跳定时器
    dispatch_source_cancel(self.beatTimer);
    //未接收到服务器心跳次数,置为初始化
    _senBeatCount = 0;
    //自动重连次数 , 置为初始化
    autoConnectCount = TCP_AutoConnectCount;
}


#pragma mark - 开启接收数据
- (void)beginReadDataTimeOut:(long)timeOut tag:(long)tag
{
    [_chatSocket readDataToData:[GCDAsyncSocket LFData] withTimeout:timeOut maxLength:0 tag:tag];
}

#pragma mark - 发送心跳
- (void)sendBeat
{
    //已经连接
    _connectStatus = SocketConnectStatus_Connected;
    //定时发送心跳开启
    dispatch_resume(self.beatTimer);
}



/**********************************************delegate*********************************************************/
#pragma mark - 接收到消息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //转为明文消息
    NSString *secretStr  = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    //去除'\n'
    secretStr            = [secretStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    //转为消息模型(具体传输的json包裹内容,加密方式,包头设定什么的需要和后台协商,操作方式根据项目而定)
    ChatModel *messageModel = [ChatModel mj_objectWithKeyValues:secretStr];
    
    //接收到服务器的心跳
    if ([messageModel.beatID isEqualToString:TCP_beatBody]) {
        
        //未接到服务器心跳次数置为0
        _senBeatCount = 0;
        NSLog(@"------------------接收到服务器心跳-------------------");
        return;
    }
    
    //消息类型 (消息类型这里是以和服务器协商后自定义的通信协议来设定 , 包括字段名,具体的通信逻辑相关 . 当然也可以用数字来替代下述的字段名,使用switch效率更高)
    ChatMessageType messageType     = ChatMessageContentType_Unknow;
    
    //普通消息类型
    if ([messageModel.messageType isEqualToString:Message_Normal]) {
        messageType = ChatMessageType_Normal;
        
        //验证消息
    }else if ([messageModel.messageType isEqualToString:Message_Validate]){
        messageType = ChatMessageType_Validate;
        
        //系统消息
    }else if ([messageModel.messageType isEqualToString:Message_System]){
        messageType = ChatMessageType_System;
        
        //发送普通消息回执
    }else if ([messageModel.messageType isEqualToString:Message_NormalReceipt]){
        messageType = ChatMessageType_NormalReceipt;
        
        //登录成功回执
    }else if ([messageModel.messageType isEqualToString:Message_LoginReceipt]){
        messageType = ChatMessageType_LoginReceipt;
        //开始发送心跳
        [self sendBeat];
        //重新建立连接后 , 重置自动重连次数
        autoConnectCount = TCP_AutoConnectCount;
        
        //发送普通消息失败回执
    }else if ([messageModel.messageType isEqualToString:Message_InvalidReceipt]){
        messageType = ChatMessageType_InvalidReceipt;
        
        //撤回消息回执
    }else if ([messageModel.messageType isEqualToString:Message_RepealReceipt]){
        messageType = ChatMessageType_RepealReceipt;
        
        // 未知消息类型
    }else{
        messageType = ChatMessageContentType_Unknow;
    }
    
#warning  - 注意 ...
    //此处可以进行本地数据库存储,具体的就不多解释 , 通常来讲 , 每个登录用户创建一个DB ,每个DB对应3张表足够 ,一张用于存储聊天列表页 , 一张用于会话聊天记录存储,还有一张用于好友列表/群列表的本地化存储. 但是注意的一点 , 必须设置自增ID . 此外,个人建议预留出10个或者20个字段以备将来增加需求,或者使用数据库升级亦可
    
    //进行回执服务器,告知服务器已经收到该条消息(实际上是可以解决消息丢失问题 , 因为心跳频率以及网络始终是有一定延迟,当你断开的一瞬间,服务器并没有办法非常及时的获取你的连接状态,所以进行双向回执会更加安全,服务器推向客户端一条消息,客户端未进行回执的话,服务器可以将此条消息设置为离线消息,再次进行推送)
    
    //消息分发,将消息发送至每个注册的Object中 , 进行相应的布局等操作
    for (id delegate in self.delegates) {
        
        if ([delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
            [delegate didReceiveMessage:messageModel type:messageType];
        }
    }
}

#pragma mark - 写入数据成功 , 重新开启允许读取数据
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [self beginReadDataTimeOut:-1 tag:0];
}

#pragma mark - TCP连接成功建立 ,配置SSL 相当于https 保证安全性 , 这里是单向验证服务器地址 , 仅仅需要验证服务器的IP即可
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    // 配置 SSL/TLS 设置信息
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithCapacity:3];
    //允许自签名证书手动验证
    [settings setObject:@YES forKey:GCDAsyncSocketManuallyEvaluateTrust];
    //GCDAsyncSocketSSLPeerName
    [settings setObject:@"此处填服务器IP地址" forKey:GCDAsyncSocketSSLPeerName];
    [_chatSocket startTLS:settings];
}

#pragma mark - TCP成功获取安全验证
- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    //登录服务器
    ChatModel *loginModel  = [[ChatModel alloc]init];
    //此版本号需和后台协商 , 便于后台进行版本控制
    loginModel.versionCode = TCP_VersionCode;
    //当前用户ID
    loginModel.fromUserID  = [Account account].myUserID;
    //设备类型
    loginModel.deviceType  = DeviceType;
    //发送登录验证
    [self sendMessage:loginModel timeOut:-1 tag:0];
    //开启读入流
    [self beginReadDataTimeOut:-1 tag:0];
}

#pragma mark - TCP已经断开连接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
//    //如果是主动断开连接
//    if (_connectStatus == SocketConnectStatus_DisconnectByUser) return;
    //置为未连接状态
    _connectStatus  = SocketConnectStatus_UnConnected;
    //自动重连
    if (autoConnectCount) {
        [self connectServerHost];
        NSLog(@"-------------第%ld次重连--------------",(long)autoConnectCount);
        autoConnectCount -- ;
    }else{
        NSLog(@"----------------重连次数已用完------------------");
    }
}

#pragma mark - 发送消息超时
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    //此处进行数据库更新消息处理
    
    //发送超时消息分发
    for (id<ChatHandlerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(sendMessageTimeOutWithTag:)]) {
            [delegate sendMessageTimeOutWithTag:tag];
        }
    }
    return -1;
}


#pragma mark - 网络监听
- (void)networkChanged:(NSNotification *)notification {
    
//    if (_connectStatus == SocketConnectStatus_DisconnectByUser) return; //主动断开连接
    
    if (networkStatus == RealStatusNotReachable||_connectStatus == SocketConnectStatus_UnConnected) {
        [self serverInterruption];//断开连接,默认还会重连3次 ,还未连接自动断开
    }
    if (networkStatus == RealStatusViaWWAN || networkStatus == RealStatusViaWiFi) {
        [self connectServerHost]; //连接服务器
    }
}




#pragma mark - 消息发送
//发送文本消息
- (void)sendTextMessage:(ChatModel *)textModel
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //模拟服务器回执
        ChatModel *receipet = [[ChatModel alloc]init];
        receipet.messageType = Message_NormalReceipt;
        receipet.sendTime = textModel.sendTime;
        ChatMessageType type = ChatMessageType_NormalReceipt;
        for (id<ChatHandlerDelegate>delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                [delegate didReceiveMessage:receipet type:type];
            }
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //模拟回复
        ChatModel *reply = [[ChatModel alloc]init];
        ChatContentModel *content = [[ChatContentModel alloc]init];
        reply.content = content;
        reply.content.text = @"收到文本内容";
        reply.messageType = Message_Normal;
        reply.contenType = Content_Text;
        reply.toUserID = textModel.fromUserID;
        reply.chatType = @"userChat";
        reply.byMyself = @0;
        ChatMessageType type = ChatMessageType_Normal;
        for (id<ChatHandlerDelegate>delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                [delegate didReceiveMessage:reply type:type];
            }
        }
    });
}

//发送语音消息
- (void)sendAudioMessage:(ChatModel *)audioModel
{
    //此处调用上传 , 上传成功后调用socket发送消息
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //模拟服务器回执
        ChatModel *receipet = [[ChatModel alloc]init];
        receipet.messageType = Message_NormalReceipt;
        receipet.sendTime = audioModel.sendTime;
        ChatMessageType type = ChatMessageType_NormalReceipt;
        for (id<ChatHandlerDelegate>delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                [delegate didReceiveMessage:receipet type:type];
            }
        }
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //模拟回复
        ChatModel *reply = [[ChatModel alloc]init];
        ChatContentModel *content = [[ChatContentModel alloc]init];
        reply.content = content;
        reply.content.text = @"收到语音";
        reply.messageType = Message_Normal;
        reply.contenType = Content_Text;
        reply.toUserID = audioModel.fromUserID;
        reply.chatType = @"userChat";
        reply.byMyself = @0;
        ChatMessageType type = ChatMessageType_Normal;
        for (id<ChatHandlerDelegate>delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                [delegate didReceiveMessage:reply type:type];
            }
        }
    });
}

//发送图片消息
- (void)sendPicMessage:(NSArray<ChatModel *>*)picModels
{
 
    //此处调用上传 , 上传成功后调用socket发送消息
    [picModels enumerateObjectsUsingBlock:^(ChatModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            //模拟服务器回执
            ChatModel *receipet = [[ChatModel alloc]init];
            receipet.messageType = Message_NormalReceipt;
            receipet.sendTime = obj.sendTime;
            NSLog(@"---回执--%@",receipet.sendTime);
            ChatMessageType type = ChatMessageType_NormalReceipt;
            for (id<ChatHandlerDelegate>delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    [delegate didReceiveMessage:receipet type:type];
                }
            }
        });

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            //模拟回复
            ChatModel *reply = [[ChatModel alloc]init];
            ChatContentModel *content = [[ChatContentModel alloc]init];
            reply.content = content;
            reply.content.text = @"收到图片";
            reply.messageType = Message_Normal;
            reply.contenType = Content_Text;
            reply.toUserID = obj.fromUserID;
            reply.chatType = @"userChat";
            reply.byMyself = @0;
            ChatMessageType type = ChatMessageType_Normal;
            for (id<ChatHandlerDelegate>delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    [delegate didReceiveMessage:reply type:type];
                }
            }
        });
    }];
}

//发送视频消息
- (void)sendVideoMessage:(ChatModel *)videoModel
{
}


@end
