//
//  AlbumTableViewController.h
//  YourSnaps
//
//  Created by Hicham Chourak on 19/07/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *albums;
- (IBAction)addAblumBarButtomItemPressed:(UIBarButtonItem *)sender;
@end
