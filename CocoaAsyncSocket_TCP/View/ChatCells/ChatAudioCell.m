//
//  ChatAudioCell.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatAudioCell.h"
#import "ChatModel.h"

@interface ChatAudioCell ()
//头像
@property (nonatomic, strong) UIImageView *iconView;
//背景
@property (nonatomic, strong) UIImageView *backButton; //背景
//时间
@property (nonatomic, strong) UILabel *timeLabel;
//时间容器
@property (nonatomic, strong) UIView *timeContainer;
//失败按钮
@property (nonatomic, strong) UIButton *failureButton;
//菊花
@property (nonatomic, strong) UIActivityIndicatorView *activiView;
//秒数label
@property (nonatomic, strong) UILabel *secondLabel;
//红点
@property (nonatomic, strong) UILabel *redPoint;
//声音GIF
@property (nonatomic, strong) UIImageView *voiceGIFView;
//昵称
@property (nonatomic, strong) UILabel *nickNameLabel;//昵称
//播放回调
@property (nonatomic, copy) playAudioCallback playCallback;
//长按回调
@property (nonatomic, copy) longpressCallback longpressCallback;
//用户详情回调
@property (nonatomic, copy) userInfoCallback userInfoCallback;
//重新发送回调
@property (nonatomic, copy) sendAgainCallback sendAgainCallback;
@end

@implementation ChatAudioCell

//秒数
- (UILabel *)secondLabel
{
    if (!_secondLabel) {
        _secondLabel = [[UILabel alloc]init];
        _secondLabel.font = FontSet(12.f);
        _secondLabel.textColor = UICOLOR_RGB_Alpha(0x999999, 1);
    }
    return _secondLabel;
}

//昵称
- (UILabel *)nickNameLabel
{
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc]init];
        _nickNameLabel.font = FontSet(12.f);
        _nickNameLabel.textColor = UICOLOR_RGB_Alpha(0x333333, 1);
    }
    return _nickNameLabel;
}

//红点
- (UILabel *)redPoint
{
    if (!_redPoint) {
        _redPoint = [[UILabel alloc]init];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            ViewRadius(_redPoint, 4.f);
        });
        _redPoint.backgroundColor = [UIColor redColor];
    }
    return _redPoint;
}

//语音动画
- (UIImageView *)voiceGIFView
{
    if (!_voiceGIFView) {
        _voiceGIFView = [[UIImageView alloc]init];
    }
    return _voiceGIFView;
}

//菊花
- (UIActivityIndicatorView *)activiView
{
    if (!_activiView) {
        _activiView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activiView.color = UICOLOR_RGB_Alpha(0xcdcdcd, 1);
    }
    return _activiView;
}

//失败按钮
- (UIButton *)failureButton
{
    if (!_failureButton) {
        _failureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_failureButton setImage:LoadImage(@"发送失败") forState:UIControlStateNormal];
        [_failureButton addTarget:self action:@selector(sendAgain) forControlEvents:UIControlEventTouchUpInside];
        _failureButton.hidden = YES; //默认隐藏
    }
    return _failureButton;
}

//时间容器
- (UIView *)timeContainer
{
    if (!_timeContainer) {
        _timeContainer = [[UIView alloc]init];
        _timeContainer.backgroundColor = UICOLOR_RGB_Alpha(0xcecece, 1);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            ViewRadius(_timeContainer, 5.f);
        });
        [_timeContainer addSubview:self.timeLabel];
    }
    return _timeContainer;
}

//时间
- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textColor = UIMainWhiteColor;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = FontSet(12);
    }
    return _timeLabel;
}

//气泡
- (UIImageView *)backButton
{
    if (!_backButton) {
        _backButton = [[UIImageView alloc]init];
        _backButton.userInteractionEnabled = YES;
        [_backButton addSubview:self.voiceGIFView];
        //单击手势,播放语音
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playAudio)];
        [_backButton addGestureRecognizer:tap];
        //长按手势
        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longpressHandle)];
        [_backButton addGestureRecognizer:longpress];
    }
    return _backButton;
}

