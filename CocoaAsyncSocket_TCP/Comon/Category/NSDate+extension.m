//
//  NSDate+extension.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "NSDate+extension.h"

@implementation NSDate (extension)

+ (NSString *)timeStringWithTimeInterval:(NSString *)timeInterval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval.longLongValue/1000]; //此处根据项目需求,选择是否除以1000 , 如果时间戳精确到秒则去掉1000
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    //今天
    if ([date isToday]) {
        
        formatter.dateFormat = @"HH:mm";
        
        return [formatter stringFromDate:date];
    }else{
        
        //昨天
        if ([date isYesterday]) {
            
            formatter.dateFormat = @"昨天 HH:mm";
            return [formatter stringFromDate:date];
            
            //一周内 [date weekdayStringFromDate]
        }else if ([date isSameWeek]){
            
            formatter.dateFormat = [NSString stringWithFormat:@"%@ %@",[date weekdayStringFromDate],@"HH:mm"];
            return [formatter stringFromDate:date];
            
            //直接显示年月日
        }else{
            
            formatter.dateFormat = @"yy-MM-dd  HH:mm";
            return [formatter stringFromDate:date];
        }
    }
    return nil;
}

//是否在同一周
- (BOOL)isSameWeek
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    return (selfCmps.year == nowCmps.year) && (selfCmps.month == nowCmps.month) && (selfCmps.day == nowCmps.day);
}


//根据日期求星期几
- (NSString *)weekdayStringFromDate{
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期天", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [calendar setTimeZone: timeZone];
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:self];
    return [weekdays objectAtIndex:theComponents.weekday];
}


//是否为今天
- (BOOL)isToday
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    return (selfCmps.year == nowCmps.year) && (selfCmps.month == nowCmps.month) && (selfCmps.day == nowCmps.day);
}



//是否为昨天
- (BOOL)isYesterday
{

    NSDate *nowDate = [[NSDate date] dateWithYMD];
    NSDate *selfDate = [self dateWithYMD];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay fromDate:selfDate toDate:nowDate options:0];
    return cmps.day == 1;
}

//格式化
- (NSDate *)dateWithYMD
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSString *selfStr = [fmt stringFromDate:self];
    return [fmt dateFromString:selfStr];
}

@end
