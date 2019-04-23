//
//  QJSearchController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/4/16.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJSearchController.h"

@interface QJSearchController ()

@end

@implementation QJSearchController

- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController {
    self = [super initWithSearchResultsController:searchResultsController];
    if (self) {
        [self.searchBar setImage:[UIImage imageNamed:@"sift"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
        self.searchBar.enablesReturnKeyAutomatically = NO; // 设置无内容的时候可以点击搜索按钮
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

@end
