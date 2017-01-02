//
//  QJThumbImageCell.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/1.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJThumbImageCell.h"

@interface QJThumbImageCell ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@end

@implementation QJThumbImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)refreshUI:(NSString *)imageUrl row:(NSInteger)row {
    [self.thumbImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"panda"]];
    self.numberLabel.text = [NSString stringWithFormat:@"%ld",row];
}

@end
