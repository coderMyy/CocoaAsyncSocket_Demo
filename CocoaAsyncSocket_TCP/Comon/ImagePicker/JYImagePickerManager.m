//
//  JYImagePickerManager.m
//  JYHomeCloud
//
//  Created by guo xiaowei on 2016/12/16.
//  Copyright © 2016年 JYall Network Technology Co.,Ltd. All rights reserved.
//

#import "JYImagePickerManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "JYCenterAddUploadManager.h"
#import "JYAccountTool.h"


@interface JYImagePickerManager ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImagePickerController        *_imgPickC;
    UIViewController                *_vc;
    CallBackBlock                 _callBackBlock;
    
    MPMoviePlayerController *_moviePlayer;
}
@end



@implementation JYImagePickerManager

+ (instancetype)shareInstance
{
    static dispatch_once_t once;
    static JYImagePickerManager *pickManager;
    dispatch_once(&once, ^{
        pickManager = [[JYImagePickerManager alloc] init];
    });
    return pickManager;
}

- (instancetype)init
{
    if([super init]){
        if(!_imgPickC){
            _imgPickC = [[UIImagePickerController alloc] init];  // 初始化 _imgPickC
        }
    }
    return self;
}

- (void)presentPicker:(PickerType)pickerType target:(UIViewController *)vc callBackBlock:(CallBackBlock)callBackBlock
{
    
    _vc = vc;
    _callBackBlock = callBackBlock;
    if(pickerType == PickerType_Camera){
        // 拍照
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            _imgPickC.delegate = self;
            _imgPickC.sourceType = UIImagePickerControllerSourceTypeCamera;
//            _imgPickC.allowsEditing = YES;
//            _imgPickC.showsCameraControls = YES;
            
            UIView *view = [[UIView  alloc] init];
            view.backgroundColor = [UIColor grayColor];
            
            _imgPickC.mediaTypes = @[(NSString *)kUTTypeImage];
//            _imgPickC.cameraOverlayView = view;
            [_vc presentViewController:_imgPickC animated:YES completion:nil];
        }else{
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"" message:@"相机不可用" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [alertV show];
        }
    }
    else if(pickerType ==    PickerType_Video){
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            _imgPickC.delegate = self;
            _imgPickC.sourceType = UIImagePickerControllerSourceTypeCamera;
            _imgPickC.allowsEditing = YES;
            UIView *view = [[UIView  alloc] init];
            view.backgroundColor = [UIColor grayColor];
            
            //录制视频时长，默认10s
//            _imgPickC.videoMaximumDuration = 10;
            
            //相机类型（拍照、录像...）字符串需要做相应的类型转换
            _imgPickC.mediaTypes = @[(NSString *)kUTTypeMovie];//,(NSString *)kUTTypeImage
            
            /**视频上传质量
             UIImagePickerControllerQualityTypeHigh高清
             UIImagePickerControllerQualityTypeMedium中等质量
             UIImagePickerControllerQualityTypeLow低质量
             UIImagePickerControllerQualityType640x480
             */
            _imgPickC.videoQuality = UIImagePickerControllerQualityTypeHigh;
            [_vc presentViewController:_imgPickC animated:YES completion:nil];
            
            
        }else{
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"" message:@"相机不可用" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [alertV show];
        }
    }
    else if(pickerType == PickerType_Photo){
        // 相册
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
            _imgPickC.delegate = self;
            _imgPickC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//            _imgPickC.allowsEditing = YES;
            [_vc presentViewController:_imgPickC animated:YES completion:nil];
        }else{
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"" message:@"相册不可用" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [alertV show];
        }
        
    }
}

#pragma mark ---- UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    JYUpLoadTaskModel *taskModel    =   [[JYUpLoadTaskModel alloc]init];
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    
    //判断资源类型
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        //如果是图片
        UIImage *image  = info[UIImagePickerControllerOriginalImage];
        //压缩图片（
        NSData *fileData = UIImageJPEGRepresentation(image, 1.0);
        //保存图片至相册
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        
        //拿到拍照的FileDta
        taskModel.sourceData    =   fileData;
        taskModel.totalLength   =   fileData.length;
        taskModel.fileType      =   @"picture";
        taskModel.image         =   image;
//         _callBackBlock(info, NO,taskModel); // block回调
        //上传图片
//        //上传到服务器
//        [[JYCenterAddUploadManager shareInstance]uploadOperationWithOperationStyle:JYUploadOperationStylePhoto parent:@"root" taskModel:taskModel localPath:nil photosVideos:^(NSArray *photosOrVideos)  {
//            
//        } currentTaskCallBack:^(JYUpLoadTaskModel *taskModel,NSInteger index) {
//            
//        }];
        
    }else{
        [Tool showLoadingOnWindow];
        //如果是视频
        NSURL *url = info[UIImagePickerControllerMediaURL];
        
        //上传的视频格式转化
        [self movFileTransformToMP4WithSourceUrl:url completion:^(NSString *Mp4FilePath,NSString *uniqueName) {
            
            //播放视频
            _moviePlayer.contentURL = [NSURL fileURLWithPath:Mp4FilePath];
            [_moviePlayer play];
            //保存视频至相册（异步线程）
            NSString *urlStr = Mp4FilePath;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
                    
                    UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                }
            });

            
            NSData *videoData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:Mp4FilePath]];
            taskModel.sourceData    =   videoData;
            taskModel.totalLength   =   videoData.length;
            taskModel.fileType      =   @"video";
            taskModel.fileName      =   uniqueName;
            
             _callBackBlock(info, NO,taskModel); // block回调
        }];

        
