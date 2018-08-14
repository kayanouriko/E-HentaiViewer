//
//  QJRankingInfoCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/14.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJRankingInfoCell.h"
#import "QJListItem.h"

@interface QJRankingInfoCell ()

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *catgoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *langueLabel;

@end

@implementation QJRankingInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
    
    self.leftImageView.layer.cornerRadius = 5.f;
    self.catgoryLabel.layer.cornerRadius = 3.f;
    self.catgoryLabel.clipsToBounds = YES;
}

- (void)setModel:(QJListItem *)model {
    _model = model;
    
    self.titleNameLabel.text = ([QJGlobalInfo isExHentaiTitleJnMode] && _model.title_jpn.length) ? _model.title_jpn : _model.title;
    self.catgoryLabel.text = [NSString stringWithFormat:@"  %@  ",_model.category];
    self.catgoryLabel.backgroundColor = _model.categoryColor;
    self.langueLabel.text = _model.language;
    [self.leftImageView yy_setImageWithURL:[NSURL URLWithString:_model.thumb] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionHandleCookies];
}

@end
