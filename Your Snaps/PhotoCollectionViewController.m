//
//  PhotoCollectionViewController.m
//  MySnaps
//
//  Created by Hicham Chourak on 31/07/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import "PhotoCollectionViewController.h"
#import "PhotoCollectionViewCell.h"
#import "Photo.h"
#import "PictureDataTransformer.h"
#import "CoreDataHelper.h"
#import "PhotoDetailViewController.h"

@interface PhotoCollectionViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSMutableArray *slider;
@property (strong, nonatomic) Photo *photo;

@end

@implementation PhotoCollectionViewController {
    BOOL cameraIsAvailable;
}

- (NSMutableArray *)photos
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
    self.collectionView.backgroundColor = [UIColor whiteColor];
    cameraIsAvailable = NO;
    self.navigationItem.title = self.albumTitleText;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithRed:(239.0 / 255.0) green:(240.0 / 255.0) blue:(244.0 / 255.0) alpha: 1];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSSet *unorderedPhotos = self.album.photos;
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSArray *sortedPhotos = [unorderedPhotos sortedArrayUsingDescriptors:@[dateDescriptor]];
    
    self.photos = [sortedPhotos mutableCopy];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DetailSegue"])
    {
        if ([segue.destinationViewController isKindOfClass:[PhotoDetailViewController class]])
        {
            PhotoDetailViewController *targetViewController = segue.destinationViewController;
            //NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
            Photo *selectedPhoto = [self.photos lastObject];//self.photos[indexPath.row];
            targetViewController.photo = selectedPhoto;
        }
    }
    
}

- (IBAction)cameraBarButtonItemPressed:(UIBarButtonItem *)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        cameraIsAvailable = YES;
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                @"Take Photo",
                                @"Choose From Collection",
                                nil];
        [popup showInView:[UIApplication sharedApplication].keyWindow];
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        cameraIsAvailable = NO;
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                @"Choose From Collection",
                                nil];
        [popup showInView:[UIApplication sharedApplication].keyWindow];
    }
    
    
    /*UIImagePickerController *picker = [[UIImagePickerController alloc] init];
     picker.delegate = self;
     
     if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
     {
     picker.sourceType = UIImagePickerControllerSourceTypeCamera;
     } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
     picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
     }
     
     [self presentViewController:picker animated:YES completion:nil];*/
}

- (IBAction)deleteBarButtonItemPressed:(UIBarButtonItem *)sender
{
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    browser.zoomPhotosToFill = YES;
    browser.displayActionButton = YES;
    browser.displayNavArrows = YES;
    browser.alwaysShowControls = NO;
    browser.enableGrid = NO;
    browser.startOnGrid = NO;
    browser.displaySelectionButtons = YES;
    
    [browser setCurrentPhotoIndex:0];
    
    [self.navigationController pushViewController:browser animated:YES];
    
    [browser showNextPhotoAnimated:YES];
    [browser showPreviousPhotoAnimated:YES];
}

#pragma mark - Helper Methods

- (Photo *)photoFromImage:(UIImage *)image
{
    Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:[CoreDataHelper managedObjectContext]];
    photo.image = image;
    //photo.originalImage = image;
    photo.date = [NSDate date];
    photo.albumBook = self.album;
    
    NSError *error = nil;
    
    if (![[photo managedObjectContext] save:&error]) {
        //Error
        //NSLog(@"%@", error);
    }
    
    return photo;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(int)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    
    float scaleRatio = 0;
    
    if (image.size.width < image.size.height)
    {
        scaleRatio = newSize / image.size.width;
    } else {
        scaleRatio = newSize / image.size.height;
    }
    
    CGSize size = CGSizeMake((int)(image.size.width * scaleRatio), (int)(image.size.height * scaleRatio));
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PhotoCell";
    
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Photo *photo = self.photos[indexPath.row];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.imageView.image = photo.image;
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark -UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    browser.zoomPhotosToFill = YES;
    browser.displayActionButton = YES;
    browser.displayNavArrows = YES;
    browser.alwaysShowControls = NO;
    browser.enableGrid = NO;
    browser.startOnGrid = NO;
    //browser.displaySelectionButtons = YES;
    
    [browser setCurrentPhotoIndex:indexPath.row];
    
    [browser showNextPhotoAnimated:YES];
    [browser showPreviousPhotoAnimated:YES];
    
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return [self.photos count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    
    if (index < [self.photos count])
    {
        Photo *photo = self.photos[index];
        MWPhoto *sliderPhoto = [MWPhoto photoWithImage:photo.image];
        
        return sliderPhoto;
    }
    
    return nil;
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index
{
    return NO;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected
{
    self.photo = self.photos[index];
    
    [[self.photo managedObjectContext] deleteObject:self.photo];
    
    
    NSError *error = nil;
    
    [[self.photo managedObjectContext] save:&error];
    
    if (error)
    {
        //NSLog(@"%@", error);
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView *primaryImage = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)];
            primaryImage.backgroundColor = [UIColor clearColor];
            primaryImage.alpha =1.0f;
            
            UIView *secondaryImage = [[UIView alloc] initWithFrame:CGRectMake(0,0,70,70)];
            secondaryImage.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
            secondaryImage.backgroundColor = [UIColor blackColor];
            secondaryImage.alpha = 0.7;
            secondaryImage.layer.cornerRadius = 5;
            [primaryImage addSubview:secondaryImage];
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
            indicator.center = CGPointMake(35, 35);
            [indicator setHidesWhenStopped:NO];
            [secondaryImage addSubview:indicator];
            [indicator startAnimating];
            
            
            [picker.view addSubview:primaryImage];
            
        });
        
        UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
        if (!selectedImage) selectedImage = info[UIImagePickerControllerOriginalImage];
        
        int scale = 960;
        UIImage *image;
        
        if (selectedImage.size.width > scale || selectedImage.size.height > scale )
        {
            image = [self imageWithImage:selectedImage scaledToSize:960];
        } else {
            image = selectedImage;
        }
        
        [self.photos addObject:[self photoFromImage:image]];
        
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [self dismissViewControllerAnimated:YES completion:nil];
            [self performSegueWithIdentifier:@"DetailSegue" sender:nil];
        });
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //NSLog(@"cancel");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    if (cameraIsAvailable)
    {
        switch (buttonIndex) {
            case 0:
                [self performSelector:@selector(showCamera) withObject:nil afterDelay:0.3];
                break;
            case 1:
                [self performSelector:@selector(showSavedPhotos) withObject:nil afterDelay:0.3];
                break;
            default:
                break;
        }
    } else {
        switch (buttonIndex) {
            case 0:
                [self performSelector:@selector(showSavedPhotos) withObject:nil afterDelay:0.3];
                break;
            default:
                break;
        }
    }
}

- (void)showCamera
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)showSavedPhotos
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            [button setTitleColor:[UIColor colorWithRed:(83.0 / 255.0) green:(95.0 / 255.0) blue:(147.0 / 255.0) alpha: 1] forState:UIControlStateNormal];
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    navigationController.navigationBar.barStyle = UIBarStyleBlack;
}


@end
