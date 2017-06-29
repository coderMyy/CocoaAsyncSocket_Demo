//
//  ChatAudioPlayTool.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/25.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatAudioPlayTool : NSObject

+ (instancetype)audioPlayTool:(NSString *)path;

- (void)play;

@end
