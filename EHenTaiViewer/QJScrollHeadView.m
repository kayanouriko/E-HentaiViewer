//
//  QJScrollHeadView.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/7/24.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJScrollHeadView.h"

@interface QJScrollHeadView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *underLineViewRightLine;

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJScrollHeadView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.selectedIndex = 0;
}

- (IBAction)btnAction:(UIButton *)sender {
    NSInteger index = sender.tag - 300;
    self.selectedIndex = index;
    [self changeUnderLineWithBool:index];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didSelectedTitleWithIndex:)]) {
        [self.delegate didSelectedTitleWithIndex:index];
    }
}

- (void)changeUnderLineWithBool:(BOOL)isRight {
    //修改下划线
    [UIView animateWithDuration:0.25f animations:^{
        self.underLineViewRightLine.constant = isRight ? -55 : 0;
        [self layoutIfNeeded];
    }];
    //修改颜色
    UIButton *button1 = (UIButton *)[self viewWithTag:300];
    UIButton *button2 = (UIButton *)[self viewWithTag:301];
    [button1 setTitleColor:isRight ? [UIColor blackColor] : DEFAULT_COLOR forState:UIControlStateNormal];
    [button2 setTitleColor:isRight ? DEFAULT_COLOR : [UIColor blackColor] forState:UIControlStateNormal];
}

#pragma mark -setter
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [self changeUnderLineWithBool:selectedIndex];
}

@end
