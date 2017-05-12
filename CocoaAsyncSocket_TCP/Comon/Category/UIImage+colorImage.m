//
//  UIImage+colorImage.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "UIImage+colorImage.h"

@implementation UIImage (colorImage)

//给我一种颜色，一个尺寸，我给你返回一个UIImage
+ (UIImage *)imageFromContextWithColor:(UIColor *)color size:(CGSize)size{
    
    CGRect rect=(CGRect){{0.0f,0.0f},size};
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextFillRect(context, rect);
    
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageFromContextWithColor:(UIColor *)color{
    
    CGSize size=CGSizeMake(1.0f, 1.0f);
    
    return [self imageFromContextWithColor:color size:size];
}

@end
