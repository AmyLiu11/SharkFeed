//
//  PhotoNavigationController.m
//  SharkFeed_XiaofenLiu
//
//  Created by Xiaofen Liu on 11/12/15.
//  Copyright © 2015 Xiaofen Liu. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotoItem.h"
#import "ImageDownloader.h"
#import "FlickerFetcherOperation.h"
#import "DetailImageViewController.h"
#import "SharkDefines.h"


static NSString *CellIdentifier = @"FlickrCell";
static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";

@interface PhotoViewController ()

@property (strong, nonatomic) IBOutlet UINavigationBar *bar;

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@property (nonatomic, strong) FlickerFetcherOperation *parser;

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) UIRefreshControl * refreshControl;

@property (nonatomic, strong) UIImageView * fishHook;

@property (nonatomic, strong) UIImageView * fish;

@property (nonatomic, strong) UILabel * pullLabel;

@property (nonatomic, assign) NSUInteger page;

@property (nonatomic, assign) NSUInteger totalPage;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bar.barTintColor = [UIColor blueColor];
    self.SharkFeedView.delegate = self;
    self.SharkFeedView.dataSource = self;
    _imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.page = 1;
    [self setupRefreshControl];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.entries != nil && self.entries.count != 0) {
        [self.SharkFeedView reloadData];
    } else {
        [self fetchJsonDataFromFlickrWithPage:(int)self.page];
    }
}

- (void)startRefresh:(id)sender{
    self.page = 1;
    [self fetchJsonDataFromFlickrWithPage:(int)self.page];
    [(UIRefreshControl *)sender endRefreshing];
}


- (BOOL)fetchJsonDataFromFlickrWithPage:(int)page{
    
    NSString *tag = @"shark";
    NSString *request = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&tags=%@&page=%d&extras=url_t,url_c,url_l,url_o&format=json&nojsoncallback=1&api_key=%@", tag, page, FlickrAPIKey];
    
    // create an session data task to obtain and the shark feed
    NSURLSessionDataTask *sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:request]]
                                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                                            
                                                                            
                                                                            if (error != nil)
                                                                            {
                                                                                
                                                                                [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                                                                                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                                                    
                                                                                    if ([error code] == NSURLErrorAppTransportSecurityRequiresSecureConnection)
                                                                                    {
                                                                                                                                                                        abort();
                                                                                    }
                                                                                    else
                                                                                    {
                                                                                        [self handleError:error];
                                                                                    }
                                                                                }];
                                                                            }
                                                                            else
                                                                            {
                                                                                // create the queue to run our ParseOperation
                                                                                self.queue = [[NSOperationQueue alloc] init];
                                                                                
                                                                                // create an FlickerFetcherOperation (NSOperation subclass) to parse the Shark feed data so that the UI is not blocked
                                                                                NSDictionary * results = data ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error: &error] : nil;
                                                                                self.totalPage =  [[results valueForKeyPath:@"photos.pages"] integerValue];
                                                                                
                                                                                NSLog(@"%ld", [[results valueForKeyPath:@"photos.page"] integerValue]);
                                                                                _parser = [[FlickerFetcherOperation alloc] initWithData:data];
                                                                                
                                                                                __weak PhotoViewController *weakSelf = self;
                                                                                
                                                                                self.parser.errorHandler = ^(NSError *parseError) {
                                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                                                        [weakSelf handleError:parseError];
                                                                                    });
                                                                                };
                                                                                
                                                                                // referencing parser from within its completionBlock would create a retain cycle
                                                                                __weak FlickerFetcherOperation *weakParser = self.parser;
