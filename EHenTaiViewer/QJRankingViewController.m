//
//  QJRankingViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/14.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//
//这个页面我写得怎么那么垃圾啊

#import "QJRankingViewController.h"
#import "QJRankingInfoCell.h"
#import "QJHenTaiParser.h"
#import "QJRankingHeadInfoCell.h"
#import "QJRankingUploadCell.h"
#import "QJNewInfoViewController.h"
#import "QJCollectionViewFlowLayout.h"
#import "QJButton.h"
#import "QJHomeViewController.h"

@interface QJRankingViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *yesterdayTopCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *yesterdayCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *yesterdayUploadCollectionView;

@property (weak, nonatomic) IBOutlet UICollectionView *monthTopCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *monthCollectionView;

@property (weak, nonatomic) IBOutlet UICollectionView *yearTopCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *yearCollectionView;

@property (weak, nonatomic) IBOutlet UICollectionView *allTimeTopCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *allTimeCollectionView;

@property (nonatomic, strong) NSMutableArray<NSArray<QJListItem *> *> *datas;
@property (nonatomic, strong) NSMutableArray<NSArray<QJToplistUploaderItem *> *> *uploads;
@property (nonatomic, strong) NSArray<NSString *> *urls;//用于跳转列表的url

- (IBAction)btnAction:(QJButton *)sender;


@end

@implementation QJRankingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
    
    [self showFreshingViewWithTip:nil];
    [self updateResource];
}

