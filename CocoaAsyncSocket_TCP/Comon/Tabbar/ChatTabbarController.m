//
//  ChatTabbarController.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/15.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatTabbarController.h"
#import "ChatNavigationController.h"
#import "ChatTabbar.h"

@interface ChatTabbarController ()
//自定义tabbar
@property (nonatomic, strong)  ChatTabbar *customTabbar;

@end

@implementation ChatTabbarController

- (ChatTabbar *)customTabbar
{
    if (!_customTabbar) {
        _customTabbar = [[ChatTabbar alloc]init];
        __weak typeof(self) weakself = self;
        _customTabbar.swtCallback = ^(NSInteger index){
            weakself.selectedIndex = index;
        };
    }
    return _customTabbar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加子控制器
    [self addChildControllers];
    
    //替换原生tabbar
    [self initTabbar];
}

#pragma mark - 初始化tabbar
- (void)initTabbar
{
    [self.tabBar removeFromSuperview];
    [self setValue:self.customTabbar forKey:@"tabBar"];
}

#pragma mark - 添加子控制器
- (void)addChildControllers
{
    NSArray *vcInfos = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Tabbars" ofType:@"plist"]];
    for (NSDictionary *dict in vcInfos) {
        Class vcClass = NSClassFromString(dict[@"ControllerName"]);
        UIViewController *vc = [[vcClass alloc]init];
        ChatNavigationController *nav = [[ChatNavigationController alloc]initWithRootViewController:vc];
        vc.title = dict[@"ItemName"];
        [self addChildViewController:nav];
    }
}



@end
