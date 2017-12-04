//
//  QJNewCommentCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/11/23.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJNewCommentCell.h"
#import "QJSearchViewController.h"
#import "QJGalleryItem.h"
#import "NSString+StringHeight.h"
#import <SafariServices/SafariServices.h>
#import "UITextView+Addition.h"

@interface QJNewCommentCell ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UITextView *commentTextV;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJNewCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.commentTextV.delegate = self;
    self.bgView.layer.cornerRadius = 5.f;
    self.bgView.clipsToBounds = YES;
}

- (void)refreshUIWithDict:(NSDictionary *)dict {
    [self.titleBtn setTitle:dict[@"reporter"] forState:UIControlStateNormal];
    self.likeLabel.text = dict[@"score"];
    //self.commentLabel.text = dict[@"content"];
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithData:[dict[@"content"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    self.commentTextV.attributedText = attri;
    self.commentTextV.font = AppFontContentStyle();
    
    self.moreBtn.hidden = ![self.commentTextV checkContentLength];
    
    self.timeLabel.text = dict[@"repostTime"];
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

- (IBAction)btnAction:(UIButton *)sender {
    NSInteger index = sender.tag - 100;
    if (index) {
        //代理
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickMoreBtnWithCell:)]) {
            [self.delegate didClickMoreBtnWithCell:self];
        }
        return;
    }
    //跳转上传者搜索
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
