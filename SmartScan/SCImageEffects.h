//
//  SCImageEffects.h
//  SmartScan
//
//  Created by Murvin Bhantooa (O581573) on 12/04/2014.
//  Copyright (c) 2014 Murvin Bhantooa. All rights reserved.
//

@import Foundation;

@interface SCImageEffects : NSObject

+ (UIImage *)blurImage:(UIImage *)sourceImage;

+ (UIImage *)imageWithView:(UIView *)view;

@end
