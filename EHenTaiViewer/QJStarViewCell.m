//
//  QJStarViewCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/1.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJStarViewCell.h"
#import "XHStarRateView.h"
#import "QJGalleryItem.h"
#import "QJListItem.h"

@interface QJStarViewCell ()

@property (weak, nonatomic) IBOutlet XHStarRateView *starView;
@property (weak, nonatomic) IBOutlet UILabel *starLabel;

@end

@implementation QJStarViewCell

- (void)refreshUI:(QJGalleryItem *)item listItem:(QJListItem *)listItem {
    self.starLabel.text = [NSString stringWithFormat:@"(%.2f/%@)",listItem.rating,[item.baseInfoDic[@"favorited"] componentsSeparatedByString:@" "].firstObject];
    self.starView.currentScore = listItem.rating;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.starView.currentScore = 4.5f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
