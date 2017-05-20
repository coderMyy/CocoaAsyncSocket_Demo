//
//  UIImage+photoPicker.m
//  JYHomeCloud
//
//  Created by 孟遥 on 16/12/19.
//  Copyright © 2016年 JYall Network Technology Co.,Ltd. All rights reserved.
//

#import "UIImage+photoPicker.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import "JYPhotoVideoListModel.h"

typedef void(^albumAuthorizationCallBack)();

@implementation UIImage (photoPicker)





/**
  获取选择的照片的原图data   上传服务器处使用
 
 @param photosCallback <#photosCallback description#>
 */
+ (void)openPhotoPickerGetOrignalData:(JYPhotoPickerDataCallback)photosCallback taget:(UIViewController *)target maxCount:(NSInteger)count isNeedShowTakePictureButton:(BOOL)needShowButton
{
    
    TZImagePickerController *picker = [self initPickerWithtaget:target maxCount:count];
    picker.allowTakePicture    =  needShowButton;  //是否允许拍照
    picker.allowPickingVideo = NO;       //是否展示视频
    picker.allowPickingOriginalPhoto = NO;  //关掉按钮 , 实质上还是默认选择的原图
        //获取选择的图片数组
        picker.didFinishPickingPhotosWithInfosHandle = ^(NSArray<UIImage *> *images,NSArray *assets,BOOL isSelectOriginalPhoto,NSArray<NSDictionary *> *infos){
                
                NSMutableArray *orginalModels = [NSMutableArray array];
            __block NSInteger index = 0;
                [assets enumerateObjectsUsingBlock:^(PHAsset  *_Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    //获取所有原图
                    [[TZImageManager manager]getOriginalPhotoDataWithAsset:asset completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                        NSString *name = [[info[@"PHImageFileSandboxExtensionTokenKey"]componentsSeparatedByString:@"/"]lastObject];
                        JYPhotoVideoModel *photoModel = [[JYPhotoVideoModel alloc]init];
                        photoModel.isOrignal = YES;
                        photoModel.orignalData = data;
                        photoModel.size = data.length;
                        photoModel.fileName = [[JYAccountTool account].userName stringByAppendingString:[NSString stringWithFormat:@"%u%@",arc4random_uniform(99999)*arc4random_uniform(99999),name]];
                        [orginalModels addObject:photoModel];
                        
                        if (index == images.count -1) {
                            //回调
                            photosCallback(orginalModels);
                        }
                        index++;
                    }];
            }];
      };
}



/**
  获取图片数组 , 模型包含名称 , 图片对象 , data ,大小
 //此框架 , 默认返回的就是原图 ,需要小图需要自行压缩
 @param imagesCallback <#imagesCallback description#>
 @param target         <#target description#>
 */
