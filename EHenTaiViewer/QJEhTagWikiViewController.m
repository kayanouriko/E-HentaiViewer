//
//  QJEhTagWikiViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2018/9/15.
//  Copyright © 2018 kayanouriko. All rights reserved.
//

#import "QJEhTagWikiViewController.h"
#import "Tag+CoreDataClass.h"

@interface QJEhTagWikiViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<NSArray<Tag *> *> *datas;
@property (strong, nonatomic) NSArray<NSString *> *indexDatas;

@end

@implementation QJEhTagWikiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
}

#pragma mark -TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas[section].count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [UIView new];
    headView.backgroundColor = [UIColor whiteColor];
    
    UIView *line = [UIView new];
    line.translatesAutoresizingMaskIntoConstraints = NO;
    line.backgroundColor = [UIColor lightGrayColor];
    [headView addSubview:line];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = self.indexDatas[section];
    titleLabel.textColor = [UIColor lightGrayColor];
    titleLabel.font = [UIFont systemFontOfSize:16.f];
    [headView addSubview:titleLabel];
    
    [headView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[line(5)]-10-[titleLabel]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(line, titleLabel)]];
    [headView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[line(20)]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(line)]];
    [headView addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:headView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    return headView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    cell.textLabel.text = self.datas[indexPath.section][indexPath.row].name;
    cell.detailTextLabel.text = self.datas[indexPath.section][indexPath.row].cname;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//添加索引栏标题数组
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.indexDatas;
}


//点击索引栏标题时执行
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 44;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        // [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        
    }
    return _tableView;
}

- (NSArray<NSArray<Tag *> *> *)datas {
    if (!_datas) {
        NSArray *tags = [Tag MR_findAllSortedBy:@"name" ascending:YES];
        NSMutableDictionary *dict = [NSMutableDictionary new];
        for (Tag *tag in tags) {
            NSString *indexStr = [[tag.name substringToIndex:1] uppercaseString];
            if ([dict.allKeys containsObject:indexStr]) {
                NSMutableArray *array = dict[indexStr];
                [array addObject:tag];
                dict[indexStr] = array;
            } else {
                NSMutableArray *array = [NSMutableArray arrayWithObject:tag];
                dict[indexStr] = array;
            }
        }
        
        // 筛选完了之后
        self.indexDatas = [dict.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2 options:NSNumericSearch];
        }];
        
        NSMutableArray *sortDatas = [NSMutableArray new];
        for (NSString *index in self.indexDatas) {
            [sortDatas addObject:dict[index]];
        }
        
        _datas = [sortDatas copy];
    }
    return _datas;
}

- (NSArray<NSString *> *)indexDatas {
    if (!_indexDatas) {
        _indexDatas = @[];
    }
    return _indexDatas;
}

@end
