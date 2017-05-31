//
//  ChatImageCell.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatImageCell.h"
#import "ChatModel.h"

@interface ChatImageCell ()
//头像
@property(nonatomic,strong) UIImageView *iconView;
//图片
@property (nonatomic, strong) UIImageView *picView;
//进度数字label
@property (nonatomic, strong) UILabel *progressLabel;
//失败按钮
@property (nonatomic, strong) UIButton *failureButton;
//遮罩
@property (nonatomic, strong) UIImageView *coverView;
//时间
@property (nonatomic, strong) UILabel *timeLabel;
//时间容器
@property (nonatomic, strong) UIView *timeContainer;
//昵称
@property (nonatomic, strong) UILabel *nickNameLabel;

@end

@implementation ChatImageCell

- (UILabel *)nickNameLabel
{
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc]init];
        _nickNameLabel.font = FontSet(12.f);
        _nickNameLabel.textColor = UICOLOR_RGB_Alpha(0x333333, 1);
    }
    return _nickNameLabel;
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

//时间
- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textColor = UIMainWhiteColor;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = FontSet(12.f);
    }
    return _timeLabel;
}


//遮罩
- (UIImageView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIImageView alloc]init];
        _coverView.userInteractionEnabled = YES;
        //添加单击手势,展示大图
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toBigPicture)];
        [_coverView addGestureRecognizer:tap];
        //长按手势
        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longpressHandle)];
        [_coverView addGestureRecognizer:longpress];
    }
    return _coverView;
}

//失败
- (UIButton *)failureButton
{
    if (!_failureButton) {
        _failureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_failureButton setImage:LoadImage(@"发送失败") forState:UIControlStateNormal];
        [_failureButton addTarget:self action:@selector(sendAgain) forControlEvents:UIControlEventTouchUpInside];
        _failureButton.hidden = YES;//默认隐藏
    }
    return _failureButton;
}

//进度
- (UILabel *)progressLabel
{
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc]init];
        _progressLabel.textColor = UIMainWhiteColor;
        _progressLabel.font = FontSet(14.f);
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.hidden = YES;  //默认隐藏
    }
    return _progressLabel;
}

//图片
- (UIImageView *)picView
{
    if (!_picView) {
        _picView = [[UIImageView alloc]init];
        _picView.userInteractionEnabled = YES;
        [_picView addSubview:self.coverView];
         [_picView addSubview:self.progressLabel];
    }
    return _picView;
}

//头像
- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc]init];
        _iconView.userInteractionEnabled = YES;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            ViewRadius(_iconView, 25.f);
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
        
        self.contentView.backgroundColor = UIMainBackColor;
        [self.contentView addSubview:self.timeContainer];
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.picView];
        [self.contentView addSubview:self.failureButton];
        [self.contentView addSubview:self.nickNameLabel];
    }
    return self;
}


- (void)setImageModel:(ChatModel *)imageModel
{
    _imageModel = imageModel;
    //处理时间
    self.timeContainer.frame = CGRectZero;
    //处理时间
    if (imageModel.shouldShowTime) {
        self.timeContainer.hidden = NO;
        self.timeLabel.text = [NSDate timeStringWithTimeInterval:imageModel.sendTime];
        CGSize timeTextSize  = [self.timeLabel sizeThatFits:CGSizeMake(SCREEN_WITDTH, 20)];
        self.timeLabel.frame = Frame(5,(20 - timeTextSize.height)*0.5, timeTextSize.width, timeTextSize.height);
        self.timeContainer.frame = Frame((SCREEN_WITDTH - timeTextSize.width-10)*0.5, 15,timeTextSize.width + 10, 20);
    }
    self.timeContainer.hidden = !imageModel.shouldShowTime;
    //处理失败按钮 , 处理进度按钮 ,昵称隐藏处理
    BOOL isSend   = [imageModel.isSend integerValue];
    self.failureButton.hidden    = !imageModel.byMyself.integerValue || isSend || imageModel.isSending.integerValue;
    self.progressLabel.hidden  = !imageModel.byMyself.integerValue || imageModel.isSending.integerValue;
    self.nickNameLabel.hidden = imageModel.byMyself.integerValue || hashEqual(imageModel.chatType, @"userChat");
        
    //赋值
    [self setContent];
    //frame
    [self setFrame];
}


