//
//  QJNewInfoViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/11/20.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJNewInfoViewController.h"
#import "XHStarRateView.h"
#import "QJListItem.h"
#import "QJHenTaiParser.h"
#import "QJGalleryItem.h"
#import "QJImageCollectionViewCell.h"
#import "QJTagView.h"
#import "QJNewCommentCell.h"
#import "QJNetworkTool.h"
#import "NSString+StringHeight.h"
#import "QJLikeButton.h"
#import "QJCollectionViewFlowLayout.h"

#import "QJTorrentInfoController.h"
#import "QJAllCommentController.h"
#import "QJSearchViewController.h"
#import "QJGoCommentController.h"
#import "QJFavouriteViewController.h"

#import "QJNewBrowerViewController.h"

//iconfont
#import "TBCityIconFont.h"
#import "UIImage+TBCityIconFont.h"

@interface QJNewInfoViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, QJNewCommentCellDelegate, XHStarRateViewDelegate, QJFavouriteViewControllerDelagate>

//导航栏部分
@property (nonatomic, strong) UIView *topBgView;
@property (nonatomic, strong) UIBarButtonItem *readItem;
@property (nonatomic, strong) UIBarButtonItem *actionItem;
//srollView
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomLine;
//段头详情部分
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIButton *readBtn;
@property (weak, nonatomic) IBOutlet UIView *likeBgView;
@property (nonatomic, strong) QJLikeButton *likeBtn;
@property (weak, nonatomic) IBOutlet UILabel *soreLabel;
@property (weak, nonatomic) IBOutlet UILabel *personLabel;
@property (weak, nonatomic) IBOutlet XHStarRateView *starView;
@property (weak, nonatomic) IBOutlet UIButton *catgroeyBtn;
@property (weak, nonatomic) IBOutlet UIButton *torrentBtn;
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;


//跳转磁力链接部分
- (IBAction)torrentAction:(UIButton *)sender;
//阅读
- (IBAction)readAction:(UIButton *)sender;

//预览部分
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightLine;
@property (nonatomic, strong) NSArray *previewDatas;

//标签部分
@property (weak, nonatomic) IBOutlet UIView *tagView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagViewHeightLine;

//评论及评分
@property (weak, nonatomic) IBOutlet XHStarRateView *commentStarView;
@property (weak, nonatomic) IBOutlet UILabel *commentTipLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *commentCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentCollectionViewHeightLine;

@property (nonatomic, strong) NSArray *commentDatas;
//跳转评论
- (IBAction)commentAction:(UIButton *)sender;
//撰写评论
- (IBAction)discussAction:(UIButton *)sender;

//信息
@property (weak, nonatomic) IBOutlet UILabel *btLabel;
@property (weak, nonatomic) IBOutlet UILabel *ryLabel;
@property (weak, nonatomic) IBOutlet UILabel *flLabel;
@property (weak, nonatomic) IBOutlet UILabel *sczLabel;
@property (weak, nonatomic) IBOutlet UILabel *scsjLabel;
@property (weak, nonatomic) IBOutlet UILabel *fhlLabel;
@property (weak, nonatomic) IBOutlet UILabel *kjxLabel;
@property (weak, nonatomic) IBOutlet UILabel *yyLabel;
@property (weak, nonatomic) IBOutlet UILabel *dxLabel;
@property (weak, nonatomic) IBOutlet UILabel *ysLabel;
@property (weak, nonatomic) IBOutlet UILabel *sccsLabel;

//其他部分
@property (nonatomic, strong) QJGalleryItem *infoModel;

- (IBAction)similarAction:(UIButton *)sender;
- (IBAction)otherAction:(UIButton *)sender;


@end

@implementation QJNewInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
    
    [self showFreshingViewWithTip:nil];
    [self updateResource];
}

- (void)setContent {
    self.view.userInteractionEnabled = NO;
    self.scrollView.delegate = self;
    self.scrollViewBottomLine.constant = UITabBarSafeBottomMargin();
    
    [self headPartUI];
    
    [self previewUI];
    
    [self baseInfoUI];
}

