//
//  QJCommentCell.m
//  ExReadViewer
//
//  Created by 覃江 on 2016/12/31.
//  Copyright © 2016年 茅野瓜子. All rights reserved.
//

#import "QJCommentCell.h"

@interface QJCommentCell ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UITextView *commentTextV;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) NSString *urlStr;

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJCommentCell

- (void)refreshUI:(NSDictionary *)dict {
    [self.titleBtn setTitle:dict[@"reporter"] forState:UIControlStateNormal];
    self.likeLabel.text = dict[@"score"];
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
    self.bgView.layer.cornerRadius = 5.f;
    self.bgView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

//拦截URL,高于iOS9的不跳safari浏览器
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    // 这里拦截url,交由外面处理
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentCell:didClickContentUrlWithURL:)]) {
        [self.delegate commentCell:self didClickContentUrlWithURL:URL];
        return NO;
    }
    return YES;
}

//跳转
- (IBAction)btnAction:(UIButton *)sender {
    NSString *uploader = [self.titleBtn titleForState:UIControlStateNormal];
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentCell:didClickUserImageWithUserName:)]) {
        [self.delegate commentCell:self didClickUserImageWithUserName:uploader];
    }
}

@end
