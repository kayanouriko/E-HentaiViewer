//
//  QJSearchHeadView.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/15.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSearchHeadView.h"

@interface QJSearchHeadView ()

@property (weak, nonatomic) IBOutlet UILabel *titleNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJSearchHeadView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)btnAction:(UIButton *)sender {
    
}

@end