- (void)headPartUI {
    //两个按钮美化
    self.readBtn.layer.cornerRadius = 15.f;
    
    [self.likeBgView addSubview:self.likeBtn];
    [self.likeBgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_likeBtn]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_likeBtn)]];
    [self.likeBgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_likeBtn]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_likeBtn)]];
    self.likeBtn.likeState = QJLikeButtonStateLoading;
    //封面
    [self.thumbImageView yy_setImageWithURL:[NSURL URLWithString:self.model.thumb] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionHandleCookies];
    self.thumbImageView.layer.cornerRadius = 3.f;
    self.thumbImageView.clipsToBounds = YES;
    //标题
    self.titleLabel.text = ([QJGlobalInfo isExHentaiTitleJnMode] && self.model.title_jpn.length) ? self.model.title_jpn : self.model.title;
    //上传者
    self.authorLabel.text = self.model.uploader;
    //分类
    [self.catgroeyBtn setTitle:[NSString stringWithFormat:@"  %@  ",self.model.category] forState:UIControlStateNormal];
    self.catgroeyBtn.backgroundColor = self.model.categoryColor;
    self.catgroeyBtn.layer.cornerRadius = 3.f;
    self.catgroeyBtn.clipsToBounds = YES;
    //评分
    self.starView.backgroundColor = [UIColor clearColor];
    self.starView.currentScore = self.model.rating;
    self.soreLabel.text = [NSString stringWithFormat:@"%.02f", self.model.rating];
    //提示
    self.torrentBtn.hidden = !self.model.torrentcount;
}

- (void)previewUI {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;//设置水平滚动
    
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QJImageCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([QJImageCollectionViewCell class])];
    
    CGFloat width = UIScreenWidth() / 2.f > 240 ? 240 : UIScreenWidth() / 2.f;
    self.collectionViewHeightLine.constant = width * 4 / 3 + 20;
}

- (void)baseInfoUI {
    if ([[QJHenTaiParser parser] checkCookie]) {
        self.commentStarView.rateStyle = HalfStar;
    }
    else {
        self.commentStarView.userInteractionEnabled = NO;
    }
    
    self.commentCollectionView.delegate = self;
    self.commentCollectionView.dataSource = self;
    
    QJCollectionViewFlowLayout *layout = [QJCollectionViewFlowLayout new];
    self.commentCollectionView.contentInset = UIEdgeInsetsMake(0, 30, 0, 30);
    self.commentCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.commentCollectionView.collectionViewLayout = layout;
    self.commentCollectionView.backgroundColor = [UIColor clearColor];
    [self.commentCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QJNewCommentCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([QJNewCommentCell class])];
}

#pragma mark -XHStarRateViewDelegate
-(void)starRateView:(XHStarRateView *)starRateView currentScore:(CGFloat)currentScore {
    NSInteger rating = starRateView.currentScore * 2;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"是否为画廊评分为%ld?", rating] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:cancelBtn];
    UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        starRateView.userInteractionEnabled = NO;
        [[QJHenTaiParser parser] updateStarWithGid:self.model.gid token:self.model.token apikey:self.infoModel.apikey apiuid:self.infoModel.apiuid rating:rating complete:^(QJHenTaiParserStatus status) {
            starRateView.userInteractionEnabled = YES;
        }];
    }];
    [alertVC addAction:okBtn];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark -请求数据
