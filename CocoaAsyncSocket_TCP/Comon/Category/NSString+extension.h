//
//  NSString+extension.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/14.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (extension)

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;


+ (CGSize)stringSizeWithContainer:(UIView *)container maxSize:(CGSize)maxSize;

@end
