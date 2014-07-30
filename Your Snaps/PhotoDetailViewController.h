//
//  PhotoDetailViewController.h
//  YourSnaps
//
//  Created by Hicham Chourak on 20/07/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Photo;

@interface PhotoDetailViewController : UIViewController

@property (strong, nonatomic) Photo *photo;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)saveButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)deleteButtonPressed:(UIBarButtonItem *)sender;

@end