//头像
- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc]init];
        _iconView.userInteractionEnabled = YES;
        ViewRadius(_iconView,25);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toUserInfo)];
        [_iconView addGestureRecognizer:tap];
    }
    return _iconView;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = UIMainBackColor;
        [self.contentView addSubview:self.timeContainer];
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.backButton];
        [self.contentView addSubview:self.redPoint];
        [self.contentView addSubview:self.secondLabel];
        [self.contentView addSubview:self.activiView];
    }
    return self;
}

- (void)setAudioModel:(ChatModel *)audioModel
{
    _audioModel = audioModel;
    
    //处理时间
    self.timeContainer.frame = CGRectZero;
    //处理时间
    if (audioModel.shouldShowTime) {
        self.timeLabel.text = [NSDate timeStringWithTimeInterval:audioModel.sendTime];
        CGSize timeTextSize  = [self.timeLabel sizeThatFits:CGSizeMake(SCREEN_WITDTH, 20)];
        self.timeLabel.frame = Frame(5,(20 - timeTextSize.height)*0.5, timeTextSize.width, timeTextSize.height);
        self.timeContainer.frame = Frame((SCREEN_WITDTH - timeTextSize.width-10)*0.5, 15,timeTextSize.width + 10, 20);
    }
    self.timeContainer.hidden = !audioModel.shouldShowTime;
    //处理失败按钮
    BOOL isSend   = [audioModel.isSend integerValue];
    self.failureButton.hidden   = isSend || audioModel.isSending.integerValue || !audioModel.byMyself.integerValue;
    //昵称隐藏处理
    self.nickNameLabel.hidden = audioModel.byMyself.integerValue || hashEqual(audioModel.chatType, @"userChat");
    //红点隐藏处理
    self.redPoint.hidden   = audioModel.byMyself.integerValue || audioModel.isRead.integerValue;
    //转圈处理
    audioModel.isSending.integerValue &&audioModel.byMyself.integerValue ? [self.activiView startAnimating] : [self.activiView stopAnimating];
    //赋值
    [self setContent];
    //frame
    [self setFrame];
}


- (void)setContent
{
    //秒数
    self.secondLabel.text = [NSString stringWithFormat:@"%@''",_audioModel.content.seconds];

    //我方
    if (_audioModel.byMyself.integerValue) {
        
        //头像
        [self.iconView downloadImage:[Account account].portrait placeholder:defaulUserIcon];
        //气泡
        UIImage *voiceBackImage = LoadImage(@"我方文字气泡");
        //拉伸
        voiceBackImage           = [voiceBackImage stretchableImageWithLeftCapWidth:voiceBackImage.size.width *0.5 topCapHeight:voiceBackImage.size.height *0.5];
        self.backButton.image   = voiceBackImage;
        self.voiceGIFView.image = LoadImage(@"我方语音icon03");
    }else{
        
        //头像
        [self.iconView downloadImage:_audioModel.fromPortrait placeholder:defaulUserIcon];
        //气泡
        UIImage *voiceBackImage = LoadImage(@"对方文字气泡");
        //拉伸
        [voiceBackImage resizableImageWithCapInsets:UIEdgeInsetsMake(voiceBackImage.size.height *0.9, voiceBackImage.size.width *0.5, voiceBackImage.size.height *0.1, voiceBackImage.size.width * 0.5) resizingMode:UIImageResizingModeStretch];
        self.backButton.image = voiceBackImage;
        self.voiceGIFView.image = LoadImage(@"对方语音icon03");
    }
}

