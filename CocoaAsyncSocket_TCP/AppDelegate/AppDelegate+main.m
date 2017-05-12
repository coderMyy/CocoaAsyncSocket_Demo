//
//  AppDelegate+main.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "AppDelegate+main.h"
#import "ChatNavigationController.h"
#import "ChatListViewController.h"

@implementation AppDelegate (main)

- (void)initMainController
{
    self.window = [[UIWindow alloc]initWithFrame:SCREEN_BOUNDS];
    ChatListViewController *chatlistVC= [[ChatListViewController alloc]init];
    ChatNavigationController *nav = [[ChatNavigationController alloc]initWithRootViewController:chatlistVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}



@end
