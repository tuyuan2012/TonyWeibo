//
//  HWSpecial.h
//  黑马微博2期
//
//  Created by apple on 14/11/15.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HWSpecial : NSObject
/** 这段特殊文字的内容 */
@property (nonatomic, copy) NSString *text;
/** 这段特殊文字的范围 */
@property (nonatomic, assign) NSRange range;
/** 这段特殊文字的矩形框(要求数组里面存放CGRect) */
@property (nonatomic, strong) NSArray *rects;
@end
