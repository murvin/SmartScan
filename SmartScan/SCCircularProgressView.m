//
//  SCCircularProgressView.m
//  SmartScanner
//
//  Created by Murvin Bhantooa (O581573) on 05/04/2014.
//  Copyright (c) 2014 Murvin Bhantooa. All rights reserved.
//

#import "SCCircularProgressView.h"

/**
 *  Determines the thickness of the gradient
 */
static const NSUInteger kGradientLayerWidth = 3;

static const NSUInteger kGradientLayerCornerRadius = 18;

static const CFTimeInterval kGradientLayerAnimationDuration = 0.5;

static const NSTimeInterval kAnimationDuration = 0.3f;


@implementation SCCircularProgressView {

    NSArray *_colorArray;

    BOOL _isAnimating;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        _colorArray = @[[UIColor redColor], [UIColor yellowColor], [UIColor greenColor], [UIColor blueColor]];
        [self createLayers];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame colorArray:(NSArray *)colorArray
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _colorArray = colorArray;
        [self createLayers];
    }
    return self;
}

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (void)startAnimating
{
    if (!_isAnimating)
    {
        _isAnimating = YES;

        [self animateGradientColors];
    }
}

- (void)stopAnimating
{
    if (_isAnimating)
    {
        _isAnimating = NO;
    }
}

-(void)animateCenterToPoint:(CGPoint)centerPoint
{
    [UIView animateWithDuration:kAnimationDuration
                          delay:0.0f
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                            self.center = centerPoint;

                        } completion:NULL];
}

#pragma mark - Private Helpers

- (void)createLayers
{
    [self createGradientLayer];
    [self addLayerMask];
}

- (void)addLayerMask
{
    CALayer *maskLayer = [[CALayer alloc] init];
    maskLayer.cornerRadius = kGradientLayerCornerRadius;
    maskLayer.frame = CGRectMake(kGradientLayerWidth,
                                 kGradientLayerWidth,
                                 CGRectGetWidth(self.layer.bounds) - (kGradientLayerWidth * 2),
                                 CGRectGetHeight(self.layer.bounds) - (kGradientLayerWidth * 2));

    maskLayer.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
    maskLayer.borderWidth = kGradientLayerWidth;
    self.layer.mask = maskLayer;
}

- (void)createGradientLayer
{
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    gradientLayer.endPoint = CGPointMake(1.0f, 1.0f);
    gradientLayer.cornerRadius = kGradientLayerCornerRadius;
    NSMutableArray *colorRefArray = [@[] mutableCopy];
    for (UIColor *color in _colorArray)
    {
        [colorRefArray addObject:(id)color.CGColor];
    }
    gradientLayer.colors = [colorRefArray copy];
}

- (NSArray *)shiftColors:(NSArray *)colors
{
    NSMutableArray *mutable = [colors mutableCopy];
    id last = [mutable lastObject];
    [mutable removeLastObject];
    [mutable insertObject:last atIndex:0];
    return [NSArray arrayWithArray:mutable];
}

- (void)animateGradientColors
{
    CAGradientLayer *layer = (id)[self layer];
    NSArray *fromColors = [layer colors];
    NSArray *toColors = [self shiftColors:fromColors];
    [layer setColors:toColors];

    CABasicAnimation *animation;
    animation = [CABasicAnimation animationWithKeyPath:@"colors"];
    [animation setFromValue:fromColors];
    [animation setToValue:toColors];
    [animation setDuration:kGradientLayerAnimationDuration];
    [animation setRemovedOnCompletion:YES];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [animation setDelegate:self];

    [layer addAnimation:animation forKey:@"animateGradient"];
}

#pragma mark - CAAnimation Delegate Method
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
    if (_isAnimating)
    {
        [self animateGradientColors];
    }
}

@end
