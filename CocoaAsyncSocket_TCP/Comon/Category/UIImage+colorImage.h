//
//  UIImage+colorImage.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (colorImage)

+ (UIImage *)imageFromContextWithColor:(UIColor *)color; //一像素图片

+ (UIImage *)imageFromContextWithColor:(UIColor *)color size:(CGSize)size;

@end
