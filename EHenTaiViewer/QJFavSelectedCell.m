//
//  QJFavSelectedCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/7/28.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJFavSelectedCell.h"

@interface QJFavSelectedCell ()

@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UILabel *favLabel;


@end

@implementation QJFavSelectedCell

- (void)refreshUI:(UIColor *)color index:(NSInteger)index {
    self.headView.backgroundColor = color;
    self.favLabel.text = [NSString stringWithFormat:@"Favorites %ld",index];
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
