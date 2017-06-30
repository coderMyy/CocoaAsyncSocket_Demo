//
//  ChatVideoCell.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatVideoCell.h"
#import "ChatModel.h"
#import "ChatUtil.h"

@interface ChatVideoCell ()

//头像
@property (strong, nonatomic)  UIImageView *iconView;
//进度
@property (strong, nonatomic)  UILabel *progressLabel;
//发送时间
@property (strong, nonatomic)  UILabel *timeLabel;
//大小
@property (strong, nonatomic)  UILabel *sizeLabel;
//缩略图
@property (strong, nonatomic)  UIImageView *picView;
//遮罩
@property (nonatomic, strong) UIImageView *coverView;
//失败
@property (strong, nonatomic)  UIButton *failureButton;
//播放按钮
@property (strong, nonatomic)  UIImageView *playImageView;
//时长
@property (nonatomic, strong)  UILabel *secondsLabel;
//时间容器
@property (nonatomic, strong) UIView *timeContainer;
//昵称
@property (nonatomic, strong) UILabel *nickNameLabel;

@end

@implementation ChatVideoCell

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


- (UIImageView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIImageView alloc]init];
    }
    return _coverView;
}

- (UILabel *)secondsLabel
{
    if (!_secondsLabel) {
        _secondsLabel = [[UILabel alloc]init];
        _secondsLabel.textColor = UIMainWhiteColor;
        _secondsLabel.font = FontSet(7.f);
        _secondsLabel.textAlignment = NSTextAlignmentRight;
        _secondsLabel.numberOfLines = 1;
    }
    return _secondsLabel;
}

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


- (UILabel *)progressLabel
{
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc]init];
        _progressLabel.textColor = UIMainWhiteColor;
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.font = FontSet(14.f);
        _progressLabel.hidden = YES;  //默认隐藏
    }
    return _progressLabel;
}

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


- (UILabel *)sizeLabel
{
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc]init];
        _sizeLabel.font = FontSet(7.f);
        _sizeLabel.textColor = UIMainWhiteColor;
        _sizeLabel.textAlignment = NSTextAlignmentLeft;
        _sizeLabel.numberOfLines = 1;
    }
    return _sizeLabel;
}

- (UIImageView *)picView
{
    if (!_picView) {
        _picView = [[UIImageView alloc]init];
        _picView.userInteractionEnabled = YES;
        //添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(downLoadVideo)];
        [_picView addGestureRecognizer:tap];
        //长按手势
        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longpressHandle)];
        [_picView addGestureRecognizer:longpress];
        
        [_picView addSubview:self.coverView];
        [_picView addSubview:self.playImageView];
        [_picView addSubview:self.sizeLabel];
        [_picView addSubview:self.secondsLabel];
        [_picView addSubview:self.progressLabel];
    }
    return _picView;
}


- (UIButton *)failureButton
{
    if (!_failureButton) {
        _failureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_failureButton setImage:LoadImage(@"发送失败") forState:UIControlStateNormal];
        [_failureButton addTarget:self action:@selector(sendAgain) forControlEvents:UIControlEventTouchUpInside];
        _failureButton.hidden = YES;
    }
    return _failureButton;
}

- (UIImageView *)playImageView
{
    if (!_playImageView) {
        _playImageView = [[UIImageView alloc]init];
        _playImageView.image = LoadImage(@"视频icon");
        
    }
    return _playImageView;
}



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIMainBackColor;
        [self.contentView addSubview:self.timeContainer];
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.picView];
        [self.contentView addSubview:self.failureButton];
        [self.contentView addSubview:self.nickNameLabel];
    }
    return self;
}


- (void)setVideoModel:(ChatModel *)videoModel
{
    _videoModel = videoModel;
    
    self.timeContainer.frame  = CGRectZero; //处理复用
    //处理时间
    if (videoModel.shouldShowTime) {
        self.timeContainer.hidden = NO;
        self.timeLabel.text = [NSDate timeStringWithTimeInterval:videoModel.sendTime];
        CGSize timeTextSize  = [self.timeLabel sizeThatFits:CGSizeMake(SCREEN_WITDTH, 20)];
        self.timeLabel.frame = Frame(5,(20 - timeTextSize.height)*0.5, timeTextSize.width, timeTextSize.height);
        self.timeContainer.frame = Frame((SCREEN_WITDTH - timeTextSize.width-10)*0.5, 15,timeTextSize.width + 10, 20);
    }else{
        self.timeContainer.hidden = YES;
    }
    
    //进度显示设置
    self.progressLabel.hidden = !videoModel.isSending.integerValue;
    //处理播放按钮显示
    self.playImageView.hidden = videoModel.isSending.integerValue;
    //处理视频大小显示
    self.sizeLabel.hidden = !videoModel.content.fileSize.longLongValue;
    
    [self setContent:videoModel];
    
    [self setFrames:videoModel];

}

