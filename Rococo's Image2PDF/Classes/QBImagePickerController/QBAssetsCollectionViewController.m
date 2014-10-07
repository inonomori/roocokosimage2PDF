//
//  QBAssetsCollectionViewController.m
//  QBImagePickerController
//
//  Created by Tanaka Katsuma on 2013/12/31.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import "QBAssetsCollectionViewController.h"

// Views
#import "QBAssetsCollectionViewCell.h"
#import "QBAssetsCollectionFooterView.h"

#define TAG_BIGPHOTO_BLACK_BG 2931

@interface QBAssetsCollectionViewController ()

@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, assign) NSUInteger numberOfAssets;
@property (nonatomic, assign) NSUInteger numberOfPhotos;
@property (nonatomic, assign) NSUInteger numberOfVideos;

@property (nonatomic, weak) QBAssetsCollectionViewCell *longPressedCell;

@end

@implementation QBAssetsCollectionViewController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    
    if (self) {
        // View settings
        self.collectionView.backgroundColor = [UIColor whiteColor];
        
        // Register cell class
        [self.collectionView registerClass:[QBAssetsCollectionViewCell class]
                forCellWithReuseIdentifier:@"AssetsCell"];
        [self.collectionView registerClass:[QBAssetsCollectionFooterView class]
                forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                       withReuseIdentifier:@"FooterView"];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Scroll to bottom --- iOS 7 differences
    CGFloat topInset;
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        topInset = ((self.edgesForExtendedLayout && UIRectEdgeTop) && (self.collectionView.contentInset.top == 0)) ? (20.0 + 44.0) : 0.0;
    } else {
        topInset = (self.collectionView.contentInset.top == 0) ? (20.0 + 44.0) : 0.0;
    }
    
    [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.collectionViewLayout.collectionViewContentSize.height - self.collectionView.frame.size.height + topInset)
                                 animated:NO];
    
    // Validation
    if (self.allowsMultipleSelection) {
        self.navigationItem.rightBarButtonItem.enabled = [self validateNumberOfSelections:self.imagePickerController.selectedAssetURLs.count];
    }
}


#pragma mark - Accessors

- (void)setFilterType:(QBImagePickerControllerFilterType)filterType
{
    _filterType = filterType;
    
    // Set assets filter
    [self.assetsGroup setAssetsFilter:ALAssetsFilterFromQBImagePickerControllerFilterType(self.filterType)];
}

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    _assetsGroup = assetsGroup;
    
    // Set title
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    // Set assets filter
    [self.assetsGroup setAssetsFilter:ALAssetsFilterFromQBImagePickerControllerFilterType(self.filterType)];
    
    // Load assets
    NSMutableArray *assets = [NSMutableArray array];
    __block NSUInteger numberOfAssets = 0;
    __block NSUInteger numberOfPhotos = 0;
    __block NSUInteger numberOfVideos = 0;
    
    [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            numberOfAssets++;
            
            NSString *type = [result valueForProperty:ALAssetPropertyType];
            if ([type isEqualToString:ALAssetTypePhoto]) numberOfPhotos++;
            else if ([type isEqualToString:ALAssetTypeVideo]) numberOfVideos++;
            
            [assets addObject:result];
        }
    }];
    
    self.assets = assets;
    self.numberOfAssets = numberOfAssets;
    self.numberOfPhotos = numberOfPhotos;
    self.numberOfVideos = numberOfVideos;
    
    // Update view
    [self.collectionView reloadData];
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    self.collectionView.allowsMultipleSelection = allowsMultipleSelection;
    
    // Show/hide done button
    if (allowsMultipleSelection) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        [self.navigationItem setRightBarButtonItem:doneButton animated:NO];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }
}

- (BOOL)allowsMultipleSelection
{
    return self.collectionView.allowsMultipleSelection;
}


#pragma mark - Actions

- (void)done:(id)sender
{
    // Delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsCollectionViewControllerDidFinishSelection:)]) {
        [self.delegate assetsCollectionViewControllerDidFinishSelection:self];
    }
}


#pragma mark - Managing Selection

- (void)selectAssetHavingURL:(NSURL *)URL
{
    for (NSInteger i = 0; i < self.assets.count; i++) {
        ALAsset *asset = [self.assets objectAtIndex:i];
        NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
        
        if ([assetURL isEqual:URL]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            
            return;
        }
    }
}


#pragma mark - Validating Selections

- (BOOL)validateNumberOfSelections:(NSUInteger)numberOfSelections
{
    NSUInteger minimumNumberOfSelection = MAX(1, self.minimumNumberOfSelection);
    BOOL qualifiesMinimumNumberOfSelection = (numberOfSelections >= minimumNumberOfSelection);
    
    BOOL qualifiesMaximumNumberOfSelection = YES;
    if (minimumNumberOfSelection <= self.maximumNumberOfSelection) {
        qualifiesMaximumNumberOfSelection = (numberOfSelections <= self.maximumNumberOfSelection);
    }
    
    return (qualifiesMinimumNumberOfSelection && qualifiesMaximumNumberOfSelection);
}

- (BOOL)validateMaximumNumberOfSelections:(NSUInteger)numberOfSelections
{
    NSUInteger minimumNumberOfSelection = MAX(1, self.minimumNumberOfSelection);
    
    if (minimumNumberOfSelection <= self.maximumNumberOfSelection) {
        return (numberOfSelections <= self.maximumNumberOfSelection);
    }
    
    return YES;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.numberOfAssets;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QBAssetsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetsCell" forIndexPath:indexPath];
    cell.showsOverlayViewWhenSelected = self.allowsMultipleSelection;
    
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    cell.asset = asset;
    
    UILongPressGestureRecognizer *lpg = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPreviewView:)];
    
    
    [cell addGestureRecognizer:lpg];
    
    return cell;
}


