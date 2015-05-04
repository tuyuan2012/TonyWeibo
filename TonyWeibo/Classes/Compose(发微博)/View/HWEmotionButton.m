//
//  HWEmotionButton.m
//  黑马微博2期
//
//  Created by apple on 14-10-23.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HWEmotionButton.h"
#import "HWEmotion.h"

@implementation HWEmotionButton

/**
 *  当控件不是从xib、storyboard中创建时，就会调用这个方法
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        HWLog(@"initWithFrame");
        [self setup];
    }
    return self;
}

/**
 *  当控件是从xib、storyboard中创建时，就会调用这个方法
 */
- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder]) {
        HWLog(@"initWithCoder");
        [self setup];
    }
    return self;
}

//- (void)setHighlighted:(BOOL)highlighted {
//    
//}

/**
 *  初始化代码
 */
- (void)setup
{
    self.titleLabel.font = [UIFont systemFontOfSize:32];
    
    // 按钮高亮的时候。不要去调整图片（不要调整图片会灰色）
    self.adjustsImageWhenHighlighted = NO;
//    self.adjustsImageWhenDisabled
}

/**
 *  这个方法在initWithCoder:方法后调用
 */
- (void)awakeFromNib
{
    HWLog(@"awakeFromNib");
}

- (void)setEmotion:(HWEmotion *)emotion
{
    _emotion = emotion;
    
    if (emotion.png) { // 有图片
        [self setImage:[UIImage imageNamed:emotion.png] forState:UIControlStateNormal];
    } else if (emotion.code) { // 是emoji表情，就是文字，设置其大小，就是设置字体大小（对应图片的尺寸，如64*64@2x.png，字体大小此时就是32）！
        // 设置emoji
        [self setTitle:emotion.code.emoji forState:UIControlStateNormal];
    }
}
@end
