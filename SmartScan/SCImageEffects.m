//
//  SCImageEffects.m
//  SmartScan
//
//  Created by Murvin Bhantooa (O581573) on 12/04/2014.
//  Copyright (c) 2014 Murvin Bhantooa. All rights reserved.
//

#import "SCImageEffects.h"

@implementation SCImageEffects

+ (UIImage *)blurImage:(UIImage *)sourceImage
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];

    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:@(15.0f) forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    // CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches up exactly to the bounds of our original image
    CGImageRef blurredImageRef = [context createCGImage:result fromRect:[inputImage extent]];

    return [UIImage imageWithCGImage:blurredImageRef];
}

+ (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return img;
}

@end
