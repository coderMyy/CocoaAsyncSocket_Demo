//
//  UIImage+photoPicker.h
//  JYHomeCloud
//
//  Created by 孟遥 on 16/12/19.
//  Copyright © 2016年 JYall Network Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JYPhotoVideoModel;

//返回选中的所有图片 , 原图或者压缩图
typedef void(^JYPhotoPickerImagesCallback)(NSArray<JYPhotoVideoModel *> *images);

//返回照片原图的data
typedef void(^JYPhotoPickerDataCallback)(NSArray<JYPhotoVideoModel *> *datas);

//返回视频存储的位置
typedef void(^JYVideoPathCallback)(NSString *filePath,NSString *size);

//立刻返回封面图
typedef void(^JYVideoCoverImageBackRightNow)(UIImage *coverImage,NSString *fileName,long long int duration);


@interface UIImage (photoPicker)




/**
 获取选中照片数组模型  ,此方法用于打开相册选择照片 ,  是否选择原图  由用户自行决定

 @param imagesCallback <#imagesCallback description#>
 @param target         控制器
 @param count          最大选择张数
 @param needShowButton 是否需要展示拍照按钮
 */
+ (void)openPhotoPickerGetImages:(JYPhotoPickerImagesCallback)imagesCallback target:(UIViewController *)target maxCount:(NSInteger)count isNeedShowTakePictureButton:(BOOL)needShowButton rect:(CGRect)rect;




/**
 获取原图data , 此方法仅限于上传原图使用 , 如不需要原图 , 则使用上述方法 , 避免获取图片过大

 @param photosCallback <#photosCallback description#>
 @param target         控制器
 @param count          最大选择张数
 @param needShowButton 是否需要展示拍照按钮
 */
+ (void)openPhotoPickerGetOrignalData:(JYPhotoPickerDataCallback)photosCallback taget:(UIViewController *)target maxCount:(NSInteger)count isNeedShowTakePictureButton:(BOOL)needShowButton;



/**
 IM专用

 @param imagesCallback <#photosCallback description#>
 @param target <#target description#>
 @param count <#count description#>
 */
+ (void)openPhotoPickerGetImages:(JYPhotoPickerImagesCallback)imagesCallback target:(UIViewController *)target maxCount:(NSInteger)count;

/**
 获取选中的视频 , 如实现了 JYVideoCoverImageBackRightNow , 则会立马返回一张该视频的缩略图   如不需要,直接传入nil即可

 @param videoPathCallback <#videoPathFileNameCallback description#>
 @param coverBack                 <#coverBack description#>
 @param target                    <#target description#>
 @param basePath                  <#basePath description#>
 */
+ (void)openPhotoPickerGetVideo:(JYVideoPathCallback)videoPathCallback coverBackRightNow:(JYVideoCoverImageBackRightNow)coverBack target:(UIViewController *)target CacheDirectory:(NSString *)basePath;

@end
