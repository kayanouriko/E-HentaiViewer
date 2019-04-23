//
//  QJSettingLoginCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/22.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSettingLoginCell.h"

@interface QJSettingLoginCell ()

// 控件
@property (weak, nonatomic) IBOutlet UILabel *loginNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UIView *leftImageBgView; // 封面阴影
@property (weak, nonatomic) IBOutlet UILabel *desLabel; // 描述信息

@end

@implementation QJSettingLoginCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.leftImageBgView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.leftImageBgView.layer.cornerRadius = 30.f;
    self.leftImageBgView.layer.shadowOffset = CGSizeMake(0, 0);
    self.leftImageBgView.layer.shadowOpacity = 0.1f;
    self.leftImageBgView.layer.shadowRadius = 4.f;
}

- (void)updateUserInfo {
    NSString *imageUrl = [QJGlobalInfo getExHentaiUserImageUrl];
    if ([imageUrl containsString:@"http"]) {
        [self.leftImageView yy_setImageWithURL:[NSURL URLWithString:imageUrl] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionHandleCookies];
    }
    else {
        self.leftImageView.image = [UIImage imageNamed:imageUrl];
    }
    
    self.loginNameLabel.text = [QJGlobalInfo getExHentaiUserName];
    self.desLabel.text = [QJGlobalInfo getExHentaiUserDes];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