- (void)updateResource {
    self.view.userInteractionEnabled = NO;
    [[QJHenTaiParser parser] updateGalleryInfoWithUrl:self.model.url complete:^(QJHenTaiParserStatus status, QJGalleryItem *item) {
        if (status == QJHenTaiParserStatusSuccess) {
            self.view.userInteractionEnabled = YES;
            self.infoModel = item;
            //段头
            self.personLabel.text = [NSString stringWithFormat:@"%@个评分",[item.baseInfoDic[@"favorited"] componentsSeparatedByString:@" "].firstObject];
            self.languageLabel.text = [item.baseInfoDic[@"language"] uppercaseString];
            //预览
            self.previewDatas = item.smallImages;
            [self.collectionView reloadData];
            //标签
            [self reloadTagViewWithTagArr:item.tagArr];
            //评论部分
            self.commentStarView.currentScore = item.customSore;
            self.commentStarView.delegate = self;
            
            self.commentDatas = item.comments;
            [self.commentCollectionView reloadData];
            if (self.commentDatas.count == 0) {
                self.commentCollectionViewHeightLine.constant = 31.f;
                self.commentCollectionView.hidden = YES;
            }
            else {
                self.commentTipLabel.hidden = YES;
            }
            //信息部分
            [self reloadBaseInfoWithDict:item.baseInfoDic];
            //改变收藏按钮
            [self changeFavoritesStatus];
            
            [self addActionItem];
            
            if ([self isShowFreshingStatus]) {
                [self hiddenFreshingView];
            }
        }
        else {
            if ([self isShowFreshingStatus]) {
                [self showErrorViewWithTip:nil];
            }
        }
    }];
}

- (void)addActionItem {
    self.navigationItem.rightBarButtonItem = self.actionItem;
}

