//
//  HWEmotionKeyboard.m
//  黑马微博2期
//
//  Created by apple on 14-10-22.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HWEmotionKeyboard.h"
#import "HWEmotionListView.h"
#import "HWEmotionTabBar.h"
#import "HWEmotion.h"
#import "HWEmotionTool.h"

@interface HWEmotionKeyboard() <HWEmotionTabBarDelegate>
/** 容纳表情内容的控件，保存正在显示listView */
@property (nonatomic, weak) HWEmotionListView *showingListView;
/** 表情内容：建了四个控件，控件是不耗内存的，关键是图片！
    用到谁，创建谁！懒加载！（用到时创建，永远只创建一次）它们可能会被从试图上移走，但还要保命！
    所以用strong*/
@property (nonatomic, strong) HWEmotionListView *recentListView;
@property (nonatomic, strong) HWEmotionListView *defaultListView;
@property (nonatomic, strong) HWEmotionListView *emojiListView;
@property (nonatomic, strong) HWEmotionListView *lxhListView;
/** tabbar */
@property (nonatomic, weak) HWEmotionTabBar *tabBar;
@end

@implementation HWEmotionKeyboard

#pragma mark - 懒加载
- (HWEmotionListView *)recentListView
{
    if (!_recentListView) {
        self.recentListView = [[HWEmotionListView alloc] init];
        // 加载沙盒中的数据
        self.recentListView.emotions = [HWEmotionTool recentEmotions];
    }
    return _recentListView;
}

- (HWEmotionListView *)defaultListView
{
    if (!_defaultListView) {
        self.defaultListView = [[HWEmotionListView alloc] init];
        self.defaultListView.emotions = [HWEmotionTool defaultEmotions];
    }
    return _defaultListView;
}

- (HWEmotionListView *)emojiListView
{
    if (!_emojiListView) {
        self.emojiListView = [[HWEmotionListView alloc] init];
        self.emojiListView.emotions = [HWEmotionTool emojiEmotions];
    }
    return _emojiListView;
}

- (HWEmotionListView *)lxhListView
{
    if (!_lxhListView) {
        self.lxhListView = [[HWEmotionListView alloc] init];
        self.lxhListView.emotions = [HWEmotionTool lxhEmotions];
    }
    return _lxhListView;
}

#pragma mark - 初始化
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // tabbar
        HWEmotionTabBar *tabBar = [[HWEmotionTabBar alloc] init];
        tabBar.delegate = self;
        [self addSubview:tabBar];
        self.tabBar = tabBar;
        
        // 表情选中的通知
        [HWNotificationCenter addObserver:self selector:@selector(emotionDidSelect) name:HWEmotionDidSelectNotification object:nil];
    }
    return self;
}

- (void)emotionDidSelect
{
    self.recentListView.emotions = [HWEmotionTool recentEmotions];
}

- (void)dealloc
{
    [HWNotificationCenter removeObserver:self];
}

/**子控件的位置和大小在该方法中设置*/
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 1.tabbar
    self.tabBar.width = self.width;
    self.tabBar.height = 37;
    self.tabBar.x = 0;
    self.tabBar.y = self.height - self.tabBar.height;
    
    // 2.表情内容
    self.showingListView.x = self.showingListView.y = 0;
    self.showingListView.width = self.width;
    self.showingListView.height = self.tabBar.y;
}

#pragma mark - HWEmotionTabBarDelegate
- (void)emotionTabBar:(HWEmotionTabBar *)tabBar didSelectButton:(HWEmotionTabBarButtonType)buttonType
{
    // 移除正在显示的listView控件（用到哪个就显示哪个！）
    [self.showingListView removeFromSuperview];
    // 移除contentView（contentView：为了方便删东西和算尺寸）之前显示的控件
    // [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 根据按钮类型，切换键盘上面的listview
    switch (buttonType) {
        case HWEmotionTabBarButtonTypeRecent: { // 最近
            // 加载沙盒中的数据
//            self.recentListView.emotions = [HWEmotionTool recentEmotions];
            [self addSubview:self.recentListView];
            break;
        }
            
        case HWEmotionTabBarButtonTypeDefault: { // 默认
            [self addSubview:self.defaultListView];
            break;
        }
            
        case HWEmotionTabBarButtonTypeEmoji: { // Emoji
            [self addSubview:self.emojiListView];
            break;
        }
            
        case HWEmotionTabBarButtonTypeLxh: { // Lxh
            [self addSubview:self.lxhListView];
            break;
        }
    }
    
    // 设置正在显示的listView
    self.showingListView = [self.subviews lastObject];
    
    // 重新计算子控件的frame（算控件是很快的），你每点一下就调用一次，不要认为很占内存哈，图片才是内存的最大杀手！设置frame
    //setNeedsLayout内部会在恰当的时刻，重新调用layoutSubviews，重新布局子控件！
    [self setNeedsLayout];//直接调用[self layoutSubviews]是无效的，这个方法是系统来管理调用的！RunLoop
}

@end
