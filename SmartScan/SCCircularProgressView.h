//
//  SCCircularProgressView.h
//  SmartScanner
//
//  Created by Murvin Bhantooa (O581573) on 05/04/2014.
//  Copyright (c) 2014 Murvin Bhantooa. All rights reserved.
//

@import UIKit;

@interface SCCircularProgressView : UIView

- (id)initWithFrame:(CGRect)frame colorArray:(NSArray *)colorArray;

- (void)startAnimating;

- (void)stopAnimating;

- (void)animateToFrame : (CGRect)frame withCompletionBlock : (void (^)(BOOL finised))completion;

@end
