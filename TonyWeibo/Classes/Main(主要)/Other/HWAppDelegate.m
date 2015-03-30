//
//  HWAppDelegate.m
//  黑马微博2期
//
//  Created by apple on 14-10-7.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HWAppDelegate.h"
#import "HWOAuthViewController.h"
#import "HWAccountTool.h"
#import "SDWebImageManager.h"

@interface HWAppDelegate()
@property (nonatomic, assign) UIBackgroundTaskIdentifier task;
@end

@implementation HWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 1.创建窗口
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    
    // 2.设置根控制器
    HWAccount *account = [HWAccountTool account];
    if (account) { // 之前已经登录成功过
        [self.window switchRootViewController];
    } else {
        self.window.rootViewController = [[HWOAuthViewController alloc] init];
    }
    
    // 3.显示窗口
    [self.window makeKeyAndVisible];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

/**
 *  当app进入后台时调用
 */
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /**
     *  app的状态
     *  1.死亡状态：没有打开app
     *  2.前台运行状态
     *  3.后台暂停状态：停止一切动画、定时器、多媒体、联网操作，很难再作其他操作
     *  4.后台运行状态
     */
    // 向操作系统申请后台运行的资格，能维持多久，是不确定的
//    self.task = [application beginBackgroundTaskWithExpirationHandler:^{
//        // 当申请的后台运行时间已经结束（过期），就会调用这个block
//        
//        // 赶紧结束任务
//        [application endBackgroundTask:self.task];
//    }];
    __block UIBackgroundTaskIdentifier task = [application beginBackgroundTaskWithExpirationHandler:^{
        // 当申请的后台运行时间已经结束（过期），就会调用这个block

        // 赶紧结束任务
        [application endBackgroundTask:task];
    }];
    
    /**
    1.定义变量UIBackgroundTaskIdentifier task
    2.执行右边的代码
    [application beginBackgroundTaskWithExpirationHandler:^{
        // 当申请的后台运行时间已经结束（过期），就会调用这个block
        
        // 赶紧结束任务
        [application endBackgroundTask:task];
    }];
     3.将右边方法的返回值赋值给task
     */
    
    
    // 在Info.plst中设置后台模式：Required background modes == App plays audio or streams audio/video using AirPlay
    // 搞一个0kb的MP3文件，没有声音
    // 循环播放
    
    // 以前的后台模式只有3种
    // 保持网络连接
    // 多媒体应用
    // VOIP:网络电话
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - 成功程序内存警告
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    SDWebImageManager *mgr = [SDWebImageManager sharedManager];
    // 1.取消下载
    [mgr cancelAll];
    
    // 2.清除内存中的所有图片
    [mgr.imageCache clearMemory];
}
@end