//                                                                                __weak UIRefreshControl * control = self.refreshControl;
//                                                                                __weak UILabel * lab = self.pullLabel;
                                                                                
                                                                                self.parser.completionBlock = ^(void) {
                                                                                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                                                    if (weakParser.photoList != nil)
                                                                                    {
                                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                                            if (self.page != 1) {
                                                                                                [weakSelf.entries addObjectsFromArray:weakParser.photoList];
                                                                                            } else {
                                                                                                if (weakSelf.entries != nil) {
                                                                                                    weakSelf.entries = nil;
                                                                                                }
                                                                                                weakSelf.entries = [NSMutableArray arrayWithArray:weakParser.photoList];
                                                                                            }
                                                                    
//                                                                                            [control endRefreshing];
                                                                                            // tell our collection view to reload its data, now that parsing has completed
                                                                                            [weakSelf.SharkFeedView reloadData];
                                                                                            
                                                                                        });
                                                                                    }
                                                                                    
                                                                                    // we are finished with the queue and our ParseOperation
                                                                                    weakSelf.queue = nil;
                                                                                };
                                                                                
                                                                                [self.queue addOperation:self.parser]; // this will start the "ParseOperation"
                                                                            }
                                                                        }];
    
    [sessionTask resume];
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    return YES;
}

- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    
    // alert user that our current record was deleted, and then we leave this view controller
    //
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Show SharkFeed"
                                                                   message:errorMessage
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         // dissmissal of alert completed
                                                     }];
    
    [alert addAction:OKAction];
    [self presentViewController:alert animated:YES completion:nil];
}



- (void)terminateAllDownloads
{
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
}

- (void)dealloc
{
    // terminate all pending download connections
    [self terminateAllDownloads];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self terminateAllDownloads];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger count = self.entries.count;
    
    // if there's no data yet, return enough rows to fill the screen
    if (count == 0)
    {
        return kCustomCount;
    }
    return count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = nil;
    
    NSUInteger nodeCount = self.entries.count;
    
    if (nodeCount == 0)
    {
        // add a placeholder cell while waiting on table data
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:PlaceholderCellIdentifier forIndexPath:indexPath];
        
    }
    else
    {
       cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Leave cells empty if there's no data yet
        if (nodeCount > 0)
        {
            // Set up the cell representing the app
            PhotoItem * pItem = (self.entries)[indexPath.item];
            
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
            
            // Only load cached images; defer new downloads until scrolling ends
            if (!pItem.image)
            {
                if (self.SharkFeedView.dragging == NO && self.SharkFeedView.decelerating == NO)
                {
                    [self startIconDownload:pItem forIndexPath:indexPath];
                }
                // if a download is deferred or in progress, return a placeholder image
                imageView.image = [UIImage imageNamed:@"placeholder.png"];
            }
            else
            {
                imageView.image = pItem.image;
            }
        }
    }
    
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.item == self.entries.count - 1) {
        self.page++;
        if (self.page > self.totalPage) {
            return;
        }
        [self fetchJsonDataFromFlickrWithPage:(int)self.page];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (SCREEN_WIDTH == SCREEN_WIDTH_BEFORE_IPHONE6) {
        return CGSizeMake(80, 80);
    }
    return CGSizeMake(100, 100);
}


#pragma mark - Collection cell image support

- (void)startIconDownload:(PhotoItem *)pRecord forIndexPath:(NSIndexPath *)indexPath
{
    ImageDownloader *iconDownloader = (self.imageDownloadsInProgress)[indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[ImageDownloader alloc] init];
        iconDownloader.photoRecord = pRecord;
        [iconDownloader setCompletionHandler:^{
            
            UICollectionViewCell *cell = [self.SharkFeedView cellForItemAtIndexPath:indexPath];
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];

            // Display the newly loaded image
            imageView.image = pRecord.image;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        (self.imageDownloadsInProgress)[indexPath] = iconDownloader;
        [iconDownloader startDownload:IMAGE_TYPE_THUMB];
    }
}

- (void)loadImagesForOnscreenRows
{
    if (self.entries.count > 0)
    {
        NSArray *visibleItems = [self.SharkFeedView indexPathsForVisibleItems];
        
        for (NSIndexPath *indexPath in visibleItems)
        {
            PhotoItem * pItem = (self.entries)[indexPath.item];
            
            if (!pItem.image)
                // Avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:pItem forIndexPath:indexPath];
            }
        }
    }
}

