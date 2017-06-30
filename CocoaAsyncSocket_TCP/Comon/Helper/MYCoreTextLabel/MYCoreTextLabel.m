//
//  MYCoreTextLabel.m
//  图文混排demo
//
//  Created by 孟遥 on 2017/2/5.
//  Copyright © 2017年 孟遥. All rights reserved.
//

#define keywordTag  @"keywordTag"
#define keyWordCoverTag 1998
#define canClickLinkTag @"canClickLinkTag"
#define linkCoverTag    998

#import "MYCoreTextLabel.h"

@interface MYCoreTextLabel ()

@property (nonatomic, strong) UITextView *contentTextView;    //文本view
@property (nonatomic, strong) NSMutableArray<MYLinkModel *> *links;   //所有的可点击链接模型
@property (nonatomic, strong) NSMutableArray<MYSubCoretextResult *> *allResults;//所有结果
@property (nonatomic, copy) eventCallback touchCallback;      //点击链接回调
@property (nonatomic, copy) NSString *text; //文本
@property (nonatomic, strong) NSArray *customLinks; //自定义链接
@property (nonatomic, strong) NSArray *keywords;    // 关键字
@property (nonatomic, strong) MYLinkModel *currentTouchLink; //记录当前手指所在链接模型
@property (nonatomic, strong) NSMutableArray<MYLinkModel *> *clickLinksCache; //常规链接模型临时存储 (缓存的目的在于,点击时查询相应模型)
@property (nonatomic, assign,getter=isKeywordConfiged) BOOL keywordConfig; //临时记录

@end

@implementation MYCoreTextLabel

- (NSMutableArray *)clickLinksCache
{
    if (!_clickLinksCache) {
        _clickLinksCache = [NSMutableArray array];
    }
    return _clickLinksCache;
}

- (UITextView *)contentTextView
{
    if (!_contentTextView) {
        _contentTextView                        = [[UITextView alloc]init];
        _contentTextView.textContainerInset     = UIEdgeInsetsMake(1, 1, 1, 1);
        _contentTextView.editable               = NO;
        _contentTextView.userInteractionEnabled = NO;
        _contentTextView.scrollEnabled          = NO;
        _contentTextView.backgroundColor        = [UIColor clearColor];
    }
    return _contentTextView;
}

//所有结果集
- (NSMutableArray<MYSubCoretextResult *> *)allResults
{
    if (!_allResults) {
        
        //配置自定义链接
        [MYCoretextResultTool customLinks:_customLinks];
        //配置关键字
        [MYCoretextResultTool keyWord:_keywords];
        //配置需要展示的链接类型
        [MYCoretextResultTool webLink:_showWebLink trend:_showTrendLink topic:_showTopicLink phone:_showPhoneLink mail:_showMailLink];
        //剪切表情,获得表情以及链接结果集
        _allResults = [MYCoretextResultTool subTextWithEmotion:self.text];
    }
    return _allResults;
}

