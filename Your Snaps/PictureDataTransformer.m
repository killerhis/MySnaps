//
//  TWPictureDataTransformer.m
//  YourSnaps
//
//  Created by Hicham Chourak on 20/07/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import "PictureDataTransformer.h"

@implementation PictureDataTransformer

+ (Class)transformedValueClass
{
    return [NSData class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return UIImagePNGRepresentation(value);
}

- (id)reverseTransformedValue:(id)value
{
    UIImage *image = [UIImage imageWithData:value];
    return image;
}

@end
