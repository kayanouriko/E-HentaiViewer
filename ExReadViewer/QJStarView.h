//
//  QJStarView.h
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/9.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TouchBlock)(CGFloat score);

@interface QJStarView : UIView

@property (strong, nonatomic) TouchBlock touchBlock;
@property (assign, nonatomic) BOOL canChangeStar;//默认不能改变星星评价

- (void)refreshStarWithCount:(CGFloat)count width:(CGFloat)width;

@end
