//
//  Account.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/4/20.
//  Copyright © 2017年 mengyao. All rights reserved.
//
/*
 https://github.com/coderMyy/CocoaAsyncSocket_Demo  github地址 ,会持续更新关于即时通讯的细节 , 以及最终的UI代码
 
 https://github.com/coderMyy/MYCoreTextLabel  图文混排 , 实现图片文字混排 , 可显示常规链接比如网址,@,话题等 , 可以自定义链接字,设置关键字高亮等功能 . 适用于微博,微信,IM聊天对话等场景 . 实现这些功能仅用了几百行代码，耦合性也较低
 
 https://github.com/coderMyy/MYDropMenu  上拉下拉菜单，可随意自定义，随意修改大小，位置，各个项目通用
 
 https://github.com/coderMyy/MYPhotoBrowser 简易版照片浏览器。功能主要有 ： 点击点放大缩小 ， 长按保存发送给好友操作 ， 带文本描述照片，从点击照片放大，当前浏览照片缩小等功能。功能逐渐完善增加中.
 
 https://github.com/coderMyy/MYNavigationController  导航控制器的压缩 , 使得可以将导航范围缩小到指定区域 , 实现页面中的页面效果 . 适用于路径选择,文件选择等
 
 如果有好的建议或者意见 ,欢迎博客或者QQ指出 , 您的支持是对贡献代码最大的鼓励,谢谢. 求STAR ..😊😊😊
 */


#import <Foundation/Foundation.h>

@interface Account : NSObject<NSCoding>

@property (nonatomic ,copy) NSString *myUserID; //当前用户ID

@property (nonatomic ,strong) NSNumber *sex; //性别

@property (nonatomic ,strong) NSNumber *age; //年龄

@property (nonatomic ,copy) NSString *birthDay; //生日

@property (nonatomic ,strong,getter=isVip) NSNumber *vip; //是否会员

@property (nonatomic ,strong,getter=isOnline) NSNumber *online;//是否在线

@property (nonatomic ,copy) NSString *lastLoginTime; //最后登录时间

@property (nonatomic, copy) NSString *nickName; //我的昵称

@property (nonatomic, copy) NSString *portrait;  //头像url

/*
 这里仅仅是一个模拟 , 真正的关于当前用户的资料可能还会有很多
 */

+ (instancetype)account;

@end
