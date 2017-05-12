//
//  NSDate+extension.h
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (extension)

//判断时间戳是否为当天,昨天,一周内,年月日
+ (NSString *)timeStringWithTimeInterval:(NSString *)timeInterval;

@end
