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

@property (nonatomic, weak) IBOutlet SCCircularProgressView *circularProgressView;

@end

@implementation SCViewController {

    /**
     *  The progress view is translated to the tap point for focus..
     */
    UITapGestureRecognizer *_tapGestureRecognizer;
}

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

    _scanner = [[SCScanner alloc] initForMetaDataObjectType:metaDataObjectTypesArray
                                   captureDeviceOrientation:AVCaptureVideoOrientationPortrait
                                            completionBlock:^void (SCScan *scan){
                    NSLog(@"Found code: %@", scan.stringValue);
                    [weakSelf.scanner stopScan];
                }];

    [_scanner.videoPreviewLayer setFrame:[self view].frame];
    [self.view.layer insertSublayer:_scanner.videoPreviewLayer atIndex:0];

    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTap:)];
    [self.view addGestureRecognizer:_tapGestureRecognizer];

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_circularProgressView startAnimating];
    [_scanner startScan];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_scanner stopScan];
    [_circularProgressView stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)didRecognizeTap:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:self.view];
    [self.circularProgressView animateCenterToPoint:tapPoint];
}

@end
