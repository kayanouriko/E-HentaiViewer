//
//  QJMainListCell.m
//  ExReadViewer
//
//  Created by 覃江 on 2016/12/26.
//  Copyright © 2016年 茅野瓜子. All rights reserved.
//

#import "QJMainListCell.h"
#import "QJStarView.h"

@interface QJMainListCell ()

@property (weak, nonatomic) IBOutlet UIView *cellBgView;

@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;//封面
@property (weak, nonatomic) IBOutlet UILabel *titleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *mangaLabel;
@property (weak, nonatomic) IBOutlet QJStarView *starView;
@property (weak, nonatomic) IBOutlet UILabel *postedLabel;
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;

@property (strong, nonatomic) NSDictionary *colorDict;

@end

@implementation QJMainListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.thumbImageView.alpha = 0;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.cellBgView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.cellBgView.layer.shadowOffset = CGSizeMake(4,4);
    self.cellBgView.layer.shadowOpacity = 0.2;
    self.cellBgView.layer.shadowRadius = 4;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)refreshUI:(NSDictionary *)dict {
    self.titleNameLabel.text = dict[@"title"];
    self.uploaderLabel.text = dict[@"uploader"];
    self.postedLabel.text = dict[@"posted"];
    NSString *category = [dict[@"category"] uppercaseString];
    self.mangaLabel.text = [NSString stringWithFormat:@"  %@  ",category];
    self.mangaLabel.backgroundColor = self.colorDict[category];
    [self.starView refreshStarWithCount:[dict[@"rating"] floatValue] width:20.f];
    self.languageLabel.text = dict[@"language"];
    NSString *imageUrlStr = dict[@"thumb"];
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageUrlStr] options:SDWebImageHandleCookies progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        self.thumbImageView.image = image;
        [UIView animateWithDuration:0.5f animations:^{
            self.thumbImageView.alpha = 1;
        }];
    }];
}

#pragma mark -懒加载
- (NSDictionary *)colorDict {
    if (nil == _colorDict) {
        _colorDict = @{
                       @"DOUJINSHI":DOUJINSHI_COLOR,
                       @"MANGA":MANGA_COLOR,
                       @"ARTIST CG SETS":ARTISTCG_COLOR,
                       @"GAME CG SETS":GAMECG_COLOR,
                       @"WESTERN":WESTERN_COLOR,
                       @"NON-H":NONH_COLOR,
                       @"IMAGE SETS":IMAGESET_COLOR,
                       @"COSPLAY":COSPLAY_COLOR,
                       @"ASIAN PORN":ASIANPORN_COLOR,
                       @"MISC":MISC_COLOR
                       };
    }
    return _colorDict;
}

@end
