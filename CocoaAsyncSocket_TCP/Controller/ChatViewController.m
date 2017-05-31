//
//  ChatViewController.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatKeyboard.h"   //键盘
#import "ChatTextCell.h"   //文本cell
#import "ChatAudioCell.h" //语音cell
#import "ChatImageCell.h" //图片cell
#import "ChatVideoCell.h"  //视频cell
#import "ChatFileCell.h"  // 文件cell
#import "ChatTipCell.h"  //提示语cell
#import "ChatModel.h"   //消息模型
#import "ChatUtil.h"    //工具类
#import "ChatAudioPlayTool.h" //语音播放器
#import "ChatHandler.h"

@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource,ChatHandlerDelegate>

//聊天列表
@property (nonatomic, strong) UITableView *chatTableView;
//消息数据源
@property (nonatomic, strong) NSMutableArray *talkMessages;
//titleView
@property (nonatomic, strong) UILabel *titleView;
//铃铛
@property (nonatomic, strong) UIImageView *bellView;
//键盘
@property (nonatomic, strong) ChatKeyboard *customKeyboard;
//语音播放器
@property (nonatomic, strong) ChatAudioPlayTool *audioPlayTool;
@end

@implementation ChatViewController

- (ChatKeyboard *)customKeyboard
{
    if (!_customKeyboard) {
        _customKeyboard = [[ChatKeyboard alloc]init];
        //传入当前控制器 ，方便打开相册（如放到控制器 ， 后期的逻辑过多，控制器会更加臃肿）
        __weak typeof(self) weakself = self;
        //普通文本消息
            [_customKeyboard textCallback:^(NSString *text) {
                //发送文本
                [weakself sendTextMessage:text];

        } audioCallback:^(ChatAlbumModel *audio) {
            
             [weakself sendAudioMessage:audio];
        } picCallback:^(NSArray<ChatAlbumModel *> *images) {
            
            [weakself sendPictureMessage:images];
        } videoCallback:^(ChatAlbumModel *videoModel) {
            
            [weakself sendVideoMessage:videoModel];
        } target:self];
    }
    return _customKeyboard;
}

- (UIImageView *)bellView
{
    if (!_bellView) {
        _bellView = [[UIImageView alloc]init];
        _bellView.image = LoadImage(@"grey_bell");
    }
    return _bellView;
}
- (UILabel *)titleView
{
    if (!_titleView) {
        _titleView = [[UILabel alloc]init];
        _titleView.font = FontSet(16);
        _titleView.textColor = UIMainWhiteColor;
        _titleView.textAlignment = NSTextAlignmentLeft;
        //铃铛
        [_titleView addSubview:self.bellView];
    }
    return _titleView;
}

- (NSMutableArray *)talkMessages
{
    if (!_talkMessages) {
        _talkMessages = [NSMutableArray array];
    }
    return _talkMessages;
}

- (UITableView *)chatTableView
{
    if (!_chatTableView) {
        _chatTableView = [[UITableView alloc]initWithFrame:Frame(0, 0, SCREEN_WITDTH, Height(self.view.bounds)-49) style:UITableViewStylePlain];
        _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _chatTableView.backgroundColor = UIMainBackColor;
        _chatTableView.allowsSelection = NO;
        _chatTableView.delegate     = self;
        _chatTableView.dataSource = self;
        //普通文本,表情消息类型
        [_chatTableView registerClass:[ChatTextCell class] forCellReuseIdentifier:@"ChatTextCell"];
        //语音消息类型
        [_chatTableView registerClass:[ChatAudioCell class] forCellReuseIdentifier:@"ChatAudioCell"];
        //图片消息类型
        [_chatTableView registerClass:[ChatImageCell class] forCellReuseIdentifier:@"ChatImageCell"];
        //视频消息类型
        [_chatTableView registerClass:[ChatVideoCell class] forCellReuseIdentifier:@"ChatVideoCell"];
        //文件消息类型
        [_chatTableView registerClass:[ChatFileCell class] forCellReuseIdentifier:@"ChatFileCell"];
         //提示消息类型
        [_chatTableView registerClass:[ChatTipCell class] forCellReuseIdentifier:@"ChatTipCell"];
    }
    return _chatTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化UI
    [self initUI];
    //拉取数据库消息
    [self getHistoryMessages];
    //注册成为handler代理
    [[ChatHandler shareInstance]addDelegate:self delegateQueue:nil];
}

#pragma mark - 接收消息
- (void)didReceiveMessage:(ChatModel *)chatModel type:(ChatMessageType)messageType
{
    switch (messageType) {
        //普通消息
        case ChatMessageType_Normal:
        {
            [self.talkMessages addObject:chatModel];
            [self.chatTableView reloadData];
            [self scrollToBottom];
        }
            break;
        //普通消息成功回执
        case ChatMessageType_NormalReceipt:
        {
            NSPredicate *predict = [NSPredicate predicateWithFormat:@"sendTime = %@",chatModel.sendTime];
            ChatModel *refreshModel = [self.talkMessages filteredArrayUsingPredicate:predict].firstObject;
            refreshModel.isSend = @1;
            refreshModel.isSending = @0;
            [self.chatTableView reloadData];
        }
            break;
        //失败回执
        case ChatMessageType_InvalidReceipt:
        {
        }
            break;
        //撤回消息回执
        case ChatMessageType_RepealReceipt:
        {
        }
            break;
        default:
            break;
    }
}

