//
//  QJThumbImageCell.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/1.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJThumbImageCell.h"
#import "WUIImage.h"
#import "SDWebImageDownloader.h"

@interface QJThumbImageCell ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@end

@implementation QJThumbImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)refreshUI:(NSDictionary *)imageDict row:(NSInteger)row {
    self.thumbImageView.image = [UIImage imageNamed:@"panda"];
    [[SDWebImageManager sharedManager] downloadImageWithURL:imageDict[@"url"] options:SDWebImageHandleCookies progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        CGRect rect = CGRectMake([imageDict[@"x"] integerValue], 0, [imageDict[@"width"] integerValue], [imageDict[@"height"] integerValue]);
        UIImage *thumbImage = [WUIImage SeparateImage:image withRect:rect];
        self.thumbImageView.image = thumbImage;
        [UIView animateWithDuration:0.5f animations:^{
            self.thumbImageView.alpha = 1;
        }];
        
    }];
    self.numberLabel.text = [NSString stringWithFormat:@"%ld",(long)row + 1];
}

@end
