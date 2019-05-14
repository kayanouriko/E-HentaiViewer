//
//  QJBrowerSettingViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/5/11.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJBrowerSettingViewController.h"

@interface QJBrowerSettingViewController ()

// 保持屏幕常亮
@property (weak, nonatomic) IBOutlet UISwitch *lightSwitch;

// 亮度
@property (weak, nonatomic) IBOutlet UISlider *lightSlider;

@end

@implementation QJBrowerSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
    
    [self setDatas];
}

- (void)setContent {
    self.view.backgroundColor = [UIColor clearColor];
    
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view sendSubviewToBack:bgView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissHadlerAction)];
    [bgView addGestureRecognizer:tap];
}

- (void)setDatas {
    if (self.delegate) {
        [self changeBgViewWithTag:300 buttonTag:200 selectIndex:[self.delegate currentDirectionSegSelectedIndexWithController:self]];
        [self changeBgViewWithTag:310 buttonTag:210 selectIndex:[self.delegate currentOrientationSegSelectedIndexWithController:self]];
        self.lightSlider.value = [self.delegate currentBrightnessWithController:self];
        self.lightSwitch.on = [self.delegate currentKeepLightWithController:self];
    }
}

// MARK: View Method
- (void)dismissHadlerAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissController:)]) {
        [self.delegate dismissController:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dissmissButtonAction:(UIButton *)sender {
    [self dismissHadlerAction];
}

// MARK: Control Method
- (IBAction)readModeAction:(UIButton *)sender {
    // 200: 水平 201: 垂直
    NSInteger index = sender.tag - 200;
    [self changeBgViewWithTag:300 buttonTag:200 selectIndex:index];
    if (self.delegate && [self.delegate respondsToSelector:@selector(controller:directionSegDidClickBtnWithSelectedIndex:)]) {
        [self.delegate controller:self directionSegDidClickBtnWithSelectedIndex:index];
    }
}

- (IBAction)screenAction:(UIButton *)sender {
    // 210: 竖屏 211: 横屏 212: 系统
    NSInteger index = sender.tag - 210;
    [self changeBgViewWithTag:310 buttonTag:210 selectIndex:index];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(controller:orientationSegDidClickBtnWithSelectedIndex:)]) {
        [self.delegate controller:self orientationSegDidClickBtnWithSelectedIndex:index];
    }
}

- (void)changeBgViewWithTag:(NSInteger)bgViewTag buttonTag:(NSInteger)buttonTag selectIndex:(NSInteger)index {
    for (NSInteger i = 0; i < 3; i++) {
        UIView *bgView = [self.view viewWithTag:bgViewTag + i];
        UIButton *button = [self.view viewWithTag:buttonTag + i];
        if (bgView && button) {
            if (i == index) {
                bgView.layer.borderColor = DEFAULT_COLOR.CGColor;
                bgView.layer.borderWidth = 2.f;
                bgView.backgroundColor = [UIColor colorWithWhite:1.f alpha:1.f];
            } else {
                bgView.layer.borderColor = DEFAULT_COLOR.CGColor;
                bgView.layer.borderWidth = 0;
                bgView.backgroundColor = [UIColor colorWithWhite:1.f alpha:.6f];
            }
        }
    }
}

- (IBAction)keepLightValueChangeAction:(UISwitch *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(controller:keepLight:)]) {
        [self.delegate controller:self keepLight:sender.on];
    }
}

- (IBAction)lightValueChangeAction:(UISlider *)sender {
    // 亮度调整
    if (self.delegate && [self.delegate respondsToSelector:@selector(controller:brightnessSliderDidChangeValue:)]) {
        [self.delegate controller:self brightnessSliderDidChangeValue:sender.value];
    }
}

// 控制器弹出方式
- (UIModalTransitionStyle)modalTransitionStyle {
    return UIModalTransitionStyleCoverVertical;
}

// 设置控制器透明
- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationOverCurrentContext;
}

@end
