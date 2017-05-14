 //
//  MYCoretextResultTool.m
//  图文混排demo
//
//  Created by 孟遥 on 2017/2/11.
//  Copyright © 2017年 孟遥. All rights reserved.
//

#import "MYCoretextResultTool.h"
#import "MYSubCoretextResult.h"
#import <objc/runtime.h>

static const char textKey;
static const char keyWordKey;
static const NSArray *customlinksKey;

@implementation MYCoretextResultTool

+ (void)customLinks:(NSArray<NSString *> *)customLinks
{
    objc_setAssociatedObject(self ,&customlinksKey ,customLinks ,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)keyWord:(NSArray<NSString *> *)keywords
{
    objc_setAssociatedObject(self ,&keyWordKey ,keywords ,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//以表情切割结果集
+ (NSMutableArray<MYSubCoretextResult *> *)subTextWithEmotion:(NSString *)text
{
    //获取表情结果集
    NSArray *emotionResults = [self emotionResults:text];
    if (!emotionResults.count) {
        return [NSMutableArray arrayWithObject:[self normalTextResult:NSMakeRange(0,text.length) string:text]];
    }
    //返回表情，普通文本所有集
    return [NSMutableArray arrayWithArray:[self subResults:emotionResults]];
}


#pragma mark - 根据表情集剪切文本
+ (NSArray<MYSubCoretextResult *> *)subResults:(NSArray<MYSubCoretextResult *> *)emotionResults
{
    NSMutableArray<MYSubCoretextResult *> *detailResults    = [NSMutableArray array];
    [detailResults addObjectsFromArray:emotionResults];
    NSString *text = objc_getAssociatedObject(self,&textKey);
    __weak typeof(self) weakself = self;
    [emotionResults enumerateObjectsUsingBlock:^(MYSubCoretextResult  *_Nonnull result, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //如果只有一个表情情况
        if (emotionResults.count == 1) {
            
            [weakself emotionResultDeal:result.range string:text resultModel:result];
            NSArray *normals = [text componentsSeparatedByString:result.string];
            //赋值表情附件
            if (normals.count) {
                if ([normals.firstObject length]) {
                    MYSubCoretextResult *firstNorResult = [weakself normalTextResult:[text rangeOfString:normals.firstObject] string:text];
                    [detailResults insertObject:firstNorResult atIndex:0];
                }
                if ([normals.lastObject length]) {
                
                MYSubCoretextResult *lastNorResult  = [weakself normalTextResult:[text rangeOfString:normals.lastObject] string:text];
                [detailResults addObject:lastNorResult];
                }
            }
            return ;
        }
        
        //第一个
        if (idx == 0) {
            
            //赋值表情附件
            [weakself emotionResultDeal:result.range string:text resultModel:emotionResults[idx]];
            
            //插入最前面文本
            MYSubCoretextResult *firstNorTextResult = [weakself firstNorTextResult:result];
            if (firstNorTextResult) {
             [detailResults insertObject:firstNorTextResult atIndex:0];
            }
        }else {
            
            //赋值表情附件
            [weakself emotionResultDeal:result.range string:text resultModel:emotionResults[idx]];
            //插入中间普通文本
            MYSubCoretextResult *midNorResult = [weakself midNorTextResult:emotionResults index:idx];
            if (midNorResult) {
             [detailResults insertObject:midNorResult atIndex:[detailResults indexOfObject:result]];
            }
            
            //最后一个链接处理
            if (idx == emotionResults.count -1) {
                MYSubCoretextResult *lastNorTextResult = [weakself lastNorTextResult:result];
                if (lastNorTextResult) {
                 [detailResults addObject:lastNorTextResult];
                }
            }
        }
    }];
    return detailResults;
}


#pragma mark - 获取所有有序表情集
+ (NSArray<MYSubCoretextResult *> *)emotionResults:(NSString *)text
{
    
    objc_setAssociatedObject(self ,&textKey ,text ,OBJC_ASSOCIATION_COPY);
    //匹配表情
    NSMutableArray *emotionResults = [self regexEmotion:text];
    //表情结果集排序
    [emotionResults sortUsingComparator:^NSComparisonResult(MYSubCoretextResult *_Nonnull result1, MYSubCoretextResult  *_Nonnull result2) {
        
        return result1.range.location > result2.range.location;
    }];
    return emotionResults;
}


#pragma mark - 赋值表情附件
+ (void)emotionResultDeal:(NSRange)range string:(NSString *)text resultModel:(MYSubCoretextResult *)result
{
    result.string = [text substringWithRange:range];
    result.range  = range;
}


#pragma mark - 表情以外普通文本内容
+ (MYSubCoretextResult *)normalTextResult:(NSRange)range string:(NSString *)text
{
    NSString *rangeString     = [text substringWithRange:range];
    MYSubCoretextResult *subNormalResult = [[MYSubCoretextResult alloc]init];
    subNormalResult.range     = range;
    subNormalResult.string    = rangeString;
    subNormalResult.isEmotion = NO;
    
    NSMutableArray *links     = [NSMutableArray array];
    //匹配网址
    NSArray *webs             = [self regexWebs:rangeString];
    [links addObjectsFromArray:webs];
    
    //匹配 @
    NSArray *trends           = [self regexTrend:rangeString];
    [links addObjectsFromArray:trends];
    
    //匹配#话题#
    NSArray *topics           = [self regexTopic:rangeString];
    [links addObjectsFromArray:topics];
    
    //匹配关键字
    NSArray *keywords         = [self regexKeyword:rangeString];
    [links addObjectsFromArray:keywords];
    
    //匹配指定字符串
    NSArray *tagStrs          = [self regexStr:rangeString];
    [links addObjectsFromArray:tagStrs];
    
    subNormalResult.links     = links;
    return subNormalResult;
}


#pragma mark - 获取除开最前面部分和最后部分的普通文本
+ (MYSubCoretextResult *)midNorTextResult:(NSArray<MYSubCoretextResult *> *)emotionResults index:(NSInteger)index
{
    MYSubCoretextResult *result    = emotionResults[index];
    NSInteger currentLocation      = result.range.location;
    //前一个location
    MYSubCoretextResult *preResult = emotionResults[index - 1];
    NSInteger preLocation          = preResult.range.location;
    NSInteger preLength            = preResult.range.length;
    //获取文本
    NSInteger length               = currentLocation - preLocation - preLength;
    NSInteger location             = preLocation + preResult.range.length;
    
    if (length) {
        NSString *text             = objc_getAssociatedObject(self,&textKey);
        return [self normalTextResult:NSMakeRange(location, length) string:text];
    }
    return nil;
}

#pragma mark -获取最前面部分文本
+ (MYSubCoretextResult *)firstNorTextResult:(MYSubCoretextResult *)emotionResult
{
    NSRange range = NSMakeRange(0, emotionResult.range.location);
    if (emotionResult.range.location !=0) { //不是从0开始,剪切之前的文本
        
        NSString *text = objc_getAssociatedObject(self,&textKey);
        return [self normalTextResult:range string:text];
    }
    return nil;
}

#pragma mark - 最后一个文本
+ (MYSubCoretextResult *)lastNorTextResult:(MYSubCoretextResult *)lastEmotionResult
{
    NSInteger location = lastEmotionResult.range.location + lastEmotionResult.range.length;
    NSString *text = objc_getAssociatedObject(self,&textKey);
    
    if (lastEmotionResult.range.location +lastEmotionResult.range.length < text.length) {
        NSRange range = NSMakeRange(location, text.length - location);
        return [self normalTextResult:range string:text];
    }
    return nil;
}

#pragma mark - 匹配表情
+ (NSMutableArray<MYSubCoretextResult *>*)regexEmotion:(NSString *)text
{
    NSMutableArray<MYSubCoretextResult *> *emotionResults = [NSMutableArray array];
    //正则匹配表情
    NSError *error = nil;
    NSString *emotionRegex = @"\\[[^\\[\\]]*\\]";
    NSRegularExpression *emotionExpression = [NSRegularExpression regularExpressionWithPattern:emotionRegex options:NSRegularExpressionCaseInsensitive error:&error];
    [emotionExpression enumerateMatchesInString:text options:NSMatchingReportCompletion range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        
        if (result.range.length) {
            MYSubCoretextResult *resultModel = [[MYSubCoretextResult alloc]init];
            resultModel.isEmotion            = YES;
            resultModel.range                = result.range;
            [emotionResults addObject:resultModel];
        }
    }];
    return emotionResults;
}

#pragma mark - 匹配网址
+ (NSArray<MYSubCoretextResult *>*)regexWebs:(NSString *)rangeString
{
    NSMutableArray *weblinks = [NSMutableArray array];
    //正则匹配超链接
    NSString *linkRegex = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *linkExpression = [NSRegularExpression regularExpressionWithPattern:linkRegex options:NSRegularExpressionCaseInsensitive error:nil];
    //遍历结果
    [linkExpression enumerateMatchesInString:rangeString options:NSMatchingReportCompletion range:NSMakeRange(0, rangeString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        
        if (result.range.length) {
            MYLinkModel *link = [[MYLinkModel alloc]init];
            link.range        = result.range;
            link.linkText     = [rangeString substringWithRange:result.range];
            link.linkType     = MYLinkTypetWebLink;
            [weblinks addObject:link];
        }
    }];
    return weblinks;
}

#pragma mark - 匹配 @ 
+ (NSArray<MYSubCoretextResult *>*)regexTrend:(NSString *)rangeString
{
    NSMutableArray *trendlinks = [NSMutableArray array];
    //正则匹配 @
    NSString *ARegex = @"@[a-zA-Z0-9\\u4e00-\\u9fa5\\-]+ ?";
    NSRegularExpression *AExpression = [NSRegularExpression regularExpressionWithPattern:ARegex options:NSRegularExpressionCaseInsensitive error:nil];
    [AExpression enumerateMatchesInString:rangeString options:NSMatchingReportCompletion range:NSMakeRange(0, rangeString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        
        if (result.range.length) {
            
            MYLinkModel *link = [[MYLinkModel alloc]init];
            link.range        = result.range;
            link.linkText     = [rangeString substringWithRange:result.range];
            link.linkType     = MYLinkTypetTrendLink;
            [trendlinks addObject:link];
        }
    }];
    return trendlinks;
}

#pragma mark - 匹配 #话题#
+ (NSArray<MYSubCoretextResult *>*)regexTopic:(NSString *)rangeString
{
    NSMutableArray *topiclinks = [NSMutableArray array];
    //正则匹配## 话题
    NSString *trendRegex = @"#[a-zA-Z0-9\\u4e00-\\u9fa5]+#";
    NSRegularExpression *trendExpression = [NSRegularExpression regularExpressionWithPattern:trendRegex options:NSRegularExpressionCaseInsensitive error:nil];
    [trendExpression enumerateMatchesInString:rangeString options:NSMatchingReportCompletion range:NSMakeRange(0, rangeString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        
        if (result.range.length) {
            MYLinkModel *link = [[MYLinkModel alloc]init];
            link.range        = result.range;
            link.linkText     = [rangeString substringWithRange:result.range];
            link.linkType     = MYLinkTypetTopicLink;
            [topiclinks addObject:link];
        }
    }];
    return topiclinks;
}

#pragma mark - 匹配关键字 keyword
+ (NSArray<MYSubCoretextResult *>*)regexKeyword:(NSString *)rangeString
{
    NSMutableArray *keywords = [NSMutableArray array];
    //正则匹配关键字keyword
    NSArray *keywordRegexs = objc_getAssociatedObject(self, &keyWordKey);
    if (!keywordRegexs.count) return nil ;
    
    for (NSString * keyword in keywordRegexs) {
        
        NSRegularExpression *keywordExpression = [NSRegularExpression regularExpressionWithPattern:keyword options:NSRegularExpressionCaseInsensitive error:nil];
        [keywordExpression enumerateMatchesInString:rangeString options:NSMatchingReportCompletion range:NSMakeRange(0, rangeString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            
            if (result.range.length) {
                MYLinkModel *link = [[MYLinkModel alloc]init];
                link.range        = result.range;
                link.linkText     = [rangeString substringWithRange:result.range];
                link.linkType     = MYLinkTypeKeyword;
                [keywords addObject:link];
            }
        }];
    }
    
    return keywords;
}

#pragma mark - 匹配指定字符串 
+ (NSArray<MYSubCoretextResult *>*)regexStr:(NSString *)rangeString
{
    
    NSMutableArray *tagStrs = [NSMutableArray array];
    //正则匹配指定链接字符串
    NSArray *customLinks = objc_getAssociatedObject(self,&customlinksKey);
    if (!customLinks.count) return nil;
    
    [customLinks enumerateObjectsUsingBlock:^(NSString  *_Nonnull otherlink, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *strRegex = otherlink;
        NSRegularExpression *strExpression = [NSRegularExpression regularExpressionWithPattern:strRegex options:NSRegularExpressionCaseInsensitive error:nil];
        [strExpression enumerateMatchesInString:rangeString options:NSMatchingReportCompletion range:NSMakeRange(0, rangeString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            
            if (result.range.length) {
                MYLinkModel *link = [[MYLinkModel alloc]init];
                link.range        = result.range;
                link.linkText     = [rangeString substringWithRange:result.range];
                link.linkType     = MYLinkTypeCustomLink; //自定义链接
                [tagStrs addObject:link];
            }
        }];
    }];
    return tagStrs;
}

@end
