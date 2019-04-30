//
//  QJColorPickShowView.m
//  QJColorPicker
//
//  Created by QinJ on 2019/4/28.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJColorPickShowView.h"
#import "QJColorPickUtils.h"

@interface QJColorPickShowView ()

@property (strong, nonatomic) UIView *showView;
@property (strong, nonatomic) UIView *line;
@property (strong, nonatomic) UILabel *label;

@end

@implementation QJColorPickShowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setContent];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setContent];
    }
    return self;
}

- (void)setContent {
    self.backgroundColor = [UIColor whiteColor];
    self.showColor = [UIColor whiteColor];
    
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.layer.borderWidth = .5f;
    self.layer.cornerRadius = 5.f;
    
    [self addSubview:self.showView];
    [self addSubview:self.line];
    [self addSubview:self.label];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    self.showView.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame) - 30);
    self.line.frame = CGRectMake(0, CGRectGetHeight(frame) - 30, CGRectGetWidth(frame), .5f);
    self.label.frame = CGRectMake(0, CGRectGetHeight(frame) - 30, CGRectGetWidth(frame), 30);
}

#pragma mark - Setter
- (void)setShowColor:(UIColor *)showColor {
    _showColor = showColor;
    self.showView.backgroundColor = showColor;
    self.label.text = [NSString stringWithFormat:@"#%@", [QJColorPickUtils hexStringWithColor:showColor hasAlpha:NO]];
    self.hexColor = self.label.text;
}

#pragma mark - Getter
- (UIView *)showView {
    if (!_showView) {
        _showView = [UIView new];
        _showView.backgroundColor = [UIColor whiteColor];
    }
    return _showView;
}

- (UILabel *)label {
    if (!_label) {
        _label = [UILabel new];
        _label.textColor = [UIColor lightGrayColor];
        _label.font = [UIFont systemFontOfSize:12.f];
        _label.minimumScaleFactor = .05f;
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

- (UIView *)line {
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _line;
}

@end
