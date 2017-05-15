//
//  ChatTabbar.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/15.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^swtControllerBlock)(NSInteger index);

@interface ChatTabbar : UITabBar

@property (nonatomic, copy) swtControllerBlock swtCallback;

@end
