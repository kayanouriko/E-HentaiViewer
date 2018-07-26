//
//  QJSettingListCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/24.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSettingListCell.h"
#import "QJSettingModel.h"
#import "QJProtectTool.h"

@interface QJSettingListCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;

- (IBAction)valueChange:(UISwitch *)sender;

@end

@implementation QJSettingListCell

- (void)setModel:(QJSettingModel *)model {
    _model = model;
    self.titleNameLabel.text = model.title;
    if ([model.type isEqualToString:@"开关"]) {
        if ([model.title isEqualToString:@"启动保护"]) {
            if (![[QJProtectTool shareTool] isEnableTouchID]) {
                self.switchBtn.enabled = NO;
                model.value = @"0";
                model.subTitle = @"该手机不支持TouchID";
            }
        }
        self.switchBtn.on = [model.value boolValue];
        self.subTitleLabel.text = self.switchBtn.on ? model.subTitleSelected : model.subTitle;
    }
    else {
        self.subTitleLabel.text = model.subTitle;
    }
    self.switchBtn.hidden = ![model.type isEqualToString:@"开关"];
    self.accessoryType = [model.type isEqualToString:@"开关"] ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = [model.type isEqualToString:@"开关"] ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)valueChange:(UISwitch *)sender {
    self.model.value = [NSString stringWithFormat:@"%@",@(sender.on)];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(valueChangeWithSwitch:model:)]) {
        [self.delegate valueChangeWithSwitch:sender model:self.model];
    }
}

@end
