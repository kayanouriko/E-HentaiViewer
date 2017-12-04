//
//  QJSearchBar.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/11/6.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSearchBar.h"

@interface QJSearchBar ()

@property (weak, nonatomic) IBOutlet UIView *searchBgView;

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJSearchBar

- (void)awakeFromNib {
    [super awakeFromNib];
    self.searchBgView.layer.cornerRadius = 18.f;
}

- (IBAction)btnAction:(UIButton *)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickSiftBtn)]) {
        [self.delegate didClickSiftBtn];
    }
}

@end
