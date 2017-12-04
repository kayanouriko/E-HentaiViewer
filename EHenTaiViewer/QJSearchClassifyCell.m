//
//  QJSearchClassifyCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/18.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSearchClassifyCell.h"

@interface QJSearchClassifyCell ()

@property (nonatomic, strong) NSArray<NSString *> *classifyArr;
@property (nonatomic, strong) NSArray<UIColor *> *colorArr;
@property (nonatomic, strong) NSMutableArray *buttonStateArr;

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJSearchClassifyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setContent];
}

- (void)setContent {
    if (NSObjForKey(@"SearchBtnState")) {
        [self.buttonStateArr addObjectsFromArray:NSObjForKey(@"SearchBtnState")];
    }
    else {
        //该循环基本只有第一次运行会用到,故不写在懒加载中,影响性能
        NSMutableArray *arr = [NSMutableArray new];
        for (NSInteger i = 0; i < self.classifyArr.count; i++) {
            [arr addObject:@(1)];
        }
        self.buttonStateArr = arr;
        NSObjSetForKey(@"SearchBtnState", arr);
        NSObjSynchronize();
    }
    
    for (NSInteger i = 0; i < self.classifyArr.count; i++) {
        NSString *title = self.classifyArr[i];
        [self makeButtonWithTitle:title index:i];
    }
}

//创建分类按钮
- (void)makeButtonWithTitle:(NSString *)title index:(NSInteger)index {
    UIButton *addBtn = (UIButton *)[self.contentView viewWithTag:1000 + index];
    [addBtn setTitle:title forState:UIControlStateNormal];
    [addBtn setTitleColor:self.colorArr[index] forState:UIControlStateNormal];
    [addBtn setTitle:title forState:UIControlStateSelected];
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    addBtn.selected = [self.buttonStateArr[index] boolValue];
    addBtn.backgroundColor = addBtn.selected ? self.colorArr[index] : [UIColor whiteColor];
    addBtn.layer.borderColor = self.colorArr[index].CGColor;
    addBtn.layer.borderWidth = 0.5f;
    addBtn.titleLabel.font = AppFontStyle();
    //监听某个值变化
    [addBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

//观察取值改变
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    UIButton *btn = (UIButton *)object;
    self.buttonStateArr[btn.tag - 1000] = change[@"new"];
}

- (void)saveButtonState {
    NSObjSetForKey(@"SearchBtnState", self.buttonStateArr);
    NSObjSynchronize();
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)btnAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [UIView animateWithDuration:0.25f animations:^{
        sender.backgroundColor = sender.selected ? [UIColor colorWithCGColor:sender.layer.borderColor] : [UIColor whiteColor];
    }];
}

#pragma mark -懒加载
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (NSInteger i = 0; i < self.classifyArr.count; i++) {
        UIButton *btn = (UIButton *)[self viewWithTag:1000 + i];
        [btn removeObserver:self forKeyPath:@"selected"];
    }
}

@end
