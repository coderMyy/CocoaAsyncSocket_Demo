//
//  ChatUtil.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatUtil.h"
#import "ChatModel.h"
#import "ChatAlbumModel.h"
#import "MYCoreTextLabel.h"
#import <Photos/Photos.h>

@implementation ChatUtil

+ (void)shouldShowTime:(ChatModel *)currentmodel premodel:(ChatModel *)premodel
{
    if (!premodel) {
         currentmodel.showTime = !premodel;
    }
    //取最后两个时间戳比较时间
    NSInteger length = (currentmodel.sendTime.longLongValue-premodel.sendTime.longLongValue)/1000; //socket处时间戳多了三位
    
    if (length>60) {
        
       currentmodel.showTime = YES;
    }else{
        currentmodel.showTime = NO;
    }
}

#pragma mark - 消息高度计算
+ (CGFloat)heightForMessage:(ChatModel *)currentChatmodel premodel:(ChatModel *)premodel
{
    //是否显示时间
    [self shouldShowTime:currentChatmodel premodel:premodel];
    
    CGFloat height = 0.f;
    //文本,表情
    if (hashEqual(currentChatmodel.contenType, Content_Text)) {
        MYCoreTextLabel *coreLabel = [[MYCoreTextLabel alloc]init];
        coreLabel.textFont = FontSet(14);
        coreLabel.lineSpacing = 6;
        coreLabel.imageSize =CGSizeMake(24, 24);
        [coreLabel setText:currentChatmodel.content.text customLinks:nil keywords:nil];
        CGSize labelSize = [coreLabel sizeThatFits:CGSizeMake(SCREEN_WITDTH - 145, MAXFLOAT)];
        height = 5 + 10 + labelSize.height + 10;
        height = height < 50 ? 50 : height;
        //验证是否群聊
        [self groupChatConfig:currentChatmodel];
        return currentChatmodel.messageHeight += currentChatmodel.shouldShowTime ? height + 50 : height + 15;
        //语音
    }else if (hashEqual(currentChatmodel.contenType, Content_Audio)){
        
        height = 50;
        //验证是否群聊
        [self groupChatConfig:currentChatmodel];
        return currentChatmodel.messageHeight += currentChatmodel.shouldShowTime ? height + 50 : height + 15;
        //图片
    }else if (hashEqual(currentChatmodel.contenType, Content_Picture)){
        
        CGFloat picHeight = currentChatmodel.content.picSize.height;
        CGFloat picWidth  = currentChatmodel.content.picSize.width;
        //宽大于高
        if (picWidth > picHeight) {
        
            //极宽极低固定50高
            if (100*(picHeight/picWidth)<=50) {
                height = 50;
            }else{
                height = 135 *(picHeight/picWidth);
            }
        //宽小于高
        }else if (picWidth < picHeight){
            
            height = 130;
        //宽高相等
        }else{
            height = 120;
        }
        //验证是否群聊
        [self groupChatConfig:currentChatmodel];
        return currentChatmodel.messageHeight += currentChatmodel.shouldShowTime ? height + 50 : height + 15;
        //视频
    }else if (hashEqual(currentChatmodel.contenType, Content_Video)){
        
        return currentChatmodel.messageHeight += currentChatmodel.shouldShowTime ? height + 50 : height + 15;
        //文件
    }else if (hashEqual(currentChatmodel.contenType, Content_File)){
        
        return currentChatmodel.messageHeight += currentChatmodel.shouldShowTime ? height + 50 : height + 15;
        //提示语
    }else{
        
        return currentChatmodel.messageHeight += currentChatmodel.shouldShowTime ? height + 50 : height + 15;
    }
}

//群聊特殊布局
+ (void)groupChatConfig:(ChatModel *)chatModel
{
    if (hashEqual(chatModel.chatType, @"groupChat")&&!chatModel.byMyself.integerValue) {
        chatModel.messageHeight += 16;
    }
}


#pragma marl - 创建发送消息模型
+ (ChatModel *)creatMessageModel:(ChatModel *)config
{
    ChatModel * chatModel = [[ChatModel alloc]init];
    ChatContentModel *content = [[ChatContentModel alloc]init];
    chatModel.content          = content;
    chatModel.fromUserID     = [Account account].myUserID;
    chatModel.toUserID         = config.toUserID;
    chatModel.messageType  = @"normal";
    chatModel.chatType        = config.chatType;
    chatModel.deviceType     = @"iOS";
    chatModel.versionCode   = TCP_VersionCode;
    chatModel.byMyself        = @1;
    chatModel.isSend           = @0;
    chatModel.isRead           = @0;
    chatModel.isSending       = @1;
    chatModel.beatID            = TCP_beatBody;
    chatModel.fromPortrait    = [Account account].portrait;
    chatModel.toPortrait        = config.toPortrait;
    chatModel.nickName       = config.nickName;
    chatModel.groupID          = config.groupID;
    chatModel.groupName    = config.groupName;
    chatModel.noDisturb       = config.noDisturb;
    
    return chatModel; 
}

