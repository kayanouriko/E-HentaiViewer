//
//  QJCommentCell.m
//  ExReadViewer
//
//  Created by 覃江 on 2016/12/31.
//  Copyright © 2016年 茅野瓜子. All rights reserved.
//

#import "QJCommentCell.h"
#import "QJOtherListController.h"
#import <SafariServices/SafariServices.h>

@interface QJCommentCell ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UITextView *commentTextV;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) NSString *urlStr;

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJCommentCell

- (void)refreshUI:(NSDictionary *)dict {
    [self.titleBtn setTitle:dict[@"reporter"] forState:UIControlStateNormal];
    self.likeLabel.text = dict[@"score"];
    //self.commentLabel.text = dict[@"content"];
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithData:[dict[@"content"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    self.commentTextV.attributedText = attri;
    self.commentTextV.font = AppFontContentStyle();
    
    self.timeLabel.text = dict[@"repostTime"];
    self.urlStr = dict[@"reporterUrl"];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.commentTextV.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

//拦截URL,高于iOS9的不跳safari浏览器
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    //TODO:如果属于网站链接,则直接跳转页面而不是跳转浏览器
    
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 9.0) {
        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:URL];
        [[self viewController] presentViewController:safariVC animated:YES completion:nil];
        return NO;
    }
    return YES;
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
