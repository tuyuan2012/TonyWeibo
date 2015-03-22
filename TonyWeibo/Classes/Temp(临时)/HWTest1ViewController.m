//
//  HWTest1ViewController.m
//  黑马微博2期
//
//  Created by apple on 14-10-7.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HWTest1ViewController.h"
#import "HWTest2ViewController.h"

@interface HWTest1ViewController ()

@end

@implementation HWTest1ViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    HWTest2ViewController *test2 = [[HWTest2ViewController alloc] init];
    test2.title = @"测试2控制器";
    [self.navigationController pushViewController:test2 animated:YES];
}

@end
