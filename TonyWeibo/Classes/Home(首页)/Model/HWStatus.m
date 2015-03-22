
//
//  HWStatus.m
//  黑马微博2期
//
//  Created by apple on 14-10-12.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HWStatus.h"
#import "MJExtension.h"
#import "HWPhoto.h"
#import "HWUser.h"
#import "HWTextPart.h"
#import "RegexKitLite.h"
#import "HWEmotion.h"
#import "HWEmotionTool.h"
#import "HWSpecial.h"

@implementation HWStatus
- (NSDictionary *)objectClassInArray
{
    return @{@"pic_urls" : [HWPhoto class]};
}

/**
 *  普通文字 --> 属性文字
 *
 *  @param text 普通文字
 *
 *  @return 属性文字
 */
- (NSAttributedString *)attributedTextWithText:(NSString *)text
{
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    
    // 表情的规则
    NSString *emotionPattern = @"\\[[0-9a-zA-Z\\u4e00-\\u9fa5]+\\]";
    // @的规则
    NSString *atPattern = @"@[0-9a-zA-Z\\u4e00-\\u9fa5-_]+";
    // #话题#的规则
    NSString *topicPattern = @"#[0-9a-zA-Z\\u4e00-\\u9fa5]+#";
    // url链接的规则
    NSString *urlPattern = @"\\b(([\\w-]+://?|www[.])[^\\s()<>]+(?:\\([\\w\\d]+\\)|([^[:punct:]\\s]|/)))";
    NSString *pattern = [NSString stringWithFormat:@"%@|%@|%@|%@", emotionPattern, atPattern, topicPattern, urlPattern];
    
    // 遍历所有的特殊字符串
    NSMutableArray *parts = [NSMutableArray array];
    [text enumerateStringsMatchedByRegex:pattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        if ((*capturedRanges).length == 0) return;
        
        HWTextPart *part = [[HWTextPart alloc] init];
        part.special = YES;
        part.text = *capturedStrings;
        part.emotion = [part.text hasPrefix:@"["] && [part.text hasSuffix:@"]"];
        part.range = *capturedRanges;
        [parts addObject:part];
    }];
    // 遍历所有的非特殊字符
    [text enumerateStringsSeparatedByRegex:pattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        if ((*capturedRanges).length == 0) return;
        
        HWTextPart *part = [[HWTextPart alloc] init];
        part.text = *capturedStrings;
        part.range = *capturedRanges;
        [parts addObject:part];
    }];
    
    // 排序
    // 系统是按照从小 -> 大的顺序排列对象
    [parts sortUsingComparator:^NSComparisonResult(HWTextPart *part1, HWTextPart *part2) {
        // NSOrderedAscending = -1L, NSOrderedSame, NSOrderedDescending
        // 返回NSOrderedSame:两个一样大
        // NSOrderedAscending(升序):part2>part1
        // NSOrderedDescending(降序):part1>part2
        if (part1.range.location > part2.range.location) {
            // part1>part2
            // part1放后面, part2放前面
            return NSOrderedDescending;
        }
        // part1<part2
        // part1放前面, part2放后面
        return NSOrderedAscending;
    }];
    
    UIFont *font = [UIFont systemFontOfSize:15];
    NSMutableArray *specials = [NSMutableArray array];
    // 按顺序拼接每一段文字
    for (HWTextPart *part in parts) {
        // 等会需要拼接的子串
        NSAttributedString *substr = nil;
        if (part.isEmotion) { // 表情
            NSTextAttachment *attch = [[NSTextAttachment alloc] init];
            NSString *name = [HWEmotionTool emotionWithChs:part.text].png;
            if (name) { // 能找到对应的图片
                attch.image = [UIImage imageNamed:name];
                attch.bounds = CGRectMake(0, -3, font.lineHeight, font.lineHeight);
                substr = [NSAttributedString attributedStringWithAttachment:attch];
            } else { // 表情图片不存在
                substr = [[NSAttributedString alloc] initWithString:part.text];
            }
        } else if (part.special) { // 非表情的特殊文字
           substr = [[NSAttributedString alloc] initWithString:part.text attributes:@{
                                                                              NSForegroundColorAttributeName : [UIColor redColor]
                                                                              }];
            
            // 创建特殊对象
            HWSpecial *s = [[HWSpecial alloc] init];
            s.text = part.text;
            NSUInteger loc = attributedText.length;
            NSUInteger len = part.text.length;
            s.range = NSMakeRange(loc, len);
            [specials addObject:s];
        } else { // 非特殊文字
            substr = [[NSAttributedString alloc] initWithString:part.text];
        }
        [attributedText appendAttributedString:substr];
    }
    
    // 一定要设置字体,保证计算出来的尺寸是正确的
    [attributedText addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributedText.length)];
    [attributedText addAttribute:@"specials" value:specials range:NSMakeRange(0, 1)];
    
    return attributedText;
}

