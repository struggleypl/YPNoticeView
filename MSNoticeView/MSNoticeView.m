//
//  MSNoticeView.m
//  TipsView
//
//  Created by ypl on 2018/12/28.
//  Copyright © 2018年 ypl. All rights reserved.
//

#import "MSNoticeView.h"
#import <Masonry.h>
#import "MSDefine.h"

#define IS_IPhoneX_All \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#define kWindowHeight ((IS_IPhoneX_All?44:20)+44)
#define kDuration 0.5
#define kTimerInterval 3.0
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kDefaultBgColor  [UIColor colorWithRed:76/255.0 green:136/255.0 blue:255/255.0 alpha:1/1.0]
#define kLabelMarginLeft WLTSize(50)
#define kLabelMarginTop ((IS_IPhoneX_All?44:20)+0)
#define kLabelHeight WLTSize(44)
#define kLabelTextSize WLTSize(16.0)

@implementation MSNoticeView

static UIWindow *_window;
static NSTimer *_timer;
static NoticeViewClickBlock _clickBlock;

+(void)showSuccess:(NSString *)msg detail:(NSString *)detailMsg  hudColor:(UIColor *)color clickBlock:(NoticeViewClickBlock)clickBlock {
    //设置window
    [self setupWindow:color autoHidden:YES];
    //设置标签
    [self setupLabel:msg detail:detailMsg isSuccess:YES];
    //设置按钮
    [self setupButtonUseBlock:clickBlock];
}

+(void)showError:(NSString *)msg detail:(NSString *)detailMsg  hudColor:(UIColor *)color clickBlock:(NoticeViewClickBlock)clickBlock {
    //设置window
    [self setupWindow:color autoHidden:YES];
    //设置标签
    [self setupLabel:msg detail:detailMsg isSuccess:NO];
    //设置按钮
    [self setupButtonUseBlock:clickBlock];
}

+(void)showMessage:(NSString *)msg detail:(NSString *)detailMsg action:(SEL) action target:(id)target{
    [self showMessage:msg detail:detailMsg action:action target:target hudColor:kDefaultBgColor];
}

+(void)showMessage:(NSString *)msg detail:(NSString *)detailMsg action:(SEL) action target:(id)target hudColor:(UIColor *)color{
    //设置window
    [self setupWindow:color autoHidden:YES];
    //设置标签
    [self setupLabel:msg detail:detailMsg isSuccess:YES];
    //设置按钮
    [self setupButton:action target:target];
}

+(void)showMessage:(NSString *)msg detail:(NSString *)detailMsg hudColor:(UIColor *)color clickBlock:(NoticeViewClickBlock)clickBlock{
    //设置window
    [self setupWindow:color autoHidden:YES];
    //设置标签
    [self setupLabel:msg detail:detailMsg isSuccess:YES];
    //设置按钮
    [self setupButtonUseBlock:clickBlock];
    
}

+(void)dismiss{
    [UIView animateWithDuration:kDuration animations:^{
        CGRect frame = _window.frame;
        frame.origin.y = -kWindowHeight;
        _window.frame = frame;
    } completion:^(BOOL finished) {
        _window = nil;
    }];
}

+ (void)setupWindow:(UIColor *)color autoHidden:(BOOL)autoHidden {
    //关闭定时器
    [_timer invalidate];
    CGFloat windowStartY = -kWindowHeight;
    CGRect frame = CGRectMake(0, windowStartY, [UIScreen mainScreen].bounds.size.width,kWindowHeight);
    //先隐藏之前的window
    _window.hidden = YES;
    //重新设置window
    _window = [[UIWindow alloc] init];
    _window.frame = frame;
    _window.windowLevel = UIWindowLevelStatusBar + 2;
    _window.backgroundColor = color;
    _window.hidden = NO;
    _window.userInteractionEnabled = YES;
    //给window设置一个动画
    frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,kWindowHeight);
    [UIView animateWithDuration:kDuration animations:^{
        _window.frame = frame;
    }];
    
    [self setCornerRadius:10 byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight inRect:frame];
    //启动定时器
    if (autoHidden) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    }
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipe:)];
    [swipe setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [_window addGestureRecognizer:swipe];
}

+ (void)handleSwipe:(UISwipeGestureRecognizer *)recognizer {
    if(recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        [self dismiss];
    }
}

+ (void)setCornerRadius:(CGFloat)cornerRadius byRoundingCorners:(UIRectCorner)corners inRect:(CGRect)rect{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer * maskLayer = [[CAShapeLayer alloc]init];
    //设置大小
    maskLayer.frame = rect;
    //设置图形样子
    maskLayer.path = maskPath.CGPath;
    _window.layer.mask = maskLayer;
}

+ (void)setupLabel:(NSString *)msg detail:(NSString *)detailMsg isSuccess:(BOOL)isSuccess {
    NSString *imageName = @"ic_home_public_success";
    if (!isSuccess) {
        imageName = @"ic_home_public_error";
    }
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [_window addSubview:img];
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(WLTNumSize(kLabelMarginTop+7));
        make.left.equalTo(WLTNumSize(17));
        make.width.height.equalTo(WLTNumSize(20));
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.font = font_RegularSize(kLabelTextSize);
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 1;
    label.text = msg;
    [_window addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(WLTNumSize(kLabelMarginTop-5));
        make.left.equalTo(WLTNumSize(kLabelMarginLeft));
        make.right.equalTo(WLTNumSize(-80));
    }];
    
    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.textColor = [UIColor whiteColor];
    detailLabel.font = font_RegularSize(WLTSize(13));
    detailLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    detailLabel.textAlignment = NSTextAlignmentLeft;
    detailLabel.numberOfLines = 1;
    detailLabel.text = detailMsg;
    [_window addSubview:detailLabel];
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.mas_bottom);
        make.left.equalTo(label).offset(-2);
        make.right.equalTo(label);
    }];
}

+(void)setupButton:(SEL)action target:(id)target{
    UIButton *button =[UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if (action && target) {
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    [_window addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(WLTNumSize(kLabelMarginTop));
        make.right.equalTo(WLTNumSize(-kLabelMarginLeft));
        make.width.equalTo(WLTNumSize(60));
        make.height.equalTo(WLTNumSize(24));
    }];
}

+(void)setupButtonUseBlock:(NoticeViewClickBlock)clickBlock {
    _clickBlock = clickBlock;
    UIButton *button =[UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitleColor: [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    [button setTitle:@"去看看" forState:UIControlStateNormal];
    [button setBackgroundColor:color_theme()];
    [button addTarget:self action:@selector(buttonOnClick:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 11;
    button.clipsToBounds = YES;
    button.titleLabel.font = font_RegularSize(WLTSize(13));
    [_window addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(WLTNumSize(kLabelMarginTop+4));
        make.right.equalTo(WLTNumSize(-15));
        make.width.equalTo(WLTNumSize(65));
        make.height.equalTo(@22);
    }];
}

+(void)buttonOnClick:(UIButton *)button{
    if (_clickBlock) {
        NSString *msg = [self getFloatViewMsg];
        _clickBlock(msg);
        [self dismiss];
    }
}

+(NSString *)getFloatViewMsg{
    NSString *msg = @"";
    for (UIView *eachView in _window.subviews) {
        if ([eachView isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)eachView;
            msg = label.text;
            break;
        }
    }
    return msg;
    
}

@end
