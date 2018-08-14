//
//  QJSearchViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/7/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSearchViewController.h"
#import "Tag+CoreDataClass.h"
#import "QJHenTaiParser.h"
#import "QJNewInfoViewController.h"
#import "NSString+StringHeight.h"
#import "QJSearchBar.h"
#import "QJButton.h"
#import "QJListTableView.h"
#import "QJListCell.h"
#import "QJGalleryItem.h"
#import "QJEnum.h"

@interface QJSearchViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, QJSearchBarDelagate, UITextFieldDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *actity;
@property (nonatomic, assign) QJFreshStatus status;
@property (weak, nonatomic) IBOutlet UISegmentedControl *starSegControl;
@property (nonatomic, strong) QJListTableView *tableView;//列表搜索
@property (weak, nonatomic) IBOutlet UIView *siftBgView;
@property (nonatomic, strong) QJSearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) NSString *url;

@property (nonatomic, strong) NSMutableArray *buttonStateArr;
@property (nonatomic, strong) NSArray<NSString *> *classifyArr;
@property (nonatomic, strong) NSArray<UIColor *> *colorArr;

@end

@implementation QJSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
    
    if (self.model) {
        self.searchBar.searchTextF.text = self.model.searchKey;
        self.url = self.model.url;
        [self updateResource];
    }
}

