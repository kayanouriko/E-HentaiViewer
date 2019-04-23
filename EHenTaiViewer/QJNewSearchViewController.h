//
//  QJNewSearchViewController.h
//  EHenTaiViewer
//
//  Created by QinJ on 2019/3/26.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QJNewSearchViewControllerType) {
    QJNewSearchViewControllerTypeSearch, // 普通搜索
    QJNewSearchViewControllerTypeFavorites, // 收藏夹搜索
    QJNewSearchViewControllerTypeTag, // 标签跳转
};

@interface QJNewSearchViewController : QJViewController

@property (strong, nonatomic) NSString *searchKey; // 搜索关键词
@property (strong, nonatomic) NSMutableArray *settings;
@property (assign, nonatomic) QJNewSearchViewControllerType type;
@property (strong, nonatomic) UINavigationController *nav;

// 父类触发了搜索按钮的方法
- (void)viewsShouldSearchBarSearchButtonClicked:(UISearchBar *)searchBar;
// 父类触发了筛选按钮的方法
- (void)viewsShouldSearchBarBookmarkButtonClicked:(UISearchBar *)searchBar;

@end

NS_ASSUME_NONNULL_END
