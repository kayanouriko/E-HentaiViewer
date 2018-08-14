//
//  QJNewBrowerViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/7.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJNewBrowerViewController.h"
#import "QJMangaManager.h"
#import "QJMangaImageDownloader.h"
#import "QJMangaImageModel.h"
#import "QJCollectionViewFlowLayout.h"
#import "QJNewBrowerImageCell.h"
#import "QJOrientationManager.h"
#import "QJBrowerSettingPopView.h"
#import "QJLabel.h"
#import "QJBrowserBookMarkPopView.h"

//iconfont
#import "TBCityIconFont.h"
#import "UIImage+TBCityIconFont.h"

// coredata
#import "QJBrowerCollectManager.h"

@interface QJNewBrowerViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, QJBrowerSettingPopViewDelegate, UIGestureRecognizerDelegate, QJNewBrowerImageCellDelegate, QJBrowserBookMarkPopViewDelegate>

// 导航栏部分
@property (nonatomic, strong) UIBarButtonItem *funcItem;
@property (nonatomic, strong) UIBarButtonItem *addFavorteItem;
@property (nonatomic, strong) UIBarButtonItem *removeFavorteItem;
@property (nonatomic, strong) UIBarButtonItem *favoriteItem;
@property (nonatomic, strong) UIBarButtonItem *cancelItem;
@property (nonatomic, strong) UIBarButtonItem *saveItem;
@property (weak, nonatomic) IBOutlet QJLabel *mangaNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mangaNameLabelTopLine;

//弹出框
@property (nonatomic, strong) QJBrowerSettingPopView *popView;
@property (nonatomic, strong) QJBrowserBookMarkPopView *bookmarkPopView;

// 图片部分
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) NSArray<QJMangaImageModel *> *datas;
@property (nonatomic, strong) QJMangaManager *manager;
// 滑动部分
@property (weak, nonatomic) IBOutlet UIView *pageCountBgView;
@property (weak, nonatomic) IBOutlet UILabel *pageCountBigLabel;
// 工具栏部分
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
- (IBAction)progressSliderValueChange:(UISlider *)sender;
- (IBAction)sliderTouchDown:(UISlider *)sender;
- (IBAction)sliderUpInside:(UISlider *)sender;

@property (weak, nonatomic) IBOutlet QJLabel *pageCountLabel;

// 当前页数
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign) NSInteger currentPage;

// 杂项
@property (nonatomic, assign, getter=isFristRefresh) BOOL fristRefresh;

@end

@implementation QJNewBrowerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    [self initData];
}

