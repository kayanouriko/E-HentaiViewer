//
//  QJRankingInfoCell.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/14.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJListItem;

@interface QJRankingInfoCell : UICollectionViewCell

@property (nonatomic, strong) QJListItem *model;
@property (weak, nonatomic) IBOutlet UIView *underLine;

@end