+ (void)openPhotoPickerGetImages:(JYPhotoPickerImagesCallback)imagesCallback target:(UIViewController *)target maxCount:(NSInteger)count isNeedShowTakePictureButton:(BOOL)needShowButton rect:(CGRect)rect
{
    
    TZImagePickerController *picker = [self initPickerWithtaget:target maxCount:count];
    picker.allowTakePicture  = needShowButton; //是否需要展示拍照按钮
    picker.allowPickingVideo = NO;     //是否需要展示视频
    picker.allowPickingOriginalPhoto = YES;   //是否允许选择原图
    if (rect.size.width != 0) {
        picker.allowCrop = YES;
        picker.cropRect = rect;
    }
    picker.didFinishPickingPhotosWithInfosHandle = ^(NSArray<UIImage *> *images,NSArray *assets,BOOL isSelectOriginalPhoto,NSArray<NSDictionary *> *infos){
        
        //选择了原图
        if (isSelectOriginalPhoto) {
            
            __block int index = 0;
            
            NSMutableArray *imagesArray = [NSMutableArray array];
            [assets enumerateObjectsUsingBlock:^(PHAsset  *_Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
               
                NSLog(@"-------------------------------------------------");
                JYPhotoVideoModel *photoModel = [[JYPhotoVideoModel alloc]init];
                photoModel.isOrignal = YES;
                [imagesArray addObject:photoModel];
                
                //获取原图照片,先会返回缩略图
              [[TZImageManager manager]getOriginalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
                 
                  NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                  if ([info[PHImageResultIsDegradedKey]integerValue] == NO) {
                      NSLog(@"xxxxxxxxx------------xxxxxxxxxxxxxxxx------------------------------xxxxxxxxxxxxxxxxxxxxxx");
                  //获取原图data
                  [[TZImageManager manager]getOriginalPhotoDataWithAsset:asset completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                     
                      NSString *name = [[info[@"PHImageFileSandboxExtensionTokenKey"]componentsSeparatedByString:@"/"]lastObject];
                      photoModel.fileName = [[JYAccountTool account].userName stringByAppendingString:[NSString stringWithFormat:@"%u%@",arc4random_uniform(999999)*arc4random_uniform(999999),name]];
                      photoModel.orignalData = data;
                      photoModel.orignalImage = photo;
                      photoModel.size = data.length;
                      
                      if (index == assets.count - 1) {
                          //回调
                          imagesCallback(imagesArray);
                      }
                      index ++;
                   }];
                }
              }];
            }];
            
            //非原图
        }else{
            
            __block int index = 0;
            
            // ===============================================压缩新增
            NSArray *orignalImageArray = images;
            NSMutableArray *newSmallImagesArray = [NSMutableArray array];
            [orignalImageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               
                UIImage *orignalImage = (UIImage *)obj;
                NSData *smallData = UIImageJPEGRepresentation(orignalImage, 0.1);
                UIImage *newSmallImage = [UIImage imageWithData:smallData];
                [newSmallImagesArray addObject:newSmallImage];
            }];
            // ================================================
            
            NSMutableArray *imagesArray = [NSMutableArray array];
            [assets enumerateObjectsUsingBlock:^(PHAsset  *_Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
               
                JYPhotoVideoModel *photoModel = [[JYPhotoVideoModel alloc]init];
                photoModel.isOrignal = NO;
                photoModel.normalImage = newSmallImagesArray[idx];
                [imagesArray addObject:photoModel];
                PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
                option.networkAccessAllowed = YES;
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                NSLog(@"---------------------------------------------------");
                
                [[PHImageManager defaultManager]requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    
                    // ============================压缩新增
                    NSData *normalData = UIImageJPEGRepresentation([UIImage imageWithData:imageData], 0.1);
                    // ============================
                    
                    NSString *name = [[info[@"PHImageFileSandboxExtensionTokenKey"]componentsSeparatedByString:@"/"]lastObject];
                    photoModel.fileName = [[JYAccountTool account].userName stringByAppendingString:[NSString stringWithFormat:@"%u%@",arc4random_uniform(997659)*arc4random_uniform(9342499),name]];
                    photoModel.normalData = normalData;
                    photoModel.size = normalData.length;
                    NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxr");
                    //回调数据 2
                    if (index == assets.count -1) {
                        imagesCallback(imagesArray);
                        return ;
                    }
                    index ++;
                }];
                NSLog(@"oooooooooooooooooooooooooooooooooooooooooooooooooooo");
            }];
        }
    };
}




/**
  下载获取视频

 */