- (void)setContent:(ChatModel *)videoModel
{
    
    NSArray *width_height_duration = [videoModel.content.text componentsSeparatedByString:@"-"];
    CGFloat width = [width_height_duration[0]floatValue];
    CGFloat height = [width_height_duration[1]floatValue];
    NSString *duration = width_height_duration.lastObject;
    
    //视频大小
    NSString *videoSize = [ChatUtil dataSize:videoModel];
    //进度
    CGFloat progress = videoModel.progress.floatValue;
    NSString *progressText = [[NSString stringWithFormat:@"%li",(NSInteger)(progress *100)]stringByAppendingString:@"%"];
    self.progressLabel.text = progressText;   //进度
    self.sizeLabel.text = videoSize;   //视频大小
    self.secondsLabel.text = [ChatUtil videoDurationWithSeconds:duration.longLongValue];
    self.nickNameLabel.text   = videoModel.nickName; //昵称
    //拉伸遮罩
    UIImage *rightHeightCoverImage = LoadImage(@"右－竖图片遮罩");
    UIImage *rightWidthCoverImage  = LoadImage(@"右－横图片遮罩");
    UIImage *leftHeightCoverImage  = LoadImage(@"左－竖图片遮罩");
    UIImage *leftWidthCoverImage   = LoadImage(@"左－横图片遮罩");
    //高的
    rightHeightCoverImage          = [rightHeightCoverImage stretchableImageWithLeftCapWidth:rightHeightCoverImage.size.width*0.3 topCapHeight:rightHeightCoverImage.size.height*0.6];
    //宽的
    rightWidthCoverImage           = [rightWidthCoverImage stretchableImageWithLeftCapWidth:rightHeightCoverImage.size.width*0.3 topCapHeight:rightHeightCoverImage.size.height*0.8];
    
    leftHeightCoverImage           = [leftHeightCoverImage stretchableImageWithLeftCapWidth:rightHeightCoverImage.size.width*0.6 topCapHeight:rightHeightCoverImage.size.height*0.8];
    leftWidthCoverImage            = [leftWidthCoverImage stretchableImageWithLeftCapWidth:rightHeightCoverImage.size.width*0.5 topCapHeight:rightHeightCoverImage.size.height*0.8];
    
    //本人
    CGFloat scale = width/height;
    if ([videoModel.fromUserID isEqualToString:[AccountTool account].myUserID]) {
        
        //处理发送失败按钮
        BOOL isSend   = [videoModel.isSend integerValue];
        self.failureButton.hidden = isSend || videoModel.isSending.integerValue;
        
        [self.iconView downloadImage:[AccountTool account].portrait placeholder:@"userhead"];
        //从本地读取
        NSString *path = [[ChatCache_Path stringByAppendingPathComponent:videoModel.toUserID]stringByAppendingPathComponent:@"ChatCache"];
        NSString *picturePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_cover.jpg",videoModel.content.fileName]];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:picturePath]];
        UIImage *picImage = [UIImage imageWithData:imageData];
        //本地如果存在
        if (picImage) {
            self.picView.image = picImage;
        }else{
            //服务器生成 (此情况一般是转发)
//            [self.picView downloadImage:[StreamServer stringByAppendingPathComponent:messageModel.content.thumbnailLoc] placeholder:@"userhead"];
        }
        
        //高大于宽
        if (height > width) {
            
            if (scale *105 <=50) {
                
                self.coverView.image = LoadImage(@"右－超长遮罩");
            }else{
                self.coverView.image = rightHeightCoverImage;
            }
            
        }else if (height == width){
            
            self.coverView.image = rightWidthCoverImage;
        }else{
            
            if (100*(height/width)<=50) {
                self.coverView.image = LoadImage(@"右－超宽遮罩");
            }else{
                self.coverView.image = rightWidthCoverImage;
            }
        }
        
    }else{
        
        [self.iconView downloadImage:videoModel.fromPortrait placeholder:@"userhead"];
        
        //服务器生成图
//        [self.picView downloadImage:[StreamServer stringByAppendingPathComponent:messageModel.content.thumbnailLoc] placeholder:@"userhead"];
        
        //高大于宽
        if (height > width) {
            
            if (scale *105 <=50) {
                self.coverView.image = LoadImage(@"左－超长遮罩");
            }else{
                self.coverView.image = leftHeightCoverImage;
            }
            
        }else if (height == width){
            
            self.coverView.image = leftWidthCoverImage;
        }else{
            
            if (100*(height/width)<=50) {
                
                self.coverView.image = LoadImage(@"左－超宽遮罩");
            }else{
                self.coverView.image = leftWidthCoverImage;
            }
        }
    }
}


