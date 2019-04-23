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

@interface QJListCell ()

// 控件
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView; // 封面
@property (weak, nonatomic) IBOutlet UILabel *titleLabel; // 标题
@property (weak, nonatomic) IBOutlet UILabel *uploaderLabel; // 作者
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet XHStarRateView *starView;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel; // 评分
@property (weak, nonatomic) IBOutlet UIImageView *downloadImageView;
@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pageImageView;
@property (weak, nonatomic) IBOutlet UILabel *pageLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel; // 分类
@property (weak, nonatomic) IBOutlet UILabel *timeLabel; // 时间

@end

@implementation QJListCell

- (void)refreshUI:(QJListItem *)item {
    
    self.titleLabel.text = ([QJGlobalInfo isExHentaiTitleJnMode] && item.title_jpn.length) ? item.title_jpn : item.title;
    self.uploaderLabel.text = item.uploader;
    self.rateLabel.text = [NSString stringWithFormat:@"%.2f", item.rating];
    self.starView.currentScore = item.rating;
    self.categoryLabel.text = [NSString stringWithFormat:@"  %@  ",item.category];
    self.categoryLabel.backgroundColor = item.categoryColor;
    self.timeLabel.text = item.posted;
    [self.thumbImageView yy_setImageWithURL:[NSURL URLWithString:item.thumb] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionHandleCookies];
    
    // self.tagView.tagArr = [QJGlobalInfo isExHentaiTagCnMode] ? item.chTags : item.tags;
    self.tagLabel.attributedText = [NSString convertStringsWithArray:[QJGlobalInfo isExHentaiTagCnMode] ? item.listChTags : item.listTags];
    
    self.downloadLabel.hidden = !item.torrentcount;
    self.downloadLabel.text = [NSString stringWithFormat:@"%ld", item.torrentcount];
    self.downloadImageView.hidden = self.downloadLabel.hidden;
    
    self.pageLabel.text = [NSString stringWithFormat:@"%ld", item.filecount];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.starView.rateStyle = IncompleteStar; // 设置为不完整评分
    
    self.thumbImageView.layer.cornerRadius = 5.f;
    self.thumbImageView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.thumbImageView.layer.borderWidth = 0.5f;
    
    self.pageImageView.image = [self.pageImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.downloadImageView.image = [self.downloadImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