- (NSMutableArray<MYLinkModel *> *)links
{
    if (!_links) {
        _links = [NSMutableArray array];
        
        //重新生成可点击链接模型,进一步处理,完善包裹区域
        __weak typeof(self) weakself = self;
        [self.contentTextView.attributedText enumerateAttribute:canClickLinkTag inRange:NSMakeRange(0, self.contentTextView.attributedText.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
           
            NSString *linkString         = value;
            if (!linkString.length) return ;//过滤空字符
            if ([_keywords containsObject:linkString]) return ;//屏蔽关键字
                
            MYLinkModel *link          = [[MYLinkModel alloc]init];
            link.range                       = range;
            link.linkText                    = linkString;
            //链接类型整理
            NSPredicate *predicate   = [NSPredicate predicateWithFormat:@"linkText = %@",linkString];
            NSArray * norResults      = [weakself.clickLinksCache filteredArrayUsingPredicate:predicate];
            MYLinkModel *cachelink = norResults.firstObject;
            if (cachelink) {
                link.linkType              = cachelink.linkType;
                switch (link.linkType) {
                    case MYLinkTypeCustomLink:
                        link.clickBackColor = _customLinkBackColor;
                        link.clickFont         = _customLinkFont;
                        break;
                    case MYLinkTypetWebLink:
                        link.clickBackColor = _webLinkBackColor;
                        link.clickFont         = _webLinkFont;
                        break;
                    case MYLinkTypeMailLink:
                        link.clickBackColor = _mailLinkBackColor;
                        link.clickFont         = _mailLinkFont;
                        break;
                    case MYLinkTypePhoneLink:
                        link.clickBackColor = _phoneLinkBackColor;
                        link.clickFont         = _phoneLinkFont;
                        break;
                    case MYLinkTypetTopicLink:
                        link.clickBackColor = _topicLinkBackColor;
                        link.clickFont         = _topicLinkFont;
                        break;
                    case MYLinkTypetTrendLink:
                        link.clickBackColor = _trendLinkBackColor;
                        link.clickFont         = _trendLinkFont;
                        break;
                    default:
                        break;
                }
            }
            weakself.contentTextView.selectedRange = range;
            NSArray *selectedRects = [weakself.contentTextView selectionRectsForRange:weakself.contentTextView.selectedTextRange];
            NSMutableArray *rects  = [NSMutableArray array];
            for (UITextSelectionRect *rect  in selectedRects) {
                
                if (!rect.rect.size.width||!rect.rect.size.height) continue;
                [rects addObject:rect];
            }
            link.rects = rects;
            [_links addObject:link];
        }];
    }
    return _links;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.contentTextView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentTextView.frame = self.bounds;
    if (_keywordConfig) return;
    //设置高亮关键字
    [self keyWord:[[NSMutableAttributedString alloc]initWithAttributedString:self.contentTextView.attributedText]];
    _keywordConfig = YES;
}



#pragma mark - 添加指定字符串链接,关键字,公共接口
- (void)setText:(NSString *)text customLinks:(NSArray<NSString *> *)customLinks keywords:(NSArray<NSString *> *)keywords
{
    _text        = text;
    _customLinks = customLinks;
    _keywords    = keywords;
}

#pragma mark - 添加指定区间链接 , 公共接口
- (void)setText:(NSString *)text linkRanges:(NSArray<NSValue *> *) ranges keywords:(NSArray<NSString *> *)keywords
{
    _text   = text;
    _keywords = keywords;
    NSMutableArray *customLinks = [NSMutableArray array];
    for (NSValue *rangeValue in ranges) {
        NSRange range = rangeValue.rangeValue;
        if (range.location + range.length >text.length) continue;
        [customLinks addObject:[text substringWithRange:range]];
    }
    _customLinks = customLinks;
}

#pragma mark - 开始渲染
- (void)render
{
    //属性矫正
    [self judge];
    //复用处理
    [self reuseHandle];
    [self configAttribute:_text];
}

