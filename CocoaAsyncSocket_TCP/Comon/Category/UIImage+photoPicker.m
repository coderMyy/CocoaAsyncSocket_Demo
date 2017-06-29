//
//  UIImage+photoPicker.m
//  JYHomeCloud
//
//  Created by 孟遥 on 16/12/19.
//  Copyright © 2016年 All rights reserved.
//

#import "UIImage+photoPicker.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import "ChatAlbumModel.h"

typedef void(^albumAuthorizationCallBack)();

@implementation UIImage (photoPicker)


/**
  下载获取视频

 */
+ (void)openPhotoPickerGetVideo:(videoBaseInfoCallback)callback target:(UIViewController *)target
{
    //每次只能选取一个视频
    TZImagePickerController *picker = [self initPickerWithtaget:target maxCount:1];
    picker.allowPickingImage = NO;
    picker.allowPickingVideo = YES;
    picker.didFinishPickingVideoHandle = ^(UIImage *coverImage,id asset){
        
        //缓存视频到本地
        [self getVideoPathFromPHAsset:asset complete:callback cover:coverImage];
     };
}










/**
  缓存视频到本地

 @param asset            <#asset description#>
 @param cover <#coverCallbackNow description#>
 */
+ (void)getVideoPathFromPHAsset:(PHAsset *)asset complete:(videoBaseInfoCallback)callback cover:(UIImage *)cover {
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
        //命名规范可以自行定义 ， 但是要保证不要重复
        fileName = [NSString stringWithFormat:@"chatVideo_%@%@",getCurrentTime(),resource.originalFilename];
    }
    //创建视频模型
    ChatAlbumModel *videoModel = [[ChatAlbumModel alloc]init];
    //缩略图
    videoModel.videoCoverImg = cover;
    //视频时长
    videoModel.duration = [@(asset.duration)stringValue];
    //视频名称
    videoModel.name = fileName;
    //回调含有基本信息的视频模型
    if (callback) {
        callback(videoModel);
    }
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
        
    } target:target];
    return picker;
}





+ (void)photoAlbumAuthorizationJudge:(albumAuthorizationCallBack)callback target:(UIViewController *)target
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
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
                //打开用户设置
                [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:sureAction];
            [alert addAction:cancelAction];
            [target presentViewController:alert animated:YES completion:nil];
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
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                //打开用户设置
                [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:sureAction];
            [alert addAction:cancelAction];
            [target presentViewController:alert animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}




#pragma mark - 获取相册图片
+ (void)openPhotoPickerGetImages:(photoPickerImagesCallback)imagesCallback target:(UIViewController *)target maxCount:(NSInteger)count
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
                
                ChatAlbumModel *imageModel = [[ChatAlbumModel alloc]init];
                imageModel.isOrignal = YES;
                [imagesArray addObject:imageModel];
                
                //获取原图照片,先会返回缩略图
                [[TZImageManager manager]getOriginalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
                    
                    if ([info[PHImageResultIsDegradedKey]integerValue] == NO) {
                        //获取原图data
                        [[TZImageManager manager]getOriginalPhotoDataWithAsset:asset completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                            
                            NSString *name = [[info[@"PHImageFileSandboxExtensionTokenKey"]componentsSeparatedByString:@"/"]lastObject];
                            imageModel.name = [NSString stringWithFormat:@"chatPicture_%@%@",getCurrentTime(),name];
                            imageModel.orignalPicData = data;
                            imageModel.picSize = photo.size;
                            imageModel.size = [@(data.length)stringValue];
                            
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
            NSArray *orignalImageArray = images;
            
            NSMutableArray *imagesArray = [NSMutableArray array];
            [assets enumerateObjectsUsingBlock:^(PHAsset  *_Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
                
                ChatAlbumModel *imageModel = [[ChatAlbumModel alloc]init];
                imageModel.isOrignal = NO;
//                imageModel.normalImage = newSmallImagesArray[idx];
                [imagesArray addObject:imageModel];
                PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
                option.networkAccessAllowed = YES;
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                
                [[PHImageManager defaultManager]requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    
                    // ============================压缩
                    NSData *normalData = UIImageJPEGRepresentation([UIImage imageWithData:imageData], 0.1);
                    // ============================
                    UIImage *orignalImg = orignalImageArray[idx];
                    NSString *name = [[info[@"PHImageFileSandboxExtensionTokenKey"]componentsSeparatedByString:@"/"]lastObject];
                    imageModel.name = [NSString stringWithFormat:@"chatPicture_%@%@",getCurrentTime(),name];
                    imageModel.normalPicData = normalData;
                    imageModel.picSize = orignalImg.size;
                    imageModel.size = [@(normalData.length)stringValue];
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


NS_INLINE NSString *getCurrentTime() {
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    return [NSString stringWithFormat:@"%llu",recordTime];
}

@end