- (void)setFrames:(ChatModel *)videoModel
{
    
    NSArray *widthHeight = [videoModel.content.text componentsSeparatedByString:@"-"];
    CGFloat width = [widthHeight[0]floatValue];
    CGFloat height = [widthHeight[1]floatValue];
    
    //本人
    CGFloat scale = width/height;
    if ([videoModel.fromUserID isEqualToString:[AccountTool account].myUserID]) {
        
        self.iconView.frame = Frame(SCREEN_WITDTH - 65, MaxY(self.timeContainer.frame)+15, 50, 50);
        //高大于宽
        if (height>width) {
            
            if (scale *105 <=50) {
                self.picView.frame = Frame(SCREEN_WITDTH - 115, MinY(self.iconView.frame), 50, 130);
                
            }else{
                self.picView.frame = Frame(MinX(self.iconView.frame)-130*scale ,MinY(self.iconView.frame), 130*scale, 130);
            }
            self.coverView.frame = self.picView.bounds;
            CGSize sizeLabelSize = [self.sizeLabel sizeThatFits:CGSizeMake(Width(self.picView.frame)*0.5, 10)];
            self.sizeLabel.frame = Frame(7, Height(self.picView.frame)-10 - 5, sizeLabelSize.width, 10);
            self.secondsLabel.frame = Frame(MaxX(self.sizeLabel.frame),MinY(self.sizeLabel.frame),Width(self.picView.frame) - 15 - MaxX(self.sizeLabel.frame),10.f);
            self.playImageView.frame = Frame((Width(self.picView.frame)-24)*0.5, (Height(self.picView.frame)-24)*0.5, 24, 24);
            self.progressLabel.frame = Frame(0, (Height(self.picView.frame)-14)*0.5, Width(self.picView.frame), 14);
            self.failureButton.frame = Frame(MinX(self.picView.frame)-34, MinY(self.picView.frame)+(Height(self.picView.frame)-24)*0.5, 24, 24);
            
            return;
            //宽高相等
        }else if(height == width){
            
            self.picView.frame = Frame(MinX(self.iconView.frame)-   120, MinY(self.iconView.frame), 120, 120);
            CGSize sizeLabelSize = [self.sizeLabel sizeThatFits:CGSizeMake(Width(self.picView.frame)*0.5, 10)];
            self.sizeLabel.frame = Frame(7, Height(self.picView.frame)-10 - 5, sizeLabelSize.width, 10);
            self.secondsLabel.frame = Frame(MaxX(self.sizeLabel.frame),MinY(self.sizeLabel.frame),Width(self.picView.frame) - 15 - MaxX(self.sizeLabel.frame),10.f);
            self.playImageView.frame = Frame((Width(self.picView.frame)-24)*0.5, (Height(self.picView.frame)-24)*0.5, 24, 24);
            self.progressLabel.frame = Frame(0, (Height(self.picView.frame)-14)*0.5, Width(self.picView.frame), 14);
            self.coverView.frame = self.picView.bounds;
            self.failureButton.frame = Frame(MinX(self.picView.frame)-34, MinY(self.picView.frame)+(Height(self.picView.frame)-24)*0.5, 24, 24);
            
            return;
            //宽大于高
        }else{
            
            if (100*(height/width)<=50) {
                self.picView.frame = Frame(SCREEN_WITDTH -195, MinY(self.iconView.frame), 135, 50);
                self.picView.contentMode = UIViewContentModeScaleToFill;
            }else{
                self.picView.frame = Frame(MinX(self.iconView.frame)-135, MinY(self.iconView.frame), 135, 135 *(height/width));
            }
            CGSize sizeLabelSize = [self.sizeLabel sizeThatFits:CGSizeMake(Width(self.picView.frame)*0.5, 10)];
            self.sizeLabel.frame = Frame(7, Height(self.picView.frame)-10 - 5, sizeLabelSize.width, 10);
            self.secondsLabel.frame = Frame(MaxX(self.sizeLabel.frame),MinY(self.sizeLabel.frame),Width(self.picView.frame) - 15 - MaxX(self.sizeLabel.frame),10.f);
            self.playImageView.frame = Frame((Width(self.picView.frame)-24)*0.5, (Height(self.picView.frame)-24)*0.5, 24, 24);
            self.progressLabel.frame = Frame(0, (Height(self.picView.frame)-14)*0.5, Width(self.picView.frame), 14);
            self.coverView.frame = self.picView.bounds;
            self.failureButton.frame = Frame(MinX(self.picView.frame)-34, MinY(self.picView.frame)+(Height(self.picView.frame)-24)*0.5, 24, 24);
            
            return;
        }
        
        //别人
    }else{
        
        
        //处理是否显示昵称
        if (hashEqual(videoModel.chatType, @"userChat")) {
            self.nickNameLabel.hidden = YES;
            self.iconView.frame = Frame(15, MaxY(self.timeContainer.frame)+15, 50, 50);
        }else{
            self.nickNameLabel.hidden = NO;
            self.nickNameLabel.frame  = Frame(15 + 50 + 10,MaxY(self.timeContainer.frame)+15, 250, 13.f);
            self.iconView.frame = Frame(15, MaxY(self.nickNameLabel.frame)+3, 50, 50);
        }
        
        //高大于宽
        if (height>width) {
            
            if (105*scale<=50) {
                
                self.picView.frame = Frame(MaxX(self.iconView.frame), MinY(self.iconView.frame), 50, 130);
                self.picView.contentMode = UIViewContentModeScaleToFill;
            }else{
                self.picView.frame = Frame(MaxX(self.iconView.frame), MinY(self.iconView.frame), 130*scale, 130);
            }
            CGSize sizeLabelSize = [self.sizeLabel sizeThatFits:CGSizeMake(Width(self.picView.frame)*0.5, 10)];
            self.sizeLabel.frame = Frame(7, Height(self.picView.frame)-10 - 5, sizeLabelSize.width, 10);
            self.secondsLabel.frame = Frame(MaxX(self.sizeLabel.frame),MinY(self.sizeLabel.frame),Width(self.picView.frame) - 7 - MaxX(self.sizeLabel.frame),10.f);
            self.playImageView.frame = Frame((Width(self.picView.frame)-24)*0.5, (Height(self.picView.frame)-24)*0.5, 24, 24);
            self.progressLabel.frame = Frame(0, (Height(self.picView.frame)-14)*0.5, Width(self.picView.frame), 14);
            self.coverView.frame = self.picView.bounds;
            
            return;
            //宽高相等
        }else if(height == width){
            
            self.picView.frame = Frame(MaxX(self.iconView.frame), MinY(self.iconView.frame), 120, 120);
            CGSize sizeLabelSize = [self.sizeLabel sizeThatFits:CGSizeMake(Width(self.picView.frame)*0.5, 10)];
            self.sizeLabel.frame = Frame(7, Height(self.picView.frame)-10 - 5, sizeLabelSize.width, 10);
            self.secondsLabel.frame = Frame(MaxX(self.sizeLabel.frame),MinY(self.sizeLabel.frame),Width(self.picView.frame) - 7 - MaxX(self.sizeLabel.frame),10.f);
            self.coverView.frame = self.picView.bounds;
            self.playImageView.frame = Frame((Width(self.picView.frame)-24)*0.5, (Height(self.picView.frame)-24)*0.5, 24, 24);
            self.progressLabel.frame = Frame(0, (Height(self.picView.frame)-14)*0.5, Width(self.picView.frame), 14);
            return;
            //宽大于高
        }else{
            
            if (100 *(height/width)<=50) {
                
                self.picView.frame = Frame(MaxX(self.iconView.frame), MinY(self.iconView.frame), 135, 50);
                self.picView.contentMode = UIViewContentModeScaleToFill;
            }else{
                self.picView.frame = Frame(MaxX(self.iconView.frame), MinY(self.iconView.frame), 135, 135 *(height/width));
            }
            CGSize sizeLabelSize = [self.sizeLabel sizeThatFits:CGSizeMake(Width(self.picView.frame)*0.5, 10)];
            self.sizeLabel.frame = Frame(7, Height(self.picView.frame)-10 - 5, sizeLabelSize.width, 10);
            self.secondsLabel.frame = Frame(MaxX(self.sizeLabel.frame),MinY(self.sizeLabel.frame),Width(self.picView.frame) - 7 - MaxX(self.sizeLabel.frame),10.f);
            self.playImageView.frame = Frame((Width(self.picView.frame)-24)*0.5, (Height(self.picView.frame)-24)*0.5, 24, 24);
            self.coverView.frame = self.picView.bounds;
            self.progressLabel.frame = Frame(0, (Height(self.picView.frame)-14)*0.5, Width(self.picView.frame), 14);
            return;
        }
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

#pragma mark - 下载视频在线播放
- (void)downLoadVideo
{
    
}

#pragma mark - 重新发送
- (void)sendAgain
{
    
}

@end