//跳转列表
- (IBAction)btnAction:(QJButton *)sender {
    NSInteger index = sender.tag - 200;
    QJHomeViewController *vc = [QJHomeViewController new];
    vc.navTitle = sender.value;
    vc.url = self.urls[index];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setContent {
    self.title = @"Toplist";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    QJCollectionViewFlowLayout *yesterdayTopLayout = [QJCollectionViewFlowLayout new];
    self.yesterdayTopCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.yesterdayTopCollectionView.delegate = self;
    self.yesterdayTopCollectionView.dataSource = self;
    self.yesterdayTopCollectionView.contentInset = UIEdgeInsetsMake(0, 30, 0, 30);
    self.yesterdayTopCollectionView.collectionViewLayout = yesterdayTopLayout;
    [self.yesterdayTopCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QJRankingHeadInfoCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([QJRankingHeadInfoCell class])];
    
    QJCollectionViewFlowLayout *yesterdayLayout = [QJCollectionViewFlowLayout new];
    self.yesterdayCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.yesterdayCollectionView.delegate = self;
    self.yesterdayCollectionView.dataSource = self;
    self.yesterdayCollectionView.contentInset = UIEdgeInsetsMake(0, 30, 0, 30);
    self.yesterdayCollectionView.collectionViewLayout = yesterdayLayout;
    [self.yesterdayCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QJRankingInfoCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([QJRankingInfoCell class])];
    
    QJCollectionViewFlowLayout *yesterdayUploadLayout = [QJCollectionViewFlowLayout new];
    self.yesterdayUploadCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.yesterdayUploadCollectionView.delegate = self;
    self.yesterdayUploadCollectionView.dataSource = self;
    self.yesterdayUploadCollectionView.contentInset = UIEdgeInsetsMake(0, 30, 0, 30);
    self.yesterdayUploadCollectionView.collectionViewLayout = yesterdayUploadLayout;
    [self.yesterdayUploadCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QJRankingUploadCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([QJRankingUploadCell class])];
    
    QJCollectionViewFlowLayout *monthTopLayout = [QJCollectionViewFlowLayout new];
    self.monthTopCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.monthTopCollectionView.delegate = self;
    self.monthTopCollectionView.dataSource = self;
    self.monthTopCollectionView.contentInset = UIEdgeInsetsMake(0, 30, 0, 30);
    self.monthTopCollectionView.collectionViewLayout = monthTopLayout;
    [self.monthTopCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QJRankingHeadInfoCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([QJRankingHeadInfoCell class])];
    
    QJCollectionViewFlowLayout *monthLayout = [QJCollectionViewFlowLayout new];
    self.monthCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.monthCollectionView.delegate = self;
    self.monthCollectionView.dataSource = self;
    self.monthCollectionView.contentInset = UIEdgeInsetsMake(0, 30, 0, 30);
    self.monthCollectionView.collectionViewLayout = monthLayout;
    [self.monthCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QJRankingInfoCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([QJRankingInfoCell class])];
    
    QJCollectionViewFlowLayout *yearTopLayout = [QJCollectionViewFlowLayout new];
    self.yearTopCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.yearTopCollectionView.delegate = self;
    self.yearTopCollectionView.dataSource = self;
    self.yearTopCollectionView.contentInset = UIEdgeInsetsMake(0, 30, 0, 30);
    self.yearTopCollectionView.collectionViewLayout = yearTopLayout;
    [self.yearTopCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QJRankingHeadInfoCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([QJRankingHeadInfoCell class])];
    
    QJCollectionViewFlowLayout *yearLayout = [QJCollectionViewFlowLayout new];
    self.yearCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.yearCollectionView.delegate = self;
    self.yearCollectionView.dataSource = self;
    self.yearCollectionView.contentInset = UIEdgeInsetsMake(0, 30, 0, 30);
    self.yearCollectionView.collectionViewLayout = yearLayout;
    [self.yearCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QJRankingInfoCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([QJRankingInfoCell class])];
    
    QJCollectionViewFlowLayout *allTimeTopLayout = [QJCollectionViewFlowLayout new];
    self.allTimeTopCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.allTimeTopCollectionView.delegate = self;
    self.allTimeTopCollectionView.dataSource = self;
    self.allTimeTopCollectionView.contentInset = UIEdgeInsetsMake(0, 30, 0, 30);
    self.allTimeTopCollectionView.collectionViewLayout = allTimeTopLayout;
    [self.allTimeTopCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QJRankingHeadInfoCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([QJRankingHeadInfoCell class])];
    
    QJCollectionViewFlowLayout *allTimeLayout = [QJCollectionViewFlowLayout new];
    self.allTimeCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.allTimeCollectionView.delegate = self;
    self.allTimeCollectionView.dataSource = self;
    self.allTimeCollectionView.contentInset = UIEdgeInsetsMake(0, 30, 0, 30);
    self.allTimeCollectionView.collectionViewLayout = allTimeLayout;
    [self.allTimeCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QJRankingInfoCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([QJRankingInfoCell class])];
}

- (void)updateResource {
    [[QJHenTaiParser parser] updateToplistInfoComplete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray, NSArray<QJToplistUploaderItem *> *uploaderArrary) {
        if (status == QJHenTaiParserStatusSuccess) {
            NSMutableArray *subDatas = [NSMutableArray new];
            for (QJListItem *item in listArray) {
                [subDatas addObject:item];
                if (subDatas.count == 10) {
                    [self.datas addObject:[subDatas mutableCopy]];
                    [subDatas removeAllObjects];
                }
            }
            
            [subDatas removeAllObjects];
            for (QJToplistUploaderItem *item in uploaderArrary) {
                [subDatas addObject:item];
                if (subDatas.count == 10) {
                    [self.uploads addObject:[subDatas mutableCopy]];
                    [subDatas removeAllObjects];
                }
            }
            [self allCollectionViewReloadData];
            [self hiddenFreshingView];
        }
        else {
            [self showErrorViewWithTip:nil];
        }
    }];
}

- (void)allCollectionViewReloadData {
    [self.yesterdayTopCollectionView reloadData];
    [self.monthTopCollectionView reloadData];
    [self.yearTopCollectionView reloadData];
    [self.allTimeTopCollectionView reloadData];
    
    [self.yesterdayCollectionView reloadData];
    [self.monthCollectionView reloadData];
    [self.yearCollectionView reloadData];
    [self.allTimeCollectionView reloadData];
    
    [self.yesterdayUploadCollectionView reloadData];
}

