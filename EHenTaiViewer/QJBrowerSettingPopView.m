//
//  QJBrowerSettingPopView.m
//  EHenTaiViewer
//
//  Created by kayanouriko on 2018/6/27.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import "QJBrowerSettingPopView.h"

@interface QJBrowerSettingPopView()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, assign) CGPoint point;
@property (nonatomic, strong) NSMutableArray *showViewVLFs;

// 屏幕方向
@property (weak, nonatomic) IBOutlet UISegmentedControl *orientationSeg;
- (IBAction)orientationSegValueChange:(UISegmentedControl *)sender;

// 滚动方向
@property (weak, nonatomic) IBOutlet UISegmentedControl *directionSeg;
- (IBAction)directionSegValueChange:(UISegmentedControl *)sender;

// 亮度
@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;
- (IBAction)brightnessSliderValueChange:(UISlider *)sender;

@end

@implementation QJBrowerSettingPopView

+ (QJBrowerSettingPopView *)initWithDelegate:(id<QJBrowerSettingPopViewDelegate>)theDelegate {
    QJBrowerSettingPopView *showView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([QJBrowerSettingPopView class]) owner:self options:nil].firstObject;
    showView.delegate = theDelegate;
    // 初始化部分
    showView.orientationSeg.selectedSegmentIndex = [showView.delegate currentOrientationSegSelectedIndex];
    showView.directionSeg.selectedSegmentIndex = [showView.delegate currentDirectionSegSelectedIndex];
    showView.brightnessSlider.value = [showView.delegate currentBrightness];
    
    return showView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // 采用自动布局
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.alpha = 0;
    self.layer.cornerRadius = 5.f;
    self.layer.masksToBounds = YES;
    self.showed = NO;
}

#pragma mark - View Action
- (void)show {
    [self showWithAnimate:YES];
}

- (void)showWithAnimate:(BOOL)animate{
    self.showed = YES;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.bgView];
    [window addSubview:self];
    
    CGFloat margin = (isIPhoneX && !(isAppOrientationPortrait)) ? 10 + UISearchBarHeight() : 10;
    [window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=margin)-[self(360@500)]-margin-|" options:0 metrics:@{@"margin": @(margin)} views:NSDictionaryOfVariableBindings(self)]];
    CGFloat y = UINavigationBarHeight() + 10;
    [window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-y-[self(240.5@500)]-(>=marginButtom)-|" options:0 metrics:@{@"y": @(y), @"marginButtom": @(UITabBarSafeBottomMargin() + 10)} views:NSDictionaryOfVariableBindings(self)]];
    
    [window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_bgView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bgView)]];
    [window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_bgView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bgView)]];
    
    NSTimeInterval timeInterval = animate ? 0.25f : 0;
    [UIView animateWithDuration:timeInterval animations:^{
        self.bgView.alpha = 0.2f;
        self.alpha = 1.f;
    }];
}

- (void)closeWithAnimate {
    [UIView animateWithDuration:0.25f animations:^{
        self.bgView.alpha = 0;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.showed = NO;
        [self.bgView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)close {
    self.bgView.alpha = 0;
    self.alpha = 0;
    self.showed = NO;
    [self.bgView removeFromSuperview];
    [self removeFromSuperview];
}

- (void)changeFrameIfNeed {
    [self close];
    [self showWithAnimate:NO];
}

#pragma mark - Control Action
// 旋转方向
- (IBAction)orientationSegValueChange:(UISegmentedControl *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(orientationSegDidClickBtnWithSelectedIndex:)]) {
        [self.delegate orientationSegDidClickBtnWithSelectedIndex:sender.selectedSegmentIndex];
    }
}

// 滚动方向
- (IBAction)directionSegValueChange:(UISegmentedControl *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(directionSegDidClickBtnWithSelectedIndex:)]) {
        [self.delegate directionSegDidClickBtnWithSelectedIndex:sender.selectedSegmentIndex];
    }
}

// 亮度
- (IBAction)brightnessSliderValueChange:(UISlider *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(brightnessSliderDidChangeValue:)]) {
        [self.delegate brightnessSliderDidChangeValue:sender.value];
    }
}

#pragma mark - Getter
- (UIView *)bgView {
    if (nil == _bgView) {
        _bgView = [UIView new];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0;
        _bgView.userInteractionEnabled = YES;
        _bgView.translatesAutoresizingMaskIntoConstraints = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeWithAnimate)];
        [_bgView addGestureRecognizer:tap];
    }
    return _bgView;
}

@end
