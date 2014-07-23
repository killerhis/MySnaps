//
//  AlbumCollectionViewCell.m
//  MySnaps
//
//  Created by Hicham Chourak on 23/07/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import "AlbumCollectionViewCell.h"
#define IMAGEVIEW_BORDER_LENGTH 5

@implementation AlbumCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, IMAGEVIEW_BORDER_LENGTH, IMAGEVIEW_BORDER_LENGTH)];
    [self.contentView addSubview:self.imageView];
}

@end
