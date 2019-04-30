//
//  QJColorPickSlider.m
//  QJColorPicker
//
//  Created by QinJ on 2019/4/28.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJColorPickSlider.h"
#import "QJColorPickUtils.h"

@interface QJArrowLayer : CALayer

@property (assign, nonatomic) CGPoint point;

@end

@implementation QJArrowLayer

- (void)drawInContext:(CGContextRef)ctx {
    
    
    CGRect frame = self.bounds;
    
    CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 1.f);
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 0);
    CGContextSetLineWidth(ctx, 3.f);
    
    CGPoint sPoints1[3];//坐标点
    sPoints1[0] = CGPointMake(self.point.x - 3, 0);//坐标1
    sPoints1[1] = CGPointMake(self.point.x + 3, 0);//坐标2
    sPoints1[2] = CGPointMake(self.point.x, 3);//坐标3
    CGContextAddLines(ctx, sPoints1, 3);//添加线
    CGContextClosePath(ctx);//封起来
    CGContextDrawPath(ctx,kCGPathFillStroke);//根据坐标绘制路径
    
    CGPoint sPoints2[3];//坐标点
    sPoints2[0] = CGPointMake(self.point.x - 3, CGRectGetHeight(frame));//坐标1
    sPoints2[1] = CGPointMake(self.point.x + 3, CGRectGetHeight(frame));//坐标2
    sPoints2[2] = CGPointMake(self.point.x, CGRectGetHeight(frame) - 3);//坐标3
    CGContextAddLines(ctx, sPoints2, 3);//添加线
    CGContextClosePath(ctx);//封起来
    CGContextDrawPath(ctx,kCGPathFillStroke);//根据坐标绘制路径
}

- (void)setPoint:(CGPoint)point {
    _point = point;
    [self setNeedsDisplay];
}

@end

@interface QJColorPickSlider ()

@property (strong, nonatomic) CAGradientLayer *gradientLayerColor;
@property (strong, nonatomic) QJArrowLayer *arrowLayer;
@property (assign, nonatomic) CGPoint currentPoint;

@end

@implementation QJColorPickSlider

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
    self.currentPoint = CGPointMake(12, 12);
    
    self.backgroundColor = [UIColor whiteColor];
    [self.layer insertSublayer:self.gradientLayerColor atIndex:0];
    [self.layer insertSublayer:self.arrowLayer above:self.gradientLayerColor];
}

- (void)layoutSubviews {
    // set layer frame
    CGRect frame = self.bounds;
    frame.origin.x = 12;
    frame.origin.y = 6;
    frame.size.width -= 24;
    frame.size.height -= 12;
    self.gradientLayerColor.frame = frame;
    self.arrowLayer.frame = self.bounds;
}

#pragma mark - Touches
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self p_handleTouchColor:touches];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self p_handleTouchColor:touches];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self p_handleTouchColor:touches];
}

// eg:phone cancel
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self p_handleTouchColor:touches];
}

- (void)p_handleTouchColor:(NSSet<UITouch *> *)touches {
    CGPoint point = [[touches anyObject] locationInView:self];
    // handle point
    if (point.x < 12) {
        point.x = 12;
    }
    else if (point.x >= CGRectGetWidth(self.frame) - 12) {
        point.x = CGRectGetWidth(self.frame) - 12 - 1;
    }
    
    if (point.y < 12) {
        point.y = 12;
    }
    else if (point.y > CGRectGetHeight(self.frame) - 12) {
        point.y = CGRectGetHeight(self.frame) - 12;
    }
    self.currentPoint = point;
    [self p_checkColorInfoWithPoint:self.currentPoint];
}

- (void)p_checkColorInfoWithPoint:(CGPoint)point {
    // change crosslayer frame
    self.arrowLayer.point = point;
    // get color
    self.currentColor = [QJColorPickUtils getColorWithPoint:point layer:self.layer];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(colorPickSlider:didChangeColor:)]) {
        [self.delegate colorPickSlider:self didChangeColor:self.currentColor];
    }
}

#pragma mark - Setter
- (void)setShowColor:(UIColor *)showColor {
    _showColor = showColor;
    self.gradientLayerColor.colors = @[
                                       (__bridge id)[UIColor blackColor].CGColor,
                                       (__bridge id)showColor.CGColor,
                                       ];
    [self p_checkColorInfoWithPoint:self.currentPoint];
}

#pragma mark - Getter
- (CAGradientLayer *)gradientLayerColor {
    if (!_gradientLayerColor) {
        _gradientLayerColor = [CAGradientLayer layer];
        _gradientLayerColor.colors = @[
                                       (__bridge id)[UIColor blackColor].CGColor,
                                       (__bridge id)[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5].CGColor,
                                       (__bridge id)[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0].CGColor,
                                       ];
        _gradientLayerColor.transform = CATransform3DMakeRotation(M_PI / 2, 0, 0, 1);
    }
    return _gradientLayerColor;
}

- (QJArrowLayer *)arrowLayer {
    if (!_arrowLayer) {
        _arrowLayer = [QJArrowLayer layer];
        _arrowLayer.contentsScale = [[UIScreen mainScreen] scale];
        _arrowLayer.point = CGPointMake(12, 12);
    }
    return _arrowLayer;
}

@end
