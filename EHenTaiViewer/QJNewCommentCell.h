//
//  QJNewCommentCell.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/11/23.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJNewCommentCell;

@protocol QJNewCommentCellDelegate <NSObject>

@optional
- (void)didClickMoreBtnWithCell:(QJNewCommentCell *)cell;

@end

@interface QJNewCommentCell : UICollectionViewCell

@property (weak, nonatomic) id<QJNewCommentCellDelegate>delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
- (void)refreshUIWithDict:(NSDictionary *)dict;

@end
