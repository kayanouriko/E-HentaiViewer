//
//  QJRankingHeadInfoCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/15.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJRankingHeadInfoCell.h"
#import "XHStarRateView.h"
#import "QJListItem.h"

@interface QJRankingHeadInfoCell ()


@property (weak, nonatomic) IBOutlet UIView *contentBgView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *catgeoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *langueLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet XHStarRateView *starView;

@end

@implementation QJRankingHeadInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
    self.thumbImageView.layer.cornerRadius = 5.f;
    self.contentBgView.layer.cornerRadius = 5.f;
    self.contentBgView.clipsToBounds = YES;
    self.catgeoryLabel.layer.cornerRadius = 3.f;
    self.catgeoryLabel.clipsToBounds = YES;
    self.starView.rateStyle = HalfStar;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, UIScreenWidth() - 30, 191);
    gradientLayer.colors = @[(id)[[UIColor clearColor] colorWithAlphaComponent:0.0f].CGColor,(id)[[UIColor blackColor] colorWithAlphaComponent:0.7f].CGColor];
    gradientLayer.locations = @[[NSNumber numberWithFloat:0.5f], [NSNumber numberWithFloat:1.0f]];
    [self.contentBgView.layer addSublayer:gradientLayer];
}

- (void)setModel:(QJListItem *)model {
    _model = model;
    self.titleLabel.text = ([QJGlobalInfo isExHentaiTitleJnMode] && _model.title_jpn.length) ? _model.title_jpn : _model.title;
    self.uploaderLabel.text = _model.uploader;
    self.starView.currentScore = _model.rating;
    self.catgeoryLabel.text = [NSString stringWithFormat:@"  %@  ",_model.category];
    self.catgeoryLabel.backgroundColor = _model.categoryColor;
    self.langueLabel.text = _model.language;
    [self.thumbImageView yy_setImageWithURL:[NSURL URLWithString:_model.thumb] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionHandleCookies];
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    self.timeLabel.text = [NSString stringWithFormat:@"#%ld", (long)_index];
}

@end
