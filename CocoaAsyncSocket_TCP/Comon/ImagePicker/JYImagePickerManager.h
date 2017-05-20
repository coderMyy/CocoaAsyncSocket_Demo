//
//  JYImagePickerManager.h
//  JYHomeCloud
//
//  Created by guo xiaowei on 2016/12/16.
//  Copyright © 2016年 JYall Network Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, PickerType)
{
    PickerType_Camera = 0, // 拍照
    PickerType_Video,//视频
    PickerType_Photo, // 照片
};

typedef void(^albumAuthorizationCallBack)();

typedef void(^CallBackBlock)(NSDictionary *infoDict, BOOL isCancel,JYUpLoadTaskModel *taskModel);  // 回调

@interface JYImagePickerManager : NSObject

+ (instancetype)shareInstance; // 单例

- (void)presentPicker:(PickerType)pickerType target:(UIViewController *)vc callBackBlock:(CallBackBlock)callBackBlock;


+ (void)photoAlbumAuthorizationJudge:(albumAuthorizationCallBack)callback;
+ (void)avAuthorizationJudge:(albumAuthorizationCallBack)callback;

@end
