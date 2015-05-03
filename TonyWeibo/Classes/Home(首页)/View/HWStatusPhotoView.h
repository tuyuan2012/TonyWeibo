//
//  HWStatusPhotoView.h
//  黑马微博2期
//
//  Created by apple on 14-10-18.
//  Copyright (c) 2014年 heima. All rights reserved.
//  一张配图

#import <UIKit/UIKit.h>
@class HWPhoto;
/**继承UIImageView*/
@interface HWStatusPhotoView : UIImageView
/**photo模型*/
@property (nonatomic, strong) HWPhoto *photo;
@end
