//
//  SCViewController.m
//  SmartScan
//
//  Created by Murvin Bhantooa (O581573) on 09/04/2014.
//  Copyright (c) 2014 Murvin Bhantooa. All rights reserved.
//

#import "SCViewController.h"
#import "SCScanner.h"
#import "SCScan.h"
#import "SCCircularProgressView.h"

@interface SCViewController ()

@property(nonatomic, strong) SCScanner *scanner;
@property (weak, nonatomic) IBOutlet SCCircularProgressView *circularProgressView;
@end

@implementation SCViewController

- (void)viewDidLoad
{
    __typeof(self) __weak weakSelf = self;

    // All the types we want to support
    NSArray *metaDataObjectTypesArray = @[AVMetadataObjectTypeQRCode,
                                          AVMetadataObjectTypeAztecCode,
                                          AVMetadataObjectTypeCode128Code,
                                          AVMetadataObjectTypeCode39Code,
                                          AVMetadataObjectTypeCode39Mod43Code,
                                          AVMetadataObjectTypeEAN13Code,
                                          AVMetadataObjectTypeEAN8Code,
                                          AVMetadataObjectTypeEAN13Code,
                                          AVMetadataObjectTypePDF417Code,
                                          AVMetadataObjectTypeUPCECode,
                                          ];

    self.scanner = [[SCScanner alloc] initForMetaDataObjectType:metaDataObjectTypesArray
                                       captureDeviceOrientation:AVCaptureVideoOrientationPortrait
                                                completionBlock:^void (SCScan *scan){
                                                    NSLog(@"Found code: %@", scan.stringValue);
                                                    CGRect scanFrame = [scan transformedBoundsForPreviewLayer:_scanner.videoPreviewLayer];
                                                    [weakSelf.circularProgressView animateToFrame:scanFrame withCompletionBlock:^(BOOL finished){
                                                        [weakSelf.scanner stopScan];
                                                        [weakSelf.circularProgressView stopAnimating];
                                                    }];

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
