//
//  QJMainSettingListCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2018/9/2.
//  Copyright © 2018 kayanouriko. All rights reserved.
//

#import "QJMainSettingListCell.h"

@interface QJMainSettingListCell ()

@property (weak, nonatomic) IBOutlet UIView *contentBgView;


@end

@implementation QJMainSettingListCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    self.contentBgView.layer.cornerRadius = 5.f;
//    self.contentBgView.layer.borderWidth = 1.f;
//    self.contentBgView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1f].CGColor;
//    self.contentBgView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
