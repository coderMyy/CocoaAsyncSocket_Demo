//
//  ChatKeyboard.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/15.
//  Copyright © 2017年 mengyao. All rights reserved.
//


#import "ChatKeyboard.h"
#import "ChatRecordTool.h"

@interface ChatHandleButton : UIButton
@end
@implementation ChatHandleButton
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = Frame(0, 0, 60, 60);  //图片 60.60
    self.titleLabel.frame   = Frame(0, MaxY(self.imageView.frame)+5,Width(self.imageView.frame), 12); //固定高度12
}

@end

@interface ChatKeyboard ()<UITextViewDelegate>
 //表情
@property (nonatomic, strong) UIView *facesKeyboard;
//按钮 (拍照,视频,相册)
@property (nonatomic, strong) UIView *handleKeyboard;
//顶部消息操作栏
@property (nonatomic, strong) UIView *messageBar;
//语音按钮
@property (nonatomic, strong) UIButton *audioButton;
//长按说话按钮
@property (nonatomic, strong) UIButton *audioLpButton;
//表情按钮
@property (nonatomic, strong) UIButton *swtFaceButton;
//加号按钮
@property (nonatomic, strong) UIButton *swtHandleButton;
//输入框
@property (nonatomic, strong) UITextView *msgTextView;
//录音工具(需引用)
@property (nonatomic, strong) ChatRecordTool *recordTool;

@end

@implementation ChatKeyboard

//录音工具
- (ChatRecordTool *)recordTool
{
    if (!_recordTool) {
        _recordTool = [ChatRecordTool chatRecordTool];
    }
    return _recordTool;
}

//表情键盘
- (UIView *)facesKeyboard
{
    if (!_facesKeyboard) {
        _facesKeyboard = [[UIView alloc]init];
        _facesKeyboard.backgroundColor = [UIColor greenColor];
    }
    return _facesKeyboard;
}

