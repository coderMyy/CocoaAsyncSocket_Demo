//
//  ChatConfigModel.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/23.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatConfigModel : NSObject

@property (nonatomic, copy) NSString *toUserID;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *groupID;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSString *chatType;

@end
