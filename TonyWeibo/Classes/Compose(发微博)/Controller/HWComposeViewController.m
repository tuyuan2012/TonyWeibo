//
//  HWComposeViewController.m
//  黑马微博2期
//
//  Created by apple on 14-10-20.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HWComposeViewController.h"
#import "HWAccountTool.h"
#import "HWEmotionTextView.h"
#import "MBProgressHUD+MJ.h"
#import "AFNetworking.h"
#import "HWComposeToolbar.h"
#import "HWComposePhotosView.h"
#import "HWEmotionKeyboard.h"
#import "HWEmotion.h"

@interface HWComposeViewController () <UITextViewDelegate, HWComposeToolbarDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
/** 输入控件 */
@property (nonatomic, weak) HWEmotionTextView *textView;
/** 键盘顶部的工具条 */
@property (nonatomic, weak) HWComposeToolbar *toolbar;
/** 相册（存放拍照或者相册中选择的图片） */
@property (nonatomic, weak) HWComposePhotosView *photosView;
#warning 一定要用strong，保住它的命：当没有任何指针指向它的时候，它依然还活着！
/** 表情键盘，所有的UI控件你都用强指针，也是没问题的，只是你能用弱指针，就用弱指针，因为弱指针有时比较安全
    但此时的键盘，我们需要保住它的命，所有用强指针strong！*/
@property (nonatomic, strong) HWEmotionKeyboard *emotionKeyboard;
/** 是否正在切换键盘 */
@property (nonatomic, assign) BOOL switchingKeybaord;
@end

@implementation HWComposeViewController
#pragma mark - 懒加载
- (HWEmotionKeyboard *)emotionKeyboard
{
    if (!_emotionKeyboard) {/**键盘只创建一次*/
        self.emotionKeyboard = [[HWEmotionKeyboard alloc] init];
        // 键盘的宽度
        self.emotionKeyboard.width = self.view.width;
        self.emotionKeyboard.height = 216;
        
        /** 如下写是有问题的：此时当，inputView一旦清空为nil，那么emotionKeyboard就挂了！所以这个键盘一定要用strong强指针！
         HWEmotionKeyboard *emotionKeyboard = [[HWEmotionKeyboard alloc] init];
         emotionKeyboard.width = self.view.width;
         emotionKeyboard.height = 216.0f;
         self.textView.inputView = emotionKeyboard;
         */
    }
    return _emotionKeyboard;
}

#pragma mark - 系统方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 设置导航栏内容
    [self setupNav];
    
    // 添加输入控件
    [self setupTextView];
    
    // 添加工具条
    [self setupToolbar];
    
    // 添加相册
    [self setupPhotosView];
    
//    self.automaticallyAdjustsScrollViewInsets
    //默认为YES，当scrollView（继承scrollView也可以）遇到UINavigationBar、UITabBar等控件的时候（无论scrollView是否被它们挡住的时候，都会自动设置；只看你这个scrollView所在的viewController的控制器是否被导航控制器包住），默认会设置scrollView的contentInset：64、49
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // 成为第一响应者（能输入文本的控件一旦成为第一响应者，就会叫出相应的键盘）
    [self.textView becomeFirstResponder];
}

- (void)dealloc
{
    [HWNotificationCenter removeObserver:self];
}

#pragma mark - 初始化方法
/**
 * 添加相册
 */
- (void)setupPhotosView
{
    HWComposePhotosView *photosView = [[HWComposePhotosView alloc] init];
    photosView.y = 100;
    photosView.width = self.view.width;
    // 随便写的
    photosView.height = self.view.height;
    [self.textView addSubview:photosView];
    self.photosView = photosView;
}
/**
 * 添加工具条：放在键盘上面
 */
- (void)setupToolbar
{
    HWComposeToolbar *toolbar = [[HWComposeToolbar alloc] init];
    toolbar.width = self.view.width;
    toolbar.height = 44;
    toolbar.y = self.view.height - toolbar.height;
    toolbar.delegate = self;
    [self.view addSubview:toolbar];
    self.toolbar = toolbar;
}

/**
 * 设置导航栏内容
 */
