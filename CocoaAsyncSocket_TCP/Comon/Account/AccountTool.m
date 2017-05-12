//
//  AccountTool.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/4/20.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "AccountTool.h"

@implementation AccountTool

+ (void)save:(Account *)account
{
    NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"account.arch"];
    [NSKeyedArchiver archiveRootObject:account toFile:cachePath];
}

+ (Account *)account
{
    NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"account.arch"];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
}

@end