- (void)setContent
{
    //拉伸遮罩
    UIImage *rightCoverImage = LoadImage(@"右－横图片遮罩");
    UIImage *leftCoverImage    = LoadImage(@"左－横图片遮罩");
    rightCoverImage          = [rightCoverImage stretchableImageWithLeftCapWidth:rightCoverImage.size.width *0.5 topCapHeight:rightCoverImage.size.height *0.5];
    leftCoverImage            = [leftCoverImage stretchableImageWithLeftCapWidth:leftCoverImage.size.width*0.5 topCapHeight:leftCoverImage.size.height*0.5];

    //我方图片
    if (_imageModel.byMyself.integerValue) {
        
        //我的头像
         [self.iconView downloadImage:[AccountTool account].portrait placeholder:@"userhead"];
        //进度
        CGFloat progress = _imageModel.progress.floatValue;
        NSString *progressText = [[NSString stringWithFormat:@"%li",(NSInteger)(progress *100)]stringByAppendingString:@"%"];
        self.progressLabel.text = progressText;
        //获取本地资源缓存路径
        NSString *imgCachePath = nil;
        //群聊资源缓存路径
        if (hashEqual(_imageModel.chatType, @"groupChat")) {
            
            imgCachePath = [ChatCache_Path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/small_%@",_imageModel.groupID,_imageModel.content.fileName]];
        //单聊资源缓存路径
        }else{
            imgCachePath = [ChatCache_Path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/small_%@",_imageModel.toUserID,_imageModel.content.fileName]];
        }
        NSData *picData = [NSData dataWithContentsOfFile:imgCachePath];
        UIImage *image = [UIImage imageWithData:picData];
        //图片
        self.picView.image = image;
        //遮罩
        self.coverView.image = rightCoverImage;
    //对方图片
    }else{
        
        
    }
}

- (void)setFrame
{
    //图片宽高比
    CGFloat widHgtScale = _imageModel.content.picSize.width /  _imageModel.content.picSize.height;
    //图片高宽比
    CGFloat hgtWidScale = _imageModel.content.picSize.height / _imageModel.content.picSize.width;
    //我方图片
    if (_imageModel.byMyself.integerValue) {
    
        //头像
        self.iconView.frame = Frame(SCREEN_WITDTH - 65, MaxY(self.timeContainer.frame)+15, 50, 50);
        
        //高大于宽
        if (widHgtScale>0&&widHgtScale < 1) {
        
            //极窄极高 (展示固定50宽,不能再窄)
            if (105*widHgtScale<=50) {
                self.picView.frame = Frame(SCREEN_WITDTH - 115, MinY(self.iconView.frame), 50, 130);
            }else{
                self.picView.frame = Frame(MinX(self.iconView.frame)-130*widHgtScale ,MinY(self.iconView.frame), 130*widHgtScale, 130);
            }
            
        //宽大于高
        }else if (widHgtScale >1){
        
            //极宽极低(展示固定高度50,不能更低)
            if (100*(hgtWidScale)<=50) {
                self.picView.frame = Frame(SCREEN_WITDTH -195, MinY(self.iconView.frame), 130, 50);
            }else{
                self.picView.frame = Frame(MinX(self.iconView.frame)-135, MinY(self.iconView.frame), 135, 135 *hgtWidScale);
            }
        //宽高相等
        }else{
            self.picView.frame = Frame(MinX(self.iconView.frame)- 120, MinY(self.iconView.frame), 120, 120);
        }
        //进度
        self.progressLabel.frame = Frame(0, (Height(self.picView.frame)-14)*0.5, Width(self.picView.frame), 14);
        //失败按钮
        self.failureButton.frame = Frame(MinX(self.picView.frame)-34, MinY(self.picView.frame)+(Height(self.picView.frame)-24)*0.5, 24, 24);
        //遮罩
        self.coverView.frame = self.picView.bounds;
        
    //对方图片
    }else{
        
    }
}

#pragma mark - 头像长按
- (void)iconLongPress:(UILongPressGestureRecognizer *)longpress
{
    
}

#pragma mark - 单击头像
- (void)toUserInfo
{
    
}

#pragma mark - 进入大图查看
- (void)toBigPicture
{
    
}

#pragma mark - 图片长按
- (void)longpressHandle
{
    
}



@end
