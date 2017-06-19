//
//  QJCommentCell.m
//  ExReadViewer
//
//  Created by 覃江 on 2016/12/31.
//  Copyright © 2016年 茅野瓜子. All rights reserved.
//

#import "QJCommentCell.h"
#import "QJOtherListController.h"

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
    self.commentLabel.text = dict[@"content"];
    self.timeLabel.text = dict[@"repostTime"];
    self.urlStr = dict[@"reporterUrl"];
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
    QJOtherListController *vc = [QJOtherListController new];
    vc.type = QJOtherListControllerTypePerson;
    vc.key = [self.titleBtn titleForState:UIControlStateNormal];
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
