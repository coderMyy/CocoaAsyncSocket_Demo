//
//  UMSocialShareEditViewController.h
//  UMSocialSDK
//
//  Created by wangfei on 16/8/16.
//  Copyright © 2016年 dongjianxiong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMSocialPlatformConfig.h"

@class UMSocialMessageObject;

@interface UMSocialShareEditViewController : UIViewController

@property (nonatomic,strong) UIImageView* editBar;
@property (nonatomic,strong) UILabel* numLabel;
@property (nonatomic,strong) UIImageView* imageView;
@property (nonatomic,strong) UIButton* delBtn;
@property (nonatomic,strong) UITextView* editView;
@property (nonatomic,strong) UMSocialMessageObject *shareContent;
@property (nonatomic, copy)  UMSocialRequestCompletionHandler shareCompletionBlock;
@property (nonatomic,strong) NSString* usid;
@property (nonatomic,assign) UMSocialPlatformType platformType;


@end