+ (void)openPhotoPickerGetVideo:(JYVideoPathCallback)videoPathCallback coverBackRightNow:(JYVideoCoverImageBackRightNow)coverBack target:(UIViewController *)target CacheDirectory:(NSString *)basePath
{
    
    BOOL isDir = NO;
    if (![[NSFileManager defaultManager]fileExistsAtPath:basePath isDirectory:&isDir]) {
        
        [[NSFileManager defaultManager]createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    TZImagePickerController *picker = [self initPickerWithtaget:target maxCount:1];
    picker.allowPickingImage = NO;
    picker.allowPickingVideo = YES;
    
    picker.didFinishPickingVideoHandle = ^(UIImage *coverImage,id asset){
        
        //缓存视频到本地
        [self getVideoPathFromPHAsset:asset cachePath:basePath Complete:videoPathCallback coverBackRightNow:coverBack cover:coverImage];
        
     };
}










/**
  缓存视频到本地

 @param asset            <#asset description#>
 @param basePath         <#basePath description#>
 @param videPathCallback <#videPathCallback description#>
 @param coverCallbackNow <#coverCallbackNow description#>
 */
+ (void)getVideoPathFromPHAsset:(PHAsset *)asset cachePath:(NSString *)basePath Complete:(JYVideoPathCallback)videPathCallback  coverBackRightNow:(JYVideoCoverImageBackRightNow)coverCallbackNow cover:(UIImage *)cover {
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource;
    
    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypePairedVideo ||
            assetRes.type == PHAssetResourceTypeVideo) {
            resource = assetRes;
        }
    }
    NSString *fileName = @"tempAssetVideo.mov";
    if (resource.originalFilename) {
        fileName = [[JYAccountTool account].userName stringByAppendingString:[NSString stringWithFormat:@"%u%@",arc4random_uniform(99999)*arc4random_uniform(99999),resource.originalFilename]];
    }
    //立刻回调视频封面图 ,名称 , 视频长短
    if (coverCallbackNow) {
        coverCallbackNow(cover,fileName,asset.duration);
    }
    
    //异步存储
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        if (asset.mediaType == PHAssetMediaTypeVideo || asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHImageRequestOptionsVersionCurrent;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;  //此处可调节质量
        
            //临时存储路径
            NSString *PATH_MOVIE_FILE = [basePath stringByAppendingPathComponent:fileName];
            [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
            [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource
                                                                        toFile:[NSURL fileURLWithPath:PATH_MOVIE_FILE]
                                                                       options:nil
                                                             completionHandler:^(NSError * _Nullable error) {
                                                                 if (error) {
                                                                     
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         videPathCallback(nil, nil);
                                                                     });
                                                                     
                                                                 } else {
                                                                     long long int size = [[NSData dataWithContentsOfFile:PATH_MOVIE_FILE]length];
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         videPathCallback(PATH_MOVIE_FILE,[@(size)stringValue]);
                                                                         NSLog(@"--------------------------------------------xxxxx%lld",size);
                                                                     });
                                                                 }
                                                             }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
               
                videPathCallback(nil, nil);
            });
        }
    });
}