//        //视频上传
//        [[JYCenterAddUploadManager shareInstance]uploadOperationWithOperationStyle:JYUploadOperationStyleViedeo parent:@"root" taskModel:taskModel localPath:nil photosVideos:^(NSArray *photosOrVideos)  {
//            
//        } currentTaskCallBack:^(JYUpLoadTaskModel *taskModel,NSInteger index) {
//            
//        }];
    }
    
    [_vc dismissViewControllerAnimated:YES completion:^{
        
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
            _callBackBlock(info, NO,taskModel); // block回调
        }
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_vc dismissViewControllerAnimated:YES completion:^{
        _callBackBlock(nil, YES,nil); // block回调
    }];
}


#pragma mark 图片保存完毕的回调
- (void) image: (UIImage *) image didFinishSavingWithError:(NSError *) error contextInfo: (void *)contextInf{
    if (error) {
        NSLog(@"图片视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"图片保存成功.");
    }
}

#pragma mark 视频保存完毕的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInf{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
    }
}

#pragma 视频转化
- (void)movFileTransformToMP4WithSourceUrl:(NSURL *)sourceUrl completion:(void(^)(NSString *Mp4FilePath,NSString *uniqueName))comepleteBlock
{
    /**
     *  mov格式转mp4格式
     */
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceUrl options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    NSLog(@"%@",compatiblePresets);
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *uniqueName = [NSString stringWithFormat:@"Video_data_%@.mp4",[formatter stringFromDate:date]];
        NSString * resultPath = [NSTemporaryDirectory() stringByAppendingPathComponent:uniqueName];
        
        NSLog(@"output File Path : %@",resultPath);
        
        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        
        exportSession.outputFileType = AVFileTypeMPEG4;//可以配置多种输出文件格式
        
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         
         {
             dispatch_async(dispatch_get_main_queue(), ^{
//                 [hud hideAnimated:YES];
             });
             
             switch (exportSession.status) {
                     
                 case AVAssetExportSessionStatusUnknown:
                     
                     NSLog(@"AVAssetExportSessionStatusUnknown");

                     break;
                     
                 case AVAssetExportSessionStatusWaiting:
                     
                     NSLog(@"AVAssetExportSessionStatusWaiting");

                     break;
                     
                 case AVAssetExportSessionStatusExporting:
                     
                     NSLog(@"AVAssetExportSessionStatusExporting");
    
                     break;
                     
                 case AVAssetExportSessionStatusCompleted:
                 {
                     
                  NSLog(@"AVAssetExportSessionStatusCompleted");
                     
                     comepleteBlock(resultPath,uniqueName);
                     
                     NSLog(@"mp4 file size:%lf MB",[NSData dataWithContentsOfURL:exportSession.outputURL].length/1024.f/1024.f);
                 }
                     break;
                     
                 case AVAssetExportSessionStatusFailed:
                     
                    NSLog(@"AVAssetExportSessionStatusFailed");

                     break;
                     
                 case AVAssetExportSessionStatusCancelled:
                     
                     NSLog(@"AVAssetExportSessionStatusFailed");
                     
                     break;
                     
             }
             
         }];
        
    }
}


+ (void)photoAlbumAuthorizationJudge:(albumAuthorizationCallBack)callback
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
//    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    //相册
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
        case PHAuthorizationStatusRestricted:
        {
            //引导用户打开权限
            [NSObject alertShowForAuthorizationWithTarget:nil callBack:^{
                //打开用户设置
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
        }
            break;
            
            //已经授权过
        case PHAuthorizationStatusAuthorized:
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
//    //相机
//    switch (authStatus) {
//            //未决定状态
//        case AVAuthorizationStatusNotDetermined:
//            
//        {
//            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//                
//            }];
//        }
//            break;
//            //拒绝
//        case AVAuthorizationStatusRestricted:
//        {
//            //alert提示用户去设置里打开权限
//            //引导用户打开权限
//            [NSObject alertShowForAuthorizationWithTarget:nil callBack:^{
//                //打开用户设置
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//            }];
//        }
//            break;
//        case AVAuthorizationStatusAuthorized:
//        {
//            
//        }
//            break;
//        case AVAuthorizationStatusDenied:{
//            
//            //引导用户打开权限
//            [NSObject alertShowForAuthorizationWithTarget:nil callBack:^{
//                //打开用户设置
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//            }];
//        }
//            break;
//        default:
//            break;
//    }

}

+ (void)avAuthorizationJudge:(albumAuthorizationCallBack)callback{

    //权限判断
    AVAuthorizationStatus  authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authStatus) {
            //未决定状态
        case AVAuthorizationStatusNotDetermined:
            
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                callback();
            }];
        }
            break;
            //拒绝
        case AVAuthorizationStatusRestricted:
        {
            //alert提示用户去设置里打开权限
            //引导用户打开权限
            [NSObject alertShowForAuthorizationWithTarget:nil callBack:^{
                //打开用户设置
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
        }
            break;
        case AVAuthorizationStatusAuthorized:
        {
            callback();
        }
            break;
        case AVAuthorizationStatusDenied:{
            
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

@end
