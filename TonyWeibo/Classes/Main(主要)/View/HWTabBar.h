//
//  HWTabBar.h
//  黑马微博2期
//
//  Created by apple on 14-10-8.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWTabBar;

#warning 因为HWTabBar继承自UITabBar，所以称为HWTabBar的代理，也必须实现UITabBar的代理协议
@protocol HWTabBarDelegate <UITabBarDelegate>
@optional
- (void)tabBarDidClickPlusButton:(HWTabBar *)tabBar;
@end

@interface HWTabBar : UITabBar
@property (nonatomic, weak) id<HWTabBarDelegate> delegate;

@end
