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
static const NSUInteger kGradientLayerWidth = 4;

static const NSUInteger kGradientLayerCornerRadius = 18;

static const CFTimeInterval kGradientLayerAnimationDuration = 0.5;


@implementation SCCircularProgressView {

    NSArray *_colorArray;

    BOOL _isAnimating;

    /**
     *  A handle on the initial frame this view was created with for reverse animations.
     */
    CGRect _initialFrame;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        _colorArray = @[[UIColor redColor], [UIColor yellowColor], [UIColor greenColor], [UIColor blueColor]];
        _initialFrame = self.frame;
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

- (void)animateToFrame:(CGRect)frame withCompletionBlock:(void (^)(BOOL finised))completion
{
    if (CGRectEqualToRect(self.frame, frame))
    {
        completion(YES);
    }
    else
    {
        [UIView animateWithDuration:0.3f delay:0.0f
             usingSpringWithDamping:0.4f
              initialSpringVelocity:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState animations:^{
             self.frame = frame;

         } completion:completion];
    }
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

    maskLayer.borderWidth = kGradientLayerWidth;
    self.layer.mask = maskLayer;
}

- (void)createGradientLayer
{
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    gradientLayer.endPoint = CGPointMake(1.0f, 1.0f);
    gradientLayer.cornerRadius = kGradientLayerCornerRadius;
    gradientLayer.opacity = 0.5f;
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
