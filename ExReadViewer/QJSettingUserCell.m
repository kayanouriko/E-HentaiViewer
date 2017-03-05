//
//  QJSettingUserCell.m
//  ExReadViewer
//
//  Created by QinJ on 2017/3/5.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJSettingUserCell.h"

@interface QJSettingUserCell ()

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end

@implementation QJSettingUserCell

- (void)readUserName {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"loginName"]) {
        self.userNameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginName"];
    }
    else {
        self.userNameLabel.text = @"未登陆";
        [[NSUserDefaults standardUserDefaults] setObject:self.userNameLabel.text forKey:@"loginName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
