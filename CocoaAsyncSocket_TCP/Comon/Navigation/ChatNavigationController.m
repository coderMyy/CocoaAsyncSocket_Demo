//
//  ChatNavigationController.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatNavigationController.h"
#import "UIImage+colorImage.h"

@interface ChatNavigationController ()

@end

@implementation ChatNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
}

+ (void)initialize
{
    UINavigationBar *navBar = [UINavigationBar appearance];
    UIImage *barImg = [UIImage imageFromContextWithColor:UICOLOR_RGB_Alpha(0x000000, 0.8)];
    [navBar setBackgroundImage:barImg forBarMetrics:UIBarMetricsDefault];
    navBar.barStyle  =  UIBarStyleBlack;
    [navBar setTintColor:UIMainWhiteColor];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
     [super pushViewController:viewController animated:animated];
}

@end
