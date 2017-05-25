//
//  ChatRecordTool.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/18.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatRecordTool.h"
#import "Mp3Recorder.h"
#import "UIImageView+GIF.h"

@interface ChatRecordTool ()<Mp3RecorderDelegate>
//定时器
@property (nonatomic, strong) dispatch_source_t recordTimer;
//蒙板
@property (nonatomic, strong) UIView *recordCoverView;
//展示
@property (nonatomic, strong) UIImageView *animationView;
//倒计时
@property (nonatomic, strong) UILabel *cutdownLabel;
//录音
@property (nonatomic, strong) Mp3Recorder *recorder;
//录制的秒数
@property (nonatomic, assign) NSUInteger recordSeconds;
//callback
@property (nonatomic, copy) audioInfoCallback infoCallback;
@end

@implementation ChatRecordTool

- (dispatch_source_t)recordTimer
{
    if (!_recordTimer) {
        _recordTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_recordTimer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    }
    return _recordTimer;
}

- (Mp3Recorder *)recorder
{
    if (!_recorder) {
        _recorder = [[Mp3Recorder alloc]initWithDelegate:self];
    }
    return _recorder;
}

- (UIImageView *)animationView
{
    if (!_animationView) {
        _animationView = [[UIImageView alloc]initWithFrame:Frame((SCREEN_WITDTH - 120)*0.5, (SCREEN_HEIGHT - 120)*0.5, 120, 120)];
    }
    return _animationView;
}

- (UILabel *)cutdownLabel
{
    if (!_cutdownLabel) {
        _cutdownLabel = [[UILabel alloc]initWithFrame:Frame((SCREEN_WITDTH - 120)*0.5, (SCREEN_HEIGHT - 120)*0.5, 120, 120)];
        _cutdownLabel.font = [UIFont systemFontOfSize:50 weight:0.2];
        _cutdownLabel.textColor = [UIColor whiteColor];
        _cutdownLabel.textAlignment = NSTextAlignmentCenter;
        _cutdownLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        ViewRadius(_cutdownLabel, 10.f);
        _cutdownLabel.hidden = YES; //默认隐藏
    }
    return _cutdownLabel;
}

- (UIView *)recordCoverView
{
    if (!_recordCoverView) {
        _recordCoverView = [[UIView alloc]initWithFrame:SCREEN_BOUNDS];
        _recordCoverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _recordCoverView.userInteractionEnabled = NO;
        [_recordCoverView addSubview:self.animationView];
        [_recordCoverView addSubview:self.cutdownLabel];
    }
    return _recordCoverView;
}

//初始化录音蒙板
+ (instancetype)chatRecordTool
{
    return [[self alloc]init];
}


//开始录音
- (void)beginRecord
{
    //开始录制
    [self.recorder startRecord];
    //蒙板展示
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.recordCoverView];
    //展示GIF
    [self.animationView GIF_PrePlayWithImageNamesArray:@[@"正发送语音1",@"正发送语音2",@"正发送语音3"] duration:0];
    //开启定时器
    dispatch_source_set_event_handler(self.recordTimer, ^{
        
        _recordSeconds ++ ;
        //处理倒计时UI
        
    });
    dispatch_resume(self.recordTimer);
}

//取消录音
- (void)cancelRecord
{
    //取消录制
    [self.recorder cancelRecord];
    
    [self clearRecord];
}

//录音结束
- (void)stopRecord:(audioInfoCallback)infoCallback
{
    _infoCallback = infoCallback;
    //结束录制
    [self.recorder stopRecord];
    [self clearRecord];
}

//手指移开录音按钮
- (void)moveOut
{
    //大于50开始倒计时
    if (_recordSeconds > 50) {
        
    }else{
        //停止GIF
        [self.animationView GIF_Stop];
        //展示固定图
        [self.animationView setImage:LoadImage(@"松开取消发送")];
    }
}

//继续录制
- (void)continueRecord
{
    //播放GIF
     [self.animationView GIF_PrePlayWithImageNamesArray:@[@"正发送语音1",@"正发送语音2",@"正发送语音3"] duration:0];
}


#pragma mark - delegate
- (void)endConvertWithData:(NSData *)voiceData seconds:(NSTimeInterval)time
{
    if (_infoCallback) {
        _infoCallback(voiceData,(NSInteger)time);
    }
}


#pragma mark - 录音相关清除
- (void)clearRecord
{
    //蒙板消失
    [UIView animateWithDuration:0.25 animations:^{
        self.recordCoverView.alpha = 0.0001;
    } completion:^(BOOL finished) {
        //移除
        [self.recordCoverView removeFromSuperview];
        //关闭定时器
        dispatch_source_cancel(_recordTimer);
    }];
}


- (void)dealloc
{
    dispatch_source_cancel(_recordTimer);
}

@end
