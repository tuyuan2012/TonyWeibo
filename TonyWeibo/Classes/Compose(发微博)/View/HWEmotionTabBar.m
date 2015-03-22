//
//  HWEmotionTabBar.m
//  黑马微博2期
//
//  Created by apple on 14-10-22.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HWEmotionTabBar.h"
#import "HWEmotionTabBarButton.h"

@interface HWEmotionTabBar()
@property (nonatomic, weak) HWEmotionTabBarButton *selectedBtn;
@end

@implementation HWEmotionTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBtn:@"最近" buttonType:HWEmotionTabBarButtonTypeRecent];
        [self setupBtn:@"默认" buttonType:HWEmotionTabBarButtonTypeDefault];
//        [self btnClick:[self setupBtn:@"默认" buttonType:HWEmotionTabBarButtonTypeDefault]];
        [self setupBtn:@"Emoji" buttonType:HWEmotionTabBarButtonTypeEmoji];
        [self setupBtn:@"浪小花" buttonType:HWEmotionTabBarButtonTypeLxh];
    }
    return self;
}

/**
 *  创建一个按钮
 *
 *  @param title 按钮文字
 */
- (HWEmotionTabBarButton *)setupBtn:(NSString *)title buttonType:(HWEmotionTabBarButtonType)buttonType
{
    // 创建按钮
    HWEmotionTabBarButton *btn = [[HWEmotionTabBarButton alloc] init];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
    btn.tag = buttonType;
    [btn setTitle:title forState:UIControlStateNormal];
    [self addSubview:btn];
    
    // 设置背景图片
    NSString *image = @"compose_emotion_table_mid_normal";
    NSString *selectImage = @"compose_emotion_table_mid_selected";
    if (self.subviews.count == 1) {
        image = @"compose_emotion_table_left_normal";
        selectImage = @"compose_emotion_table_left_selected";
    } else if (self.subviews.count == 4) {
        image = @"compose_emotion_table_right_normal";
        selectImage = @"compose_emotion_table_right_selected";
    }
    
    [btn setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:selectImage] forState:UIControlStateDisabled];
    
    return btn;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 设置按钮的frame
    NSUInteger btnCount = self.subviews.count;
    CGFloat btnW = self.width / btnCount;
    CGFloat btnH = self.height;
    for (int i = 0; i<btnCount; i++) {
        HWEmotionTabBarButton *btn = self.subviews[i];
        btn.y = 0;
        btn.width = btnW;
        btn.x = i * btnW;
        btn.height = btnH;
    }
}

- (void)setDelegate:(id<HWEmotionTabBarDelegate>)delegate
{
    _delegate = delegate;
    
    // 选中“默认”按钮
    [self btnClick:(HWEmotionTabBarButton *)[self viewWithTag:HWEmotionTabBarButtonTypeDefault]];
}

/**
 *  按钮点击
 */
- (void)btnClick:(HWEmotionTabBarButton *)btn
{
    self.selectedBtn.enabled = YES;
    btn.enabled = NO;
    self.selectedBtn = btn;
    
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(emotionTabBar:didSelectButton:)]) {
        [self.delegate emotionTabBar:self didSelectButton:btn.tag];
    }
}

@end
