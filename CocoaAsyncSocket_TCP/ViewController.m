//
//  ViewController.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/4/14.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UITextField *messageTextField;

@property (nonatomic, strong) UIButton *sendBtn;

@end

@implementation ViewController

- (UIButton *)sendBtn
{
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:18.f weight:0.5];
        _sendBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    return _sendBtn;
}

- (UITextField *)messageTextField
{
    if (!_messageTextField) {
        _messageTextField = [[UITextField alloc]init];
        _messageTextField.placeholder = @"请输入消息内容";
        _messageTextField.textColor = [UIColor redColor];
        _messageTextField.font = [UIFont systemFontOfSize:14.f];
        _messageTextField.textAlignment = NSTextAlignmentLeft;
        _messageTextField.layer.borderColor = [UIColor redColor].CGColor;
        _messageTextField.layer.borderWidth = 1.f;
        
    }
    return _messageTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}


- (void)initUI
{
    [self.view addSubview:self.messageTextField];
    self.messageTextField.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 200)*0.5,200, 200, 20);
    
    [self.view addSubview:self.sendBtn];
    self.sendBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 100)*0.5, 250, 80,50);
}

/*
 
  <关于连接状态监听>
 
 1. 普通网络监听
 
  由于即时通讯对于网络状态的判断需要较为精确 ，原生的Reachability实际上在很多时候判断并不可靠 。
  主要体现在当网络较差时，程序可能会出现连接上网络 ， 但并未实际上能够进行数据传输 。
  开始尝试着用Reachability加上一个普通的网络请求来双重判断实现更加精确的网络监听 ， 但是实际上是不可行的 。
  如果使用异步请求依然判断不精确 ， 若是同步请求 ， 对性能的消耗会很大 。
  最终采取的解决办法 ， 使用RealReachability ，对网络监听同时 ，PING服务器地址或者百度 ，网络监听问题基本上得以解决
 
 2. TCP连接状态监听：
 
 TCP的连接状态监听主要使用服务器和客户端互相发送心跳 ，彼此验证对方的连接状态 。
 规则可以自己定义 ， 当前使用的规则是 ，当客户端连接上服务器端口后 ，且成功建立SSL验证后 ，向服务器发送一个登陆的消息(login)。
 当收到服务器的登陆成功回执（loginReceipt)开启心跳定时器 ，每一秒钟向服务器发送一次心跳 ，心跳的内容以安卓端/iOS端/服务端最终协商后为准 。
 当服务端收到客户端心跳时，也给服务端发送一次心跳 。正常接收到对方的心跳时，当前连接状态为已连接状态 ，当服务端或者客户端超过3次（自定义）没有收到对方的心跳时，判断连接状态为未连接。
 
 
 
 
 <关于本地缓存>
 
 1. 数据库缓存 
 
 建议每个登陆用户创建一个DB ，切换用户时切换DB即可 。
 搭建一个完善IM体系 ， 每个DB至少对应3张表 。
 一张用户存储聊天列表信息，这里假如它叫chatlist ，即微信首页 ，用户存储每个群或者单人会话的最后一条信息 。来消息时更新该表，并更新内存数据源中列表信息。或者每次来消息时更新内存数据源中列表信息 ，退出程序或者退出聊天列表页时进行数据库更新。后者避免了频繁操作数据库，效率更高。
 一张用户存储每个会话中的详细聊天记录 ，这里假如它叫chatinfo。该表也是如此 ，要么接到消息立马更新数据库，要么先存入内存中，退出程序时进行数据库缓存。
 一张用于存储好友或者群列表信息 ，这里假如它叫myFriends ，每次登陆或者退出，或者修改好友备注，删除好友，设置星标好友等操作都需要更新该表。
 
 2. 沙盒缓存
 
 当发送或者接收图片、语音、文件信息时，需要对信息内容进行沙盒缓存。
 沙盒缓存的目录分层 ，个人建议是在每个用户根据自己的userID在Cache中创建文件夹，该文件夹目录下创建每个会话的文件夹。
 这样做的好处在于 ， 当你需要删除聊天列表会话或者清空聊天记录 ，或者app进行内存清理时 ，便于找到该会话的所有缓存。大致的目录结构如下
 ../Cache/userID(当前用户ID)/toUserID(某个群或者单聊对象)/...（图片，语音等缓存）
 
 
 
 <聊天UI的搭建>
 
 1. 聊天列表UI（微信首页）
 
 这个页面没有太多可说的 ， 一个tableView即可搞定 。需要注意的是 ，每次收到消息时，都需要将该消息置顶 。每次进入程序时，拉取chatlist表存储的每个会话的最后一条聊天记录进行展示 。
 
 2. 会话页面
 
 该页面tableView或者collectionView均可实现 ，看个人喜好 。这里是我用的是tableView . 
 根据消息类型大致分为普通消息 ，语音消息 ，图片消息 ，文件消息 ，视频消息 ，提示语消息（以上为打招呼内容，xxx已加入群，xxx撤回了一条消息等）这几种 ，固cell的注册差不多为5种类型，每种消息对应一种消息。
 视频消息和图片消息cell可以复用 。
 不建议使用过少的cell类型 ，首先是逻辑太多 ，不便于处理 。其次是效率并不高。
 
 
 <发送消息>
 
 1. 文本消息/表情消息
 
 直接调用咱们封装好的ChatHandler的sendMessage方法即可 ， 发送消息时 ，需要存入或者更新chatlist和chatinfo两张表。若是未连接或者发送超时 ，需要重新更新数据库存储的发送成功与否状态 ，同时更新内存数据源 ，刷新该条消息展示即可。
 若是表情消息 ，传输过程也是以文本的方式传输 ，比如一个大笑的表情 ，可以定义为[大笑] ，当然规则自己可以和安卓端web端协商，本地根据plist文件和表情包匹配进行图文混排展示即可 。
 https://github.com/coderMyy/MYCoreTextLabel ，图文混排地址 ， 如果觉得有用 ， 请star一下 ，好人一生平安
 
 
 2. 语音消息
 
 语音消息需要注意的是 ，多和安卓端或者web端沟通 ，找到一个大家都可以接受的格式 ，转码时使用同一种格式，避免某些格式其他端无法播放，个人建议Mp3格式即可。
 同时，语音也需要做相应的降噪 ，压缩等操作。
 发送语音大约有两种方式 。
 一是全部内容均通过TCP传输并携带该条语音的相关信息，例如时长，大小等信息，具体的你得测试一条压缩后的语音体积有多大，若是过大，则需要进行分割然后以消息的方法时发送。接收语音时也进行拼接。
 二是语音内容使用http传输，传输到服务器生成相应的id ，获取该id再附带该条语音的相关信息 ，以TCP方式发送给对方，当对方收到该条消息时，先去下载该条信息，并根据该条语音的相关信息进行展示。
 

 
 
 
 
*/










@end
