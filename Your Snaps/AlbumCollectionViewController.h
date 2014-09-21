//
//  AlbumCollectionViewController.h
//  MySnaps
//
//  Created by Hicham Chourak on 23/07/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumCollectionViewController : UICollectionViewController


@property (strong, nonatomic) NSMutableArray *albums;
- (IBAction)addAblumBarButtomItemPressed:(UIBarButtonItem *)sender;
@end
