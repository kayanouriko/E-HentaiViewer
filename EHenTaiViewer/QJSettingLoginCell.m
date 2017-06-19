//
//  QJSettingLoginCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/22.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSettingLoginCell.h"

@interface QJSettingLoginCell ()

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;

@end

@implementation QJSettingLoginCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.leftImageView.layer.cornerRadius = 30.f;
    self.leftImageView.clipsToBounds = YES;
    self.leftImageView.layer.borderWidth = 0.5;
    self.leftImageView.layer.borderColor = [UIColor colorWithRed:0.400 green:0.024 blue:0.067 alpha:1.00].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