#pragma mark - 配置属性
- (void)configAttribute:(NSString *)text
{
    __weak typeof(self) weakSelf = self;
     NSMutableAttributedString *stringM = [[NSMutableAttributedString alloc]init];
    //遍历结果集
    [self.allResults enumerateObjectsUsingBlock:^(MYSubCoretextResult * _Nonnull result, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //表情
        if (result.isEmotion) {
           
            //图片富文本
            NSTextAttachment *attachmeent         = [[NSTextAttachment alloc]init];
            UIImage *emotionImage                 = [UIImage imageNamed:result.string];
            if (emotionImage) { //有对应表情
             
                attachmeent.image                 = emotionImage;
                attachmeent.bounds  = CGRectMake(0, -3, _imageSize.width, _imageSize.height);
                NSAttributedString *imageString   = [NSAttributedString attributedStringWithAttachment:attachmeent];
                [stringM appendAttributedString:imageString];
            }else{
                NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:result.string];
                [weakSelf normalTextAttribute:string];
                [stringM appendAttributedString:string];
            }
            
        }else{ //非表情
            
            //设置文本属性
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:result.string];
            //普通文本属性
            [weakSelf normalTextAttribute:string];
            //设置链接属性
            if (result.links.count) {
             
                for (MYLinkModel *link in result.links) { // 14-4 2-7 2-21
                    
                    switch (link.linkType) {
                        case MYLinkTypetWebLink:
                        {
                            [self webLinkAttribute:string range:link.range];
                            //标记自定义链接
                            [string addAttribute:canClickLinkTag value:[result.string substringWithRange:link.range] range:link.range];
                            //缓存常规链接
                            [self.clickLinksCache addObject:link];
                        }
                            break;
                        case MYLinkTypeCustomLink:
                        {
                            //自定义链接设置属性
                            [self customLinkAttribute:string range:link.range];
                            //标记自定义链接
                            [string addAttribute:canClickLinkTag value:[result.string substringWithRange:link.range] range:link.range];
                            //缓存常规链接
                            [self.clickLinksCache addObject:link];
                        }
                            break;
                        case MYLinkTypeMailLink:
                        {
                            //邮箱链接设置属性
                            [self mailLinkAttribute:string range:link.range];
                            //标记邮箱链接
                            [string addAttribute:canClickLinkTag value:[result.string substringWithRange:link.range] range:link.range];
                            //缓存常规链接
                            [self.clickLinksCache addObject:link];
                        }
                            break;
                        case MYLinkTypePhoneLink:
                        {
                            //手机链接设置属性
                            [self phoneLinkAttribute:string range:link.range];
                            //标记手机链接
                            [string addAttribute:canClickLinkTag value:[result.string substringWithRange:link.range] range:link.range];
                            //缓存常规链接
                            [self.clickLinksCache addObject:link];
                        }
                            break;
                        case MYLinkTypetTopicLink:
                        {
                            //话题链接设置属性
                            [self topicLinkAttribute:string range:link.range];
                            //标记话题链接
                            [string addAttribute:canClickLinkTag value:[result.string substringWithRange:link.range] range:link.range];
                            //缓存常规链接
                            [self.clickLinksCache addObject:link];
                        }
                            break;
                        case MYLinkTypetTrendLink:
                        {
                            //@链接设置属性
                            [self trendLinkAttribute:string range:link.range];
                            //标记@链接
                            [string addAttribute:canClickLinkTag value:[result.string substringWithRange:link.range] range:link.range];
                            //缓存常规链接
                            [self.clickLinksCache addObject:link];
                        }
                            break;
                        case MYLinkTypeKeyword:
                        {
                            //关键字设置属性
                            [self keywordAttribute:string range:link.range];
                            //标记关键字
                            [string addAttribute:keywordTag value:[result.string substringWithRange:link.range] range:link.range];
                        }
                            break;
                        default:
                            break;
                    }
                }
            }
            [stringM appendAttributedString:string];
        }
    }];
    self.contentTextView.attributedText = stringM;
}




- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch         = [touches anyObject];
    CGPoint touchPoint     = [touch locationInView:self.contentTextView];
    MYLinkModel *linkModel = [self selectedLink:touchPoint];
    [self addSelectedAnimation:linkModel];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissAnimation];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *moveTouch  = [touches anyObject];
    CGPoint movePoint   = [moveTouch locationInView:moveTouch.view];
    
    BOOL isContained    = NO;
    for (UITextSelectionRect *rect in self.currentTouchLink.rects) {
        if (CGRectContainsPoint(rect.rect, movePoint)) {
            isContained = YES;
        }
    }
    if (!isContained) {
     [self dismissAnimation];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissAnimation];
}


#pragma mark - 获取点击链接模型
- (MYLinkModel *)selectedLink:(CGPoint)touchPoint
{
    
    MYLinkModel *linkModel = nil;
    for (MYLinkModel *link in self.links) {
        
        for (UITextSelectionRect *rect in link.rects) {
            
            if (CGRectContainsPoint(rect.rect, touchPoint)) {
                
                linkModel             = link;
                self.currentTouchLink = link; //记录当前点击
                //回调内容
                if ([self.delegate respondsToSelector:@selector(linkText:type:)]) {
                    [self.delegate linkText:link.linkText type:link.linkType];
                }
                break;
            }
        }
    }
    return linkModel;
}

#pragma mark - 点击效果
- (void)addSelectedAnimation:(MYLinkModel *)linkModel
{
    [linkModel.rects enumerateObjectsUsingBlock:^(UITextSelectionRect * _Nonnull rect, NSUInteger idx, BOOL * _Nonnull stop) {
       
        UIView *coverView            = [[UIView alloc]init];
        coverView.backgroundColor    = linkModel.clickBackColor;
        coverView.alpha              = _linkBackAlpha;
//        CGRect frame                 = rect.rect;
//        frame.size.height            = linkModel.clickFont.lineHeight + 2.f;
//        frame.origin.y                 = roundf(frame.origin.y);
        coverView.frame              = rect.rect;
        coverView.tag                = linkCoverTag;
        coverView.layer.cornerRadius = 3.f;
        coverView.clipsToBounds      = YES;
        [self insertSubview:coverView atIndex:0];
    }];
}

