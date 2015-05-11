//
//  HWEmotionTool.m
//  黑马微博2期
//
//  Created by apple on 14-10-23.
//  Copyright (c) 2014年 heima. All rights reserved.
//

// 最近表情的存储路径
#define HWRecentEmotionsPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"emotions.archive"]

#import "HWEmotionTool.h"
#import "HWEmotion.h"
#import "MJExtension.h"

@implementation HWEmotionTool

static NSMutableArray *_recentEmotions;
/**
    static 全局的，可以改的，如果在一个类中声明static，类中其他地方用到的时候，也是使用的改变量。和java类似，但不能用类名直接访问。
 */
/**
    类方法不能访问成员变量
 */

/**
    initialize该方法只调一次
 */
+ (void)initialize
{
    //得遵守NSCoding协议
    _recentEmotions = [NSKeyedUnarchiver unarchiveObjectWithFile:HWRecentEmotionsPath];
    if (_recentEmotions == nil) {
        _recentEmotions = [NSMutableArray array];
    }
}

+ (HWEmotion *)emotionWithChs:(NSString *)chs
{
    NSArray *defaults = [self defaultEmotions];
    for (HWEmotion *emotion in defaults) {
        if ([emotion.chs isEqualToString:chs]) return emotion;
    }
    
    NSArray *lxhs = [self lxhEmotions];
    for (HWEmotion *emotion in lxhs) {
        if ([emotion.chs isEqualToString:chs]) return emotion;
    }
    
    return nil;
}

+ (void)addRecentEmotion:(HWEmotion *)emotion
{
    // 删除重复的表情
    [_recentEmotions removeObject:emotion];
    
    // 将表情放到数组的最前面
    [_recentEmotions insertObject:emotion atIndex:0];
    
    // 将所有的表情数据写入沙盒：得遵守NSCoding协议
    [NSKeyedArchiver archiveRootObject:_recentEmotions toFile:HWRecentEmotionsPath];
}

/**
 *  返回装着HWEmotion模型的数组
 */
+ (NSArray *)recentEmotions
{
    return _recentEmotions;
}

static NSArray *_emojiEmotions, *_defaultEmotions, *_lxhEmotions;
+ (NSArray *)emojiEmotions
{
    if (!_emojiEmotions) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EmotionIcons/emoji/info.plist" ofType:nil];
        _emojiEmotions = [HWEmotion objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:path]];
    }
    return _emojiEmotions;
}

+ (NSArray *)defaultEmotions
{
    if (!_defaultEmotions) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EmotionIcons/default/info.plist" ofType:nil];
        _defaultEmotions = [HWEmotion objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:path]];
    }
    return _defaultEmotions;
}

+ (NSArray *)lxhEmotions
{
    if (!_lxhEmotions) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EmotionIcons/lxh/info.plist" ofType:nil];
        _lxhEmotions = [HWEmotion objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:path]];
    }
    return _lxhEmotions;
}
@end
