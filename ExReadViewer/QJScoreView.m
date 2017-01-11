//
//  QJScoreView.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/10.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJScoreView.h"
#import "QJStarView.h"

@interface QJScoreView ()

@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet UILabel *similarLabel;
@property (weak, nonatomic) IBOutlet UILabel *coverLabel;

@property (weak, nonatomic) IBOutlet QJStarView *starView;
@property (weak, nonatomic) IBOutlet UILabel *starInfoLabel;

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJScoreView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.favoritesLabel.text = NSLocalizedString(@"favorites", nil);
    self.shareLabel.text = NSLocalizedString(@"share", nil);
    self.similarLabel.text = NSLocalizedString(@"similar_gallery", nil);
    self.coverLabel.text = NSLocalizedString(@"search_cover", nil);
}

- (void)refreshUI:(NSDictionary *)dict {
    NSString *scoreAvg = dict[@"scoreAvg"];
    self.starInfoLabel.text = [NSString stringWithFormat:@"%@ / %@",dict[@"scorePerson"],scoreAvg];
    NSArray *array = [scoreAvg componentsSeparatedByString:@" "];
    [self.starView refreshStarWithCount:[array.lastObject floatValue] width:50.f];
}

- (IBAction)btnAction:(UIButton *)sender {
    ScoreViewType status = sender.tag - 1200;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickBtnWithStatus:)]) {
        [self.delegate didClickBtnWithStatus:status];
    }
}

@end
