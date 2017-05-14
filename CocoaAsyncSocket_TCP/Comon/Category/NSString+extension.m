//
//  NSString+extension.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/14.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "NSString+extension.h"

@implementation NSString (extension)

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *dict = @{NSFontAttributeName: font};
    CGSize textSize = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    return textSize;
}


+ (CGSize)stringSizeWithContainer:(UIView *)container maxSize:(CGSize)maxSize
{
    if (!container) {
        return CGSizeZero;
    }
    CGSize needSize = [container sizeThatFits:maxSize];
    return needSize;
}

@end
