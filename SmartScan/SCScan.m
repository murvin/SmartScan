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
        _metaDataObject = [metaDataObject copy];
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
    AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[videoPreviewLayer transformedMetadataObjectForMetadataObject:_metaDataObject];

    return transformed.bounds;
}

@end
