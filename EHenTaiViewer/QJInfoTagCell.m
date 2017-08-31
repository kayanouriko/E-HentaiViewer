//
//  QJInfoTagCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJInfoTagCell.h"
#import "QJTagView.h"

@interface QJInfoTagCell ()

@property (weak, nonatomic) IBOutlet UIView *tagView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagViewHeightLine;

@end

@implementation QJInfoTagCell

- (void)refreshUI:(NSArray *)array {
    BOOL isCN = [NSObjForKey(@"TagCnMode") boolValue];
    for (UIView *subView in self.tagView.subviews) {
        [subView removeFromSuperview];
    }
    CGFloat tagViewHeight = 10;
    for (NSArray *subArray in array) {
        CGFloat viewHeight = isCN ? [subArray[3] floatValue] : [subArray[2] floatValue];
        QJTagView *tagView = [[QJTagView alloc] initWithFrame:CGRectMake(0, tagViewHeight, UIScreenWidth(), viewHeight)];
        [self.tagView addSubview:tagView];
        [tagView refreshUI:subArray isCN:isCN];
        tagViewHeight += viewHeight;
    }
    //如果没有tag,提示没有tag
    if (array.count == 0) {
        UILabel *tagLabel = [UILabel new];
        tagLabel.text = @"没有标签";
        tagLabel.textAlignment = NSTextAlignmentCenter;
        tagLabel.font = AppFontContentStyle();
        tagLabel.frame = CGRectMake(0, 0, UIScreenWidth(), 50);
        tagLabel.textColor = [UIColor lightGrayColor];
        [self.tagView addSubview:tagLabel];
        tagViewHeight = 50;
    }
    self.tagViewHeightLine.constant = tagViewHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
