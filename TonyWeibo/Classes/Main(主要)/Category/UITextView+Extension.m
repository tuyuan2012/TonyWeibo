//
//  UITextView+Extension.m
//  黑马微博2期
//
//  Created by apple on 14-10-23.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "UITextView+Extension.h"

@implementation UITextView (Extension)
- (void)insertAttributedText:(NSAttributedString *)text
{
    [self insertAttributedText:text settingBlock:nil];
}

/**
    你这个方法功能就是插文字，那么你就乖乖负责插入文字；不要改我文字本身的熟性！
 */
- (void)insertAttributedText:(NSAttributedString *)text settingBlock:(void (^)(NSMutableAttributedString *))settingBlock
{
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    // 拼接之前的文字（图片和普通文字）
    [attributedText appendAttributedString:self.attributedText];
    
    // 拼接其他文字
    NSUInteger loc = self.selectedRange.location;//光标的位置
//    [attributedText insertAttributedString:text atIndex:loc];
    [attributedText replaceCharactersInRange:self.selectedRange withAttributedString:text];
    
    // 调用外面传进来的代码：设置文本的属性
    if (settingBlock) {
        settingBlock(attributedText);
        /**相当调用了如下的代码：先定义一个block，然后再调用这个block
         ^(NSMutableAttributedString *attributedText) {
            // 设置字体
            [attributedText addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, attributedText.length)];
         }(attributedText);
         */
    }
    /**
        @property(nonatomic,copy) NSAttributedString *attributedText;
        copy属性
     */
    self.attributedText = attributedText;
    
    // 移动光标到表情的后面：设置光标的位置
    /**
        selectedRange：
        ·1、本来是用来控制textView的文字选中范围
        ·2、如果selectedRange.length为0，那么selectedRange.location就是textView的光标位置
     
     关于textView文字的字体
        ·1、如果是普通文字(text)，文字大小由textView.font控制
        ·2、如果是属性文字(attributedText)，文字的大小受textView.font控制，应该利用NSMutableAttributedString的- (void)addAttribute:(NSString *)name value:(id)value range:(NSRange)range;方法来设置字体
     */
    self.selectedRange = NSMakeRange(loc + 1, 0);
}
@end
