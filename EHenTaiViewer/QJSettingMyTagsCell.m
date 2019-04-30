//
//  QJSettingMyTagsCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/4/26.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJSettingMyTagsCell.h"
#import "NSString+StringHeight.h"
#import "QJTagModel.h"

@interface QJSettingMyTagsCell ()

@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;

@end

@implementation QJSettingMyTagsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.colorView.layer.cornerRadius = 6;
    self.colorView.clipsToBounds = YES;
    
    // 修改选中时候的颜色,去除
    self.multipleSelectionBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.multipleSelectionBackgroundView.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // 选中的时候label的背景颜色不改变
    self.colorView.backgroundColor = UIColorHex(self.model.backgroundColor);
}

#pragma mark - Setter
- (void)setModel:(QJTagModel *)model {
    _model = model;
    // 设置数据信息
    self.colorView.backgroundColor = UIColorHex(model.backgroundColor);
    self.tagLabel.text = [QJGlobalInfo isExHentaiTagCnMode] ? model.name_ch : model.name;
    self.groupLabel.text = model.group;
    self.weightLabel.text = model.weight;
    
    if (model.isNone) {
        self.statusLabel.text = @"None";
    }
    else {
        self.statusLabel.text = model.isWatched ? @"Watched" : @"Hidden";
    }
}

@end
