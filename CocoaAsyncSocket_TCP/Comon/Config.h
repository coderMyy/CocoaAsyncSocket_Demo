//
//  Config.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/4/20.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#ifndef Config_h
#define Config_h

/*******************Socket**************************/
#define TCP_VersionCode  @"1"      //当前TCP版本(服务器协商,便于服务器版本控制)
#define TCP_beatBody  @"beatID"    //心跳标识
#define TCP_AutoConnectCount  3    //自动重连次数
#define TCP_BeatDuration  1        //心跳频率
#define TCP_MaxBeatMissCount   3   //最大心跳丢失数
#define TCP_PingUrl    @"www.baidu.com"


#define networkStatus  [GLobalRealReachability currentReachabilityStatus]  //网络状态


/****************************************************/
#define hashEqual(str1,str2)  str1.hash == str2.hash  //hash码
#define SCREEN_BOUNDS   [UIScreen mainScreen].bounds //屏幕bounds
#define SCREEN_WITDTH    [UIScreen mainScreen].bounds.size.width //屏宽
#define SCREEN_HEIGHT    [UIScreen mainScreen].bounds.size.height //屏高
/// View 圆角
#define ViewRadius(View, Radius)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES]

///  View加边框
#define ViewBorder(View, BorderColor, BorderWidth )\
\
View.layer.borderColor = BorderColor.CGColor;\
View.layer.borderWidth = BorderWidth;

//frame
#define Frame(x,y,width,height)  CGRectMake(x, y, width, height)

//最大最小值
#define MaxX(frame) CGRectGetMaxX(frame)
#define MaxY(frame) CGRectGetMaxY(frame)
#define MinX(frame) CGRectGetMinX(frame)
#define MinY(frame) CGRectGetMinY(frame)
//宽度高度
#define Width(frame)    CGRectGetWidth(frame)
#define Height(frame)   CGRectGetHeight(frame)

//16进制颜色
#define UICOLOR_RGB_Alpha(_color,_alpha) [UIColor colorWithRed:((_color>>16)&0xff)/255.0f green:((_color>>8)&0xff)/255.0f blue:(_color&0xff)/255.0f alpha:_alpha]
//分割线
#define  UILineColor           UICOLOR_RGB_Alpha(0xe6e6e6,1)
//主白色
#define  UIMainWhiteColor  [UIColor whiteColor]
//主背景色
#define UIMainBackColor UICOLOR_RGB_Alpha(0xf0f0f0,1)
//加载本地图片
#define LoadImage(imageName) [UIImage imageNamed:imageName]
//加载不缓存图片
#define LoadImage_NotCache(imageName,imageType) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:imageName ofType:imageType]]
//设置字体
#define FontSet(fontSize)  [UIFont systemFontOfSize:fontSize]
//聊天缓存基本地址 (根据当前用户来创建缓存目录 , 每个登录用户创建单独资源文件夹,每个会话创建单独的文件夹 , 便于管理)
#define ChatCache_Path   [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Library/Caches/ChatSource/%@",[Account account].myUserID]]

#endif /* Config_h */
