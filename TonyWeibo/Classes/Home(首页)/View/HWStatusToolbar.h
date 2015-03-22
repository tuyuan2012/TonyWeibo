//
//  HWStatusToolbar.h
//  黑马微博2期
//
//  Created by apple on 14-10-16.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HWStatus;
@interface HWStatusToolbar : UIView
+ (instancetype)toolbar;
@property (nonatomic, strong) HWStatus *status;
@end
