//
//  MYCoretextResultTool.h
//  图文混排demo
//
//  Created by 孟遥 on 2017/2/11.
//  Copyright © 2017年 孟遥. All rights reserved.

/**
 
 Github地址 : https://github.com/coderMyy/MYCoreTextLabel 求Star , Fork .....
 博客地址    : http://blog.csdn.net/codermy  , 偶尔会记录一下学习的东西 .
 
 */


#import <Foundation/Foundation.h>
#import "MYSubCoretextResult.h"

@interface MYCoretextResultTool : NSObject


/**
 获取切割表情结果集

 @param text <#text description#>

 @return <#return value description#>
 */
+ (NSMutableArray<MYSubCoretextResult *> *)subTextWithEmotion:(NSString *)text;

#pragma mark - 设置自定义链接
+ (void)customLinks:(NSArray<NSString *> *)customLinks;


/**
 赋值keyword

 @param keywords <#keywords description#>
 */
+ (void)keyWord:(NSArray<NSString *> *)keywords;

@end