- (void)initUI {
    // 数据初始化
    self.currentPage = 0;
    self.fristRefresh = YES;
    // 当状态栏变动的时候不调整collectionView的frame
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    // 状态栏,导航栏初始化
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
    // 添加item
    self.navigationItem.leftBarButtonItems = @[self.cancelItem, self.favoriteItem];
    [self changeNavgationBarRightItems];
    // 设置画廊名字和当前页码
    self.mangaNameLabel.text = self.mangaName;
    self.mangaNameLabelTopLine.constant = UINavigationBarHeight() + 20;
    self.pageCountLabel.text = [NSString stringWithFormat:@"1 / %ld", self.count];
    // 工具栏的初始化
    // 修复底部安全区域的问题
    if (@available(iOS 11.0, *)) {
        [self.toolBar.lastBaselineAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    } else {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.toolBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    }
    // 设置Slider最大最小
    self.progressSlider.minimumValue = 1.f;
    self.progressSlider.maximumValue = self.count;
    // 背景颜色设置为黑色
    self.view.backgroundColor = [UIColor blackColor];
    // collectionView相关属性
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.collectionView.collectionViewLayout = self.layout;
    self.collectionView.pagingEnabled = self.layout.scrollDirection == UICollectionViewScrollDirectionHorizontal;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QJNewBrowerImageCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([QJNewBrowerImageCell class])];
    // 添加全局手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickView:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)initData {
    // 创建管理器,并刷新数据
    self.manager = [[QJMangaManager alloc] initWithShowKey:self.showkey gid:self.gid url:self.url count:self.count imageUrls:self.imageUrls smallImageUrls:self.smallImageUrls];
    self.datas = self.manager.photos;
    [self.collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 获取配置中的转屏并修改
    [QJOrientationManager changeOrientationFromSetting];
    // 转屏监听新方法
    // UIDeviceOrientationDidChangeNotification为系统的转屏
    // UIApplicationDidChangeStatusBarOrientationNotification UIApplicationWillChangeStatusBarOrientationNotification为软件转屏通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    //禁用侧滑手势方法
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isFristRefresh) {
        self.fristRefresh = NO;
        [self loadImageForOnscreenCellsWithIndexPath:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 把转屏重新修正为竖屏
    [QJOrientationManager recoverPortraitOrienttation];
    // 删除转屏监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    // 重新启动侧滑手势方法
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    // 下载任务退出
    [self.manager cancelAllOperations];
    self.manager = nil;
}

#pragma mark - NSNotificationCenter
- (void)deviceOrientationDidChange {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (self.orientation == orientation) return;
    // 刷新数据
    [self.collectionView reloadData];
    // 复原当前页码
    CGFloat height = 0;
    if (!(isAppScrollDiretionHorizontal)) {
        for (NSInteger i = 0; i < self.currentPage; i++) {
            height += self.datas[i].size.height;
        }
    }
    CGPoint contentOffset = isAppScrollDiretionHorizontal ? CGPointMake(self.currentPage * UIScreenWidth(), 0) : CGPointMake(0, height);
    [self.collectionView setContentOffset:contentOffset];
    self.orientation = orientation;
    // 刷新布局
    self.mangaNameLabelTopLine.constant = (isAppOrientationPortrait ? UINavigationBarHeight() : UISearchBarHeight()) + 20;
    if (self.popView.isShowed) {
        [self.popView changeFrameIfNeed];
    }
    if (self.bookmarkPopView.isShowed) {
        [self.bookmarkPopView changeFrameIfNeedWithIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]];
    }
}

#pragma mark - ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (!self.navigationController.navigationBarHidden) {
        [self clickView:nil];
    }
    [self.manager suspendAllOperations];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadImageForOnscreenCellsWithIndexPath:nil];
        [self.manager resumeAllOperations];
        [self changeControllerInfo];
        // 更换导航栏按钮
        [self changeNavgationBarRightItems];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImageForOnscreenCellsWithIndexPath:nil];
    [self.manager resumeAllOperations];
    [self changeControllerInfo];
    // 更换导航栏按钮
    [self changeNavgationBarRightItems];
}

#pragma mark - Cancelling Suspending Resuming Queues/Operations
/** 开始cell下载的任务
 @param indexPath 如果是滚动的,则传入nil,从collectionView中获取,否则通过indexPath来获取
 */