- (void)imageHeaderTouched:(id)sender
{
    UITapGestureRecognizer *tgr = sender;
    UIImageView *imageViewAttached = (UIImageView *)tgr.view;
    
    if ([imageViewAttached.image isEqual:[UIImage imageNamed:@"doctor_header_default_60_60"]])
        return;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:imageViewAttached.image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    imageView.clipsToBounds = YES;
    imageView.layer.borderWidth = 0;
    imageView.frame = [[imageViewAttached superview] convertRect:imageViewAttached.frame toView:self.view];
    
    UIView *backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [FSToolBox getApplicationFrameSize].width, [FSToolBox getApplicationFrameSize].height)];
    backGroundView.backgroundColor = [UIColor blackColor];
    backGroundView.alpha = 0;
    backGroundView.tag = TAG_BIGPHOTO_BLACK_BG;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigImageTouched:)];
    [imageView addGestureRecognizer:singleTapGestureRecognizer];
    
    [self.view addSubview:backGroundView];
    [self.view addSubview:imageView];
    imageViewAttached.hidden = YES;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
     {
         imageView.frame = CGRectMake(0, 0, [FSToolBox getApplicationFrameSize].width, [FSToolBox getApplicationFrameSize].height);
         imageView.layer.cornerRadius = 0;
         backGroundView.alpha = 1;
         
     } completion:^(BOOL finished)
     {
         [self.navigationController setNavigationBarHidden:YES animated:YES];
     }];
}

- (void)bigImageTouched:(UITapGestureRecognizer *)sender
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UIImageView *imageView = (UIImageView*)sender.view;
    imageView.layer.cornerRadius = self.longPressedCell.frame.size.width/2;
    UIView *backgroundView = [self.view viewWithTag:TAG_BIGPHOTO_BLACK_BG];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
     {
         imageView.frame = [[self.longPressedCell superview] convertRect:self.longPressedCell.frame toView:self.view];
         backgroundView.alpha = 0;
         
     } completion:^(BOOL finished)
     {
         self.longPressedCell.hidden = NO;
         [imageView removeFromSuperview];
         [backgroundView removeFromSuperview];
     }];
}


- (void)gotoPreviewView:(UILongPressGestureRecognizer *)sender
{
    
    
    
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        QBAssetsCollectionViewCell *cell = (QBAssetsCollectionViewCell *)sender.view;
        self.longPressedCell = cell;
        ALAsset *asset = cell.asset;
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        UIImage *image = [UIImage imageWithCGImage:iref scale:[rep scale] orientation:UIImageOrientationUp];
        
        
        
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = YES;
        imageView.clipsToBounds = YES;
        imageView.layer.borderWidth = 0;
        imageView.frame = [[cell superview] convertRect:cell.frame toView:self.view];
        
        UIView *backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [FSToolBox getApplicationFrameSize].width, [FSToolBox getApplicationFrameSize].height)];
        backGroundView.backgroundColor = [UIColor blackColor];
        backGroundView.alpha = 0;
        backGroundView.tag = TAG_BIGPHOTO_BLACK_BG;
        
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigImageTouched:)];
        [imageView addGestureRecognizer:singleTapGestureRecognizer];
        
        [self.view addSubview:backGroundView];
        [self.view addSubview:imageView];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
         {
             imageView.frame = CGRectMake(0, 0, [FSToolBox getApplicationFrameSize].width, [FSToolBox getApplicationFrameSize].height);
             imageView.layer.cornerRadius = 0;
             backGroundView.alpha = 1;
             
         } completion:^(BOOL finished)
         {
             [self.navigationController setNavigationBarHidden:YES animated:YES];
         }];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.bounds.size.width, 46.0);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionFooter) {
        QBAssetsCollectionFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                      withReuseIdentifier:@"FooterView"
                                                                                             forIndexPath:indexPath];
        
        switch (self.filterType) {
            case QBImagePickerControllerFilterTypeNone:
                footerView.textLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"format_photos_and_videos",
                                                                                                  @"QBImagePickerController",
                                                                                                  nil),
                                             self.numberOfPhotos,
                                             self.numberOfVideos
                                             ];
                break;
                
            case QBImagePickerControllerFilterTypePhotos:
                footerView.textLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"format_photos",
                                                                                                  @"QBImagePickerController",
                                                                                                  nil),
                                             self.numberOfPhotos
                                             ];
                break;
                
            case QBImagePickerControllerFilterTypeVideos:
                footerView.textLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"format_videos",
                                                                                                  @"QBImagePickerController",
                                                                                                  nil),
                                             self.numberOfVideos
                                             ];
                break;
        }
        
        return footerView;
    }
    
    return nil;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(77.5, 77.5);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self validateMaximumNumberOfSelections:(self.imagePickerController.selectedAssetURLs.count + 1)];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
    // Validation
    if (self.allowsMultipleSelection) {
        self.navigationItem.rightBarButtonItem.enabled = [self validateNumberOfSelections:(self.imagePickerController.selectedAssetURLs.count + 1)];
    }
    
    // Delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsCollectionViewController:didSelectAsset:)]) {
        [self.delegate assetsCollectionViewController:self didSelectAsset:asset];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    
    // Validation
    if (self.allowsMultipleSelection) {
        self.navigationItem.rightBarButtonItem.enabled = [self validateNumberOfSelections:(self.imagePickerController.selectedAssetURLs.count - 1)];
    }
    
    // Delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsCollectionViewController:didDeselectAsset:)]) {
        [self.delegate assetsCollectionViewController:self didDeselectAsset:asset];
    }
}

@end
