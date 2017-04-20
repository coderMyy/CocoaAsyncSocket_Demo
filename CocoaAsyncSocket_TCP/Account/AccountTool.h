//
//  AccountTool.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/4/20.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"

@interface AccountTool : NSObject

//保存个人信息
+ (void)save:(Account *)account;

//获取个人信息
+ (Account *)account;

@end
