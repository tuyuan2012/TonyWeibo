//
//  HWStatusCell.m
//  黑马微博2期
//
//  Created by apple on 14-10-14.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HWStatusCell.h"
#import "HWStatus.h"
#import "HWUser.h"
#import "HWStatusFrame.h"
#import "HWPhoto.h"
#import "UIImageView+WebCache.h"
#import "HWStatusToolbar.h"
#import "HWStatusPhotosView.h"
#import "HWIconView.h"
#import "HWStatusTextView.h"

@interface HWStatusCell()
/* 原创微博 */
/** 原创微博整体 */
@property (nonatomic, weak) UIView *originalView;
/** 头像 */
@property (nonatomic, weak) HWIconView *iconView;
/** 会员图标 */
@property (nonatomic, weak) UIImageView *vipView;
/** 配图 */
@property (nonatomic, weak) HWStatusPhotosView *photosView;
/** 昵称 */
@property (nonatomic, weak) UILabel *nameLabel;
/** 时间 */
@property (nonatomic, weak) UILabel *timeLabel;
/** 来源 */
@property (nonatomic, weak) UILabel *sourceLabel;
/** 正文 */
@property (nonatomic, weak) HWStatusTextView *contentLabel;

/* 转发微博 */
/** 转发微博整体 */
@property (nonatomic, weak) UIView *retweetView;
/** 转发微博正文 + 昵称 */
@property (nonatomic, weak) HWStatusTextView *retweetContentLabel;
/** 转发配图 */
@property (nonatomic, weak) HWStatusPhotosView *retweetPhotosView;

/** 工具条 */
@property (nonatomic, weak) HWStatusToolbar *toolbar;

@end

@implementation HWStatusCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"status";
    HWStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[HWStatusCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    return cell;
}

/**
 *  cell的初始化方法，一个cell只会调用一次
 *  一般在这里添加所有可能显示的子控件，以及子控件的一次性设置
 */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        // 点击cell的时候不要变色
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 设置选中时的背景为蓝色
//        UIView *bg = [[UIView alloc] init];
//        bg.backgroundColor = [UIColor blueColor];
//        self.selectedBackgroundView = bg;
        
        // 这个做法不行
//        self.selectedBackgroundView.backgroundColor = [UIColor blueColor];
        
        // 初始化原创微博
        [self setupOriginal];
        
        // 初始化转发微博
        [self setupRetweet];
        
        // 初始化工具条
        [self setupToolbar];
    }
    return self;
}

//- (void)setFrame:(CGRect)frame
//{
//    frame.origin.y += HWStatusCellMargin;
//    [super setFrame:frame];
//}

/**
 * 初始化工具条
 */
- (void)setupToolbar
{
    HWStatusToolbar *toolbar = [HWStatusToolbar toolbar];
    [self.contentView addSubview:toolbar];
    self.toolbar = toolbar;
}

/**
 * 初始化转发微博
 */
- (void)setupRetweet
{
    /** 转发微博整体 */
    UIView *retweetView = [[UIView alloc] init];
    retweetView.backgroundColor = HWColor(247, 247, 247);
    [self.contentView addSubview:retweetView];
    self.retweetView = retweetView;
    
    /** 转发微博正文 + 昵称 */
    HWStatusTextView *retweetContentLabel = [[HWStatusTextView alloc] init];
    [retweetView addSubview:retweetContentLabel];
    self.retweetContentLabel = retweetContentLabel;
    
    /** 转发微博配图 */
    HWStatusPhotosView *retweetPhotosView = [[HWStatusPhotosView alloc] init];
    [retweetView addSubview:retweetPhotosView];
    self.retweetPhotosView = retweetPhotosView;
}

/**
 * 初始化原创微博
 */
