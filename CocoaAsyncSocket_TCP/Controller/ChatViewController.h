//
//  ChatViewController.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatBaseController.h"

@class  ChatModel;

@interface ChatViewController : ChatBaseController

@property (nonatomic, strong) ChatModel *chatModel;

@end
