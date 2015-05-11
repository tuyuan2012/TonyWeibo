//
//  HWConst.m
//  黑马微博2期
//
//  Created by apple on 14-10-25.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
    宏和const（字符常亮、整型常量建议用它）的区别
 
 */
// 账号信息
NSString * const HWAppKey = @"1662641705";
NSString * const HWRedirectURI = @"http://www.baidu.com";
NSString * const HWAppSecret = @"054fe920073c6f4bb5953f8f966f1d72";

// 通知
// 表情选中的通知
NSString * const HWEmotionDidSelectNotification = @"HWEmotionDidSelectNotification";
NSString * const HWSelectEmotionKey = @"HWSelectEmotionKey";

// 删除文字的通知
NSString * const HWEmotionDidDeleteNotification = @"HWEmotionDidDeleteNotification";