//
//  PhotoCollectionViewController.h
//  MySnaps
//
//  Created by Hicham Chourak on 31/07/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "MWPhotoBrowser.h"

@interface PhotoCollectionViewController : UIViewController <MWPhotoBrowserDelegate>

@property (strong, nonatomic) Album *album;

- (IBAction)cameraBarButtonItemPressed:(UIBarButtonItem *)sender;
- (IBAction)deleteBarButtonItemPressed:(UIBarButtonItem *)sender;

@end
