//
//  HWTitleButton.m
//  黑马微博2期
//
//  Created by apple on 14-10-12.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HWTitleButton.h"

#define HWMargin 5

@implementation HWTitleButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [self setImage:[UIImage imageNamed:@"navigationbar_arrow_down"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"navigationbar_arrow_up"] forState:UIControlStateSelected];
    }
    return self;
}

// 目的：想在系统计算和设置完按钮的尺寸后，再修改一下尺寸
/**
 *  重写setFrame:方法的目的：拦截设置按钮尺寸的过程
 *  如果想在系统设置完控件的尺寸后，再做修改，而且要保证修改成功，一般都是在setFrame:中设置
 */
- (void)setFrame:(CGRect)frame
{
    frame.size.width += HWMargin;
    [super setFrame:frame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // 如果仅仅是调整按钮内部titleLabel和imageView的位置，那么在layoutSubviews中单独设置位置即可
    
    /**
     * 
        UIEdgeInsetsMake(<#CGFloat top#>, <#CGFloat left#>, <#CGFloat bottom#>, <#CGFloat right#>)
        该方法的参数只支持像素（你传点它是不会乘以屏幕伸缩比的），但iOS开发中那些获得的宽度和高度都是点坐标系
        UIImage *image = [UIImage imageName:@"pic"];
        CGFloat width = image.width;//这个width是坐标轴上的点坐标，比如13
        //但该图片在retina屏上是pic@2x.png，像素实际为26
        [UIScreen mainScreen].scale;//伸缩参数，可以通过该参数判断屏幕伸缩比例，判断是否为retina屏幕
     */
    // 1.计算titleLabel的frame
    self.titleLabel.x = self.imageView.x;
    
    // 2.计算imageView的frame
    self.imageView.x = CGRectGetMaxX(self.titleLabel.frame) + HWMargin;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];

    // 只要修改了文字，就让按钮重新计算自己的尺寸
    [self sizeToFit];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [super setImage:image forState:state];
    
    // 只要修改了图片，就让按钮重新计算自己的尺寸
    [self sizeToFit];
}
@end
