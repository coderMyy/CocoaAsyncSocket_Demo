//
//  UIImageView+GIF.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/18.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "UIImageView+GIF.h"

@implementation UIImageView (GIF)

//准备GIF播放
- (void)GIF_PrePlayWithImageNamesArray:(NSArray *)array duration:(NSInteger)duration
{
    self.hidden = NO;
    NSMutableArray *arr = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(NSString  *_Nonnull imageName, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIImage *image = [UIImage imageNamed:imageName];
        [arr addObject:image];
    }];
    //设置序列帧图像数组
    self.animationImages = arr;
    //设置动画时间
    self.animationDuration = 1;
    //设置播放次数，0代表无限次
    self.animationRepeatCount = (NSInteger)duration;
    [self startAnimating];
    //赋值
    //    objc_setAssociatedObject(self ,&imageViewKey ,imageView ,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//停止播放
- (void)GIF_Stop
{
    [self stopAnimating];
}

@end