#pragma mark -滚动到顶部
- (void)scrollToTop {
    if (self.datas.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //等布局调整完成后再放xib布局的搜索框
    if (nil == self.tableView.tableHeaderView) {
        self.tableView.tableHeaderView = self.searchBar;
    }
}

- (void)setContent {
    self.status = QJFreshStatusNone;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.actity];
    self.navigationItem.rightBarButtonItem = item;
    
    self.title = @"搜索";
    [self.view addSubview:self.tableView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view bringSubviewToFront:self.siftBgView];
    self.siftBgView.alpha = 0;
    //初始化搜索配置文件
    NSInteger smallStarIndex = 2;
    if (NSObjForKey(@"smallStar")) {
        smallStarIndex = [NSObjForKey(@"smallStar") integerValue];
    } else {
        NSObjSetForKey(@"smallStar", @(smallStarIndex));
        NSObjSynchronize();
    }
    self.starSegControl.selectedSegmentIndex = smallStarIndex;
    //按钮
    NSArray *btnStateArr = NSObjForKey(@"SearchBtnState");
    if (btnStateArr && btnStateArr.count == 19) {
        [self.buttonStateArr addObjectsFromArray:NSObjForKey(@"SearchBtnState")];
    }
    else {
        [self initBtnStatus];
    }
    //分类颜色的设置
    for (NSInteger i = 0; i < self.classifyArr.count; i++) {
        NSString *title = self.classifyArr[i];
        [self makeButtonWithTitle:title index:i];
    }
    //初始化一些筛选
    for (NSInteger i = 0; i < 9; i++) {
        QJButton *btn = (QJButton *)[self.view viewWithTag:1010 + i];
        btn.selected = [self.buttonStateArr[10 + i] boolValue];
        [self changeSiftBtnWithIndex:i selected:btn.isSelected];
        [btn addTarget:self action:@selector(siftBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    }
    //页码
    self.pageIndex = 0;
}

- (void)initBtnStatus {
    //该循环基本只有第一次运行会用到,故不写在懒加载中,影响性能
    NSMutableArray *arr = [NSMutableArray new];
    for (NSInteger i = 0; i <= 18; i++) {
        if (i < 12) {
            [arr addObject:@(1)];
        }
        else {
            [arr addObject:@(0)];
        }
    }
    self.buttonStateArr = arr;
    NSObjSetForKey(@"SearchBtnState", arr);
    NSObjSynchronize();
}

- (void)siftBtnAction:(QJButton *)btn {
    btn.selected = !btn.isSelected;
    NSInteger index = btn.tag - 1010;
    [self changeSiftBtnWithIndex:index selected:btn.isSelected];
}

- (void)changeSiftBtnWithIndex:(NSInteger)index selected:(BOOL)isSelected {
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:2000 + index];
    imageView.image = [UIImage imageNamed:isSelected ? @"checkbox" : @"checkbox_unchecked"];
}

- (void)makeButtonWithTitle:(NSString *)title index:(NSInteger)index {
    UIButton *addBtn = (UIButton *)[self.view viewWithTag:1000 + index];
    [addBtn setTitle:title forState:UIControlStateNormal];
    [addBtn setTitleColor:self.colorArr[index] forState:UIControlStateNormal];
    [addBtn setTitle:title forState:UIControlStateSelected];
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [addBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    addBtn.selected = [self.buttonStateArr[index] boolValue];
    addBtn.backgroundColor = addBtn.selected ? self.colorArr[index] : [UIColor whiteColor];
    addBtn.layer.borderColor = self.colorArr[index].CGColor;
    addBtn.layer.borderWidth = 0.5f;
    addBtn.titleLabel.font = AppFontStyle();
    //监听某个值变化
    [addBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)btnAction:(QJButton *)sender {
    sender.selected = !sender.selected;
    [UIView animateWithDuration:0.25f animations:^{
        sender.backgroundColor = sender.selected ? [UIColor colorWithCGColor:sender.layer.borderColor] : [UIColor whiteColor];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    QJButton *btn = (QJButton *)object;
    self.buttonStateArr[btn.tag - 1000] = change[@"new"];
}

- (NSString *)makeUrl {
    NSMutableString *url = [NSMutableString stringWithString:@"?"];
    NSMutableArray *infos = [NSMutableArray new];
    for (NSInteger i = 0; i <= 18; i++) {
        QJButton *button = (QJButton *)[self.view viewWithTag:1000 + i];
        if (i < 10) {
            //类别
            NSString *string = [NSString stringWithFormat:@"%@=%@", button.value, button.isSelected ? @"1" : @"0"];
            [infos addObject:string];
        }
        else {
            //额外设置项
            if (button.isSelected) {
                NSString *string = [NSString stringWithFormat:@"%@=on", button.value];
                [infos addObject:string];
                if ([button.value isEqualToString:@"f_sr"]) {
                    [infos addObject:[NSString stringWithFormat:@"f_srdd=%ld", self.starSegControl.selectedSegmentIndex + 2]];
                }
            }
        }
    }
    [url appendString:[infos componentsJoinedByString:@"&"]];
    [url appendFormat:@"&f_search=%@",[self.searchBar.searchTextF.text urlEncode]];
    return url;
}

#pragma mark -请求数据
- (void)updateResource {
    [self.actity startAnimating];
    //这里做页码的处理
    NSString *url = self.url;
    if (self.pageIndex > 0) {
        if ([url containsString:@"f_doujinshi"]) {
            url = [NSString stringWithFormat:@"%@&page=%ld", self.url, self.pageIndex];
        } else {
            url = [NSString stringWithFormat:@"%@/%ld/", self.url, self.pageIndex];
        }
        
    }
    NSLog(@"%@", url);
    [[QJHenTaiParser parser] updateListInfoWithUrl:url complete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray) {
        if (status == QJHenTaiParserStatusSuccess) {
            if (self.pageIndex == 0) {
                [self.datas removeAllObjects];
            }
            [self.datas addObjectsFromArray:listArray];
            [self.tableView reloadData];
            if ([self isShowFreshingStatus]) {
                [self hiddenFreshingView];
            }
        }
        self.status = listArray.count ? QJFreshStatusNone : QJFreshStatusNotMore;
        [self.actity stopAnimating];
    } total:nil];
}

#pragma mark -UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    //这里构成url的链接
    self.url = [self makeUrl];
    self.pageIndex = 0;
    [self updateResource];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self hiddenSiftView];
    return YES;
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self hiddenSiftView];

    CGFloat current = scrollView.contentOffset.y + scrollView.frame.size.height;
    CGFloat total = scrollView.contentSize.height;
    CGFloat ratio = current / total;
    
    CGFloat needRead = 25 * 0.7 + self.pageIndex * 25;
    CGFloat totalItem = 25 * (self.pageIndex + 1);
    CGFloat newThreshold = needRead / totalItem;
    
    if (self.datas.count && ratio >= newThreshold && self.status == QJFreshStatusNone) {
        self.status = QJFreshStatusMore;
        self.pageIndex++;
        NSLog(@"Request page %ld from server.",self.pageIndex);
        [self updateResource];
    }

}

#pragma mark -tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJListCell class])];
    [cell refreshUI:self.datas[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QJNewInfoViewController *vc = [QJNewInfoViewController new];
    //vc.hidesBottomBarWhenPushed = YES;
    vc.model = self.datas[indexPath.row];
    vc.preferredContentSize = CGSizeMake(150, 150);
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -QJSearchBarDelagate
- (void)didClickSiftBtn {
    if (self.siftBgView.alpha) {
        [self hiddenSiftView];
    } else {
        [self showSiftView];
    }
}

- (void)showSiftView {
    [self.searchBar.searchTextF resignFirstResponder];
    if (self.siftBgView.alpha == 0) {
        [self changeSiftView];
    }
}

- (void)hiddenSiftView {
    [self saveButtonState];
    if (self.siftBgView.alpha) {
        [self changeSiftView];
    }
}

- (void)changeSiftView {
    [UIView animateWithDuration:0.25f animations:^{
        self.siftBgView.alpha = self.siftBgView.alpha ? 0 : 1;
    }];
}

- (void)saveButtonState {
    NSObjSetForKey(@"SearchBtnState", self.buttonStateArr);
    NSObjSynchronize();
}

#pragma mark -getter
- (UIActivityIndicatorView *)actity {
    if (!_actity) {
        _actity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _actity.hidesWhenStopped = YES;
    }
    return _actity;
}

- (NSMutableArray *)datas {
    if (nil == _datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

- (QJListTableView *)tableView {
    if (nil == _tableView) {
        _tableView = [QJListTableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (@available(iOS 10.0, *)) {
            
        }
        else {
            _tableView.contentInset = UIEdgeInsetsMake(UINavigationBarHeight(), 0, UITabBarHeight(), 0);
        }
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _tableView;
}

- (QJSearchBar *)searchBar {
    if (nil == _searchBar) {
        _searchBar = [[NSBundle mainBundle] loadNibNamed:@"QJSearchBar" owner:nil options:nil][0];
        _searchBar.delegate = self;
        _searchBar.searchTextF.delegate = self;
    }
    return _searchBar;
}

- (NSArray<NSString *> *)classifyArr {
    if (!_classifyArr) {
        _classifyArr = @[@"DOUJINSHI",
                         @"MANGA",
                         @"ARTIST CG",
                         @"GAME CG",
                         @"WESTERN",
                         @"NON-H",
                         @"IMAGE SET",
                         @"COSPLAY",
                         @"ASIAN PORN",
                         @"MISC"];
    }
    return _classifyArr;
}

- (NSArray<UIColor *> *)colorArr {
    if (nil == _colorArr) {
        _colorArr = @[
                      DOUJINSHI_COLOR,
                      MANGA_COLOR,
                      ARTISTCG_COLOR,
                      GAMECG_COLOR,
                      WESTERN_COLOR,
                      NONH_COLOR,
                      IMAGESET_COLOR,
                      COSPLAY_COLOR,
                      ASIANPORN_COLOR,
                      MISC_COLOR
                      ];
    }
    return _colorArr;
}

- (NSMutableArray *)buttonStateArr {
    if (!_buttonStateArr) {
        _buttonStateArr = [NSMutableArray new];
    }
    return _buttonStateArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (NSInteger i = 0; i <= 18; i++) {
        QJButton *btn = (QJButton *)[self.view viewWithTag:1000 + i];
        [btn removeObserver:self forKeyPath:@"selected"];
    }
}

@end