#pragma mark -collectionView
- (CGSize)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (collectionView == self.yesterdayCollectionView || collectionView == self.monthCollectionView || collectionView == self.yearCollectionView || collectionView == self.allTimeCollectionView) {
        return CGSizeMake(UIScreenWidth() - 30 - 30, 90);
    }
    else if (collectionView == self.yesterdayUploadCollectionView) {
        return CGSizeMake(UIScreenWidth() - 30 - 30, 50);
    }
    else {
        return CGSizeMake(UIScreenWidth() - 30 - 30, 270);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.yesterdayCollectionView || collectionView == self.monthCollectionView || collectionView == self.yearCollectionView || collectionView == self.allTimeCollectionView) {
        return self.datas.count ? 7 : 0;
    }
    else if (collectionView == self.yesterdayUploadCollectionView) {
        return self.uploads.count ? 10 : 0;
    }
    else {
        return self.datas.count ? 3 : 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.yesterdayCollectionView || collectionView == self.monthCollectionView || collectionView == self.yearCollectionView || collectionView == self.allTimeCollectionView) {
        QJRankingInfoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([QJRankingInfoCell class]) forIndexPath:indexPath];
        QJListItem *model = nil;
        if (collectionView == self.yesterdayCollectionView) {
            model = self.datas[3][indexPath.item + 3];
        }
        else if (collectionView == self.monthCollectionView) {
            model = self.datas[2][indexPath.item + 3];
        }
        else if (collectionView == self.yearCollectionView) {
            model = self.datas[1][indexPath.item + 3];
        }
        else if (collectionView == self.allTimeCollectionView) {
            model = self.datas[0][indexPath.item + 3];
        }
        cell.model = model;
        cell.underLine.hidden = !((indexPath.item + 1) % 2);
        return cell;
    }
    else if (collectionView == self.yesterdayUploadCollectionView) {
        QJRankingUploadCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([QJRankingUploadCell class]) forIndexPath:indexPath];
        QJToplistUploaderItem *model = nil;
        if (collectionView == self.yesterdayUploadCollectionView) {
            model = self.uploads[3][indexPath.item];
        }
        [cell refreshCellWithModel:model index:indexPath.row + 1 isHidden:!((indexPath.item + 1) % 2)];
        return cell;
    }
    else {
        QJRankingHeadInfoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([QJRankingHeadInfoCell class]) forIndexPath:indexPath];
        QJListItem *model = nil;
        if (collectionView == self.yesterdayTopCollectionView) {
            model = self.datas[3][indexPath.item];
        }
        else if (collectionView == self.monthTopCollectionView) {
            model = self.datas[2][indexPath.item];
        }
        else if (collectionView == self.yearTopCollectionView) {
            model = self.datas[1][indexPath.item];
        }
        else if (collectionView == self.allTimeTopCollectionView) {
            model = self.datas[0][indexPath.item];
        }
        cell.index = indexPath.row + 1;
        cell.model = model;
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QJListItem *model = nil;
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[QJRankingHeadInfoCell class]]) {
        model = ((QJRankingHeadInfoCell *)cell).model;
    } else {
        model = ((QJRankingInfoCell *)cell).model;
    }
    QJNewInfoViewController *vc = [QJNewInfoViewController new];
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -getter
- (NSMutableArray<NSArray<QJListItem *> *> *)datas {
    if (nil == _datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

- (NSMutableArray<NSArray<QJToplistUploaderItem *> *> *)uploads {
    if (nil == _uploads) {
        _uploads = [NSMutableArray new];
    }
    return _uploads;
}

- (NSArray<NSString *> *)urls {
    if (nil == _urls) {
        _urls = @[@"https://e-hentai.org/toplist.php?tl=15",
                  @"https://e-hentai.org/toplist.php?tl=13",
                  @"https://e-hentai.org/toplist.php?tl=12",
                  @"https://e-hentai.org/toplist.php?tl=11"];
    }
    return _urls;
}

@end
