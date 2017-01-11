//
//  QJCommentCell.m
//  ExReadViewer
//
//  Created by 覃江 on 2016/12/31.
//  Copyright © 2016年 茅野瓜子. All rights reserved.
//

#import "QJCommentCell.h"
#import "UILabel+LinkUrl.h"
#import "QJTagViewController.h"

@interface QJCommentCell ()

@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) NSString *urlStr;

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJCommentCell

- (void)refreshUI:(NSDictionary *)dict {
    [self.titleBtn setTitle:dict[@"reporter"] forState:UIControlStateNormal];
    self.likeLabel.text = dict[@"score"];
    [self.commentLabel setTextWithLinkAttribute:dict[@"content"]];
    self.timeLabel.text = dict[@"repostTime"];
    self.urlStr = dict[@"reporterUrl"];
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

//跳转
- (IBAction)btnAction:(UIButton *)sender {
    QJTagViewController *vc = [QJTagViewController new];
    vc.mainUrl = self.urlStr;
    vc.tagName = [self.titleBtn titleForState:UIControlStateNormal];
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

@end