#pragma mark - 点击动画
- (void)dismissAnimation
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        for (UIView *coverView in self.subviews) {
            if (coverView.tag == linkCoverTag) {
                [coverView removeFromSuperview];
            }
        }
    });
}


#pragma mark - 特殊指定字符链接属性设置
- (void)customLinkAttribute:(NSMutableAttributedString *)attributeStr range:(NSRange)linkRange
{
    [attributeStr addAttribute:NSFontAttributeName value:_customLinkFont range:linkRange];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:_customLinkColor range:linkRange];
}

#pragma mark - 网址链接属性设置
- (void)webLinkAttribute:(NSMutableAttributedString *)attributeStr range:(NSRange)linkRange
{
    [attributeStr addAttribute:NSFontAttributeName value:_webLinkFont range:linkRange];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:_webLinkColor range:linkRange];
}

#pragma mark - 话题链接属性设置
- (void)topicLinkAttribute:(NSMutableAttributedString *)attributeStr range:(NSRange)linkRange
{
    [attributeStr addAttribute:NSFontAttributeName value:_topicLinkFont range:linkRange];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:_topicLinkColor range:linkRange];
}

#pragma mark - @链接属性设置
- (void)trendLinkAttribute:(NSMutableAttributedString *)attributeStr range:(NSRange)linkRange
{
    [attributeStr addAttribute:NSFontAttributeName value:_trendLinkFont range:linkRange];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:_trendLinkColor range:linkRange];

}

#pragma mark - 手机号链接属性设置
- (void)phoneLinkAttribute:(NSMutableAttributedString *)attributeStr range:(NSRange)linkRange
{
    [attributeStr addAttribute:NSFontAttributeName value:_phoneLinkFont range:linkRange];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:_phoneLinkColor range:linkRange];
}

#pragma mark - 邮箱号链接属性设置
- (void)mailLinkAttribute:(NSMutableAttributedString *)attributeStr range:(NSRange)linkRange
{
    [attributeStr addAttribute:NSFontAttributeName value:_mailLinkFont range:linkRange];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:_mailLinkColor range:linkRange];
}

#pragma mark - 关键字属性设置
- (void)keywordAttribute:(NSMutableAttributedString *)attributeStr range:(NSRange)linkRange
{
    [attributeStr addAttribute:NSFontAttributeName value:_keywordFont range:linkRange];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:_keyWordColor range:linkRange];
}



#pragma mark - 普通文本属性设置
- (void)normalTextAttribute:(NSMutableAttributedString *)attributeStr
{
    [attributeStr addAttribute:NSFontAttributeName value:_textFont range:NSMakeRange(0, attributeStr.length)];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:_textColor range:NSMakeRange(0, attributeStr.length)];
    NSMutableParagraphStyle *paragra = [[NSMutableParagraphStyle alloc]init];
    [paragra setLineBreakMode:NSLineBreakByCharWrapping];
    [paragra setLineSpacing:_lineSpacing];
    [attributeStr addAttribute:NSParagraphStyleAttributeName value:paragra range:NSMakeRange(0, attributeStr.length)];
    [attributeStr addAttribute:NSKernAttributeName value:@(_wordSpacing) range:NSMakeRange(0, attributeStr.length)];
}

