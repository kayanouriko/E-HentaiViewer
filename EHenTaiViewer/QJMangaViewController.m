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

@interface QJMangaViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,QJMangaItemDelagate, UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navgationBar;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *toolButtomBar;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UIBarButtonItem *shareItem;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navgationBarTopLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderBarButtomLine;
//计数部分
@property (weak, nonatomic) IBOutlet UIView *pageCountView;
@property (weak, nonatomic) IBOutlet UILabel *pageCountLabel;

//下部显示信息部分
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *pageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoViewBottomLine;

- (IBAction)backAction:(UIBarButtonItem *)sender;
//滑动杆的相关触碰事件
- (IBAction)sliderValueChange:(UISlider *)sender;
- (IBAction)fingerIn:(UISlider *)sender;
- (IBAction)fingerOut:(UISlider *)sender;

@end

@implementation QJMangaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContent];
    [self updateResource];
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
    self.navgationBar.delegate = self;
    
    self.pageLabel.text = [NSString stringWithFormat:@"%d / %ld",1,self.count];
    self.navgationBar.topItem.title = self.pageLabel.text;
    self.view.backgroundColor = [UIColor whiteColor];
    
    //添加view
    [self.view addSubview:self.collectionView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_collectionView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_collectionView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(StatusBarHeight)-[_collectionView]-(TabBarSafeBottomMargin)-|" options:0 metrics:@{@"StatusBarHeight": @(UIStatusBarHeight()), @"TabBarSafeBottomMargin": @(UITabBarSafeBottomMargin())} views:NSDictionaryOfVariableBindings(_collectionView)]];
    
    [self.view bringSubviewToFront:self.infoView];
    [self.view bringSubviewToFront:self.pageCountView];
    self.infoViewBottomLine.constant = UITabBarSafeBottomMargin();
    [self.view bringSubviewToFront:self.navgationBar];
    [self.view bringSubviewToFront:self.toolButtomBar];
    //滑杆最大值
    self.slider.maximumValue = self.count - 1;
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (void)changeNavbarAndSliderBar {
    if (self.navgationBarTopLine.constant > 0) {
        [self hidden];
    }
    else {
        [self show];
    }
}

- (void)show {
    if (self.navgationBar.hidden) {
        self.navgationBar.hidden = NO;
    }
    [UIView animateWithDuration:0.25f animations:^{
        self.navgationBarTopLine.constant = UIStatusBarHeight();
        self.sliderBarButtomLine.constant = UITabBarSafeBottomMargin();
        [self.view layoutIfNeeded];
    }];
}

- (void)hidden {
    [UIView animateWithDuration:0.25f animations:^{
        self.navgationBarTopLine.constant = -UINavigationBarHeight();
        self.sliderBarButtomLine.constant = -UITabBarHeight();
        [self.view layoutIfNeeded];
    }];
}

#pragma mark -滑动条值改变
- (IBAction)backAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sliderValueChange:(UISlider *)sender {
    CGFloat currValue = sender.value;
    NSInteger page = currValue / 1;
    self.pageCountLabel.text = [NSString stringWithFormat:@"%ld",page];
    self.pageLabel.text = [NSString stringWithFormat:@"%ld / %ld",(long)page,self.count];
    self.navgationBar.topItem.title = self.pageLabel.text;
}

- (IBAction)fingerOut:(UISlider *)sender {
    CGFloat currValue = sender.value;
    NSInteger page = currValue / 1;
    NSIndexPath *indexPrev=[NSIndexPath indexPathForItem:page inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPrev atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    self.pageCountView.hidden = YES;
    [self hidden];
}

- (IBAction)fingerIn:(UISlider *)sender {
    self.pageCountView.hidden = NO;
    CGPoint currOffsize = self.collectionView.contentOffset;
    NSInteger currCount = currOffsize.x / UIScreenWidth() + 1;
    self.pageCountLabel.text = [NSString stringWithFormat:@"%ld",currCount];
}

#pragma mark -QJMangaItemDelagate
- (void)changeWillBegin {
    [self hidden];
}

- (void)tapInWebView {
    [self changeNavbarAndSliderBar];
}

- (void)forwardPage {
    CGPoint currOffsize = self.collectionView.contentOffset;
    NSInteger currCount = currOffsize.x / UIScreenWidth();
    NSIndexPath *indexNow = [NSIndexPath indexPathForItem:currCount inSection:0];
    if (indexNow.item >= 1) {
        self.view.userInteractionEnabled = NO;
        NSIndexPath *indexPrev = [NSIndexPath indexPathForItem:indexNow.item - 1 inSection:indexNow.section];
        [self.collectionView reloadItemsAtIndexPaths:@[indexPrev]];
        [self.collectionView scrollToItemAtIndexPath:indexPrev atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    } else {
        [self show];
    }
}

- (void)nextPage {
    CGPoint currOffsize = self.collectionView.contentOffset;
    NSInteger currCount = currOffsize.x / UIScreenWidth();
    NSIndexPath *indexNow = [NSIndexPath indexPathForItem:currCount inSection:0];
    if (indexNow.item <= self.items.count - 2) {
        self.view.userInteractionEnabled = NO;
        NSIndexPath *indexNext = [NSIndexPath indexPathForItem:indexNow.item + 1 inSection:indexNow.section];
        [self.collectionView reloadItemsAtIndexPaths:@[indexNext]];
        [self.collectionView scrollToItemAtIndexPath:indexNext atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    } else {
        [self show];
    }
}

#pragma mark -scrollview
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint currOffsize = self.collectionView.contentOffset;
    NSInteger currCount = currOffsize.x / UIScreenWidth() + 1;
    self.pageLabel.text = [NSString stringWithFormat:@"%ld / %ld",(long)currCount,self.count];
    self.navgationBar.topItem.title = self.pageLabel.text;
    self.slider.value = currCount - 1;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (!self.pageCountView.hidden) self.pageCountView.hidden = YES;
    self.view.userInteractionEnabled = YES;
    [self hidden];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hidden];
}

#pragma mark -collection
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QJMangaItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([QJMangaItem class]) forIndexPath:indexPath];
    item.delegate = self;
    [item refreshItem:self.items[indexPath.item]];
    return item;
}

#pragma mark -懒加载
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        QJMangaFlowLayout *layout = [QJMangaFlowLayout new];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 20, UIScreenWidth(), UIScreenHeight() - 20) collectionViewLayout:layout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLogFunc();
}


@end
