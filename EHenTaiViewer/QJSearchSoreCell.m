//
//  QJSearchSoreCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/18.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSearchSoreCell.h"

@interface QJSearchSoreCell ()

- (IBAction)valueChange:(UISegmentedControl *)sender;

@end

@implementation QJSearchSoreCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)valueChange:(UISegmentedControl *)sender {
    NSObjSetForKey(@"SearchSore", @(sender.selectedSegmentIndex));
    NSObjSynchronize();
}
@end
