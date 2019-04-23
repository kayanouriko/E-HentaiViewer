//
//  QJSearchSettingTagSearchViewController.h
//  EHenTaiViewer
//
//  Created by QinJ on 2019/4/1.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class QJSearchSettingTagSearchViewController;

@protocol QJSearchSettingTagSearchViewControllerDelegate <NSObject>

@optional
- (void)tagSearchController:(QJSearchSettingTagSearchViewController *)controller tagName:(NSString *)tagName indexPath:(NSIndexPath *)indexPath;

@end

@interface QJSearchSettingTagSearchViewController : QJViewController

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id<QJSearchSettingTagSearchViewControllerDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
