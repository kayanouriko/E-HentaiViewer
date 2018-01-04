//
//  QJRankingUploadCell.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/18.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJToplistUploaderItem;

@interface QJRankingUploadCell : UICollectionViewCell

- (void)refreshCellWithModel:(QJToplistUploaderItem *)model index:(NSInteger)index isHidden:(BOOL)isHidden;

@end