- (void)loadImageForOnscreenCellsWithIndexPath:(NSIndexPath *)indexPath {
    // 数据不存在的时候直接返回
    if (self.datas.count == 0) return;
    @autoreleasepool {
        NSMutableArray *visibleItems = [NSMutableArray new];
        if (indexPath) {
            [visibleItems addObject:indexPath];
        } else {
            // 找到目前显示的cell，把他前后两个cell和本身加入下载队列
            visibleItems = [NSMutableArray arrayWithArray:[self.collectionView indexPathsForVisibleItems]];
            // 如果没有找到显示的cell，默认把第一个加入下载任务
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            if (visibleItems.count == 0) {
                [visibleItems addObject:indexPath];
            }
        }
        
        NSIndexPath *preIndexPath = nil;
        NSIndexPath *nextIndexPath = nil;
        
        NSInteger maxItem = [[visibleItems valueForKeyPath:@"@max.item"] integerValue];
        NSInteger minItem = [[visibleItems valueForKeyPath:@"@min.item"] integerValue];
        
        if (maxItem + 1 < self.datas.count) {
            nextIndexPath = [NSIndexPath indexPathForItem:maxItem + 1 inSection:0];
            [visibleItems addObject:nextIndexPath];
        }
        if (minItem - 1 >= 0) {
            preIndexPath = [NSIndexPath indexPathForItem:minItem - 1 inSection:0];
            [visibleItems addObject:preIndexPath];
        }
        
        NSSet *visibleRows = [NSSet setWithArray:visibleItems];
        ///> 正在下载和滤镜的cell
        NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[self.manager.downloads allKeys]];
        
        NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
        NSMutableSet *toBeStarted = [visibleRows mutableCopy];
        
        ///> 需要被操作的行 = 可见的 - 挂起的
        [toBeStarted minusSet:pendingOperations];
        
        ///> 需要被取消的行 = 挂起的 - 可见的
        [toBeCancelled minusSet:visibleRows];
        
        // 虽然麻烦点，先遍历确认一下需要下载的model是否已经完成了？如果完成了，则不删除正在下载的队列
        BOOL isFinish = YES;
        if (toBeStarted.count == 0) {
            isFinish = YES;
        }
        else {
            for (NSIndexPath *anIndexPath in toBeStarted) {
                QJMangaImageModel *recordToProcess = [self.datas objectAtIndex:anIndexPath.row];
                if (![recordToProcess hasImage]) {
                    isFinish = NO;
                    break;
                }
            }
        }
        // 如果只有需要下载的没有完成的时候才进行更新队列的操作
        if (!isFinish) {
            for (NSIndexPath *anIndexPath in toBeCancelled) {
                QJMangaImageDownloader *pendingDownload = [self.manager.downloads objectForKey:anIndexPath];
                // 先取消请求，再取消任务
                [pendingDownload cancelTask];
                [pendingDownload cancel];
                [self.manager.downloads removeObjectForKey:anIndexPath];
                // model的代理也要取消
                self.datas[anIndexPath.item].delegate = nil;
            }
            for (NSIndexPath *anIndexPath in toBeStarted) {
                QJMangaImageModel *recordToProcess = [self.datas objectAtIndex:anIndexPath.row];
                [self.manager startOperationForModel:recordToProcess atIndexPath:anIndexPath];
            }
        }
    }
}

#pragma mark - CollectionView Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        return CGSizeMake(UIScreenWidth(), UIScreenHeight());
    } else {
        QJMangaImageModel *model = self.datas[indexPath.item];
        return model.size;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QJNewBrowerImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([QJNewBrowerImageCell class]) forIndexPath:indexPath];
    cell.model = self.datas[indexPath.item];
    cell.delegate = self;
    return cell;
}

#pragma mark - UIGestureRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:NSStringFromClass([UIToolbar class])] || [NSStringFromClass([touch.view class]) isEqualToString:NSStringFromClass([UISlider class])]) {
        return NO;
    }
    return  YES;
}

#pragma mark - Tool Action
// 全屏单击手势
- (void)clickView:(UITapGestureRecognizer *)tap {
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden];
    [[UIApplication sharedApplication] setStatusBarHidden:self.navigationController.navigationBarHidden];
    self.toolBar.hidden = self.navigationController.navigationBarHidden;
    self.pageCountLabel.hidden = self.navigationController.navigationBarHidden;
    self.mangaNameLabel.hidden = self.navigationController.navigationBarHidden;
}

- (void)cancelAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectFavorteAction {
    [self.bookmarkPopView showWithIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]];
}

- (void)addFavorteAction {
    // 添加收藏
    if (self.datas[self.currentPage].smallImageUrl.length) {
        [QJBrowerCollectManager saveOnePageWithGid:self.gid pageIndex:self.currentPage smallImageUrl:self.datas[self.currentPage].smallImageUrl];
        [self changeNavgationBarRightItems];
    }
    else {
        Toast(@"该页图片开始下载之后才能添加书签");
    }
}

