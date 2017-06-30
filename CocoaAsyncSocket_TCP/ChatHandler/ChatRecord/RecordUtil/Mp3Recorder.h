//
//  Mp3Recorder.h
//  BloodSugar
//
//  Created by PeterPan on 14-3-24.
//  Copyright (c) 2014年 陈石. All rights reserved.
//

@import Foundation;

@protocol Mp3RecorderDelegate <NSObject>

@optional
- (void)failRecord;

- (void)beginConvert;

@required
- (void)endConvertWithData:(NSData *)voiceData seconds:(NSTimeInterval)time;

@end

@interface Mp3Recorder : NSObject

@property(nonatomic, weak) id <Mp3RecorderDelegate> delegate;

- (id)initWithDelegate:(id <Mp3RecorderDelegate>)delegate;

- (void)startRecord;

- (void)stopRecord;

- (void)cancelRecord;

@end
