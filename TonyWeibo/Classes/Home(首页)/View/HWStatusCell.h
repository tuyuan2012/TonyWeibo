//
//  HWStatusCell.h
//  黑马微博2期
//
//  Created by apple on 14-10-14.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HWStatusFrame;

@interface HWStatusCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) HWStatusFrame *statusFrame;
@end