- (void)shareAction {
    NSURL *url = [NSURL URLWithString:self.model.url];
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    UIPopoverPresentationController *popover = vc.popoverPresentationController;
    if (popover) {
        popover.sourceView = self.view;
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)changeFavoritesStatus {
    if (self.infoModel.isFavorite) {
        self.infoModel.isFavorite = YES;
        self.likeBtn.likeState = QJLikeButtonStateLike;
    } else {
        self.infoModel.isFavorite = NO;
        self.likeBtn.likeState = QJLikeButtonStateUnLike;
    }
}

- (void)reloadTagViewWithTagArr:(NSArray *)array {
    BOOL isCN = [QJGlobalInfo isExHentaiTagCnMode];
    CGFloat tagViewHeight = 10;
    for (NSArray *subArray in array) {
        CGFloat viewHeight = isCN ? [subArray[3] floatValue] : [subArray[2] floatValue];
        QJTagView *tagView = [[QJTagView alloc] initWithFrame:CGRectMake(0, tagViewHeight, UIScreenWidth(), viewHeight)];
        [self.tagView addSubview:tagView];
        [tagView refreshUI:subArray isCN:isCN];
        tagViewHeight += viewHeight;
    }
    //如果没有tag,提示没有tag
    if (array.count == 0) {
        UILabel *tagLabel = [UILabel new];
        tagLabel.text = @"没有标签";
        tagLabel.textAlignment = NSTextAlignmentCenter;
        tagLabel.font = AppFontContentStyle();
        tagLabel.frame = CGRectMake(0, 0, UIScreenWidth(), 50);
        tagLabel.textColor = [UIColor lightGrayColor];
        [self.tagView addSubview:tagLabel];
        tagViewHeight = 50;
    }
    self.tagViewHeightLine.constant = tagViewHeight;
}

- (void)reloadBaseInfoWithDict:(NSDictionary *)dict {
    self.btLabel.text = self.model.title;
    self.ryLabel.text = self.model.title_jpn;
    self.flLabel.text = [self.model.category lowercaseString];
    self.sczLabel.text = self.model.uploader;
    self.fhlLabel.text = dict[@"parent"];
    self.kjxLabel.text = dict[@"visible"];
    self.yyLabel.text = dict[@"language"];
    self.dxLabel.text = dict[@"size"];
    self.sccsLabel.text = dict[@"favorited"];
    self.ysLabel.text = dict[@"length"];
    self.scsjLabel.text = dict[@"posted"];
}

#pragma mark -按钮事件部分
- (IBAction)commentAction:(UIButton *)sender {
    if (self.commentDatas.count == 0) {
        Toast(@"尚未收到评论");
        return;
    }
    [self jumpAllComentVCWithIndex:0];
}

- (void)jumpAllComentVCWithIndex:(NSInteger)index {
    QJAllCommentController *vc = [QJAllCommentController new];
    vc.allComments = self.commentDatas;
    vc.index = index;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)discussAction:(UIButton *)sender {
    if (![[QJHenTaiParser parser] checkCookie]) {
        Toast(@"请先前往设置页面进行登录");
        return;
    }
    QJGoCommentController *vc = [QJGoCommentController new];
    vc.url = self.model.url;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)torrentAction:(UIButton *)sender {
    QJTorrentInfoController *vc = [QJTorrentInfoController new];
    vc.gid = self.model.gid;
    vc.token = self.model.token;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)readAction:(UIButton *)sender {
    [self jumpToReadBrower];
}

- (void)jumpToReadBrower {
    if ([[QJNetworkTool shareTool] isEnableMobleNetwork] && ![QJGlobalInfo isExHentaiWatchMode]) {
        Toast(@"想要浏览大图画廊请到设置中打开相关选项");
        return;
    }
    QJNewBrowerViewController *vc = [QJNewBrowerViewController new];
    vc.mangaName = self.model.title;
    vc.imageUrls = self.infoModel.imageUrls;
    vc.smallImageUrls = self.infoModel.smallImages;
    vc.url = self.model.url;
    vc.gid = self.model.gid;
    vc.count = self.model.filecount;
    vc.showkey = self.infoModel.showkey;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)similarAction:(UIButton *)sender {
    NSString *searchKey = [self.model.title handleString];
    NSString *url = [NSString stringWithFormat:@"?f_doujinshi=1&f_manga=1&f_artistcg=1&f_gamecg=1&f_western=1&f_non-h=1&f_imageset=1&f_cosplay=1&f_asianporn=1&f_misc=1&f_search=%@&f_apply=Apply+Filter",[searchKey urlEncode]];
    if (searchKey.length == 0) {
        Toast(@"暂无类似画廊");
        return;
    }
    QJGalleryTagItem *model = [QJGalleryTagItem new];
    model.searchKey = searchKey;
    model.url = url;
    [self pushSearchVCWithModel:model];
}

- (IBAction)otherAction:(UIButton *)sender {
    NSString *searchKey = [NSString stringWithFormat:@"uploader:%@", self.model.uploader];
    NSString *url = [NSString stringWithFormat:@"uploader/%@/", [self.model.uploader urlEncode]];
    QJGalleryTagItem *model = [QJGalleryTagItem new];
    model.searchKey = searchKey;
    model.url = url;
    [self pushSearchVCWithModel:model];
}

- (void)pushSearchVCWithModel:(QJGalleryTagItem *)model {
    QJSearchViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([QJSearchViewController class])];
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        CGFloat offsetY = scrollView.contentOffset.y;
        CGFloat readBtnOffsetY = self.readBtn.frame.origin.y + self.readBtn.frame.size.height - UINavigationBarHeight();
        if (offsetY > readBtnOffsetY) {
            //导航栏显示
            self.navigationItem.titleView = self.topBgView;
            self.navigationItem.rightBarButtonItem = self.readItem;
        } else {
            //导航栏不显示
            self.navigationItem.titleView = nil;
            self.navigationItem.rightBarButtonItem = self.actionItem;
        }
    }
}

#pragma mark -collectionView
- (CGSize)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (collectionView == self.collectionView) {
        CGFloat width = UIScreenWidth() / 2.f > 240 ? 240 : UIScreenWidth() / 2.f;
        return CGSizeMake(width , width * 4 / 3);
    } else {
        return CGSizeMake(UIScreenWidth() - 30 - 30 , collectionView.frame.size.height);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.collectionView) {
        return self.previewDatas.count;
    } else {
        return self.commentDatas.count >= 10 ? 10 : self.commentDatas.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.collectionView) {
        QJImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([QJImageCollectionViewCell class]) forIndexPath:indexPath];
        [cell.thumbImageView yy_setImageWithURL:[NSURL URLWithString:self.previewDatas[indexPath.item]] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionHandleCookies];
        return cell;
    } else {
        QJNewCommentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([QJNewCommentCell class]) forIndexPath:indexPath];
        [cell refreshUIWithDict:self.commentDatas[indexPath.item]];
        cell.delegate = self;
        return cell;
    }
}