//初始化文本消息模型
+ (ChatModel *)initTextMessage:(NSString *)text config:(ChatModel *)config
{
    ChatModel *textModel = [self creatMessageModel:config];
    textModel.contenType  = Content_Text;
    textModel.content.text  = text;
    return textModel;
}
//初始化语音消息模型
+ (ChatModel *)initAudioMessage:(ChatAlbumModel *)audio config:(ChatModel *)config
{
    ChatModel *audioModel = [self creatMessageModel:config];
    audioModel.contenType = Content_Audio;
    audioModel.content.seconds = audio.duration;
    NSString *name = [NSString stringWithFormat:@"ChatAudio_%@.mp3",audioModel.sendTime];
    audioModel.content.fileName = name;
    NSString *basePath = nil;
    if (hashEqual(config.chatType, @"userChat")) {
        basePath = [ChatCache_Path stringByAppendingPathComponent:config.toUserID];
    }else{
        basePath = [ChatCache_Path stringByAppendingPathComponent:config.groupID];
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL exist = [manager fileExistsAtPath:basePath];
    if (!exist) {
        [manager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    //语音写入缓存
    [audio.audioData writeToFile:[basePath stringByAppendingPathComponent:name] atomically:YES];
    return audioModel;
}
//初始化图片消息模型
+ (NSArray<ChatModel *> *)initPicMessage:(NSArray<ChatAlbumModel *> *)pics config:(ChatModel *)config
{
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (ChatAlbumModel *pic in pics) {
        
        //创建图片模型
        ChatModel *picModel = [self creatMessageModel:config];
        picModel.contenType = Content_Picture;
        picModel.content.picSize = pic.picSize;
        picModel.content.fileName = pic.name;
        [tmpArray addObject:picModel];
        
        NSString *basePath = nil;
        if (hashEqual(config.chatType, @"userChat")) {
            basePath = [ChatCache_Path stringByAppendingPathComponent:config.toUserID];
        }else{
            basePath = [ChatCache_Path stringByAppendingPathComponent:config.groupID];
        }
        
        NSFileManager *manager = [NSFileManager defaultManager];
        BOOL exist = [manager fileExistsAtPath:basePath];
        if (!exist) {
            [manager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
        //////////////////资源缓存
        //压缩比
        CGFloat compressScale = 1;
        NSData *smallAlbumData = nil;
        NSData *albumData = nil;
        //用户选择了原图
        if (pic.isOrignal) {
            
            //压缩过的小图缓存 (用户界面展示,节省资源)
            if (pic.orignalPicData.length/1024.0/1024.0 < 3) { //小于3M的
                
                compressScale = 0.1;  //压缩10倍
            }else{  //大于3M
                
                compressScale = 0.05; //压缩20倍
            }
            UIImage *image = [UIImage imageWithData:pic.orignalPicData];
            //小图data
            smallAlbumData = UIImageJPEGRepresentation(image, compressScale);
            //原图data
            albumData        = pic.orignalPicData;
            
            //默认选择,未选择原图
        }else{
            
            //压缩过的小图缓存 (用户界面展示,节省资源)
            if (pic.normalPicData.length/1024.0/1024.0 < 3) { //小于3M的
                
                compressScale = 0.1;  //压缩10倍
            }else{  //大于3M
                
                compressScale = 0.05; //压缩20倍
            }
            
            UIImage *image = [UIImage imageWithData:pic.normalPicData];
            //小图data
            smallAlbumData = UIImageJPEGRepresentation(image, compressScale);
            //原图data
            albumData        = pic.normalPicData;
        }
        //小图缓存路径
        NSString *smallDetailPath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",@"small",pic.name]];
        //原图缓存路径
        NSString *detailPath = [basePath stringByAppendingPathComponent:pic.name];
        //小图写入缓存
        [smallAlbumData writeToFile:smallDetailPath atomically:YES];
        //原图写入缓存
        [albumData writeToFile:detailPath atomically:YES];
    }
    return tmpArray;
}
//初始化视频消息模型
+ (void)initVideoMessage:(ChatAlbumModel *)video config:(ChatModel *)config videoCallback:(videoModelCallback)callback
{
    PHAsset *asset = video.videoAsset;
    NSString *basePath = nil;
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource;
    
    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypePairedVideo ||
            assetRes.type == PHAssetResourceTypeVideo) {
            resource = assetRes;
        }
    }
    if (hashEqual(config.chatType, @"userChat")) {
        basePath = [ChatCache_Path stringByAppendingPathComponent:config.toUserID];
    }else{
        basePath = [ChatCache_Path stringByAppendingPathComponent:config.groupID];
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL exist = [manager fileExistsAtPath:basePath];
    if (!exist) {
        [manager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    //具体路径
    NSString *detailPath = [basePath stringByAppendingString:video.name];
    
    //创建视频消息模型
    ChatModel *videoModel = [self creatMessageModel:config];
    videoModel.contenType  = Content_Video;
    videoModel.content.fileName = video.name;
    videoModel.content.picSize = video.videoCoverImg.size;
    
    //异步存储
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        if (asset.mediaType == PHAssetMediaTypeVideo || asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHImageRequestOptionsVersionCurrent;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;  //此处可调节质量
            [[NSFileManager defaultManager] removeItemAtPath:detailPath error:nil];
            [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource
                                                                        toFile:[NSURL fileURLWithPath:detailPath]
                                                                       options:nil
                                                             completionHandler:^(NSError * _Nullable error) {
                                                                 if (error) {
                                                                     
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         callback(nil);
                                                                     });
                                                                     
                                                                 } else {
                                                                     long long int size = [[NSData dataWithContentsOfFile:detailPath]length];
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         videoModel.content.fileSize = [@(size)stringValue];
                                                                         callback(videoModel);
                                                                         NSLog(@"------------相册视频回调----------");
                                                                     });
                                                                 }
                                                             }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                callback(nil);
            });
        }
    });
}



