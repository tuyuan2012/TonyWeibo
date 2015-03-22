//
//  HWStatusPhotosView.h
//  黑马微博2期
//
//  Created by apple on 14-10-18.
//  Copyright (c) 2014年 heima. All rights reserved.
//  cell上面的配图相册（里面会显示1~9张图片, 里面都是HWStatusPhotoView）

#import <UIKit/UIKit.h>

@interface HWStatusPhotosView : UIView
@property (nonatomic, strong) NSArray *photos;

/**
 *  根据图片个数计算相册的尺寸
 */
+ (CGSize)sizeWithCount:(NSUInteger)count;
@end