#pragma mark - 初始化
+ (TZImagePickerController *)initPickerWithtaget:(UIViewController *)target maxCount:(NSInteger)maxCount
{
    
    __block UIViewController *targetVc = target;
    TZImagePickerController *picker = [[TZImagePickerController alloc]initWithMaxImagesCount:maxCount delegate:nil];
    //判断权限
    [self photoAlbumAuthorizationJudge:^{
        
        if (!target &&![UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController) return;
        
        if (!target &&[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController) {
            targetVc = [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
        }
        
        [targetVc presentViewController:picker animated:YES completion:nil];
        
    }];
    return picker;
}





+ (void)photoAlbumAuthorizationJudge:(albumAuthorizationCallBack)callback
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
            //未决定
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
                if (status == PHAuthorizationStatusRestricted ||
                    status == PHAuthorizationStatusDenied) {
                }else{
                    callback();
                }
            }];
        }
            break;
            
            //拒绝
        case AVAuthorizationStatusRestricted:
        {
            //引导用户打开权限
            [NSObject alertShowForAuthorizationWithTarget:nil callBack:^{
                //打开用户设置
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
        }
            break;
            
            //已经授权过
        case AVAuthorizationStatusAuthorized:
        {
            callback();
        }
            break;
        case PHAuthorizationStatusDenied:{
            
            //引导用户打开权限
            [NSObject alertShowForAuthorizationWithTarget:nil callBack:^{
                //打开用户设置
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
        }
            break;
        default:
            break;
    }
}


#pragma mark - IM专用
+ (void)openPhotoPickerGetImages:(JYPhotoPickerImagesCallback)imagesCallback target:(UIViewController *)target maxCount:(NSInteger)count
{
    TZImagePickerController *picker = [self initPickerWithtaget:target maxCount:count];
    picker.allowPickingVideo = NO;     //是否需要展示视频
    picker.allowPickingOriginalPhoto = YES;   //是否允许选择原图
    picker.didFinishPickingPhotosWithInfosHandle = ^(NSArray<UIImage *> *images,NSArray *assets,BOOL isSelectOriginalPhoto,NSArray<NSDictionary *> *infos){
        
        //选择了原图
        if (isSelectOriginalPhoto) {
            
            __block int index = 0;
            
            NSMutableArray *imagesArray = [NSMutableArray array];
            [assets enumerateObjectsUsingBlock:^(PHAsset  *_Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
                
                JYPhotoVideoModel *photoModel = [[JYPhotoVideoModel alloc]init];
                photoModel.isOrignal = YES;
                [imagesArray addObject:photoModel];
                
                //获取原图照片,先会返回缩略图
                [[TZImageManager manager]getOriginalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
                    
                    if ([info[PHImageResultIsDegradedKey]integerValue] == NO) {
                        //获取原图data
                        [[TZImageManager manager]getOriginalPhotoDataWithAsset:asset completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                            
                            NSString *name = [[info[@"PHImageFileSandboxExtensionTokenKey"]componentsSeparatedByString:@"/"]lastObject];
                            photoModel.fileName = [[JYAccountTool account].userName stringByAppendingString:[NSString stringWithFormat:@"%u%@",arc4random_uniform(999999)*arc4random_uniform(999999),name]];
                            photoModel.orignalData = data;
                            photoModel.orignalImage = photo;
                            photoModel.size = data.length;
                            
                            if (index == assets.count - 1) {
                                //回调
                                imagesCallback(imagesArray);
                            }
                            index ++;
                        }];
                    }
                }];
            }];
            
            //非原图
        }else{
            
            __block int index = 0;
            
            // ===============================================压缩新增
            NSArray *orignalImageArray = images;
            NSMutableArray *newSmallImagesArray = [NSMutableArray array];
            [orignalImageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                UIImage *orignalImage = (UIImage *)obj;
                NSData *smallData = UIImageJPEGRepresentation(orignalImage, 0.1);
                UIImage *newSmallImage = [UIImage imageWithData:smallData];
                [newSmallImagesArray addObject:newSmallImage];
            }];
            // ================================================
            
            NSMutableArray *imagesArray = [NSMutableArray array];
            [assets enumerateObjectsUsingBlock:^(PHAsset  *_Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
                
                JYPhotoVideoModel *photoModel = [[JYPhotoVideoModel alloc]init];
                photoModel.isOrignal = NO;
                photoModel.normalImage = newSmallImagesArray[idx];
                [imagesArray addObject:photoModel];
                PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
                option.networkAccessAllowed = YES;
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                
                [[PHImageManager defaultManager]requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    
                    // ============================压缩新增
                    NSData *normalData = UIImageJPEGRepresentation([UIImage imageWithData:imageData], 0.1);
                    // ============================
                    
                    NSString *name = [[info[@"PHImageFileSandboxExtensionTokenKey"]componentsSeparatedByString:@"/"]lastObject];
                    photoModel.fileName = [[JYAccountTool account].userName stringByAppendingString:[NSString stringWithFormat:@"%u%@",arc4random_uniform(997659)*arc4random_uniform(9342499),name]];
                    photoModel.normalData = normalData;
                    photoModel.size = normalData.length;
                    //回调数据 2
                    if (index == assets.count -1) {
                        imagesCallback(imagesArray);
                        return ;
                    }
                    index ++;
                }];
            }];
        }
    };
}



@end
