//
//  HWUser.m
//  黑马微博2期
//
//  Created by apple on 14-10-12.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HWUser.h"

@implementation HWUser

- (void)setMbtype:(int)mbtype
{
    _mbtype = mbtype;
    
    self.vip = mbtype > 2;
}

//- (BOOL)isVip
//{
//    return self.mbrank > 2;
//}
@end
