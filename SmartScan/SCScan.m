//
//  SCScan.m
//  SmartScan
//
//  Created by Murvin Bhantooa (O581573) on 09/04/2014.
//  Copyright (c) 2014 Murvin Bhantooa. All rights reserved.
//

#import "SCScan.h"

@implementation SCScan

- (instancetype)initWithMetaDataObject:(AVMetadataObject *)metaDataObject readableStringValue:(NSString *)stringValue
{
    NSParameterAssert(metaDataObject != nil);

    self = [super init];
    if (self)
    {
        /**
         *  <AVMetadataMachineReadableCodeObject: 0x178038bc0> type "org.iso.QRCode", bounds { 0.5,0.3 0.3x0.5 }, corners { 0.5,0.4 0.5,0.8 0.8,0.9 0.8,0.3 }, time 16646515883166, stringValue "http://c.att.com/krs1b3ae0f0qgu"
         */
        _metaDataObject = metaDataObject;
        _stringValue = [stringValue copy];
    }

    return self;
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }

    if ([self class] != [object class])
    {
        return NO;
    }

    return [self isEqualToScan:object];
}

- (NSUInteger)hash
{
    return [_metaDataObject hash] ^ [_stringValue hash];
}

- (BOOL)isEqualToScan:(SCScan *)otherScan
{
    return _metaDataObject == otherScan.metaDataObject
           && _stringValue ? [_stringValue isEqualToString:otherScan.stringValue] : !otherScan.stringValue;
}

- (CGRect)transformedBoundsForPreviewLayer:(AVCaptureVideoPreviewLayer *)videoPreviewLayer
{
    if (!videoPreviewLayer)
    {
        return CGRectZero;
    }

    AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[videoPreviewLayer transformedMetadataObjectForMetadataObject:_metaDataObject];

    return transformed.bounds;
}

- (NSDate *)captureDate
{
    CMTime captureTime = _metaDataObject.time;
    NSTimeInterval seconds =  CMTimeGetSeconds(captureTime);
    NSLog(@"seconds recorded : %f", seconds);
    return nil;
}

@end