- (void)setupNav
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(send)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSString *name = [HWAccountTool account].name;
    NSString *prefix = @"发微博";
    if (name) {
        UILabel *titleView = [[UILabel alloc] init];
        titleView.width = 200;
        titleView.height = 100;
        titleView.textAlignment = NSTextAlignmentCenter;
        // 自动换行
        titleView.numberOfLines = 0;
        titleView.y = 50;
        
        NSString *str = [NSString stringWithFormat:@"%@\n%@", prefix, name];
        
        // 创建一个带有属性的字符串（比如颜色属性、字体属性等文字属性）
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
        // 添加属性
        [attrStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:[str rangeOfString:prefix]];
        [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:[str rangeOfString:name]];
        titleView.attributedText = attrStr;
        self.navigationItem.titleView = titleView;
    } else {
        self.title = prefix;
    }
}

/**
 * 添加输入控件
 */
- (void)setupTextView
{
    // 在这个控制器中，textView的contentInset.top默认会等于64（当TextView发现它所处的控制器有导航栏的时候，此时的top才会为64；这个是系统搞的）
    HWEmotionTextView *textView = [[HWEmotionTextView alloc] init];
    // 垂直方向上永远可以拖拽（有弹簧效果）
    textView.alwaysBounceVertical = YES;
    textView.frame = self.view.bounds;
    textView.font = [UIFont systemFontOfSize:15];
    textView.delegate = self;
    textView.placeholder = @"分享新鲜事...";
    [self.view addSubview:textView];
    self.textView = textView;
    
    // 文字改变的通知
    [HWNotificationCenter addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:textView];
    
    // 键盘通知
    // 键盘的frame发生改变时发出的通知（位置和尺寸）
    [HWNotificationCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    // 表情选中的通知
    [HWNotificationCenter addObserver:self selector:@selector(emotionDidSelect:) name:HWEmotionDidSelectNotification object:nil];
    
    // 删除文字的通知
    [HWNotificationCenter addObserver:self selector:@selector(emotionDidDelete) name:HWEmotionDidDeleteNotification object:nil];
}

#pragma mark - 监听方法
/**
 *  删除文字
 */
- (void)emotionDidDelete
{
    [self.textView deleteBackward];
}

/**
 *  表情被选中了
 */
- (void)emotionDidSelect:(NSNotification *)notification
{
    HWEmotion *emotion = notification.userInfo[HWSelectEmotionKey];
    [self.textView insertEmotion:emotion];
}

/**
 * 键盘的frame发生改变时调用（显示、隐藏等）
 */
- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    /**
     notification.userInfo = @{
     // 键盘弹出\隐藏后的frame
     UIKeyboardFrameEndUserInfoKey = NSRect: {{0, 352}, {320, 216}},
     // 键盘弹出\隐藏所耗费的时间
     UIKeyboardAnimationDurationUserInfoKey = 0.25,
     // 键盘弹出\隐藏动画的执行节奏（先快后慢，匀速）
     UIKeyboardAnimationCurveUserInfoKey = 7
     }
     */
    
    // 如果正在切换键盘，就不要执行后面的代码
    if (self.switchingKeybaord) return;
    
    NSDictionary *userInfo = notification.userInfo;
    // 动画的持续时间
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 键盘的frame
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 执行动画
    [UIView animateWithDuration:duration animations:^{
        // 工具条的Y值 == 键盘的Y值 - 工具条的高度
        if (keyboardF.origin.y > self.view.height) { // 键盘的Y值已经远远超过了控制器view的高度
            self.toolbar.y = self.view.height - self.toolbar.height;
        } else {
            self.toolbar.y = keyboardF.origin.y - self.toolbar.height;
        }
    }];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)send {
    if (self.photosView.photos.count) {
        [self sendWithImage];
    } else {
        [self sendWithoutImage];
    }
    // dismiss
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 * 发布带有图片的微博
 */
- (void)sendWithImage
{
    // URL: https://upload.api.weibo.com/2/statuses/upload.json
    // 参数:
    /**	status true string 要发布的微博文本内容，必须做URLencode，内容不超过140个汉字。*/
    /**	access_token true string*/
    /**	pic true binary 微博的配图。*/
    
    // 1.请求管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    
    // 2.拼接请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = [HWAccountTool account].access_token;
    params[@"status"] = self.textView.fullText;
    
    // 3.发送请求
    [mgr POST:@"https://upload.api.weibo.com/2/statuses/upload.json" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // 拼接文件数据
        UIImage *image = [self.photosView.photos firstObject];
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        [formData appendPartWithFileData:data name:@"pic" fileName:@"test.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        [MBProgressHUD showSuccess:@"发送成功"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD showError:@"发送失败"];
    }];
}

/**
 * 发布没有图片的微博
 */
- (void)sendWithoutImage
{
    // URL: https://api.weibo.com/2/statuses/update.json
    // 参数:
    /**	status true string 要发布的微博文本内容，必须做URLencode，内容不超过140个汉字。*/
    /**	access_token true string*/
    // 1.请求管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    
    // 2.拼接请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = [HWAccountTool account].access_token;
    params[@"status"] = self.textView.fullText;
    
    // 3.发送请求
    [mgr POST:@"https://api.weibo.com/2/statuses/update.json" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        [MBProgressHUD showSuccess:@"发送成功"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD showError:@"发送失败"];
    }];
}

