//
//  QJColorPickBoard.m
//  QJColorPicker
//
//  Created by QinJ on 2019/4/28.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJColorPickBoard.h"
#import "QJColorPickProtocol.h"
#import "QJColorPickUtils.h"

@interface QJCrossLayer : CALayer

@property (assign, nonatomic) CGPoint point;

@end

@implementation QJCrossLayer

- (void)drawInContext:(CGContextRef)ctx {
    CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 1);
    CGContextSetLineWidth(ctx, 3.f);
    CGContextAddArc(ctx, self.point.x, self.point.y, 8, 0, 2 * M_PI, 0);
    CGContextStrokePath(ctx);
}

- (void)setPoint:(CGPoint)point {
    _point = point;
    [self setNeedsDisplay];
}

@end

@interface QJColorPickBoard ()

@property (strong, nonatomic) CAGradientLayer *gradientLayerColor;
@property (strong, nonatomic) CAGradientLayer *gradientLayerWhite;
@property (strong, nonatomic) QJCrossLayer *crossLayer;

@end

@implementation QJColorPickBoard

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addGradientLayer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self addGradientLayer];
    }
    return self;
}

#pragma mark - Add Layer
- (void)addGradientLayer {
    [self.layer insertSublayer:self.gradientLayerColor atIndex:0];
    [self.layer insertSublayer:self.gradientLayerWhite above:self.gradientLayerColor];
    [self.layer insertSublayer:self.crossLayer above:self.gradientLayerWhite];
}

- (void)layoutSubviews {
    // set layer frame
    CGRect frame = self.bounds;
    frame.origin.x = 12;
    frame.origin.y = 12;
    frame.size.width -= 24;
    frame.size.height -= 24;
    self.gradientLayerColor.frame = frame;// self.bounds;
    self.gradientLayerWhite.frame = frame;// self.gradientLayerColor.frame;
    self.crossLayer.frame = self.bounds;
    self.crossLayer.point = CGPointMake(-100, -100);
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
    // change crosslayer frame
    self.crossLayer.point = point;
    // get color
    self.currentColor = [QJColorPickUtils getColorWithPoint:point layer:self.layer];
    if (self.delegate && [self.delegate respondsToSelector:@selector(colorPickBoard:didChangeColor:)]) {
        [self.delegate colorPickBoard:self didChangeColor:self.currentColor];
    }
}

#pragma mark - Getter
- (CAGradientLayer *)gradientLayerColor {
    if (!_gradientLayerColor) {
        _gradientLayerColor = [CAGradientLayer layer];
        // all color set
        _gradientLayerColor.colors = @[
                                  (__bridge id)[UIColor redColor].CGColor,
                                  (__bridge id)[UIColor magentaColor].CGColor,
                                  (__bridge id)[UIColor blueColor].CGColor,
                                  (__bridge id)[UIColor cyanColor].CGColor,
                                  (__bridge id)[UIColor greenColor].CGColor,
                                  (__bridge id)[UIColor yellowColor].CGColor,
                                  (__bridge id)[UIColor orangeColor].CGColor,
                                  // (__bridge id)[UIColor redColor].CGColor,
                                  ];
        // set horizontal
        _gradientLayerColor.transform = CATransform3DMakeRotation(M_PI / 2, 0, 0, 1);
    }
    return _gradientLayerColor;
}

- (CAGradientLayer *)gradientLayerWhite {
    if (!_gradientLayerWhite) {
        _gradientLayerWhite = [CAGradientLayer layer];
        _gradientLayerWhite.colors = @[
                                       (__bridge id)[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0].CGColor,
                                       (__bridge id)[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.5].CGColor,
                                       (__bridge id)[UIColor whiteColor].CGColor,
                                       ];
    }
    return _gradientLayerWhite;
}

- (QJCrossLayer *)crossLayer {
    if (!_crossLayer) {
        _crossLayer = [QJCrossLayer layer];
        _crossLayer.contentsScale = [[UIScreen mainScreen] scale];
        _crossLayer.point = CGPointMake(0, 0);
    }
    return _crossLayer;
}

- (UIColor *)currentColor {
    if (!_currentColor) {
        _currentColor = [UIColor whiteColor];
    }
    return _currentColor;
}

@end
