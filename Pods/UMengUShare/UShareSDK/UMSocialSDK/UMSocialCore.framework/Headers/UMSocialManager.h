//
//  UMComPlatformProviderManager.h
//  UMSocialSDK
//
//  Created by 张军华 on 16/8/5.
//  Copyright © 2016年 dongjianxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMSocialPlatformProvider.h"
#import "UMSocialGlobal.h"
@class UMSocialMessageObject;
@interface UMSocialManager : NSObject

+(instancetype)defaultManager;

//友盟自己的appkey(暂时写成属性)
@property(nonatomic,strong)NSString* umSocialAppkey;
@property(nonatomic,strong)NSString* umSocialAppSecret;
@property(nonatomic,readonly,strong) NSMutableArray * platformTypeArray;


/**
 *  打开日志
 *
 *  @param isOpen YES代表打开，No代表关闭
 */
-(void) openLog:(BOOL)isOpen;

/**
 *  设置平台的appkey
 *
 *  @param platformType @see UMSocialPlatformType
 *  @param appKey       第三方平台的appKey（QQ平台为appID）
 *  @param appSecret    第三方平台的appSecret（QQ平台为appKey）
 *  @param redirectURL  redirectURL
 */
- (BOOL)setPlaform:(UMSocialPlatformType)platformType
            appKey:(NSString *)appKey
         appSecret:(NSString *)appSecret
       redirectURL:(NSString *)redirectURL;


/**
 *  设置分享平台
 *
 *  @param platformType @see UMSocialPlatformType
 *  @param shareObject
 *  @param currentViewController 用于弹出类似邮件分享、短信分享等这样的系统页面
 *  @param completion   回调
 *  @discuss currentViewController 只正对sms,email等平台需要传入viewcontroller的平台，其他不需要的平台可以传入nil
 */
- (void)shareToPlatform:(UMSocialPlatformType)platformType
          messageObject:(UMSocialMessageObject *)messageObject
  currentViewController:(id)currentViewController
             completion:(UMSocialRequestCompletionHandler)completion;

/**
 *  取消授权
 *
 *  @param platformType @see UMSocialPlatformType
 *  @param completion   回调
 */
- (void)cancelAuthWithPlatform:(UMSocialPlatformType)platformType
                    completion:(UMSocialRequestCompletionHandler)completion;

/**
 *  获取用户信息
 *  @param currentViewController 用于弹出类似邮件分享、短信分享等这样的系统页面
 *  @param completion   回调
 */
- (void)getUserInfoWithPlatform:(UMSocialPlatformType)platformType
          currentViewController:(id)currentViewController
                     completion:(UMSocialRequestCompletionHandler)completion;

/**
 *  获得从sso或者web端回调到本app的回调
 *
 *  @param url 第三方sdk的打开本app的回调的url
 *
 *  @return 是否处理  YES代表处理成功，NO代表不处理
 */
-(BOOL)handleOpenURL:(NSURL *)url;


/**
 *  动态的增加用户自定义的PlatformProvider
 *
 *  @param userDefinePlatformProvider 用户自定义的userDefinePlatformProvider必须实现UMSocialPlatformProvider
 *  @param platformType               @see platformType platformType的有效范围在 （UMSocialPlatformType_UserDefine_Begin,UMSocialPlatformType_UserDefine_End)之间
 *
 *  @return YES代表返回成功,NO代表失败
 *  @disuss 在调用此函数前，必须先设置对应的平台的配置信息 @see - (BOOL)setPlaform:(UMSocialPlatformType)platformType appKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectURL:(NSString *)redirectURL;
 */
-(BOOL)addAddUserDefinePlatformProvider:(id<UMSocialPlatformProvider>)userDefinePlatformProvider
             withUserDefinePlatformType:(UMSocialPlatformType)platformType;


/**
 *  获得对应的平台类型platformType的PlatformProvider
 *
 *  @param platformType @see platformType
 *
 *  @return 返回继承UMSocialPlatformProvider的handle
 */
-(id<UMSocialPlatformProvider>)platformProviderWithPlatformType:(UMSocialPlatformType)platformType;



/**
 *  动态的删除不想显示的平台，不管是预定义还是用户自定义的
 *
 *  @param platformTypeArray 平台类型数组
 */
-(void) removePlatformProviderWithPlatformTypes:(NSArray *)platformTypeArray;

/**
 *  动态的删除PlatformProvider，不管是预定义还是用户自定义的
 *
 *  @param platformType @see UMSocialPlatformType
 */
-(void) removePlatformProviderWithPlatformType:(UMSocialPlatformType)platformType;


-(BOOL) isInstall:(UMSocialPlatformType)platformType;

-(BOOL) isSupport:(UMSocialPlatformType)platformType;


#pragma mark - DEPRECATED METHOD
/**
 *  授权平台（废弃 - 请使用-getUserInfoWithPlatform:currentViewController:completion接口进行授权）
 *
 *  @param platformType @see UMSocialPlatformType
 *  @param currentViewController 用于弹出类似邮件分享、短信分享等这样的系统页面
 *  @discuss currentViewController 只对sms,email等平台需要传入viewcontroller的平台，其他不需要的平台可以传入nil
 *  @param completion   回调
 */
- (void)authWithPlatform:(UMSocialPlatformType)platformType
   currentViewController:(id)currentViewController
              completion:(UMSocialRequestCompletionHandler)completion __attribute__((deprecated));

@end

