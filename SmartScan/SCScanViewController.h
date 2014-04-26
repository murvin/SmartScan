//
//  SCScanViewController.h
//  SmartScan
//
//  Created by Murvin Bhantooa (O581573) on 26/04/2014.
//  Copyright (c) 2014 Murvin Bhantooa. All rights reserved.
//

@import UIKit;

@class SCScan;
@interface SCScanViewController : UIViewController

/**
 *  The scan object that contains all relevant information.
 */
@property (nonatomic, strong) SCScan *scan;

- (void)setSenderBackgroundImage:(UIImage *)senderBackgroundImage;

@end