- (void)removeFavorteAction {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定取消该页的书签?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:cancelBtn];
    UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [QJBrowerCollectManager deleteOnePageWithGid:self.gid pageIndex:self.currentPage smallImageUrl:self.datas[self.currentPage].smallImageUrl];
        [self changeNavgationBarRightItems];
    }];
    [alertVC addAction:okBtn];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)changeNavgationBarRightItems {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"page == %ld",self.currentPage];
    BOOL isColected = [[QJBrowerCollectManager getAllCollectPagesWithGid:self.gid] filteredArrayUsingPredicate:predicate].count;
    self.navigationItem.rightBarButtonItems = @[self.funcItem, isColected ? self.removeFavorteItem : self.addFavorteItem, self.saveItem];
}

// 右上角更多功能item
- (void)showFuncAction {
    [self.popView show];
}

- (void)saveAction {
    NSString *imagePath = self.datas[self.currentPage].imagePath;
    if (imagePath && imagePath.length) {
        [QJOrientationManager saveImageToSystemThumbWithImagePath:imagePath];
    } else {
        Toast(@"该页图片暂时无法存储");
    }
}

// 进度修改的时候执行的方法
- (IBAction)progressSliderValueChange:(UISlider *)sender {
    self.currentPage = sender.value - 1;
    [self changeBrowserInfo];
}

- (void)changeBrowserInfo {
    self.pageCountBigLabel.text = [NSString stringWithFormat:@"%ld", self.currentPage + 1];
    self.pageCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", self.currentPage + 1, self.count];
}

- (IBAction)sliderTouchDown:(UISlider *)sender {
    self.pageCountBgView.hidden = NO;
    self.pageCountBigLabel.text = [NSString stringWithFormat:@"%ld", self.currentPage + 1];
    // 先暂停任务
    [self.manager suspendAllOperations];
}

- (IBAction)sliderUpInside:(UISlider *)sender {
    self.pageCountBgView.hidden = YES;
    [self changePage];
}

- (void)changePage {
    // 跳转对应的页码
    CGFloat height = 0;
    if (!(isAppScrollDiretionHorizontal)) {
        for (NSInteger i = 0; i < self.currentPage; i++) {
            height += self.datas[i].size.height + 10;
        }
    }
    CGPoint contentOffset = isAppScrollDiretionHorizontal ? CGPointMake(self.currentPage * UIScreenWidth(), 0) : CGPointMake(0, height);
    [self.collectionView setContentOffset:contentOffset];
    // 下载相关
    [self loadImageForOnscreenCellsWithIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]];
    [self.manager resumeAllOperations];
}

#pragma mark - QJNewBrowerImageCell Delegate
- (void)collectionViewShouldRefreshWithModel:(QJMangaImageModel *)model {
    NSInteger item = [self.datas indexOfObject:model];
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:item inSection:0]]];
}

- (void)scrollViewInCellWillBeginDragging {
    if (!self.navigationController.navigationBarHidden) {
        [self clickView:nil];
    }
}

#pragma mark - QJBrowerSettingPopView Delegate
- (NSInteger)currentOrientationSegSelectedIndex {
    return [QJOrientationManager getOrientationSegSelected];
}

- (NSInteger)currentDirectionSegSelectedIndex {
    return [QJOrientationManager getDiretionSegSelected];
}

- (CGFloat)currentBrightness {
    return [UIScreen mainScreen].brightness;
}

- (void)orientationSegDidClickBtnWithSelectedIndex:(NSInteger)selectedIndex {
    [QJOrientationManager setOrientationWithSelected:selectedIndex];
}

