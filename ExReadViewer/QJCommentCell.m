//
//  QJCommentCell.m
//  ExReadViewer
//
//  Created by 覃江 on 2016/12/31.
//  Copyright © 2016年 茅野瓜子. All rights reserved.
//

#import "QJCommentCell.h"
#import "UILabel+LinkUrl.h"

@interface QJCommentCell ()

@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJCommentCell

- (void)refreshUI:(NSDictionary *)dict {
    [self.titleBtn setTitle:dict[@"reporter"] forState:UIControlStateNormal];
    self.likeLabel.text = dict[@"score"];
    [self.commentLabel setTextWithLinkAttribute:dict[@"content"]];
    self.timeLabel.text = dict[@"repostTime"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    self.commentLabel.preferredMaxLayoutWidth = kScreenWidth - 40;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)btnAction:(UIButton *)sender {
    
}

@end
