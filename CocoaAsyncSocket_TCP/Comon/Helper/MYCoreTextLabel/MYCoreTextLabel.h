//
//  MYCoreTextLabel.h
//  图文混排demo
//
//  Created by 孟遥 on 2017/2/5.
//  Copyright © 2017年 孟遥. All rights reserved.

/**
 
 Github地址 : https://github.com/coderMyy/MYCoreTextLabel 求Star , Fork .....
 博客地址    : http://blog.csdn.net/codermy  , 偶尔会记录一下学习的东西 .
 
*/

#import <UIKit/UIKit.h>
#import "MYCoretextResultTool.h"


/**
 事件回调

 @param linkString <#linkString description#>
 */
typedef void(^eventCallback)(NSString *linkString);

@protocol MYCoreTextLabelDelegate <NSObject>

@optional

//代理回调
- (void)linkText:(NSString *)clickString type:(MYLinkType)linkType;

@end

@interface MYCoreTextLabel : UIView

//代理
@property (nonatomic, weak) id<MYCoreTextLabelDelegate> delegate;
//表情/图片尺寸大小 ,默认和字体一致
@property (nonatomic, assign) CGSize imageSize;
//链接点中背景透明度
@property (nonatomic, assign) CGFloat linkBackAlpha;




#pragma mark ---------------*******************************---------------- 普通文本部分属性  例 : 这是一个测试句子
//内容字体大小（除开链接特殊字以外内容的字体大小）,默认14.f
@property (nonatomic, strong) UIFont *textFont;
//内容字体颜色（除开链接特殊字以外的内容）,默认黑色
@property (nonatomic, strong) UIColor *textColor;
//内容行间距
@property (nonatomic, assign) CGFloat lineSpacing;
//字间距
@property (nonatomic, assign) CGFloat wordSpacing;



#pragma mark ---------------*******************************---------------- 网址链接属性  例 : www.baidu.com

//是否匹配网址链接
@property (nonatomic, assign) BOOL showWebLink;
//网址链接字体颜色   默认蓝色
@property (nonatomic, strong) UIColor *webLinkColor;
//网址链接字体大小    默认14.f
@property (nonatomic, strong) UIFont *webLinkFont;
//常规链接选中背景色  默认蓝色
@property (nonatomic, strong) UIColor *webLinkBackColor;





#pragma mark ---------------*******************************---------------- 话题链接属性   例 : #话题#

//是否显示话题链接
@property (nonatomic, assign) BOOL showTopicLink;
//常规链接字体颜色     默认蓝色
@property (nonatomic, strong) UIColor *topicLinkColor;
//常规链接字体大小     默认14.f
@property (nonatomic, strong) UIFont *topicLinkFont;
//常规链接选中背景色   默认蓝色
@property (nonatomic, strong) UIColor *topicLinkBackColor;






#pragma mark ---------------*******************************---------------- @链接属性   例 : @小明

//是否显示@链接
@property (nonatomic, assign) BOOL showTrendLink;
//@链接字体颜色      默认蓝色
@property (nonatomic, strong) UIColor *trendLinkColor;
//@链接字体大小      默认14.f
@property (nonatomic, strong) UIFont *trendLinkFont;
//@链接选中背景色   默认蓝色
@property (nonatomic, strong) UIColor *trendLinkBackColor;






#pragma mark ---------------*******************************---------------- 邮箱链接属性   例 : mengyao_block@outlook.com

//是否显示邮箱链接
@property (nonatomic, assign) BOOL showMailLink;
//邮箱链接字体颜色     默认蓝色
@property (nonatomic, strong) UIColor *mailLinkColor;
//邮箱链接字体大小     默认14.f
@property (nonatomic, strong) UIFont *mailLinkFont;
//邮箱链接选中背景色  默认蓝色
@property (nonatomic, strong) UIColor *mailLinkBackColor;





#pragma mark ---------------*******************************---------------- 手机号链接属性   例 : 139xxxxx834

//是否显示手机链接
@property (nonatomic, assign) BOOL showPhoneLink;
//手机链接字体颜色     默认蓝色
@property (nonatomic, strong) UIColor *phoneLinkColor;
//手机链接字体大小     默认14.f
@property (nonatomic, strong) UIFont *phoneLinkFont;
//手机链接选中背景色  默认蓝色
@property (nonatomic, strong) UIColor *phoneLinkBackColor;



#pragma mark ---------------*******************************---------------- 自定义链接属性   例 : 这是一个自定义链接  (自定义链接)
//额外指定链接文字颜色 默认蓝色
@property (nonatomic, strong) UIColor *customLinkColor;
//额外指定链接文字大小 , 默认 14.f
@property (nonatomic, strong) UIFont *customLinkFont;
//额外指定链接文字选中背景 , 默认蓝色
@property (nonatomic, strong) UIColor *customLinkBackColor;





#pragma mark ---------------*******************************---------------- 关键字部分属性
//关键字颜色 , 默认黑色
@property (nonatomic, strong) UIColor *keyWordColor;
//关键字字体大小, 默认 14.f
@property (nonatomic, strong) UIFont *keywordFont;
//关键字背景色 , 默认黄色
@property (nonatomic, strong) UIColor *keyWordBackColor;






+ (instancetype)coreTextLabel;

- (void)setText:(NSString *)text;

/**
  设置内容 , linkRanges可以指定 对应range位置的字符串为连接类型 , 代理回调链接类型为MYLinkTypeCustomLink自定义字符串链接类型
 
 使用说明 :  例如需要展示的文本为  @"这是一句测试数据一句一句" , 此时我仅需要把第一个 "一句"变为链接可点击状态 , 那么只需要设置 text 为该句子 , linkeRanges 传入 @[[NSValue valueWithRange:NSMakeRange(2, 2)]] 即可

 应用场景 : 此方法 , 多用于类似微信朋友圈的 xxx 回复 xxx , 朋友圈表情文字,图片文字 ,网址话题等混排
 
 @param text <#text description#>
 @param ranges <#range description#>
 @param keywords <#keywords description#>
 */
- (void)setText:(NSString *)text linkRanges:(NSArray<NSValue *> *) ranges keywords:(NSArray<NSString *> *)keywords;


/**
 内容添加链接 , 如不需要额外的指定链接 , customLinks传nil ,默认显示常规链接 @ #话题#  web
 你可以通过showPhoneLink showMailLink 等来要求是否匹配 手机号 , 邮箱等 ...
 
 使用说明 : 例如我需要展示一句话 , @"这是一个#话题#,你@小明一定要去关注喔 , 网址是www.baidu.com . 如果有惊喜或者福利 , 一定要提醒我" 
 
 此时如果 , 我需要让#话题#可以点击 , @小明 可以点击 ,www.baidu.com 可以点击 , "福利" 展示为关键字状态,就是背景有颜色,但是不可点击 , "提醒" 可以点击 , 仅需如下操作
 
 此时text传入该字符串 , #话题# 显示showTopicLink = YES , @显示 showTrendLink = YES, 网址显示showWebLink = YES , customLinks传入 @[@"提醒"] , keywords
 传入 @[@"福利"] 即可  . 各种链接都可以设置相应的属性 , 如字体大小 颜色等..
 
 应用场景 : 搜索时展示搜索关键词 , 发送验证(您已阅读相关条例,发送短信验证) , 朋友圈表情文字,图片文字 ,网址话题等混排
 
 @param text       <#text description#>
 @param customLinks <#otherlinks description#>
 */
- (void)setText:(NSString *)text customLinks:(NSArray<NSString *> *)customLinks keywords:(NSArray<NSString *> *)keywords;

@end