#pragma mark -QJNewCommentCellDelegate
- (void)didClickMoreBtnWithCell:(QJNewCommentCell *)cell {
    NSInteger index = [self.commentCollectionView indexPathForCell:cell].row;
    [self jumpAllComentVCWithIndex:index];
}

#pragma mark -getter
- (NSArray *)previewDatas {
    if (nil == _previewDatas) {
        _previewDatas = [NSArray new];
    }
    return _previewDatas;
}

- (NSArray *)commentDatas {
    if (nil == _commentDatas) {
        _commentDatas = [NSArray new];
    }
    return _commentDatas;
}

- (UIView *)topBgView {
    if (nil == _topBgView) {
        _topBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _topBgView.backgroundColor = [UIColor clearColor];
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        imageview.layer.cornerRadius = 5.f;
        imageview.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        imageview.layer.borderWidth = .5f;
        imageview.layer.masksToBounds = YES;
        [imageview yy_setImageWithURL:[NSURL URLWithString:self.model.thumb] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionHandleCookies];
        [_topBgView addSubview:imageview];
    }
    return _topBgView;
}

- (UIBarButtonItem *)readItem {
    if (nil == _readItem) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 70, 30);
        btn.layer.cornerRadius = 15.f;
        btn.backgroundColor = DEFAULT_COLOR;
        btn.titleLabel.font = [UIFont systemFontOfSize:15.f];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:@"阅读" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(jumpToReadBrower) forControlEvents:UIControlEventTouchUpInside];
        _readItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    return _readItem;
}

- (UIBarButtonItem *)actionItem {
    if (nil == _actionItem) {
        _actionItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e610", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(shareAction)];;
    }
    return _actionItem;
}

- (QJLikeButton *)likeBtn {
    if (nil == _likeBtn) {
        _likeBtn = [QJLikeButton new];
        _likeBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_likeBtn addTarget:self action:@selector(didClickItem) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeBtn;
}

- (void)didClickItem {
    if (![[QJHenTaiParser parser] checkCookie]) {
        Toast(@"请先前往设置页面进行登录");
        return;
    }
    //正在操作状态
    if (self.likeBtn.likeState == QJLikeButtonStateLoading) {
        return;
    }
    //正式操作
    if (self.infoModel.isFavorite) {
        self.likeBtn.likeState = QJLikeButtonStateLoading;
        //取消收藏
        [[QJHenTaiParser parser] updateFavoriteStatus:self.infoModel.isFavorite model:self.model index:0 content:@"" complete:^(QJHenTaiParserStatus status) {
            if (status == QJHenTaiParserStatusSuccess) {
                self.infoModel.isFavorite = !self.infoModel.isFavorite;
                [self changeFavoritesStatus];
            }
        }];
    } else {
        //收藏,跳转收藏界面
        QJFavouriteViewController *vc = [QJFavouriteViewController new];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -QJFavouriteViewControllerDelagate
- (void)didSelectFolder:(NSInteger)index content:(NSString *)content {
    self.likeBtn.likeState = QJLikeButtonStateLoading;
    [[QJHenTaiParser parser] updateFavoriteStatus:self.infoModel.isFavorite model:self.model index:index content:content complete:^(QJHenTaiParserStatus status) {
        if (status == QJHenTaiParserStatusSuccess) {
            self.infoModel.isFavorite = !self.infoModel.isFavorite;
            [self changeFavoritesStatus];
        }
    }];
}

@end