#pragma mark - 高亮关键字设置
- (void)keyWord:(NSMutableAttributedString *)attributeStr
{
    
    if (!_keywords.count) return;
    __weak typeof(self) weakself = self;
    [attributeStr enumerateAttribute:keywordTag inRange:NSMakeRange(0, attributeStr.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
       
        NSString *str = value;
        if (!str.length) return ;
        NSPredicate *predict = [NSPredicate predicateWithFormat:@"SELF = %@",str];
        NSArray *keywordResults = [_keywords filteredArrayUsingPredicate:predict];
        if (![str isEqualToString:keywordResults.firstObject]||!range.length) return ; //过滤非关键字
            
            //计算选中区域
            weakself.contentTextView.selectedRange = range;
            NSArray *coverRects = [weakself.contentTextView selectionRectsForRange:weakself.contentTextView.selectedTextRange];
            for (UITextSelectionRect *rect in coverRects) {
                if (!rect.rect.size.width||!rect.rect.size.height) continue;
                UIView *keywordView                 = [[UIView alloc]init];
                keywordView.backgroundColor    = _keyWordBackColor;
                keywordView.alpha                    = _linkBackAlpha;
                keywordView.layer.cornerRadius = 3.f;
                keywordView.clipsToBounds      = YES;
                keywordView.tag                      = keyWordCoverTag;
//                CGRect   frame                        = rect.rect;
//                frame.size.height                      = _keywordFont.lineHeight + 2.f;
//                frame.origin.y                           = roundf(frame.origin.y);
                keywordView.frame                  = rect.rect;
                [weakself insertSubview:keywordView atIndex:0];
            }
     }];
}

#pragma mark - 判断属性
- (void)judge
{
    
    if (!_text.length) {
        _text = @" ";
        return;
    }
    
    //文本内容
    if (!_textFont)  _textFont                   = [UIFont systemFontOfSize:14.f];
    if (!_textColor) _textColor                  = [UIColor blackColor];
    if (!_imageSize.width||
        !_imageSize.height) _imageSize           = CGSizeMake(_textFont.lineHeight, _textFont.lineHeight);
    if (!_linkBackAlpha) _linkBackAlpha          = 0.5f;

    //网址链接
    if (!_webLinkFont) _webLinkFont              = _textFont;
    if (!_webLinkColor) _webLinkColor            = [UIColor blueColor];
    if (!_webLinkBackColor) _webLinkBackColor    = [UIColor blueColor];
    
    //话题链接
    if (!_topicLinkFont) _topicLinkFont               = _textFont;
    if (!_topicLinkColor) _topicLinkColor           = [UIColor blueColor];;
    if (!_topicLinkBackColor) _topicLinkBackColor  = [UIColor blueColor];
    
    //@链接
    if (!_trendLinkFont) _trendLinkFont             = _textFont;
    if (!_trendLinkColor) _trendLinkColor          = [UIColor blueColor];
    if (!_trendLinkBackColor) _trendLinkBackColor   = [UIColor blueColor];
    
    //手机号链接
    if (!_phoneLinkFont) _phoneLinkFont           = _textFont;
    if (!_phoneLinkColor) _phoneLinkColor        = [UIColor blueColor];
    if (!_phoneLinkBackColor) _phoneLinkBackColor = [UIColor blueColor];
    
    //邮箱链接
    if (!_mailLinkFont) _mailLinkFont                 = _textFont;
    if (!_mailLinkColor) _mailLinkColor              = [UIColor blueColor];
    if (!_mailLinkBackColor) _mailLinkBackColor   = [UIColor blueColor];
    
    //自定义链接
    if (!_customLinkFont) _customLinkFont        = _textFont;
    if (!_customLinkColor) _customLinkColor      = [UIColor blueColor];
    if (!_customLinkBackColor) _customLinkBackColor = [UIColor blueColor];
    
    //关键字
    if (!_keyWordColor) _keyWordColor            = [UIColor blackColor];
    if (!_keyWordBackColor) _keyWordBackColor    = [UIColor yellowColor];
}

#pragma mark - 计算尺寸
- (CGSize)sizeThatFits:(CGSize)size
{
    //渲染
    [self render];
    
    if (!self.contentTextView.attributedText.length) {
        return CGSizeZero;
    }
    
    CGSize viewSize = [self.contentTextView sizeThatFits:CGSizeMake(size.width, size.height)];
    return viewSize;
}


#pragma mark - 复用处理
- (void)reuseHandle
{
    self.allResults    = nil;
    self.links         = nil;
    self.clickLinksCache = nil;
    self.keywordConfig = NO;
    for (UIView *view in self.subviews) {
        
        if (view.tag == keyWordCoverTag) {
         [view removeFromSuperview];
        }
    }
}

#pragma mark 类方法
+ (instancetype)coreTextLabel
{
    return [[self alloc]init];
}
@end
