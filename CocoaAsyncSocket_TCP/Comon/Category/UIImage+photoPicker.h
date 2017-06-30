//
//  UIImage+photoPicker.h
//  JYHomeCloud
//  Created by 孟遥 on 2017/4/14.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatAlbumModel;

//返回选中的所有图片 , 原图或者压缩图
typedef void(^photoPickerImagesCallback)(NSArray<ChatAlbumModel *> *images);

//返回视频存储的位置
typedef void(^videoBaseInfoCallback)(ChatAlbumModel *videoModel);


@interface UIImage (photoPicker)

/**

 @param imagesCallback <#photosCallback description#>
 @param target 打开相册所需
 @param count 最大可选数量
 */
+ (void)openPhotoPickerGetImages:(photoPickerImagesCallback)imagesCallback target:(UIViewController *)target maxCount:(NSInteger)count;

/**
 获取选中的视频
 */
+ (void)openPhotoPickerGetVideo:(videoBaseInfoCallback)callback target:(UIViewController *)target;

@end
