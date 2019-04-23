//
//  QJSearchSettingViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/3/30.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJSearchSettingViewController.h"
//iconfont
#import "TBCityIconFont.h"
#import "UIImage+TBCityIconFont.h"

#import "QJSearchSettingSubViewController.h"

@interface QJSearchSettingNavHeadView : UIView

@property (assign, nonatomic) NSUInteger selectIndex; // 选中的index
@property (strong, nonatomic) NSArray<NSString *> *titleArr;
@property (strong, nonatomic) UILabel *showLabel;
@property (strong, nonatomic) UIPageControl *pageControl;

- (instancetype)initWithArray:(NSArray<NSString *> *)array;

@end

@implementation QJSearchSettingNavHeadView

- (instancetype)initWithArray:(NSArray<NSString *> *)array {
    self = [super init];
    if (self) {
        self.titleArr = array;
        [self setContent];
    }
    return self;
}

- (void)setContent {
    self.pageControl.numberOfPages = self.titleArr.count;
    self.showLabel.text = self.titleArr[self.pageControl.currentPage];
    
    [self addSubview:self.showLabel];
    [self addSubview:self.pageControl];
    
    [self.showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(8);
        make.left.right.equalTo(self);
    }];
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.showLabel.mas_bottom);
        make.centerX.equalTo(self);
        make.height.equalTo(@12);
        make.bottom.equalTo(self).offset(-3);
    }];
}

- (CGSize)intrinsicContentSize {
    return UILayoutFittingExpandedSize;
}

#pragma mark - Setter
- (void)setSelectIndex:(NSUInteger)selectIndex {
    _selectIndex = selectIndex;
    
    self.pageControl.currentPage = selectIndex;
    self.showLabel.text = self.titleArr[self.pageControl.currentPage];
}

#pragma mark - Getter
- (UIPageControl *)pageControl {
    if (nil == _pageControl) {
        _pageControl = [UIPageControl new];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = DEFAULT_COLOR;
    }
    return _pageControl;
}

- (UILabel *)showLabel {
    if (nil == _showLabel) {
        _showLabel = [UILabel new];
        _showLabel.font = [UIFont systemFontOfSize:14.f];
        _showLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _showLabel;
}

@end

@interface QJSearchSettingViewController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (strong, nonatomic) QJSearchSettingNavHeadView *navgationHeadView;
@property (nonatomic, strong) UIPageViewController *pageVC;
@property (strong, nonatomic) NSArray *contents;
@property (assign, nonatomic) NSInteger currentPage;

// 下发的两个控制器
@property (strong, nonatomic) QJSearchSettingSubViewController *normalVC;
@property (strong, nonatomic) QJSearchSettingSubViewController *siftVC;

@end

@implementation QJSearchSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
}

- (void)setContent {
    // 导航栏相关的
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e607", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e62e", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = doneItem;
    
    self.navigationItem.titleView = self.navgationHeadView;
    
    // 配置子类控制器和布局相关
    self.currentPage = 0;
    [self.pageVC setViewControllers:@[self.contents.firstObject] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:self.pageVC];
    [self.view addSubview:self.pageVC.view];
    [self.pageVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
}

#pragma mark - Control Action
- (void)cancelAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneAction {
    [self.normalVC saveAndGetSettingInfo];
    NSArray *array = [self.siftVC saveAndGetSettingInfo];
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingController:changeSiftSettingWithArr:)]) {
        [self.delegate settingController:self changeSiftSettingWithArr:array];
    }
    [self cancelAction];
}

#pragma mark -- UIPageViewControllerDataSource
// 向后滑
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSInteger index = [self.contents indexOfObject:viewController];
    index--;
    if (index < 0) {
        return nil;
    }
    self.currentPage = index;
    return self.contents[index];
}

// 向前滑
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSInteger index = [self.contents indexOfObject:viewController];
    index++;
    if (index > self.contents.count - 1) {
        return nil;
    }
    self.currentPage = index;
    return self.contents[index];
}

#pragma mark -- UIPageViewControllerDelegate
// 将要滑动
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    UIViewController *nextVC = pendingViewControllers.firstObject;
    NSInteger index = [self.contents indexOfObject:nextVC];
    self.currentPage = index;
}

// 结束滑动
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    if (completed) {
        self.navgationHeadView.selectIndex = self.currentPage;
    }
}

#pragma mark - Getter
- (QJSearchSettingNavHeadView *)navgationHeadView {
    if (nil == _navgationHeadView) {
        _navgationHeadView = [[QJSearchSettingNavHeadView alloc] initWithArray:@[@"一般设定", @"高级筛选"]];
    }
    return _navgationHeadView;
}

- (NSArray *)contents {
    if (nil == _contents) {
        _contents = @[self.normalVC, self.siftVC];
    }
    return _contents;
}

- (QJSearchSettingSubViewController *)normalVC {
    if (nil == _normalVC) {
        _normalVC = [QJSearchSettingSubViewController new];
        _normalVC.type = QJSearchSettingSubViewControllerTypeNormal;
    }
    return _normalVC;
}

- (QJSearchSettingSubViewController *)siftVC {
    if (nil == _siftVC) {
        _siftVC = [QJSearchSettingSubViewController new];
        _siftVC.type = QJSearchSettingSubViewControllerTypeSift;
        _siftVC.settings = self.settings;
    }
    return _siftVC;
}

- (UIPageViewController *)pageVC {
    if (nil == _pageVC) {
        _pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageVC.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _pageVC.delegate = self;
        _pageVC.dataSource = self;
    }
    return _pageVC;
}

@end
