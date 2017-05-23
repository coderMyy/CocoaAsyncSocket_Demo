//
//  ChatAlbumModel.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/20.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatAlbumModel : NSObject

//是否为原图
@property (nonatomic, assign) BOOL isOrignal;
//名字
@property (nonatomic, copy) NSString *name;
//大小
@property (nonatomic, copy) NSString *size;
//图片压缩过的data
@property (nonatomic, strong) NSData *normalData;
//图片无压缩data
@property (nonatomic, strong) NSData *orignalData;
//图片尺寸
@property (nonatomic, assign) CGSize  picSize;
//视频缓存地址
@property (nonatomic, copy) NSString *videoCachePath;
//视频缩略图
@property (nonatomic, strong) UIImage *videoCoverImg;
//视频时长
@property (nonatomic, copy) NSString *videoDuration;

@end
