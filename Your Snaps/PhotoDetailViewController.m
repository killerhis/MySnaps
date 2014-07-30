//
//  PhotoDetailViewController.m
//  YourSnaps
//
//  Created by Hicham Chourak on 20/07/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "Photo.h"
#import "FiltersCollectionViewController.h"

@interface PhotoDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *filters;
@property (strong, nonatomic) CIContext *context;
@property (strong, nonatomic) UIImage *scaledImage;
@end

@implementation PhotoDetailViewController

- (NSMutableArray *)filters
{
    if (!_filters)
    {
        _filters = [[NSMutableArray alloc] init];
        
    }
    
    return _filters;
}

- (CIContext *)context
{
    if (!_context) {
        _context = [CIContext contextWithOptions:nil];
    }
    
    return _context;
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
    // Do any additional setup after loading the view.
    self.filters = [[[self class] photoFilters] mutableCopy];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.imageView.image = self.photo.image;
    self.view.backgroundColor = [UIColor blackColor];
    self.scaledImage = [self imageWithImage:self.photo.originalImage scaledToSize:80];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FilterSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[FiltersCollectionViewController class]])
        {
            FiltersCollectionViewController *targetViewController = segue.destinationViewController;
            targetViewController.photo = self.photo;
        }
    }
}


- (IBAction)saveButtonPressed:(UIBarButtonItem *)sender
{
    self.photo.image = self.imageView.image;
    
    if (self.photo.image) {
        
        NSError *error = nil;
        
        if (![[self.photo managedObjectContext] save:&error]) {
            //Handle Error
            NSLog(@"%@", error);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)deleteButtonPressed:(UIBarButtonItem *)sender
{
    [[self.photo managedObjectContext] deleteObject:self.photo];
    
    
    NSError *error = nil;
    
    [[self.photo managedObjectContext] save:&error];
    
    if (error)
    {
        NSLog(@"%@", error);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Helpers

+ (NSArray *)photoFilters
{
    CIFilter *sepia = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:nil];
    CIFilter *blur = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:nil];
    CIFilter *colorClamp = [CIFilter filterWithName:@"CIColorClamp" keysAndValues:@"inputMaxComponents", [CIVector vectorWithX:0.9 Y:0.9 Z:0.9 W:0.9], @"inputMinComponents", [CIVector vectorWithX:0.2 Y:0.2 Z:0.2 W:0.2], nil];
    CIFilter *instant = [CIFilter filterWithName:@"CIPhotoEffectInstant" keysAndValues:nil];
    CIFilter *noir = [CIFilter filterWithName:@"CIPhotoEffectNoir" keysAndValues:nil];
    CIFilter *vignette = [CIFilter filterWithName:@"CIVignetteEffect" keysAndValues:nil];
    CIFilter *colorControl = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputSaturationKey, @0.5, nil];
    CIFilter *transfer = [CIFilter filterWithName:@"CIPhotoEffectTransfer" keysAndValues:nil];
    CIFilter *unsharpen = [CIFilter filterWithName:@"CIUnsharpMask" keysAndValues:nil];
    CIFilter *monochrome = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:nil];
    
    NSArray *allFilters = @[sepia, blur, colorClamp, instant, noir, vignette, colorControl, transfer, unsharpen, monochrome];
    
    return allFilters;
}

- (UIImage *)filteredImageFromImage:(UIImage *)image andFilter:(CIFilter *)filter
{
    CIImage *unfilterdImage = [[CIImage alloc] initWithCGImage:image.CGImage];
    
    [filter setValue:unfilterdImage forKey:kCIInputImageKey];
    CIImage *filteredImage = [filter outputImage];
    
    CGRect extent = [filteredImage extent];
    CGImageRef cgImage = [self.context createCGImage:filteredImage fromRect:extent];
    
    UIImage *finalImage = [UIImage imageWithCGImage:cgImage];
    
    return finalImage;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.filters count] +1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    UIImageView *previewImageView = (UIImageView *)[cell viewWithTag:2000];
    
    if (indexPath.row == 0)
    {
        previewImageView.image = self.scaledImage;
    } else {
    
        dispatch_queue_t filterQueue = dispatch_queue_create("filter queue", NULL);
        
        dispatch_async(filterQueue, ^{
            // NSDate *start = [NSDate date];
            //UIImage *scaledImage = [self imageWithImage:self.photo.originalImage scaledToSize:80];
            UIImage *filterImage = [self filteredImageFromImage:self.scaledImage andFilter:self.filters[indexPath.row-1]];
            //NSLog(@"%f %f", scaledImage.size.width, scaledImage.size.height);
            //UIImage *filterImage = [self filteredImageFromImage:self.photo.originalImage andFilter:self.filters[indexPath.row]];
            dispatch_async(dispatch_get_main_queue(), ^{
                previewImageView.image = filterImage;
            });
            //NSDate *done = [NSDate date];
            //NSTimeInterval exeTime = [done timeIntervalSinceDate:start];
            //NSLog(@"%f", exeTime);
        });
        //end
    }
    return cell;
}

#pragma mark -UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UICollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    
    //self.photo.image = selectedCell.imageView.image;
    if (indexPath.row == 0)
    {
        self.imageView.image = self.photo.originalImage;
        [self.imageView setNeedsDisplay];
    } else {
        dispatch_queue_t filterQueue = dispatch_queue_create("filter queue", NULL);
        
        dispatch_async(filterQueue, ^{
            UIImage *filterImage = [self filteredImageFromImage:self.photo.originalImage andFilter:self.filters[indexPath.row-1]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = filterImage;
                [self.imageView setNeedsDisplay];
            });
        });
    }
    /*if (self.photo.image) {
        
        NSError *error = nil;
        
        if (![[self.photo managedObjectContext] save:&error]) {
            //Handle Error
            NSLog(@"%@", error);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }*/

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

@end
