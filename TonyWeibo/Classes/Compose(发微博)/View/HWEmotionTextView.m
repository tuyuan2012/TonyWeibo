//
//  HWEmotionTextView.m
//  黑马微博2期
//
//  Created by apple on 14-10-23.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HWEmotionTextView.h"
#import "HWEmotion.h"
#import "HWEmotionAttachment.h"

@implementation HWEmotionTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)insertEmotion:(HWEmotion *)emotion
{
    if (emotion.code) {
        // insertText : 将文字插入到光标所在的位置
        [self insertText:emotion.code.emoji];
    } else if (emotion.png) {
        // 加载图片
        HWEmotionAttachment *attch = [[HWEmotionAttachment alloc] init];

        // 传递模型
        attch.emotion = emotion;
        
        // 设置图片的尺寸
        CGFloat attchWH = self.font.lineHeight;
        attch.bounds = CGRectMake(0, -4, attchWH, attchWH);
        
        // 根据附件创建一个属性文字
        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:attch];
        
        // 插入属性文字到光标位置
        [self insertAttributedText:imageStr settingBlock:^(NSMutableAttributedString *attributedText) {
            // 设置字体
            [attributedText addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, attributedText.length)];
        }];
    }
}

/**把文字、emoj、图片拼接成一个完整的字符串：发送消息使用*/
- (NSString *)fullText
{
    NSMutableString *fullText = [NSMutableString string];
    HWLog(@"%@",self.attributedText);
    // 遍历所有的属性文字（图片、emoji、普通文字）
    [self.attributedText enumerateAttributesInRange:NSMakeRange(0, self.attributedText.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        //将一些内容打印出来，进行研究：学习的好方法啊！
        HWLog(@"%@  %@",attrs,NSStringFromRange(range));
        
        // 如果是图片表情
        HWEmotionAttachment *attch = attrs[@"NSAttachment"];
        if (attch) { // 图片：拼接上图片对应的文字
            [fullText appendString:attch.emotion.chs];
        } else { // emoji、普通文本
            // 获得这个范围内的文字
            NSAttributedString *str = [self.attributedText attributedSubstringFromRange:range];//分段截取每一段内容，如果是表情图片，则将其转成相应的文字
            [fullText appendString:str.string];
        }
    }];
    
    return fullText;
}

/**
 selectedRange :
     1.本来是用来控制textView的文字选中范围
     2.如果selectedRange.length为0，selectedRange.location就是textView的光标位置
     
     关于textView文字的字体
     1.如果是普通文字（text），文字大小由textView.font控制
     2.如果是属性文字（attributedText），文字大小不受textView.font控制，应该利用NSMutableAttributedString的- (void)addAttribute:(NSString *)name value:(id)value range:(NSRange)range;方法设置字体
 **/

/**
 UITextField:
     1.文字永远是一行，不能显示多行文字
     2.有placehoder属性设置占位文字
     3.继承自UIControl
     4.监听行为
     1> 设置代理
     2> addTarget:action:forControlEvents:
     3> 通知:UITextFieldTextDidChangeNotification
     
     UITextView:
     1.能显示任意行文字
     2.不能设置占位文字
     3.继承自UIScollView
     4.监听行为
     1> 设置代理
     2> 通知:UITextViewTextDidChangeNotification
 */
@end
