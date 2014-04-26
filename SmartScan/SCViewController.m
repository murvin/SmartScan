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
#import "SCScanViewController.h"

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

    _scanner = [[SCScanner alloc] initForMetaDataObjectType:[SCScanner allMetaDataObjectTypes]
                                       interfaceOrientation:UIInterfaceOrientationPortrait
                                            completionBlock:^void (SCScan *scan){
                    NSLog(@"Found code: %@ at %@", scan.stringValue, scan.captureDate);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf navigateToScanViewControllerWithPayload:scan];
                    });

                    [weakSelf.scanner stopScan];
                }];

    [_scanner.videoPreviewLayer setFrame:[self view].frame];
    [self.view.layer insertSublayer:_scanner.videoPreviewLayer atIndex:0];

    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTap:)];
    [self.view addGestureRecognizer:_tapGestureRecognizer];

    [self makeNavigationBarTransparent];

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

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_scanner setDeviceCaptureOrientation:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Helper Methods
- (void)didRecognizeTap:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:self.view];
    [_circularProgressView animateCenterToPoint:tapPoint];
    [_scanner focusOnPoint:tapPoint];
}


- (void)makeNavigationBarTransparent
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (void)navigateToScanViewControllerWithPayload:(SCScan *)scan
{
    SCScanViewController *scanViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"scanViewControllerIdentifier"];
    [scanViewController setScan:scan];
    [scanViewController setSenderBackgroundImage:_scanner.sampleBufferImage];
    [self.navigationController pushViewController:scanViewController animated:YES];
}

@end