- (void)setupOriginal
{
    /** 原创微博整体 */
    UIView *originalView = [[UIView alloc] init];
    originalView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:originalView];
    self.originalView = originalView;
    
    /** 头像 */
    HWIconView *iconView = [[HWIconView alloc] init];
    [originalView addSubview:iconView];
    self.iconView = iconView;
    
    /** 会员图标 */
    UIImageView *vipView = [[UIImageView alloc] init];
    vipView.contentMode = UIViewContentModeCenter;
    [originalView addSubview:vipView];
    self.vipView = vipView;
    
    /** 配图 */
    HWStatusPhotosView *photosView = [[HWStatusPhotosView alloc] init];
    [originalView addSubview:photosView];
    self.photosView = photosView;
    
    /** 昵称 */
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = HWStatusCellNameFont;
    [originalView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    /** 时间 */
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.font = HWStatusCellTimeFont;
    timeLabel.textColor = [UIColor orangeColor];
    [originalView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    /** 来源 */
    UILabel *sourceLabel = [[UILabel alloc] init];
    sourceLabel.font = HWStatusCellSourceFont;
    [originalView addSubview:sourceLabel];
    self.sourceLabel = sourceLabel;
    
    /** 正文 */
    HWStatusTextView *contentLabel = [[HWStatusTextView alloc] init];
    [originalView addSubview:contentLabel];
    self.contentLabel = contentLabel;
}

- (void)setStatusFrame:(HWStatusFrame *)statusFrame
{
    _statusFrame = statusFrame;
    
    HWStatus *status = statusFrame.status;
    HWUser *user = status.user;
    
    /** 原创微博整体 */
    self.originalView.frame = statusFrame.originalViewF;
    
    /** 头像 */
    self.iconView.frame = statusFrame.iconViewF;
    self.iconView.user = user;
    
    /** 会员图标 */
    if (user.isVip) {
        self.vipView.hidden = NO;
        
        self.vipView.frame = statusFrame.vipViewF;
        NSString *vipName = [NSString stringWithFormat:@"common_icon_membership_level%d", user.mbrank];
        self.vipView.image = [UIImage imageNamed:vipName];
        
        self.nameLabel.textColor = [UIColor orangeColor];
    } else {
        self.nameLabel.textColor = [UIColor blackColor];
        self.vipView.hidden = YES;
    }
    
    /** 配图 */
    if (status.pic_urls.count) {
        self.photosView.frame = statusFrame.photosViewF;
        self.photosView.photos = status.pic_urls;
        self.photosView.hidden = NO;
    } else {
        self.photosView.hidden = YES;
    }
    
    /** 昵称 */
    self.nameLabel.text = user.name;
    self.nameLabel.frame = statusFrame.nameLabelF;
    
    /** 时间 */
    NSString *time = status.created_at;
    CGFloat timeX = statusFrame.nameLabelF.origin.x;
    CGFloat timeY = CGRectGetMaxY(statusFrame.nameLabelF) + HWStatusCellBorderW;
    CGSize timeSize = [time sizeWithFont:HWStatusCellTimeFont];
    self.timeLabel.frame = (CGRect){{timeX, timeY}, timeSize};
    self.timeLabel.text = time;
    
    /** 来源 */
    CGFloat sourceX = CGRectGetMaxX(self.timeLabel.frame) + HWStatusCellBorderW;
    CGFloat sourceY = timeY;
    CGSize sourceSize = [status.source sizeWithFont:HWStatusCellSourceFont];
    self.sourceLabel.frame = (CGRect){{sourceX, sourceY}, sourceSize};
    self.sourceLabel.text = status.source;
    
    /** 正文 */
    self.contentLabel.attributedText = status.attributedText;
    self.contentLabel.frame = statusFrame.contentLabelF;
    
    /** 被转发的微博 */
    if (status.retweeted_status) {
        HWStatus *retweeted_status = status.retweeted_status;
        
        self.retweetView.hidden = NO;
        /** 被转发的微博整体 */
        self.retweetView.frame = statusFrame.retweetViewF;
        
        /** 被转发的微博正文 */
        self.retweetContentLabel.attributedText = status.retweetedAttributedText;
        self.retweetContentLabel.frame = statusFrame.retweetContentLabelF;
        
        /** 被转发的微博配图 */
        if (retweeted_status.pic_urls.count) {
            self.retweetPhotosView.frame = statusFrame.retweetPhotosViewF;
            self.retweetPhotosView.photos = retweeted_status.pic_urls;
            self.retweetPhotosView.hidden = NO;
        } else {
            self.retweetPhotosView.hidden = YES;
        }
    } else {
        self.retweetView.hidden = YES;
    }
    
    /** 工具条 */
    self.toolbar.frame = statusFrame.toolbarF;
    self.toolbar.status = status;
}

@end
