//
//  QJLikeSearchBar.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/15.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJLikeSearchBar.h"

@interface QJLikeSearchBar ()

@property (weak, nonatomic) IBOutlet UIView *searchBgView;

@end

@implementation QJLikeSearchBar

- (void)awakeFromNib {
    [super awakeFromNib];
    self.searchBgView.layer.cornerRadius = 18.f;
}

@end