#pragma mark - 注册通知
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //系统键盘弹起通知
    [[NSNotificationCenter defaultCenter]addObserver:self.customKeyboard selector:@selector(systemKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //自定义键盘系统键盘降落
    [[NSNotificationCenter defaultCenter]addObserver:self.customKeyboard selector:@selector(keyboardResignFirstResponder:) name:ChatKeyboardResign object:nil];
}

#pragma mark - dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.talkMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatModel *chatModel = self.talkMessages[indexPath.row];
    __weak typeof(self) weakself = self;
    //文本,表情消息
    if (hashEqual(chatModel.contenType, Content_Text)) {
        
        ChatTextCell *textCell = [tableView dequeueReusableCellWithIdentifier:@"ChatTextCell"];
        textCell.textModel = chatModel;
        return textCell;
        
        //语音消息
    }else if (hashEqual(chatModel.contenType, Content_Audio)){
        
        ChatAudioCell *audioCell = [tableView dequeueReusableCellWithIdentifier:@"ChatAudioCell"];
        audioCell.audioModel      = chatModel;
        //重新发送
        [audioCell sendAgain:^(ChatModel *audioModel) {
            
        //播放语音
        } playAudio:^(NSString *path) {
        
            [weakself playAudio:path];
        //长按操作
        } longpress:^(LongpressSelectHandleType type, ChatModel *audioModel) {
        
        //用户详情
        } toUserInfo:^(NSString *userID) {
            
        }];
        return audioCell;
        
        //图片消息
    }else if (hashEqual(chatModel.contenType, Content_Picture)){
        
        ChatImageCell *imageCell = [tableView dequeueReusableCellWithIdentifier:@"ChatImageCell"];
        imageCell.imageModel = chatModel;
        return imageCell;
        
        //视频消息
    }else if (hashEqual(chatModel.contenType, Content_Video)){
        
        ChatVideoCell *videoCell = [tableView dequeueReusableCellWithIdentifier:@"ChatVideoCell"];
        
        return videoCell;
        
        //文件消息
    }else if (hashEqual(chatModel.contenType, Content_File)){
        
        ChatFileCell *fileCell = [tableView dequeueReusableCellWithIdentifier:@"ChatFileCell"];
        
        return fileCell;
        
        //提示语消息
    }else{
        
        ChatTipCell *tipCell = [tableView dequeueReusableCellWithIdentifier:@"ChatTipCell"];
        
        return tipCell;
    }
}


#pragma mark - 拉取数据库消息
- (void)getHistoryMessages
{
    
}

#pragma mark - 初始化UI
- (void)initUI
{
    //初始化导航
    self.titleView.text = [_config.chatType isEqualToString:@"groupChat"] ? _config.groupName : _config.nickName;
    self.navigationItem.titleView = self.titleView;
    CGSize titleSize = [self.titleView.text sizeWithFont:self.titleView.font maxSize:CGSizeMake(200,16)];
    //正常接收消息状态
    if (_config.noDisturb.integerValue == 1) {
        self.titleView.bounds = Frame(0, 0, titleSize.width, 16);
        self.bellView.hidden  = YES;
    }else{
        self.titleView.bounds  = Frame(0, 0, titleSize.width + 5 + 14, 16);
        self.bellView.frame    = Frame(titleSize.width + 5, (Height(self.titleView.frame)-14)*0.5, 14, 14);
    }
    //初始化聊天界面
    [self.view addSubview:self.chatTableView];
    //初始化键盘
    [self.view addSubview:self.customKeyboard];
    self.customKeyboard.frame = Frame(0, SCREEN_HEIGHT - 49, SCREEN_WITDTH, CTKEYBOARD_DEFAULTHEIGHT);
}


#pragma mark - 发送文本/表情消息
- (void)sendTextMessage:(NSString *)text
{
    //创建文本消息
    ChatModel *textModel = [ChatUtil initTextMessage:text config:_config];
    [self.talkMessages addObject:textModel];
    [self.chatTableView reloadData];
    [self scrollToBottom];
    //传输文本
    [[ChatHandler shareInstance]sendTextMessage:textModel];
}

#pragma mark - 发送语音消息
- (void)sendAudioMessage:(ChatAlbumModel *)audio
{
    ChatModel *audioModel = [ChatUtil initAudioMessage:audio config:_config];
    [self.talkMessages addObject:audioModel];
    [self.chatTableView reloadData];
    [self scrollToBottom];
    //传输
    [[ChatHandler shareInstance]sendAudioMessage:audioModel];
}

#pragma mark - 发送图片消息
- (void)sendPictureMessage:(NSArray<ChatAlbumModel *> *)picModels
{
    //消息基本信息配置
    NSArray *picMessages = [ChatUtil initPicMessage:picModels config:_config];
    [self.talkMessages addObjectsFromArray:picMessages];
    [self.chatTableView reloadData];
    [self scrollToBottom];
    [[ChatHandler shareInstance]sendPicMessage:picMessages];
}

#pragma mark - 发送视频消息
- (void)sendVideoMessage:(ChatAlbumModel *)videoModel
{
    
}

#pragma mark - 滚动,点击等相关处理
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter]postNotificationName:ChatKeyboardResign object:nil];
}

#pragma mark - delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatModel *chatmodel = self.talkMessages[indexPath.row];
    ChatModel *premodel  = nil;
    if (self.talkMessages.count > 1) premodel = self.talkMessages[self.talkMessages.count - 2];
    //如果已经计算过 , 直接返回高度
    if (chatmodel.messageHeight) return  chatmodel.messageHeight;
    //计算消息高度
    return [ChatUtil heightForMessage:chatmodel premodel:premodel];
}

#pragma mark - 滚动到底部
- (void)scrollToBottom
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_talkMessages.count - 1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

#pragma mark - 播放语音
- (void)playAudio:(NSString *)path
{
    self.audioPlayTool = [ChatAudioPlayTool audioPlayTool:path];
    [self.audioPlayTool play];
}

@end
