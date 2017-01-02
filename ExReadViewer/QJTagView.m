//
//  QJTagView.m
//  ExReadViewer
//
//  Created by 覃江 on 2016/12/31.
//  Copyright © 2016年 茅野瓜子. All rights reserved.
//

#import "QJTagView.h"
#import "QJIntroInfoModel.h"

@implementation QJTagView {
    CGFloat _leftLabelWidth;
    NSInteger _buttonCount;
    NSArray *_rightArr;
}

- (void)refreshUI:(NSArray *)array {
    NSString *leftStr = array.firstObject;
    _leftLabelWidth = [leftStr boundingRectWithSize:CGSizeMake(MAXFLOAT, 25) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]} context:nil].size.width + 20;
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, _leftLabelWidth, 25)];
    leftLabel.text = leftStr;
    leftLabel.textColor = [UIColor whiteColor];
    leftLabel.font = [UIFont systemFontOfSize:14.0f];
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.backgroundColor = [UIColor purpleColor];
    leftLabel.layer.cornerRadius = 12.5f;
    leftLabel.clipsToBounds = YES;
    [self addSubview:leftLabel];
    
    _rightArr = array[1];
    _buttonCount = _rightArr.count;
    NSInteger i = 0;
    for (QJCategoryButtonInfo *model in _rightArr) {
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addBtn setTitle:model.name forState:UIControlStateNormal];
        addBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        addBtn.backgroundColor = [UIColor colorWithRed:0.098 green:0.584 blue:0.533 alpha:1.00];
        addBtn.tag = i + 1000;
        i++;
        addBtn.layer.cornerRadius = 12.5f;
        addBtn.clipsToBounds = YES;
        [addBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addBtn];
    }
}

- (void)click:(UIButton *)button {
    QJCategoryButtonInfo *model = _rightArr[button.tag - 1000];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickTagButtonWithModel:)]) {
        [self.delegate didClickTagButtonWithModel:model];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat buttonViewWidth = kScreenWidth - (_leftLabelWidth + 40) - 20;
    CGFloat buttonX = _leftLabelWidth + 40;
    NSInteger heihtCount = 0;
    for (int i = 0; i < _buttonCount; i++) {
        UIButton *btn = (UIButton *)[self viewWithTag:1000 + i];
        CGFloat buttonWidth = [btn.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 25) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]} context:nil].size.width + 20;
        if (buttonWidth > kScreenWidth - (_leftLabelWidth + 40) - 20) {
            buttonWidth = kScreenWidth - (_leftLabelWidth + 40) - 30;
        }
        if (buttonWidth > buttonViewWidth) {
            //不能放下
            heihtCount++;
            buttonX = _leftLabelWidth + 40;
            buttonViewWidth = kScreenWidth - (_leftLabelWidth + 40) - 20;
        }
        btn.frame = CGRectMake(buttonX, heihtCount * 35, buttonWidth, 25);
        //剩余宽度
        buttonViewWidth -= buttonWidth + 10;
        buttonX += buttonWidth + 10;
    }
}

@end
