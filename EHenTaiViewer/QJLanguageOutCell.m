//
//  QJLanguageOutCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJLanguageOutCell.h"
#import "QJSettingItem.h"

@interface QJLanguageOutCell ()

@property (weak, nonatomic) IBOutlet UILabel *languageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *yzImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fyImageView;
@property (weak, nonatomic) IBOutlet UIImageView *gxImageView;
@property (weak, nonatomic) IBOutlet UIImageView *allImageView;

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJLanguageOutCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.yzImageView.image = [self.yzImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.fyImageView.image = [self.fyImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.gxImageView.image = [self.gxImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.allImageView.image = [self.allImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setModel:(QJSettingLanguageItem *)model {
    _model = model;
    self.languageLabel.text = _model.name;
    NSInteger i = 0;
    self.yzImageView.image = [[UIImage imageNamed:_model.models[i++].isChecked ? @"checkbox" : @"checkbox_unchecked"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.fyImageView.image = [[UIImage imageNamed:_model.models[i++].isChecked ? @"checkbox" : @"checkbox_unchecked"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.gxImageView.image = [[UIImage imageNamed:_model.models[i++].isChecked ? @"checkbox" : @"checkbox_unchecked"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.allImageView.image = [[UIImage imageNamed:_model.models[i++].isChecked ? @"checkbox" : @"checkbox_unchecked"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (IBAction)btnAction:(UIButton *)sender {
    NSInteger index = sender.tag - 200;
    QJSettingLanguageCheckBoxItem *fatherModel = self.model.models[index];
    fatherModel.checked = !fatherModel.isChecked;
    if (index == 3) {
        for (NSInteger i = 0; i < 3; i++) {
            QJSettingLanguageCheckBoxItem *model = self.model.models[i];
            model.checked = fatherModel.checked;
        }
    }
    else {
        QJSettingLanguageCheckBoxItem *allModel = self.model.models.lastObject;
        if (fatherModel.isChecked) {
            BOOL isAllSelect = YES;
            for (NSInteger i = 0; i < 3; i++) {
                QJSettingLanguageCheckBoxItem *model = self.model.models[i];
                if (!model.isChecked) {
                    isAllSelect = NO;
                    break;
                }
            }
            allModel.checked = isAllSelect;
        }
        else {
            allModel.checked = fatherModel.isChecked;
        }
    }
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickBtn)]) {
        [self.delegate didClickBtn];
    }
}

@end
