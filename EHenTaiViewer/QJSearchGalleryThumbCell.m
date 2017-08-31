//
//  QJSearchGalleryThumbCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/2.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSearchGalleryThumbCell.h"
#import "QJListItem.h"

@interface QJSearchGalleryThumbCell ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *yyView;
@property (weak, nonatomic) IBOutlet UILabel *yyLabel;

@end

@implementation QJSearchGalleryThumbCell

- (void)refrshUI:(QJListItem *)item {
    self.titleLabel.text = item.title;
    [self.thumbImageView yy_setImageWithURL:[NSURL URLWithString:item.thumb] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionHandleCookies];
    self.yyView.hidden = !item.language.length;
    self.yyLabel.text = item.language;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

@end
