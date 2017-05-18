//
//  UIImageView+GIF.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/18.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (GIF)
//播放GIF
- (void)GIF_PrePlayWithImageNamesArray:(NSArray *)array duration:(NSInteger)duration;
//停止播放
- (void)GIF_Stop;

@end
