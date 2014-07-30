//
//  PhotosCollectionViewController.h
//  YourSnaps
//
//  Created by Hicham Chourak on 19/07/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "MWPhotoBrowser.h"

@interface PhotosCollectionViewController : UICollectionViewController <MWPhotoBrowserDelegate>

@property (strong, nonatomic) Album *album;

- (IBAction)cameraBarButtonItemPressed:(UIBarButtonItem *)sender;

@end
