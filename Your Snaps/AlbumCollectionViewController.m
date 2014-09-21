//
//  AlbumCollectionViewController.m
//  MySnaps
//
//  Created by Hicham Chourak on 23/07/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import "AlbumCollectionViewController.h"
#import "Album.h"
#import "Photo.h"
#import "CoreDataHelper.h"
#import "PhotoCollectionViewController.h"
#import "GAIDictionaryBuilder.h"

@interface AlbumCollectionViewController ()

@property (strong, nonatomic) NSIndexPath *path;
//@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSArray *photos;

@end

@implementation AlbumCollectionViewController

- (NSMutableArray *)albums
{
    if (!_albums) {
        _albums = [[NSMutableArray alloc] init];
    }
    return _albums;
}

- (NSArray *)photos
{
    if (!_photos) {
        _photos = [[NSMutableArray alloc] init];
    }
    return _photos;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:(239.0 / 255.0) green:(240.0 / 255.0) blue:(244.0 / 255.0) alpha: 1];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"AlbumCollectionView"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Album"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    NSError *error = nil;
    
    NSArray *fetchedAlbum = [[CoreDataHelper managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    self.albums = [fetchedAlbum mutableCopy];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)addAblumBarButtomItemPressed:(UIBarButtonItem *)sender
{
    UIAlertView *newAlbumAlertView = [[UIAlertView alloc] initWithTitle:@"Enter New Album Name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    [newAlbumAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [newAlbumAlertView show];
}

#pragma mark - Helper Methods

- (Album *)albumWithName:(NSString *)name
{
    NSManagedObjectContext *context = [CoreDataHelper managedObjectContext];
    
    Album *album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:context];
    album.name = name;
    album.date = [NSDate date];
    
    NSError *error = nil;
    
    if (![context save:&error]) {
        // we have error
        //NSLog(@"%@", error);
    }
    return album;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *alertText = [alertView textFieldAtIndex:0].text;
        
        [self.albums addObject:[self albumWithName:alertText]];
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.albums count] -1 inSection:0]]];
        //[self.collectionView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.albums count] -1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1001];
    
    Album *selectedAlbum = self.albums[indexPath.row];
    
    NSSet *unorderedPhotos = selectedAlbum.photos;
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSArray *sortedPhotos = [unorderedPhotos sortedArrayUsingDescriptors:@[dateDescriptor]];
    
    //self.photos = [sortedPhotos mutableCopy];
    self.photos = sortedPhotos;
        
    if ([self.photos count] != 0) {
        Photo *photo = self.photos[0];
        imageView.image = photo.image;
    } else {
        imageView.image = nil;//[UIImage imageNamed:@"astronaut.jpg"];
    }
    
    UILabel *label = (UILabel *)[cell viewWithTag:1000];
    label.text = selectedAlbum.name;
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.albums count];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UICollectionViewCell *selectedCell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    //self.photo.image = selectedCell.imageView.image;
    
    self.path = indexPath;
    
    [self performSegueWithIdentifier:@"AlbumChosen" sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Album *selectedAlbum = self.albums[self.path.row];
    
    if ([segue.identifier isEqualToString:@"AlbumChosen"]) {
        PhotoCollectionViewController *targetViewController = segue.destinationViewController;
        targetViewController.album = selectedAlbum;
        targetViewController.albumTitleText = selectedAlbum.name;
    }
}


@end
