//
//  QJRankingHeadInfoCell.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/15.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJListItem;

@interface QJRankingHeadInfoCell : UICollectionViewCell

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) QJListItem *model;

@end
