//
//  HWSpecial.m
//  黑马微博2期
//
//  Created by apple on 14/11/15.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HWSpecial.h"

@implementation HWSpecial
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ - %@", self.text, NSStringFromRange(self.range)];
}
@end
