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
    [UIView animateWithDuration:0.25f animations:^{
        self.underLineViewRightLine.constant = isRight ? -55 : 0;
        [self layoutIfNeeded];
    }];
}

#pragma mark -setter
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [self changeUnderLineWithBool:selectedIndex];
}

@end