/**
 * 监听文字改变
 */
- (void)textDidChange
{
    self.navigationItem.rightBarButtonItem.enabled = self.textView.hasText;
}

#pragma mark - UITextViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    /**键盘退下去*/
    [self.view endEditing:YES];
}

#pragma mark - HWComposeToolbarDelegate
- (void)composeToolbar:(HWComposeToolbar *)toolbar didClickButton:(HWComposeToolbarButtonType)buttonType
{
    switch (buttonType) {
        case HWComposeToolbarButtonTypeCamera: // 拍照
            [self openCamera];
            break;
            
        case HWComposeToolbarButtonTypePicture: // 相册
            [self openAlbum];
            break;
            
        case HWComposeToolbarButtonTypeMention: // @
            HWLog(@"--- @");
            break;
            
        case HWComposeToolbarButtonTypeTrend: // #
            HWLog(@"--- #");
            break;
            
        case HWComposeToolbarButtonTypeEmotion: // 表情\键盘
            [self switchKeyboard];//切换键盘
            break;
    }
}

#pragma mark - 其他方法
/**
 *  切换键盘
 */
- (void)switchKeyboard
{
    // self.textView.inputView == nil ;//此时说明使用的是系统自带的键盘
    if (self.textView.inputView == nil) { // 切换为自定义的表情键盘
        self.textView.inputView = self.emotionKeyboard;
        
        // 显示键盘按钮
        self.toolbar.showKeyboardButton = YES;
    } else { // 切换为系统自带的键盘
        self.textView.inputView = nil;
        
        // 显示表情按钮
        self.toolbar.showKeyboardButton = NO;
    }
    
    // 开始切换键盘
    self.switchingKeybaord = YES;
    
    // 退出键盘
    [self.textView endEditing:YES];
//    [self.view endEditing:YES];
//    [self.view.window endEditing:YES];
//    [self.textView resignFirstResponder];
    
    // 结束切换键盘
    self.switchingKeybaord = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 弹出键盘
        [self.textView becomeFirstResponder];
    });
}

- (void)openCamera
{
    [self openImagePickerController:UIImagePickerControllerSourceTypeCamera];
}

- (void)openAlbum
{
    // 如果想自己写一个图片选择控制器，得利用AssetsLibrary.framework，利用这个框架可以获得手机上的所有相册图片
    // UIImagePickerControllerSourceTypePhotoLibrary > UIImagePickerControllerSourceTypeSavedPhotosAlbum
    [self openImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)openImagePickerController:(UIImagePickerControllerSourceType)type
{
    if (![UIImagePickerController isSourceTypeAvailable:type]) return;
    
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = type;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
/**
 * 从UIImagePickerController选择完图片后就调用（拍照完毕或者选择相册图片完毕）
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // info中就包含了选择的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // 添加图片到photosView中
    [self.photosView addPhoto:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
}

@end