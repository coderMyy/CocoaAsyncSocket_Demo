//
//  MYSubCoretextResult.h
//  图文混排demo
//
//  Created by 孟遥 on 2017/2/12.
//  Copyright © 2017年 孟遥. All rights reserved.

/**
 
 Github地址 : https://github.com/coderMyy/MYCoreTextLabel 求Star , Fork .....
 博客地址    : http://blog.csdn.net/codermy  , 偶尔会记录一下学习的东西 .
 
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,MYLinkType){
    MYLinkTypetTrendLink = 1<<0,   // @链接
    MYLinkTypetTopicLink = 2<<0,  // 话题 ## 链接
    MYLinkTypetWebLink   = 3<<0,  // 网址链接 www. xxx .com
    MYLinkTypeCustomLink = 4<<0, //自定义链接类型
    MYLinkTypePhoneLink = 5<<0, //手机号码
    MYLinkTypeMailLink = 6<<0,     //邮箱
    MYLinkTypeKeyword = 7<<0
};


@interface MYSubCoretextResult : NSObject

@property (nonatomic, strong) NSString *string; //切割表情字符串
@property (nonatomic, assign) NSRange range;  //切割表情集range
@property (nonatomic, assign,getter=isEmotion) BOOL isEmotion;
@property (nonatomic, strong) NSArray *links; //每个结果里包含的链接

@end


@interface MYLinkModel : NSObject

@property (nonatomic, copy) NSString *linkText;  //链接内容
@property (nonatomic, strong) NSArray<UITextSelectionRect *> *rects; //矩形框数组
@property (nonatomic, assign) NSRange range;  //链接范围
@property (nonatomic, assign,getter=isTopicLink) MYLinkType linkType; //链接类型
@property (nonatomic, strong) UIColor *clickBackColor;  //点击背景颜色
@property (nonatomic, strong) UIFont *clickFont; //点击的字体大小
@end
