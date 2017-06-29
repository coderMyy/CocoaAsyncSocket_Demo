//
//  ChatAudioPlayTool.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/25.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatAudioPlayTool.h"
#import <AVFoundation/AVFoundation.h>

@interface ChatAudioPlayTool ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *item;

@end

@implementation ChatAudioPlayTool

+ (instancetype)audioPlayTool:(NSString *)path
{
    return [[self alloc]initWithPath:path];
}

- (instancetype)initWithPath:(NSString *)path
{
    if (self = [super init]) {
        self.item   = [[AVPlayerItem alloc]initWithURL:[NSURL fileURLWithPath:path]];
        self.player = [[AVPlayer alloc]initWithPlayerItem:self.item];
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                sizeof(sessionCategory),
                                &sessionCategory);
        
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                 sizeof (audioRouteOverride),
                                 &audioRouteOverride);
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        //静音模式依然播放
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
    }
    return self;
}


- (void)play
{
    [self.player play];
}
@end
