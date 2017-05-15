//
//  AppDelegate+main.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "AppDelegate+main.h"
#import "ChatTabbarController.h"

@implementation AppDelegate (main)

- (void)initMainController
{
    self.window = [[UIWindow alloc]initWithFrame:SCREEN_BOUNDS];
    ChatTabbarController *tabbarVc = [[ChatTabbarController alloc]init];
    self.window.rootViewController = tabbarVc;
    [self.window makeKeyAndVisible];
}



@end
