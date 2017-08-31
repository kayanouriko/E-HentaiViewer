//
//  QJSearchUploaderCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/2.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSearchUploaderCell.h"
#import "QJLabelView.h"
#import "QJToplistUploaderItem.h"

@interface QJSearchUploaderCell ()

@property (weak, nonatomic) IBOutlet QJLabelView *labelBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelBgViewHeightLine;

@end

@implementation QJSearchUploaderCell

- (void)refrshUI:(NSArray<QJToplistUploaderItem *> *)upladers {
    NSMutableArray *titles = [NSMutableArray new];
    for (QJToplistUploaderItem *item in upladers) {
        [titles addObject:item.name];
    }
    self.labelBgView.labels = titles;
    self.labelBgViewHeightLine.constant = self.labelBgView.viewHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
