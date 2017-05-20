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

//记录当前键盘的高度 ，键盘除了系统的键盘还有咱们自定义的键盘，互相来回切换
static CGFloat keyboardHeight = 0;

@interface ChatKeyboard ()<UITextViewDelegate,UIScrollViewDelegate>
 //表情
@property (nonatomic, strong) UIView *facesKeyboard;
//按钮 (拍照,视频,相册)
@property (nonatomic, strong) UIView *handleKeyboard;
//自定义键盘容器
@property (nonatomic, strong) UIView *keyBoardContainer;
//顶部消息操作栏
@property (nonatomic, strong) UIView *messageBar;
//表情容器
@property (nonatomic, strong) UIScrollView *emotionScrollView;
//表情键盘底部操作栏
@property (nonatomic, strong) UIView *emotionBottonBar;
//指示器
@property (nonatomic, strong) UIPageControl *emotionPgControl;
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
//表情资源
@property (nonatomic, strong) NSDictionary *emotionDict;

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

//表情资源plist (因为表情存在版权问题 , 所以这里的表情只用一个来代替)
- (NSDictionary *)emotionDict
{
    if (!_emotionDict) {
        _emotionDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"ChatEmotions" ofType:@"plist"]];
    }
    return _emotionDict;
}

//pageControl
- (UIPageControl *)emotionPgControl
{
    if (!_emotionPgControl) {
        _emotionPgControl = [[UIPageControl alloc]init];
        _emotionPgControl.pageIndicatorTintColor = UICOLOR_RGB_Alpha(0xcecece, 1);
        _emotionPgControl.currentPageIndicatorTintColor = UICOLOR_RGB_Alpha(0x999999, 1);
    }
    return _emotionPgControl;
}


//表情键盘底部操作栏 (表情键盘底部的操作栏 , 可以添加更多的操作按钮 ,类似微信那样 , 只需要再添加 和facesKeyboard handleKeyboard平级的view即可 , 几个键盘来回切换)
- (UIView *)emotionBottonBar
{
    if (!_emotionBottonBar) {
        _emotionBottonBar = [[UIView alloc]init];
        _emotionBottonBar.backgroundColor = UIMainWhiteColor;
        UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendButton.titleLabel.font = FontSet(14);
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [sendButton setTitleColor:UICOLOR_RGB_Alpha(0x333333, 1) forState:UIControlStateNormal];
        sendButton.frame = Frame(SCREEN_WITDTH - 75, 5, 60, 30);
        [sendButton addTarget:self action:@selector(sendEmotionMessage:) forControlEvents:UIControlEventTouchUpInside];
        ViewBorder(sendButton, UICOLOR_RGB_Alpha(0x333333, 1), 1);
        ViewRadius(sendButton, 5);
        [_emotionBottonBar addSubview:sendButton];
    }
    return _emotionBottonBar;
}

//表情滚动容器
- (UIScrollView *)emotionScrollView
{
    if (!_emotionScrollView) {
        _emotionScrollView = [[UIScrollView alloc]init];
        _emotionScrollView.backgroundColor = UIMainWhiteColor;
        _emotionScrollView.showsHorizontalScrollIndicator = NO;
        _emotionScrollView.pagingEnabled = YES;
        _emotionScrollView.delegate = self;
        //最多几列
        NSUInteger columnMaxCount = 8;
        //最多几行
        NSUInteger rowMaxCount = 3;
        //一页表情最多多少个
        NSUInteger emotionMaxCount = columnMaxCount *rowMaxCount;
        //左右边距
        CGFloat lrMargin = 15.f;
        //顶部边距
        CGFloat topMargin = 20.f;
        //宽高
        CGFloat widthHeight = 30.f;
        //中间间距
        CGFloat midMargin = (SCREEN_WITDTH - columnMaxCount*widthHeight - 2*lrMargin)/(columnMaxCount - 1);
        //计算一共多少页表情
        NSInteger pageCount = self.emotionDict.count / emotionMaxCount + (self.emotionDict.count %emotionMaxCount > 0 ? 1 : 0);
        //滑动范围
        _emotionScrollView.contentSize = CGSizeMake(pageCount *SCREEN_WITDTH, 0);
        
        //布局
        //当前第几个表情
        NSUInteger emotionIdx = 0;
        //index 当前第几页
        for (NSInteger index = 0; index < pageCount; index ++) {
            UIView *emotionContainer = [[UIView alloc]init];
            //添加表情按钮
            for (NSInteger i = 0; i < emotionMaxCount; i ++) {
                NSInteger row    = i % columnMaxCount;
                NSInteger colum = i / columnMaxCount;
                UIButton *emotionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                emotionBtn.tag = 999 + emotionIdx;
                NSString *emotionImgName = [self.emotionDict objectForKey:[NSString stringWithFormat:@"ChatEmotion_%li",emotionIdx]];
                [emotionBtn setImage:LoadImage(emotionImgName) forState:UIControlStateNormal];
                emotionBtn.frame = Frame(lrMargin + row *(widthHeight + midMargin), topMargin + colum*(widthHeight + midMargin), widthHeight, widthHeight);
                [emotionBtn addTarget:self action:@selector(emotionClick:) forControlEvents:UIControlEventTouchUpInside];
                [emotionContainer addSubview:emotionBtn];
                emotionIdx ++ ;
            }
            [_emotionScrollView addSubview:emotionContainer];
        }
    }
    return _emotionScrollView;
}
//表情键盘
- (UIView *)facesKeyboard
{
    if (!_facesKeyboard) {
        _facesKeyboard = [[UIView alloc]init];
        _facesKeyboard.backgroundColor = UIMainWhiteColor;
        //添加表情滚动容器
        [_facesKeyboard addSubview:self.emotionScrollView];
        //添加底部操作栏
        [_facesKeyboard addSubview:self.emotionBottonBar];
        //指示器pageControl
        [_facesKeyboard addSubview:self.emotionPgControl];
    }
    return _facesKeyboard;
}