#pragma mark - Pull to refresh UI

- (void)setupRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    // Create the graphic image views
    self.fishHook = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Pull to refresh 1.png"]];
    self.fish = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Pull to refresh 2.png"]];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"Pull to refresh sharks"];
    NSRange fullRange = NSMakeRange(0, [string length]);
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:fullRange];
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Georgia" size:12] range:fullRange];
    self.pullLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 150, 30)];
    self.pullLabel.attributedText = string;
//    self.pullLabel.text = @"Pull to refresh";
    self.pullLabel.numberOfLines = 1;
    self.pullLabel.textAlignment = NSTextAlignmentCenter;
    
    // Hide the original spinner icon
    self.refreshControl.tintColor = [UIColor clearColor];
    
    [self.refreshControl addSubview:self.fishHook];
    [self.refreshControl addSubview:self.fish];
    [self.refreshControl addSubview:self.pullLabel];
    
    self.fishHook.center = CGPointMake(SCREEN_WIDTH / 2, self.refreshControl.center.y);
    self.fish.center = CGPointMake(self.fishHook.center.x, self.fishHook.center.y + 30);
    self.pullLabel.center = CGPointMake(self.fishHook.center.x, self.fish.center.y + self.fish.frame.size.height + 5);
    self.fishHook.alpha = 0;
    self.fish.alpha = 0;
    self.pullLabel.alpha = 0;
    
    [self.refreshControl addTarget:self action:@selector(startRefresh:)
                  forControlEvents:UIControlEventValueChanged];
    [self.SharkFeedView addSubview:self.refreshControl];
}



-(void)fadeOut:(UIView*)viewToDissolve withDuration:(NSTimeInterval)duration   andWait:(NSTimeInterval)wait
{
    [UIView beginAnimations: @"Fade Out" context:nil];
    
    // wait for time before begin
    [UIView setAnimationDelay:wait];
    
    // druation of animation
    [UIView setAnimationDuration:duration];
    viewToDissolve.alpha = 0.0;
    [UIView commitAnimations];
}


-(void) fadeIn:(UIView*)viewToFadeIn withDuration:(NSTimeInterval)duration andWait:(NSTimeInterval)wait

{
    [UIView beginAnimations: @"Fade In" context:nil];
    
    // wait for time before begin
    [UIView setAnimationDelay:wait];
    
    // druation of animation
    [UIView setAnimationDuration:duration];
    viewToFadeIn.alpha = 1;
    [UIView commitAnimations];
    
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//    self.pullLabel.text = @"Refreshing...";
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Distance the table has been pulled >= 0
    CGFloat pullDistance = MAX(0.0, -self.refreshControl.frame.origin.y);
    
    if (pullDistance >= self.fish.frame.origin.y + self.fish.frame.size.height) {
        [self fadeIn:self.fishHook withDuration:0.5f andWait:0.0f];
        [self fadeIn:self.fish withDuration:0.5f andWait:0.0f];
        
    } else {
        [self fadeOut:self.fishHook withDuration:0.1f andWait:0.0f];
        [self fadeOut:self.fish withDuration:0.1f andWait:0.0f];
    }
    
    if (pullDistance >= self.fish.frame.origin.y + self.fish.frame.size.height + 10) {
        [self fadeIn: self.pullLabel withDuration:0.5f andWait:0.0f];
    } else {
        [self fadeOut:self.pullLabel withDuration:0.1f andWait:0.0f];
    }
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        NSArray *indexPaths = [self.SharkFeedView indexPathsForSelectedItems];
        DetailImageViewController *destViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        destViewController.item = (self.entries)[indexPath.item];
        [self.SharkFeedView deselectItemAtIndexPath:indexPath animated:NO];
    }
}


@end