//操作按钮键盘
- (UIView *)handleKeyboard
{
    if (!_handleKeyboard) {
        _handleKeyboard = [[UIView alloc]init];
        _handleKeyboard.backgroundColor = [UIColor redColor];
        NSArray *buttonNames = @[@"照片",@"拍摄",@"视频"];
        for (NSInteger index = 0; index < 3; index ++) {
            NSInteger  colum = index % 3;
            ChatHandleButton *handleButton = [ChatHandleButton buttonWithType:UIButtonTypeCustom];
            handleButton.titleLabel.font = FontSet(12);
            handleButton.tag = 9999 + index;
            handleButton.titleLabel.textColor = UICOLOR_RGB_Alpha(0x666666, 1);
            handleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            [handleButton setTitle:buttonNames[index] forState:UIControlStateNormal];
            [handleButton setImage:LoadImage(buttonNames[index]) forState:UIControlStateNormal];
            handleButton.frame = Frame(30 + colum*(60 + 25), 15, 60, 60);
            [handleButton addTarget:self action:@selector(handleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _handleKeyboard;
}

//输入栏
- (UIView *)messageBar
{
    if (!_messageBar) {
        _messageBar = [[UIView alloc]init];
        _messageBar.backgroundColor = UICOLOR_RGB_Alpha(0xe6e6e6, 1);
        [_messageBar addSubview:self.audioButton];
        [_messageBar addSubview:self.msgTextView];
        [_messageBar addSubview:self.audioLpButton];
        [_messageBar addSubview:self.swtFaceButton];
        [_messageBar addSubview:self.swtHandleButton];
    }
    return _messageBar;
}

//输入框
- (UITextView *)msgTextView
{
    if (!_msgTextView) {
        _msgTextView = [[UITextView alloc]init];
        _msgTextView.font = FontSet(14);
        _msgTextView.showsVerticalScrollIndicator = NO;
        _msgTextView.showsHorizontalScrollIndicator = NO;
        _msgTextView.scrollEnabled = NO;
        _msgTextView.returnKeyType = UIReturnKeySend;
        _msgTextView.enablesReturnKeyAutomatically = YES;
        _msgTextView.delegate = self;
        ViewRadius(_msgTextView, 5);
    }
    return _msgTextView;
}

//语音按钮
- (UIButton *)audioButton
{
    if (!_audioButton) {
        _audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_audioButton setImage:LoadImage(@"语音") forState:UIControlStateNormal];
        [_audioButton addTarget:self action:@selector(audioButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _audioButton;
}

//表情切换按钮
- (UIButton *)swtFaceButton
{
    if (!_swtFaceButton) {
        _swtFaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_swtFaceButton setImage:LoadImage(@"表情") forState:UIControlStateNormal];
        [_swtFaceButton addTarget:self action:@selector(switchFaceKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _swtFaceButton;
}

//切换操作键盘
- (UIButton *)swtHandleButton
{
    if (!_swtHandleButton) {
        _swtHandleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_swtHandleButton setImage:LoadImage(@"加号") forState:UIControlStateNormal];
        [_swtHandleButton addTarget:self action:@selector(switchHandleKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _swtHandleButton;
}

//长按录音按钮
- (UIButton *)audioLpButton
{
    if (!_audioLpButton) {
        _audioLpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_audioLpButton setTitle:@"按住说话" forState:UIControlStateNormal];
        [_audioLpButton setTitle:@"松开发送" forState:UIControlStateHighlighted];
        [_audioLpButton setTitleColor:UICOLOR_RGB_Alpha(0x333333, 1) forState:UIControlStateNormal];
        _audioLpButton.titleLabel.font = FontSet(14);
        //按下录音按钮
        [_audioLpButton addTarget:self action:@selector(audioLpButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        //手指离开录音按钮 , 但不松开
        [_audioLpButton addTarget:self action:@selector(audioLpButtonMoveOut:) forControlEvents:UIControlEventTouchDragExit|UIControlEventTouchDragOutside];
        //手指离开录音按钮 , 松开
        [_audioLpButton addTarget:self action:@selector(audioLpButtonMoveOutTouchUp:) forControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchCancel];
        //手指回到录音按钮,但不松开
        [_audioLpButton addTarget:self action:@selector(audioLpButtonMoveInside:) forControlEvents:UIControlEventTouchDragInside|UIControlEventTouchDragEnter];
        //手指回到录音按钮 , 松开
        [_audioLpButton addTarget:self action:@selector(audioLpButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        //默认隐藏
        _audioLpButton.hidden = YES;
        //边框,切角
        ViewBorder(_audioLpButton, UICOLOR_RGB_Alpha(0x999999, 1), 1);
        ViewRadius(_audioLpButton, 5);
    }
    return _audioLpButton;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.messageBar];
        [self addSubview:self.facesKeyboard];
        [self addSubview:self.handleKeyboard];
        
        //布局
        [self configUIFrame];
    }
    return self;
}

#pragma mark - 初始化布局
- (void)configUIFrame
{
    self.messageBar.frame = Frame(0, 0, SCREEN_WITDTH, 49);  //消息栏
    self.audioButton.frame = Frame(10, (Height(self.messageBar.frame) - 30)*0.5, 30, 30); //语音按钮
    self.audioLpButton.frame = Frame(MaxX(self.audioButton.frame)+15,(Height(self.messageBar.frame)-34)*0.5, SCREEN_WITDTH - 155, 34); //长按录音按钮
    self.msgTextView.frame = self.audioLpButton.frame;  //输入框
    self.swtFaceButton.frame  = Frame(MaxX(self.msgTextView.frame)+15, (Height(self.messageBar.frame)-30)*0.5,30, 30); //表情键盘切换按钮
    self.swtHandleButton.frame = Frame(MaxX(self.swtFaceButton.frame)+15, (Height(self.messageBar.frame)-30)*0.5, 30, 30); //加号按钮切换操作键盘
    self.handleKeyboard.frame = Frame(0,Height(self.messageBar.frame), SCREEN_WITDTH,CUSTOMKEYBOARD_HEIGHT - Height(self.messageBar.frame)); //键盘操作栏
    self.facesKeyboard.frame = self.handleKeyboard.frame; //表情容器部分
}

#pragma mark - 系统键盘即将弹起
- (void)systemKeyboardWillShow:(NSNotification *)note
{
    //获取系统键盘高度
    CGFloat systemKbHeight  = [note.userInfo[@"UIKeyboardBoundsUserInfoKey"]CGRectValue].size.height;
    //将自定义键盘跟随位移
    [self customKeyboardMove:SCREEN_HEIGHT - systemKbHeight - Height(self.messageBar.frame)];
}

#pragma mark - 切换至语音录制
- (void)audioButtonClick:(UIButton *)audioButton
{
    [_msgTextView resignFirstResponder];
    self.msgTextView.hidden = YES;
    self.audioLpButton.hidden = NO;
    [self customKeyboardMove:SCREEN_HEIGHT - Height(self.messageBar.frame)];
}
#pragma mark - 语音按钮点击
- (void)audioLpButtonTouchDown:(UIButton *)audioLpButton
{
    [self.recordTool beginRecord];
}
#pragma mark - 手指离开录音按钮 , 但不松开
- (void)audioLpButtonMoveOut:(UIButton *)audioLpButton
{
    [self.recordTool moveOut];
}
#pragma mark - 手指离开录音按钮 , 松开
- (void)audioLpButtonMoveOutTouchUp:(UIButton *)audioLpButton
{
    [self.recordTool cancelRecord];
    //手动释放一下,每次录音创建新的蒙板,避免过多处理 定时器和子控件逻辑
    self.recordTool = nil;
}
#pragma mark - 手指回到录音按钮,但不松开
- (void)audioLpButtonMoveInside:(UIButton *)audioLpButton
{
    [self.recordTool continueRecord];
}
#pragma mark - 手指回到录音按钮 , 松开
- (void)audioLpButtonTouchUpInside:(UIButton *)audioLpButton
{
    [self.recordTool stopRecord];
    //手动释放一下,每次录音创建新的蒙板,避免过多处理 定时器和子控件逻辑
    self.recordTool = nil;
}
#pragma mark - 切换到表情键盘
- (void)switchFaceKeyboard:(UIButton *)swtFaceButton
{
    _msgTextView.hidden = NO;
    _audioLpButton.hidden  = YES;
    [_msgTextView resignFirstResponder];
    [self bringSubviewToFront:self.facesKeyboard];
    //自定义键盘位移
     [self customKeyboardMove:SCREEN_HEIGHT - Height(self.frame)];
}
#pragma mark - 切换到操作键盘
- (void)switchHandleKeyboard:(UIButton *)swtHandleButton
{
    _msgTextView.hidden = NO;
    _audioLpButton.hidden = YES;
    [_msgTextView resignFirstResponder];
    [self bringSubviewToFront:self.handleKeyboard];
    //自定义键盘位移
    [self customKeyboardMove:SCREEN_HEIGHT - Height(self.frame)];
}

#pragma mark - 自定义键盘位移变化
- (void)customKeyboardMove:(CGFloat)customKbY
{
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = Frame(0,customKbY, SCREEN_WITDTH, Height(self.frame));
    }];
}

#pragma mark - 监听输入框
- (void)textViewDidChange:(UITextView *)textView
{
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

#pragma mark - 拍摄 , 照片 ,视频按钮点击
- (void)handleButtonClick:(ChatHandleButton *)button
{
    switch (button.tag - 9999) {
        case 0:
        {
        }
            break;
        case 1:
        {
        }
            break;
        case 2:
        {
        }
            break;
        default:
            break;
    }
}

@end
