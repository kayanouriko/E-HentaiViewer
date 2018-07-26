//
//  QJListCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/19.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJListCell.h"
#import "QJListItem.h"
#import "XHStarRateView.h"
#import "QJTagView.h"

@interface QJListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *catgeoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *langueLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIImageView *downloadImageView;
@property (weak, nonatomic) IBOutlet UIView *fgxView;
@property (weak, nonatomic) IBOutlet XHStarRateView *starView;
@property (nonatomic, strong) QJListItem *item;

@end

@implementation QJListCell

- (void)refreshUI:(QJListItem *)item {
    self.item = item;
    self.titleLabel.text = ([QJGlobalInfo isExHentaiTitleJnMode] && item.title_jpn.length) ? item.title_jpn : item.title;
    self.uploaderLabel.text = item.uploader;
    self.starView.currentScore = item.rating;
    self.catgeoryLabel.text = [NSString stringWithFormat:@"  %@  ",item.category];
    self.catgeoryLabel.backgroundColor = item.categoryColor;
    self.langueLabel.text = item.language;
    self.timeLabel.text = item.posted;
    self.countLabel.text = [NSString stringWithFormat:@"%ld 页",item.filecount];
    self.downloadImageView.hidden = !item.torrentcount;
    self.fgxView.hidden = !item.torrentcount;
    [self.thumbImageView yy_setImageWithURL:[NSURL URLWithString:item.thumb] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionHandleCookies];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.catgeoryLabel.layer.cornerRadius = 3.f;
    self.catgeoryLabel.clipsToBounds = YES;
    self.starView.rateStyle = HalfStar;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