- (void)directionSegDidClickBtnWithSelectedIndex:(NSInteger)selectedIndex {
    [QJOrientationManager setDiretionWithSelected:selectedIndex];
    // 这里刷新collectionview的滚动方式
    UICollectionViewScrollDirection customDirection = [QJGlobalInfo customScrollDiretion];
    self.layout.scrollDirection = customDirection;
    self.layout.minimumLineSpacing = isAppScrollDiretionHorizontal ? 0 : 10;
    self.collectionView.pagingEnabled = isAppScrollDiretionHorizontal;
    [self.collectionView reloadData];
    
    CGFloat height = 0;
    if (!(isAppScrollDiretionHorizontal)) {
        for (NSInteger i = 0; i < self.currentPage; i++) {
            height += self.datas[i].size.height + 10;
        }
    }
    CGPoint contentOffset = isAppScrollDiretionHorizontal ? CGPointMake(self.currentPage * UIScreenWidth(), 0) : CGPointMake(0, height);
    [self.collectionView setContentOffset:contentOffset];
}

- (void)brightnessSliderDidChangeValue:(CGFloat)value {
    [UIScreen mainScreen].brightness = value;
}

#pragma mark - QJBrowserBookMarkPopView Delegate
- (void)didSelectImageWithIndex:(NSInteger)index {
    if (!self.navigationController.navigationBarHidden) {
        [self clickView:nil];
    }
    self.currentPage = index;
    self.progressSlider.value = self.currentPage + 1;
    [self changeBrowserInfo];
    [self changePage];
    [self changeNavgationBarRightItems];
}

#pragma mark - Other
- (void)changeControllerInfo {
    if (isAppScrollDiretionHorizontal) {
        // 左右滚动的时候
        self.currentPage = self.collectionView.contentOffset.x / UIScreenWidth();
    } else {
        // 上下滚动的时候
        NSInteger page = 0;
        NSInteger height = 0;
        for (NSInteger i = 0; i < self.datas.count; i++) {
            height += self.datas[i].size.height + 10;
            if (height >= self.collectionView.contentOffset.y) {
                page = i;
                break;
            }
        }
        self.currentPage = page;
    }
    self.progressSlider.value = self.currentPage + 1;
    self.pageCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", self.currentPage + 1, (long)self.count];
}

#pragma mark -getter
- (UIBarButtonItem *)cancelItem {
    if (nil == _cancelItem) {
        _cancelItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e607", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    }
    return _cancelItem;
}

- (UIBarButtonItem *)favoriteItem {
    if (nil == _favoriteItem) {
        _favoriteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e60c", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(selectFavorteAction)];
    }
    return _favoriteItem;
}

- (UIBarButtonItem *)funcItem {
    if (nil == _funcItem) {
        _funcItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e614", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(showFuncAction)];
    }
    return _funcItem;
}

- (UIBarButtonItem *)addFavorteItem {
    if (nil == _addFavorteItem) {
        _addFavorteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e619", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(addFavorteAction)];
    }
    return _addFavorteItem;
}

- (UIBarButtonItem *)removeFavorteItem {
    if (nil == _removeFavorteItem) {
        _removeFavorteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e60e", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(removeFavorteAction)];
    }
    return _removeFavorteItem;
}

- (UIBarButtonItem *)saveItem {
    if (nil == _saveItem) {
        _saveItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e62a", 28, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    }
    return _saveItem;
}

- (NSArray<QJMangaImageModel *> *)datas {
    if (nil == _datas) {
        _datas = @[];
    }
    return _datas;
}

- (UICollectionViewFlowLayout *)layout {
    if (nil == _layout) {
        _layout = [UICollectionViewFlowLayout new];
        _layout.scrollDirection = [QJGlobalInfo customScrollDiretion];
        _layout.minimumLineSpacing = isAppScrollDiretionHorizontal ? 0 : 10;
        _layout.minimumInteritemSpacing = 0;
    }
    return _layout;
}

- (QJBrowerSettingPopView *)popView {
    if (nil == _popView) {
        _popView = [QJBrowerSettingPopView initWithDelegate:self];
    }
    return _popView;
}

- (QJBrowserBookMarkPopView *)bookmarkPopView {
    if (!_bookmarkPopView) {
        _bookmarkPopView = [QJBrowserBookMarkPopView creatPopViewWithDelegate:self manager:self.manager gid:self.gid];
    }
    return _bookmarkPopView;
}

@end
