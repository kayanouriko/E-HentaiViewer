//
//  QJScoreView.h
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/10.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ScoreViewType){
    ScoreViewTypeFavorites,
    ScoreViewTypeShare,
    ScoreViewTypeSimilar,
    ScoreViewTypeCover
};

@protocol QJScoreViewDelagate <NSObject>

- (void)didClickBtnWithStatus:(ScoreViewType)status;

@end

@interface QJScoreView : UIView

@property (weak, nonatomic) IBOutlet UIButton *collectBtn;
@property (weak, nonatomic) IBOutlet UILabel *favoritesLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property (weak, nonatomic) id<QJScoreViewDelagate>delegate;

- (void)refreshUI:(NSDictionary *)dict;

@end