- (void)setText:(NSString *)text
{
    _text = [text copy];
    
    // 利用text生成attributedText
    self.attributedText = [self attributedTextWithText:text];
}

- (void)setRetweeted_status:(HWStatus *)retweeted_status
{
    _retweeted_status = retweeted_status;
    
     NSString *retweetContent = [NSString stringWithFormat:@"@%@ : %@", retweeted_status.user.name, retweeted_status.text];
    self.retweetedAttributedText = [self attributedTextWithText:retweetContent];
}

/**
 1.今年
     1> 今天
     * 1分内： 刚刚
     * 1分~59分内：xx分钟前
     * 大于60分钟：xx小时前
     
     2> 昨天
     * 昨天 xx:xx
     
     3> 其他
     * xx-xx xx:xx
 
 2.非今年
 1> xxxx-xx-xx xx:xx
 */
- (NSString *)created_at
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    // 如果是真机调试，转换这种欧美时间，需要设置locale
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    // 设置日期格式（声明字符串里面每个数字和单词的含义）
    // E:星期几
    // M:月份
    // d:几号(这个月的第几天)
    // H:24小时制的小时
    // m:分钟
    // s:秒
    // y:年
    fmt.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
//    _created_at = @"Tue Sep 30 17:06:25 +0600 2014";
    
    // 微博的创建日期
    NSDate *createDate = [fmt dateFromString:_created_at];
    // 当前时间
    NSDate *now = [NSDate date];
    
    // 日历对象（方便比较两个日期之间的差距）
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // NSCalendarUnit枚举代表想获得哪些差值
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 计算两个日期之间的差值
    NSDateComponents *cmps = [calendar components:unit fromDate:createDate toDate:now options:0];
    
    if ([createDate isThisYear]) { // 今年
        if ([createDate isYesterday]) { // 昨天
            fmt.dateFormat = @"昨天 HH:mm";
            return [fmt stringFromDate:createDate];
        } else if ([createDate isToday]) { // 今天
            if (cmps.hour >= 1) {
                return [NSString stringWithFormat:@"%d小时前", (int)cmps.hour];
            } else if (cmps.minute >= 1) {
                return [NSString stringWithFormat:@"%d分钟前", (int)cmps.minute];
            } else {
                return @"刚刚";
            }
        } else { // 今年的其他日子
            fmt.dateFormat = @"MM-dd HH:mm";
            return [fmt stringFromDate:createDate];
        }
    } else { // 非今年
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        return [fmt stringFromDate:createDate];
    }
}

// source == <a href="http://app.weibo.com/t/feed/2llosp" rel="nofollow">OPPO_N1mini</a>
- (void)setSource:(NSString *)source
{
    // 正则表达式 NSRegularExpression
    // 截串 NSString
    NSRange range;
    range.location = [source rangeOfString:@">"].location + 1;
    range.length = [source rangeOfString:@"</"].location - range.location;
    _source = [NSString stringWithFormat:@"来自%@", [source substringWithRange:range]];
}
@end
