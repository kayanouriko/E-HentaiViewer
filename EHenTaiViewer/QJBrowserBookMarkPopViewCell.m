//
//  QJBrowserBookMarkPopViewCell.m
//  AnimatedTransitioningDemo
//
//  Created by zedmacbook on 2018/7/24.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import "QJBrowserBookMarkPopViewCell.h"
#import "QJMangaImageModel.h"
#import "GalleryPage+CoreDataClass.h"

@interface QJBrowserBookMarkPopViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *pageLabel;

@end

@implementation QJBrowserBookMarkPopViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 5.f;
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.layer.masksToBounds = YES;
}

#pragma mark - Setter
- (void)setModel:(QJMangaImageModel *)model {
    _model = model;
    self.pageLabel.text = [NSString stringWithFormat:@"%ld", (long)model.page];
    self.thumbImageView.image = nil;
    [model getSmallUrlWithBlock:^{
        [self.thumbImageView yy_setImageWithURL:[NSURL URLWithString:model.smallImageUrl] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionHandleCookies];
    }];
}

- (void)setGalleryPage:(GalleryPage *)galleryPage {
    _galleryPage = galleryPage;
    self.pageLabel.text = [NSString stringWithFormat:@"%ld", (long)galleryPage.page + 1];
    [self.thumbImageView yy_setImageWithURL:[NSURL URLWithString:galleryPage.smallImageUrl] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionHandleCookies];
}

@end
