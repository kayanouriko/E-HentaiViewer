//
//  QJSecondCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/1.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSecondCell.h"

@interface QJSecondCell ()

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJSecondCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)btnAction:(UIButton *)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickSecondBtnWithTag:)]) {
        [self.delegate didClickSecondBtnWithTag:sender.tag - 200];
    }
}
@end
