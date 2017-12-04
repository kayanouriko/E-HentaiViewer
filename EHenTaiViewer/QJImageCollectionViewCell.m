//
//  QJImageCollectionViewCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJImageCollectionViewCell.h"

@implementation QJImageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.thumbImageView.layer.cornerRadius = 5.f;
    self.thumbImageView.layer.borderWidth = 0.5f;
    self.thumbImageView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.thumbImageView.layer.masksToBounds = YES;
}

@end
