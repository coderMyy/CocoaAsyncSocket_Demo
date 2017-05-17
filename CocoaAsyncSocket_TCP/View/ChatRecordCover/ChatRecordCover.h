//
//  ChatRecordCover.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/17.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatRecordCover : UIView

//初始化录音蒙板
+ (instancetype)chatRecordCover;
//开始录音
+ (void)beginRecord;
//取消录音
+ (void)cancelRecord;
//录音结束
+ (void)stopRecord;

@end