- (void)setFrame
{
    //计算语音长度
    CGFloat length = 0;
    CGFloat maxLength = SCREEN_WITDTH - 145;
    //默认最小值为30
    CGFloat minLength = 40;
    //秒数
    NSInteger seconds = _audioModel.content.seconds.integerValue;
//    self.audioSeconds = seconds;
    //1秒
    switch (seconds) {
        case 1:
            length = minLength;
            break;
            //60秒
        case 60:
            length = maxLength;
            break;
            //其他
        default:
        {
            length = 40 + (SCREEN_WITDTH - 145)/59 *seconds;
            if (length >maxLength) {   //超过60秒 还是显示60秒长度
                length = maxLength;
            }
        }
            break;
    }
    CGSize secondSize = [self.secondLabel.text sizeWithFont:self.secondLabel.font maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    
    //我方
    if (_audioModel.byMyself.integerValue) {
        
        self.iconView.frame = Frame(SCREEN_WITDTH - 65,MaxY(self.timeContainer.frame)+15, 50, 50);
        self.backButton.frame = Frame(SCREEN_WITDTH - 70-length, MinY(self.iconView.frame)+5, length, 40);
        //动画
        self.voiceGIFView.frame = Frame(Width(self.backButton.frame)-39, (Height(self.backButton.frame)-24)*0.5, 24, 24);
        //红点
        self.redPoint.frame = Frame(MinX(self.backButton.frame)-13, MinY(self.backButton.frame), 8, 8);
        //秒数label
        self.secondLabel.frame = Frame(MinX(self.backButton.frame)-10-secondSize.width, MinY(self.backButton.frame)+14, secondSize.width, 12);
        //菊花
        self.activiView.frame = Frame(MinX(self.secondLabel.frame)-34, MinY(self.backButton.frame)+8, 24, 24);
        //发送失败按钮
        self.failureButton.frame = self.activiView.frame;
        
        //别人语音
    }else{
        
        if (hashEqual(_audioModel.chatType, @"userChat")) {  //单聊
            self.nickNameLabel.hidden = YES;
            //头像
            self.iconView.frame = Frame(15, MaxY(self.timeContainer.frame)+15, 50, 50);
        }else{
            self.nickNameLabel.hidden = NO;
            self.nickNameLabel.frame = Frame(15 + 50 +10.f,MaxX(self.timeContainer.frame)+15.f, 250, 13.f);
            //头像
            self.iconView.frame = Frame(15, MaxY(self.nickNameLabel.frame)+3, 50, 50);
        }
        //气泡
        self.backButton.frame = Frame(MaxX(self.iconView.frame)+5,MinY(self.iconView.frame)+5.f, length, 40);
        //语音动画
        self.voiceGIFView.frame = Frame(15, (Height(self.backButton.frame)-24)*0.5, 24, 24);
        self.voiceGIFView.image = LoadImage(@"对方语音icon03");
        //红点
        self.redPoint.frame = Frame(MaxX(self.backButton.frame)+5, MinY(self.backButton.frame), 8, 8);
        //时间秒数
        self.secondLabel.frame = Frame(MaxX(self.backButton.frame)+10, MinY(self.backButton.frame)+14, secondSize.width, 12);
    }
}


#pragma mark - 播放语音
- (void)playAudio
{
    NSArray *gifs = _audioModel.byMyself.integerValue ? @[@"我方语音icon01",@"我方语音icon02",@"我方语音icon03"] : @[@"对方语音icon01",@"对方语音icon02",@"对方语音icon03"];
    [self.voiceGIFView GIF_PrePlayWithImageNamesArray:gifs duration:_audioModel.content.seconds.integerValue];
    NSString *audioPath = nil;
    //单聊
    if (hashEqual(_audioModel.chatType, @"userChat")) {
        //本人发送
        if (_audioModel.byMyself.integerValue) {
            audioPath = [NSString stringWithFormat:@"%@/%@/%@",ChatCache_Path,_audioModel.toUserID,_audioModel.content.fileName];
        }else{
            audioPath = [NSString stringWithFormat:@"%@/%@/%@",ChatCache_Path,_audioModel.fromUserID,_audioModel.content.fileName];
        }
    }else{
        audioPath = [NSString stringWithFormat:@"%@/%@/%@",ChatCache_Path,_audioModel.groupID,_audioModel.content.fileName];
    }
    //回调播放
    if (_playCallback) {
        _playCallback(audioPath);
    }
}

#pragma mark - 回调
- (void)sendAgain:(sendAgainCallback)sendAgain playAudio:(playAudioCallback)playAudio longpress:(longpressCallback)longpress toUserInfo:(userInfoCallback)userDetailCallback
{
    _sendAgainCallback = sendAgain;
    _playCallback          = playAudio;
    _longpressCallback  = longpress;
    _userInfoCallback    = userDetailCallback;
}


#pragma mark - 重新发送
- (void)sendAgain
{
    
}

#pragma mark - 语音长按
- (void)longpressHandle
{
    
}

#pragma mark - 进入用户详情
- (void)toUserInfo
{
    
}



@end
