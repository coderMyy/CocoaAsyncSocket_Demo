//
//  UMSocialGlobal.h
//  UMSocialSDK
//
//  Created by 张军华 on 16/8/16.
//  Copyright © 2016年 dongjianxiong. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  UMSocial的全局配置文件
 */



/**
 *  用来设置UMSocial的全局设置变量
 */
@interface  UMSocialGlobal: NSObject

+ (UMSocialGlobal *)shareInstance;

/**
 *  是否用cocos2dx,0-没有使用 1-使用cocos2dx 默认为0
 */
@property(atomic,readwrite, assign)NSInteger use_coco2dx;

/**
 *  统计的主题，默认为：UMSocialDefault
 */
@property(atomic,readwrite,copy)NSString* dc;

/**
 *  是否请求的回流统计请求，默认为不请求
 */
@property(atomic,readwrite,assign)BOOL isUrlRequest;

/**
 *  type字符串
 *  @discuss type是新加入的字段，目前默认值为@"native"
 */
@property(atomic,readwrite, copy)NSString* type;


/**
 *  UMSocial的版本号
 *
 *  @return 返回当前的版本号
 */
+(NSString*)umSocialSDKVersion;


/**
 *  thumblr平台需要作为标示的字段 tag
 *  @discuss 默认的tag是UMSocial_ThumblrTag，用户可以自己设置自己的tag
 */
@property(atomic,readwrite,copy)NSString* thumblr_Tag;


/**
 *  对平台的分享文本的时候，做规定的截断，默认开启
 *  @dicuss 针对特定平台(比如:微信，qq,sina等)对当前的分享信息中的文本截断到合理的位置从而能成功分享
 */
@property(atomic,readwrite,assign)BOOL isTruncateShareText;

@end