#pragma mark - data大小转换
+ (NSString *)dataSize:(ChatModel *)chatModel
{
    long long int size = chatModel.content.fileSize.longLongValue;
    if (size<1024) {
        return [NSString stringWithFormat:@"%lldb",size];
        
    }else if (size>1024 && size < 1024 *1024) {
        
        return [NSString stringWithFormat:@"%.1fk",(CGFloat)(1.0 *size/1024)];
        
    }else if(size >1024 && size< 1024*1024*1024){
        
        return [NSString stringWithFormat:@"%.1fM",(CGFloat)(1.0 *size/1024/1024)];
    }else{
        
        return [NSString stringWithFormat:@"%.1fG",(CGFloat)(1.0 *size/1024/1024/1024)];
    }
}

#pragma mark - 时间戳转换成世界
+ (NSString *)videoDurationWithSeconds:(long long int)duration
{
    //60秒以内
    if (duration == 0) {
        return @"00:00:00";
    }else if (duration < 60) {
        return [NSString stringWithFormat:@"%@:%@:%lld",@"00",@"00",duration];  // 00:00
    }else if (duration<3600){  //一小时内
        NSString *hourStr = @"00:";  //小时 //00:00:00
        NSString *minitesStr = [NSString stringWithFormat:@"%02lld:",duration/60]; //分钟   8
        NSString *secondsStr = [NSString stringWithFormat:@"%02lld",duration%60];     // 0
        return [[hourStr stringByAppendingString:minitesStr]stringByAppendingString:secondsStr];
    }else{ //大于一小时
        
        NSString *hourStr = [NSString stringWithFormat:@"%02lld:",duration/3600]; //小时
        
        NSInteger lastSeconds = duration%3600; //余下的秒数
        if (lastSeconds > 60) {  //余下大于一分钟
            
            NSString *minitesStr = [NSString stringWithFormat:@"%02ld:",lastSeconds/60];
            NSInteger seconds = lastSeconds%60;
            NSString *secondsStr = [NSString stringWithFormat:@"%02ld",(long)seconds];
            return [[hourStr stringByAppendingString:minitesStr]stringByAppendingString:secondsStr];
        }else{
            
            NSString *minitesStr = @"00:";
            NSString *secondsStr = [NSString stringWithFormat:@"%02ld",(long)lastSeconds];
            return [[hourStr stringByAppendingString:minitesStr]stringByAppendingString:secondsStr];
        }
    }
}



@end
