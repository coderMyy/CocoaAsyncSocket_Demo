//
//  ChatViewController.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "BaseViewController.h"

@class  ChatModel;

@interface ChatViewController : BaseViewController
//必传
@property (nonatomic, strong) ChatModel *config;

@end
