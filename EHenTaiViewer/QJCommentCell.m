//
//  QJCommentCell.m
//  ExReadViewer
//
//  Created by 覃江 on 2016/12/31.
//  Copyright © 2016年 茅野瓜子. All rights reserved.
//

#import "QJCommentCell.h"
#import "QJSearchViewController.h"
#import "QJGalleryItem.h"
#import "NSString+StringHeight.h"
#import <SafariServices/SafariServices.h>

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
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 9.0) {
        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:URL];
        [[self viewController] presentViewController:safariVC animated:YES completion:nil];
        return NO;
    }
    return YES;
}

//跳转
- (IBAction)btnAction:(UIButton *)sender {
    NSString *uploader = [self.titleBtn titleForState:UIControlStateNormal];
    NSString *searchKey = [NSString stringWithFormat:@"uploader:%@", uploader];
    NSString *url = [NSString stringWithFormat:@"uploader/%@/", [uploader urlEncode]];
    QJGalleryTagItem *model = [QJGalleryTagItem new];
    model.searchKey = searchKey;
    model.url = url;
    QJSearchViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([QJSearchViewController class])];
    vc.model = model;
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
