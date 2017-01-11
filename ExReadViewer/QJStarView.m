//
//  QJStarView.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/9.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJStarView.h"

@implementation QJStarView {
    NSInteger _halfStar;
    NSInteger _starCount;
    CGFloat _width;
}

- (void)refreshStarWithCount:(CGFloat)count width:(CGFloat)width {
    _width = width;
    _halfStar = (NSInteger)(count * 100) % 100;
    _starCount = count / 1;
    //cell里面会复用,所以星星需要删除重新生成
    for (id view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)view removeFromSuperview];
        }
    }
    for (NSInteger i = 0; i < 10; i++) {
        UIImageView *starImageView = [UIImageView new];
        NSString *imageName = i < 5 ? @"star_gray" : @"star_yellow";
        starImageView.image = [UIImage imageNamed:imageName];
        starImageView.tag = 500 + i;
        [self addSubview:starImageView];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (NSInteger i = 0; i < 5; i++) {
        UIImageView *grayImageView = (UIImageView *)[self viewWithTag:500 + i];
        UIImageView *yellowImageView = (UIImageView *)[self viewWithTag:505 + i];
        grayImageView.frame = CGRectMake(i * _width, 0, _width, _width);
        CGFloat starWidth = _width;
        if (i == _starCount) {
            starWidth = _width / 2;
            if (_halfStar) {
                yellowImageView.image = [UIImage imageNamed:@"star_yellow_half"];
            }
            else {
                starWidth = 0;
            }
        }
        if (i > _starCount) {
            starWidth = 0;
        }
        yellowImageView.frame = CGRectMake(i * _width, 0, starWidth, _width);
    }
}

@end
