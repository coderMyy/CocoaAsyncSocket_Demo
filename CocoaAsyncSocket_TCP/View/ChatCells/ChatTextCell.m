//
//  ChatTextCell.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatTextCell.h"
#import "MYCoreTextLabel.h"
#import "ChatModel.h"

@interface ChatTextCell ()<MYCoreTextLabelDelegate>

//头像
@property (nonatomic, strong) UIImageView *iconView;
//背景
@property (nonatomic, strong) UIImageView *backButton; //背景
//文字图文混排
@property (nonatomic, strong) MYCoreTextLabel *coreLabel;
//时间
@property (nonatomic, strong) UILabel *timeLabel;
//时间容器
@property (nonatomic, strong) UIView *timeContainer;
//失败按钮
@property (nonatomic, strong) UIButton *failureButton;
//菊花
@property (nonatomic, strong) UIActivityIndicatorView *activiView;
//昵称
@property (nonatomic, strong) UILabel *nickNameLabel;
@end

@implementation ChatTextCell

- (UILabel *)nickNameLabel
{
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc]init];
        _nickNameLabel.font = FontSet(12.f);
        _nickNameLabel.textColor = UICOLOR_RGB_Alpha(0x333333, 1);
    }
    return _nickNameLabel;
}

- (MYCoreTextLabel *)coreLabel
{
    if (!_coreLabel) {
        _coreLabel = [[MYCoreTextLabel alloc]init];
        _coreLabel.textFont = FontSet(14);
        _coreLabel.textColor = UICOLOR_RGB_Alpha(0x333333, 1);
        _coreLabel.lineSpacing = 6;
        _coreLabel.delegate = self;
        _coreLabel.showWebLink = YES;
        _coreLabel.showMailLink = YES;
        _coreLabel.showPhoneLink = YES;
    }
    return _coreLabel;
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

- (UIImageView *)backButton
{
    if (!_backButton) {
        _backButton = [[UIImageView alloc]init];
        _backButton.userInteractionEnabled = YES;
        //背景气泡
        UIImage *backImage = LoadImage(@"我方文字气泡");
        //拉伸
        backImage = [backImage stretchableImageWithLeftCapWidth:backImage.size.width *0.2 topCapHeight:backImage.size.height *0.9];
        _backButton.image = backImage;
        //长按手势
        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longpressHandle)];
        [_backButton addGestureRecognizer:longpress];
        [_backButton addSubview:self.coreLabel];
    }
    return _backButton;
}


- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc]init];
        _iconView.userInteractionEnabled = YES;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            ViewRadius(_iconView,25);
        });
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toUserInfo)];
        [_iconView addGestureRecognizer:tap];
        //头像长按
        UILongPressGestureRecognizer *iconLongPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(iconLongPress:)];
        [_iconView addGestureRecognizer:iconLongPress];
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
        [self.contentView addSubview:self.activiView];
        [self.contentView addSubview:self.failureButton];
    }
    return self;
}

- (void)setTextModel:(ChatModel *)textModel
{
    _textModel = textModel;
    
    //时间处理
    self.timeContainer.frame = CGRectZero;
    if (textModel.shouldShowTime) {
        self.timeContainer.hidden = NO;
        self.timeLabel.text  = [NSDate timeStringWithTimeInterval:textModel.sendTime];
        CGSize timeTextSize  = [self.timeLabel sizeThatFits:CGSizeMake(SCREEN_WITDTH, 20)];
        self.timeLabel.frame = Frame(5,(20 - timeTextSize.height)*0.5, timeTextSize.width, timeTextSize.height);
        self.timeContainer.frame = Frame((SCREEN_WITDTH - timeTextSize.width-10)*0.5, 15,timeTextSize.width + 10, 20);
    }else{
        self.timeContainer.hidden = YES;
    }
    //处理转圈
    textModel.isSending.integerValue &&textModel.byMyself.integerValue ? [self.activiView startAnimating] : [self.activiView stopAnimating];
    //处理红叹号
    self.failureButton.hidden = textModel.isSend.integerValue || textModel.isSending.integerValue || !textModel.byMyself.integerValue;
    //处理昵称显示
    self.nickNameLabel.hidden = textModel.byMyself.integerValue || hashEqual(textModel.chatType, @"userChat");
    //赋值
    [self setContent];
    //设置frame
    [self setFrame];
}

- (void)setContent
{
    [self.iconView downloadImage:_textModel.fromPortrait placeholder:@"userhead"];
    
    UIImage *backImage = nil;
    //我方
    if (_textModel.byMyself.integerValue) {
        
        backImage = LoadImage(@"我方文字气泡");
        [self.coreLabel setText:_textModel.content.text customLinks:nil keywords:nil];
    }else{
        self.nickNameLabel.text = _textModel.nickName;
        backImage = LoadImage(@"对方文字气泡");
        [self.coreLabel setText:_textModel.content.text customLinks:nil keywords:nil];
    }
    backImage = [backImage stretchableImageWithLeftCapWidth:backImage.size.width * 0.8 topCapHeight:backImage.size.height *0.8];
    self.backButton.image = backImage;
    
}

- (void)setFrame
{
    CGSize size = [_coreLabel sizeThatFits:CGSizeMake(SCREEN_WITDTH - 145, MAXFLOAT)];
    if (_textModel.byMyself.integerValue) {
        //文本宽度JYScreen_Width - 145
        //我方头像
        self.iconView.frame = Frame(SCREEN_WITDTH - 65, MaxY(self.timeContainer.frame)+15, 50, 50);
        //我方文本label
        self.coreLabel.frame = Frame(10, 10,size.width, size.height);
        //我方背景气泡
        self.backButton.frame = Frame(SCREEN_WITDTH - 100 - Width(self.coreLabel.frame), MinY(self.iconView.frame)+5, Width(self.coreLabel.frame)+30, Height(self.coreLabel.frame)+20);
        self.activiView.frame = Frame(MinX(self.backButton.frame)-34,MinY(self.backButton.frame)+((Height(self.backButton.frame)-24)*0.5), 24, 24);
        //红叹号
        self.failureButton.frame = self.activiView.frame;
    }else{
    
        //处理是否显示昵称
        if (hashEqual(_textModel.chatType, @"userChat")) {
            //对方头像
            self.iconView.frame = Frame(15, MaxY(self.timeContainer.frame)+15, 50, 50);
        }else{
            self.nickNameLabel.frame  = Frame(15 + 50 + 10,MaxY(self.timeContainer.frame)+15, 250, 13.f);
            //对方头像
            self.iconView.frame = Frame(15, MaxY(self.nickNameLabel.frame)+3, 50, 50);
        }
        //对方文本label
        self.coreLabel.frame = Frame(20, 10, size.width, size.height);
        //对方气泡
        self.backButton.frame = Frame(MaxX(self.iconView.frame)+5,MinY(self.iconView.frame)+5, Width(self.coreLabel.frame)+30, Height(self.coreLabel.frame)+20);
    }
}

- (void)linkText:(NSString *)clickString type:(MYLinkType)linkType
{
    NSLog(@"----------点击了-------%@",clickString);
}


#pragma mark - 消息长按
- (void)longpressHandle
{
    
}

#pragma mark - 进入个人资料详情
- (void)toUserInfo
{
    
}

#pragma mark - 重新发送
- (void)sendAgain
{
    
}

#pragma mark - 头像长按
- (void)iconLongPress:(UILongPressGestureRecognizer *)longpress
{
    
}
@end
