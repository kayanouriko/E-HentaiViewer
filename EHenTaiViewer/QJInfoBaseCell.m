//
//  QJInfoBaseCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJInfoBaseCell.h"
#import "QJGalleryItem.h"
#import "QJListItem.h"

@interface QJInfoBaseCell ()

@property (weak, nonatomic) IBOutlet UILabel *ywTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *ryTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *flLabel;
@property (weak, nonatomic) IBOutlet UILabel *sczLabel;
@property (weak, nonatomic) IBOutlet UILabel *fhlLabel;
@property (weak, nonatomic) IBOutlet UILabel *kjxLabel;
@property (weak, nonatomic) IBOutlet UILabel *yyLabel;
@property (weak, nonatomic) IBOutlet UILabel *dxLabel;
@property (weak, nonatomic) IBOutlet UILabel *sccsLabel;
@property (weak, nonatomic) IBOutlet UILabel *ysLabel;
@property (weak, nonatomic) IBOutlet UILabel *postedLabel;

@end

@implementation QJInfoBaseCell

- (void)refreshUI:(QJGalleryItem *)item listItem:(QJListItem *)listItem {
    NSDictionary *dict = item.baseInfoDic;
    self.ywTitleLabel.text = listItem.title;
    self.ryTitleLabel.text = listItem.title_jpn;
    self.flLabel.text = [listItem.category lowercaseString];
    self.sczLabel.text = listItem.uploader;
    self.fhlLabel.text = dict[@"parent"];
    self.kjxLabel.text = dict[@"visible"];
    self.yyLabel.text = dict[@"language"];
    self.dxLabel.text = dict[@"size"];
    self.sccsLabel.text = dict[@"favorited"];
    self.ysLabel.text = dict[@"length"];
    self.postedLabel.text = dict[@"posted"];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
