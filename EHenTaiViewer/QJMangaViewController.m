//
//  QJMangaViewController.m
//  testImageView
//
//  Created by QinJ on 2017/5/3.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJMangaViewController.h"
#import "QJMangaFlowLayout.h"
#import "QJMangaItem.h"
#import "QJHenTaiParser.h"

@interface QJMangaViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,QJMangaItemDelagate>

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderButtomLine;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UIBarButtonItem *shareItem;

- (IBAction)sliderValueChange:(UISlider *)sender;

@end

@implementation QJMangaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContent];
    [self updateResource];
}

//该页面不需要侧滑返回,容易造成误操作
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

#pragma mark -数据刷新
- (void)updateResource {
    [[QJHenTaiParser parser] updateBigImageUrlWithShowKey:self.showkey gid:self.gid url:self.url count:self.count complete:^(NSArray<QJBigImageItem *> *bigImages) {
        [self.items addObjectsFromArray:bigImages];
        [self.collectionView reloadData];
    }];
}

#pragma mark -内容设置
- (void)setContent {
    self.title = [NSString stringWithFormat:@"(%d / %ld)",1,self.count];
    //TODO:分享功能暂时不做
    //self.navigationItem.rightBarButtonItem = self.shareItem;
    //添加view
    [self.view addSubview:self.collectionView];
    [self.view bringSubviewToFront:self.slider];
    //滑杆最大值
    self.slider.maximumValue = self.count - 1;
}

#pragma mark -右上角分享
- (void)clickShare {
    /*
     UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[self.item.title, self.thumbImageView.image] applicationActivities:nil];
     activity.excludedActivityTypes = @[UIActivityTypeAirDrop];
     
     UIPopoverPresentationController *popover = activity.popoverPresentationController;
     if (popover) {
     popover.sourceView = self.shareItem.customView;
     popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
     }
     
     [self presentViewController:activity animated:YES completion:nil];
     
     activity.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
     
     };
     */
}

- (void)changeNavbarAndSliderBar {
    if (self.navigationController.navigationBarHidden) {
        [self show];
    }
    else {
        [self hidden];
    }
}

- (void)show {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIView animateWithDuration:0.25f animations:^{
        self.sliderButtomLine.constant = 10;
        [self.view layoutIfNeeded];
    }];
}

- (void)hidden {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIView animateWithDuration:0.25f animations:^{
        self.sliderButtomLine.constant = -41;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark -滑动条值改变
- (IBAction)sliderValueChange:(UISlider *)sender {
    CGFloat currValue = sender.value;
    NSInteger page = currValue / 1;
    CGPoint currOffsize = self.collectionView.contentOffset;
    currOffsize.x = page * UIScreenWidth();
    [self.collectionView setContentOffset:currOffsize animated:NO];
}

#pragma mark -QJMangaItemDelagate
- (void)changeWillBegin {
    [self hidden];
}

- (void)tapInWebView {
    [self changeNavbarAndSliderBar];
}

- (void)forwardPage {
    [self customAction];
    CGPoint currOffsize = self.collectionView.contentOffset;
    currOffsize.x -= UIScreenWidth();
    if (currOffsize.x >= 0) {
        [self.collectionView setContentOffset:currOffsize animated:YES];
        self.view.userInteractionEnabled = NO;
    }
}

- (void)nextPage {
    [self customAction];
    CGPoint currOffsize = self.collectionView.contentOffset;
    currOffsize.x += UIScreenWidth();
    if (currOffsize.x <= UIScreenWidth() * (self.items.count - 1)) {
        [self.collectionView setContentOffset:currOffsize animated:YES];
        self.view.userInteractionEnabled = NO;
    }
}

//一些不能放在滚动代理里面的计算
- (void)customAction {
    [self hidden];
}

#pragma mark -scrollview
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint currOffsize = self.collectionView.contentOffset;
    NSInteger currCount = currOffsize.x / UIScreenWidth() + 1;
    self.title = [NSString stringWithFormat:@"(%ld / %ld)",(long)currCount,self.count];
    self.slider.value = currCount - 1;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.view.userInteractionEnabled = YES;
}

#pragma mark -collection
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QJMangaItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([QJMangaItem class]) forIndexPath:indexPath];
    if (!item.delegate) {
        item.delegate = self;
    }
    [item refreshItem:self.items[indexPath.item]];
    return item;
}

#pragma mark -懒加载
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        QJMangaFlowLayout *layout = [QJMangaFlowLayout new];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 20, UIScreenWidth(), UIScreenHeight() - 20) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[QJMangaItem class] forCellWithReuseIdentifier:NSStringFromClass([QJMangaItem class])];
    }
    return _collectionView;
}

- (NSMutableArray *)items {
    if (!_items) {
        _items = [NSMutableArray new];
    }
    return _items;
}

- (UIBarButtonItem *)shareItem {
    if (!_shareItem) {
        _shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(clickShare)];
    }
    return _shareItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLogFunc();
}


@end