//操作按钮键盘
- (UIView *)handleKeyboard
{
    if (!_handleKeyboard) {
        _handleKeyboard = [[UIView alloc]init];
        _handleKeyboard.backgroundColor = UIMainWhiteColor;
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
            [_handleKeyboard addSubview:handleButton];
            [handleButton addTarget:self action:@selector(handleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _handleKeyboard;
}

//自定义
- (UIView *)keyBoardContainer
{
    if (!_keyBoardContainer) {
        _keyBoardContainer = [[UIView alloc]init];
        [_keyBoardContainer addSubview:self.facesKeyboard];
        [_keyBoardContainer addSubview:self.handleKeyboard];
    }
    return _keyBoardContainer;
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
        _msgTextView.returnKeyType = UIReturnKeySend;
        _msgTextView.enablesReturnKeyAutomatically = YES;
        _msgTextView.delegate = self;
        ViewRadius(_msgTextView, 5);
        //观察者监听高度变化
        [_msgTextView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
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
        //默认隐藏
        _audioLpButton.hidden = YES;
        //边框,切角
        ViewBorder(_audioLpButton, UICOLOR_RGB_Alpha(0x999999, 1), 1);
        ViewRadius(_audioLpButton, 5);
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
    }
    return _audioLpButton;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.messageBar];
        [self addSubview:self.keyBoardContainer];
        
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
    self.audioLpButton.frame = Frame(MaxX(self.audioButton.frame)+15,(Height(self.messageBar.frame)-35)*0.5, SCREEN_WITDTH - 155, 35); //长按录音按钮
    self.msgTextView.frame = self.audioLpButton.frame;  //输入框
    self.swtFaceButton.frame  = Frame(MaxX(self.msgTextView.frame)+15, (Height(self.messageBar.frame)-30)*0.5,30, 30); //表情键盘切换按钮
    self.swtHandleButton.frame = Frame(MaxX(self.swtFaceButton.frame)+15, (Height(self.messageBar.frame)-30)*0.5, 30, 30); //加号按钮切换操作键盘
     self.keyBoardContainer.frame = Frame(0,Height(self.messageBar.frame), SCREEN_WITDTH,CTKEYBOARD_DEFAULTHEIGHT - Height(self.messageBar.frame)); //自定义键盘容器
    self.handleKeyboard.frame = self.keyBoardContainer.bounds ;//键盘操作栏
    self.facesKeyboard.frame = self.keyBoardContainer.bounds ; //表情键盘部分
    
    //表情容器部分
    self.emotionScrollView.frame =Frame(0,0, SCREEN_WITDTH, Height(self.facesKeyboard.frame)-40); //表情滚动容器
    for (NSInteger index = 0; index < self.emotionScrollView.subviews.count; index ++) { //emotion容器
        UIView *emotionView = self.emotionScrollView.subviews[index];
        emotionView.frame = Frame(index *SCREEN_WITDTH, 0, SCREEN_WITDTH, Height(self.emotionScrollView.frame));
    }
    //页码
    self.emotionPgControl.numberOfPages = self.emotionScrollView.subviews.count;
    CGSize controlSize = [self.emotionPgControl sizeForNumberOfPages:self.emotionScrollView.subviews.count];
    self.emotionPgControl.frame = Frame((SCREEN_WITDTH - controlSize.width)*0.5,Height(self.emotionScrollView.frame)-controlSize.height, controlSize.width, controlSize.height); // pageControl
    self.emotionBottonBar.frame = Frame(0,MaxY(self.emotionScrollView.frame), SCREEN_WITDTH, 40); //底部操作栏  固定 40高度
}

#pragma mark - 系统键盘即将弹起
- (void)systemKeyboardWillShow:(NSNotification *)note
{
    //重置所有按钮selected
    [self reloadSwitchButtons];
    //获取系统键盘高度
    CGFloat systemKbHeight  = [note.userInfo[@"UIKeyboardBoundsUserInfoKey"]CGRectValue].size.height;
    //记录系统键盘高度
    keyboardHeight = systemKbHeight;
    //将自定义键盘跟随位移
    [self customKeyboardMove:SCREEN_HEIGHT - systemKbHeight - Height(self.messageBar.frame)];
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
    swtFaceButton.selected = !swtFaceButton.selected;
    //重置其他按钮seleted
    self.audioButton.selected = NO;
    self.swtHandleButton.selected = NO;
    //更新记录键盘高度
    keyboardHeight = Height(self.keyBoardContainer.frame);
    
    if (swtFaceButton.selected) {
        _msgTextView.hidden = NO;
        _audioLpButton.hidden  = YES;
        [_msgTextView resignFirstResponder];
        //展示表情键盘
        [self.keyBoardContainer bringSubviewToFront:self.facesKeyboard];
        //自定义键盘位移
        [self customKeyboardMove:SCREEN_HEIGHT - Height(self.frame)];
    }else{
        [_msgTextView becomeFirstResponder];
    }
}
#pragma mark - 切换到操作键盘
- (void)switchHandleKeyboard:(UIButton *)swtHandleButton
{
    swtHandleButton.selected = !swtHandleButton.selected;
    //重置其他按钮selected
    self.audioButton.selected = NO;
    self.swtFaceButton.selected = NO;
    //更新记录键盘高度
    keyboardHeight = Height(self.keyBoardContainer.frame);
    
    if (swtHandleButton.selected) {
        _msgTextView.hidden = NO;
        _audioLpButton.hidden = YES;
        [_msgTextView resignFirstResponder];
        //展示操作键盘
        [self.keyBoardContainer bringSubviewToFront:self.handleKeyboard];
        //自定义键盘位移
        [self customKeyboardMove:SCREEN_HEIGHT - Height(self.frame)];
    }else{
        [_msgTextView becomeFirstResponder];
    }
}
#pragma mark - 切换至语音录制
- (void)audioButtonClick:(UIButton *)audioButton
{
    audioButton.selected = !audioButton.selected;
     //重置其他按钮selected
    self.swtFaceButton.selected = NO;
    self.swtHandleButton.selected = NO;
    
    if (audioButton.selected) {
        [_msgTextView resignFirstResponder];
        self.msgTextView.hidden = YES;
        self.audioLpButton.hidden = NO;
        [self customKeyboardMove:SCREEN_HEIGHT - 49]; //默认高度 输入栏 49
    }else{
        self.msgTextView.hidden = NO;
        self.audioLpButton.hidden = YES;
        [self.msgTextView becomeFirstResponder];
    }
    audioButton.selected = !_msgTextView.isFirstResponder;
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

#pragma mark - 监听输入框变化 (这里如果放到layout里自动让他布局 , 会稍显麻烦一些 , 所以自动手动控制一下)
//这里用contentSize计算较为简单和精确 , 如果计算文字高度 ,  还需要加上textView的内间距.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    CGFloat oldHeight  = [change[@"old"]CGSizeValue].height;
    CGFloat newHeight = [change[@"new"]CGSizeValue].height;
    if (oldHeight <=0 || newHeight <=0) return;
    NSLog(@"------new ----%@",change[@"new"]);
    NSLog(@"-------old ---%@",change[@"old"]);
    if (change[@"new"] != change[@"old"]) {
        NSLog(@"高度变化");
        //根据实时的键盘高度进行布局
        [self msgTextViewHeightFit:keyboardHeight];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //删除键监听
    if ([text isEqualToString:@""""]) {
        
        NSLog(@"----------------点击了系统键盘删除键");
        //系统键盘删除
        [self keyboardDelete];
        return NO;
    }
    return YES;
}

#pragma mark - 切换按钮初始化
- (void)reloadSwitchButtons
{
    self.audioButton.selected        = NO;
    self.swtFaceButton.selected    = NO;
    self.swtHandleButton.selected = NO;
}

#pragma mark - 输入框拉高
- (void)msgTextViewHeightFit:(CGFloat)currentKbHeight
{
    self.messageBar.frame = Frame(0, 0, SCREEN_WITDTH, self.msgTextView.contentSize.height +MinY(self.msgTextView.frame)*2);
    self.msgTextView.frame = Frame(MinX(self.msgTextView.frame),(Height(self.messageBar.frame)-self.msgTextView.contentSize.height)*0.5, Width(self.msgTextView.frame), self.msgTextView.contentSize.height);
    self.keyBoardContainer.frame = Frame(0, MaxY(self.messageBar.frame), SCREEN_WITDTH, Height(self.keyBoardContainer.frame));
    self.frame = Frame(0,SCREEN_HEIGHT - currentKbHeight-Height(self.messageBar.frame), SCREEN_WITDTH,Height(self.keyBoardContainer.frame) + Height(self.messageBar.frame));
}

#pragma mark - 拍摄 , 照片 ,视频按钮点击
- (void)handleButtonClick:(ChatHandleButton *)button
{
    switch (button.tag - 9999) {
        case 0:
        {
            NSLog(@"-------------点击了相册");
        }
            break;
        case 1:
        {
            NSLog(@"-------------点击了拍照");
        }
            break;
        case 2:
        {
            NSLog(@"-------------点击了视频相册");
        }
            break;
        default:
            break;
    }
}

#pragma mark - 点击表情
- (void)emotionClick:(UIButton *)emotionBtn
{
    
    //获取点击的表情
    NSString *emotionKey = [NSString stringWithFormat:@"ChatEmotion_%li",emotionBtn.tag - 999];
    NSString *emotionName = [self.emotionDict objectForKey:emotionKey];
    
    //判断是删除 ， 还是点击了正常的emotion表情
    if ([emotionName isEqualToString:@"[del_]"]) {
        
        //表情键盘删除
        [self keyboardDelete];
        
    }else{ //点击表情
        
        //获取光标所在位置
        NSInteger location = self.msgTextView.selectedRange.location;
        //变为可变字符串
        NSMutableString *txtStrM = [[NSMutableString alloc]initWithString:self.msgTextView.text];
        [txtStrM insertString:emotionName atIndex:location];
        self.msgTextView.text = txtStrM;
        //光标后移
        self.msgTextView.selectedRange = NSMakeRange(location + emotionName.length, 0);
        NSLog(@"--------当前点击了表情 : ------------------%@",emotionName);
    }
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.emotionPgControl.currentPage = scrollView.contentOffset.x / SCREEN_WITDTH;
}

#pragma mark - 表情发送按钮点击
- (void)sendEmotionMessage:(UIButton *)emotionSendBtn
{
    
}

#pragma mark - 键盘删除内容
- (void)keyboardDelete
{
    
    NSMutableString *txtStrM = [[NSMutableString alloc]initWithString:self.msgTextView.text];
    //当前光标位置
    NSInteger location = self.msgTextView.selectedRange.location;
    if (!txtStrM.length) return;
    
    //正则检测是否存在表情
    NSRegularExpression *pression = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\[\\]]*\\]" options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray *results = [pression matchesInString:self.msgTextView.text options:NSMatchingReportProgress range:NSMakeRange(0, self.msgTextView.text.length)];
    //检测光标前是否有表情
    __block BOOL deleteEmotion = NO;
    [results enumerateObjectsUsingBlock:^(NSTextCheckingResult  *_Nonnull checkResult, NSUInteger idx, BOOL * _Nonnull stop) {
        //光标前面有表情
        if (checkResult.range.location + checkResult.range.length == location) {
            
            NSLog(@"-------光标前是表情------------");
            [txtStrM replaceCharactersInRange:checkResult.range withString:@""];
            self.msgTextView.text = txtStrM;
            //光标前移
            self.msgTextView.selectedRange = NSMakeRange(location - checkResult.range.length, 0);
            deleteEmotion = YES;
            *stop = YES;
        }
    }];
    
    //如果光标前没有表情
    if (!deleteEmotion) {
        [txtStrM replaceCharactersInRange:NSMakeRange(txtStrM.length-1, 1) withString:@""];
        self.msgTextView.text = txtStrM;
        //光标前移
        self.msgTextView.selectedRange = NSMakeRange(location - 1, 0);
    }
}

- (void)dealloc
{
    [self.msgTextView removeObserver:self forKeyPath:@"contentSize"];
}



@end
