//
//  HWTest2ViewController.m
//  黑马微博2期
//
//  Created by apple on 14-10-7.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HWTest2ViewController.h"
#import "HWTest3ViewController.h"

@interface HWTest2ViewController ()

@end

@implementation HWTest2ViewController
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    HWTest3ViewController *test3 = [[HWTest3ViewController alloc] init];
    test3.title = @"测试3控制器";
    [self.navigationController pushViewController:test3 animated:YES];
}
@end