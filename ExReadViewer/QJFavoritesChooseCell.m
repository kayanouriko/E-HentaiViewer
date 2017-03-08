//
//  QJFavoritesChooseCell.m
//  ExReadViewer
//
//  Created by QinJ on 2017/3/7.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJFavoritesChooseCell.h"

@interface QJFavoritesChooseCell ()

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation QJFavoritesChooseCell

- (void)refreshUI:(NSInteger)index {
    self.titleImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"fav%ld",index]];
    self.titleLabel.text = [NSString stringWithFormat:@"Favorites %ld",index];
    if (index == 10) {
        self.titleLabel.text = @"Favorites All";
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
