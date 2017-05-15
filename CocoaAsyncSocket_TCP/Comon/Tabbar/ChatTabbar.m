//
//  ChatTabbar.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/15.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatTabbar.h"

@interface ChatTabbarButton : UIButton
@end

@implementation ChatTabbarButton

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = Frame(0,7, SCREEN_WITDTH *0.25, 24);
    self.titleLabel.frame   = Frame(0, MaxY(self.imageView.frame)+5, SCREEN_WITDTH *0.25, 12);
}

@end

@implementation ChatTabbar

#pragma mark - 自定义按钮
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        NSArray *vcInfos = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Tabbars" ofType:@"plist"]];
        for (NSInteger index = 0; index < vcInfos.count; index ++) {
            NSDictionary *dict = vcInfos[index];
            ChatTabbarButton *tabbarItem = [ChatTabbarButton buttonWithType:UIButtonTypeCustom];
            tabbarItem.titleLabel.font = FontSet(10);
            tabbarItem.tag = 10000 + index;
            tabbarItem.titleLabel.textAlignment = NSTextAlignmentCenter;
            tabbarItem.imageView.contentMode = UIViewContentModeCenter;
            [tabbarItem setTitle:dict[@"ItemName"] forState:UIControlStateNormal];
            [tabbarItem setTitleColor:UICOLOR_RGB_Alpha(0x919191, 1) forState:UIControlStateNormal];
            [tabbarItem setImage:LoadImage(dict[@"ItemImageName"]) forState:UIControlStateNormal];
            tabbarItem.frame = Frame(index *(SCREEN_WITDTH*0.25),0, SCREEN_WITDTH*0.25, 49);
            [tabbarItem addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:tabbarItem];
        }
    }
    return self;
}

#pragma mark - 移除原生按钮
- (void)layoutSubviews
{
    [super layoutSubviews];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [view removeFromSuperview];
        }
    }
}


#pragma mark - 切换控制器
- (void)itemClick:(UIButton *)item
{
    if (_swtCallback) {
        _swtCallback(item.tag - 10000);
    }
}


@end
