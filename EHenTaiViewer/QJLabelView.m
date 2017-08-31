//
//  QJLabelView.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/2.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJLabelView.h"
#import "NSString+StringHeight.h"

@implementation QJLabelView

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.labels && self.labels.count) {
        CGFloat buttonViewWidth = UIScreenWidth() - 30;
        CGFloat buttonX = 15;
        NSInteger heihtCount = 0;
        for (NSInteger i = 0; i < self.labels.count; i++) {
            UIButton *button = (UIButton *)[self viewWithTag:1000 + i];
            NSString *title = self.labels[i];
            CGFloat buttonWidth = [title StringWidthWithFontSize:AppFontContentStyle()] + 20;
            if (buttonWidth > UIScreenWidth() - 30) {
                buttonWidth = UIScreenWidth() - 30;
            }
            if (buttonWidth > buttonViewWidth) {
                //不能放下
                heihtCount++;
                buttonX = 15;
                buttonViewWidth = UIScreenWidth() - 30;
            }
            button.frame = CGRectMake(buttonX, heihtCount * 35, buttonWidth, 25);
            //剩余宽度
            buttonViewWidth -= buttonWidth + 10;
            buttonX += buttonWidth + 10;
        }
        //算出高度
        self.viewHeight = (heihtCount + 1) * 35;
    }
}

#pragma mark -setter
- (void)setLabels:(NSArray<NSString *> *)labels {
    _labels = labels;
    NSInteger i = 0;
    for (NSString *title in _labels) {
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addBtn setTitle:title forState:UIControlStateNormal];
        addBtn.titleLabel.font = AppFontContentStyle();
        [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        addBtn.backgroundColor = DEFAULT_COLOR;
        //addBtn.layer.borderWidth = 0.5f;
        //addBtn.layer.borderColor = DEFAULT_COLOR.CGColor;
        addBtn.layer.cornerRadius = 12.5f;
        addBtn.clipsToBounds = YES;
        [addBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        addBtn.tag = i + 1000;
        i++;
        [self addSubview:addBtn];
    }
}

- (void)click:(UIButton *)button {
    
}

@end
