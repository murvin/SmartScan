//
//  SCViewController.m
//  SmartScan
//
//  Created by Murvin Bhantooa (O581573) on 09/04/2014.
//  Copyright (c) 2014 Murvin Bhantooa. All rights reserved.
//

#import "SCViewController.h"
#import "SCScanner.h"
#import "SCCircularProgressView.h"

@interface SCViewController ()

@property(nonatomic, strong) SCScanner *scanner;
@property (weak, nonatomic) IBOutlet SCCircularProgressView *circularProgressView;
@end

@implementation SCViewController

- (void)viewDidLoad
{
    __typeof(self) __weak weakSelf = self;
    self.scanner = [[SCScanner alloc] initForMetaDataObjectType:@[AVMetadataObjectTypeQRCode]
                                       captureDeviceOrientation:AVCaptureVideoOrientationPortrait
                                                completionBlock:^void (NSString *scanPayload){

                                                    NSLog(@"Found code: %@", scanPayload);
                                                    [weakSelf.scanner stopScan];
                                                    [weakSelf.circularProgressView stopAnimating];
                                                }];

    [self.scanner.videoPreviewLayer setFrame:[self view].frame];
    [self.view.layer insertSublayer:self.scanner.videoPreviewLayer atIndex:0];

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.circularProgressView startAnimating];
    [self.scanner startScan];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.scanner stopScan];
    [self.circularProgressView stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
