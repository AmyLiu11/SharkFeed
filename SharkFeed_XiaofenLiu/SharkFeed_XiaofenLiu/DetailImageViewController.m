//
//  DetailImageViewController.m
//  SharkFeed_XiaofenLiu
//
//  Created by Xiaofen Liu on 11/13/15.
//  Copyright © 2015 Xiaofen Liu. All rights reserved.
//

#import "DetailImageViewController.h"
#import "ImageDownloader.h"
#import "SharkDefines.h"
#import "WebViewController.h"

@interface DetailImageViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *largeImageView;
@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) ImageDownloader * downloader;

@end

@implementation DetailImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.item != nil && self.item.lImage != nil) {
        self.largeImageView.image = self.item.lImage;
        self.titleLabel.text = self.item.title;
        return;
    }

    self.downloader = [[ImageDownloader alloc] init];

    self.downloader.photoRecord = self.item;
    __weak UIImageView * weakImageView = self.largeImageView;
    __weak PhotoItem * weakItem = self.item;
    __weak UILabel * weakLabel = self.titleLabel;
    [self.downloader setCompletionHandler:^{
        
            // Display the newly loaded image
        if (weakItem.lImage) {
            weakImageView.image = weakItem.lImage;
        }
        weakLabel.text = weakItem.title;
        
    }];
    [self.downloader startDownload:IMAGE_TYPE_LARGE];
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnPressed:(id)sender {
     [self performSegueWithIdentifier:@"back" sender:self];
}

- (IBAction)hitDownload:(id)sender {
    if (self.item.lImage != nil) {
        UIImageWriteToSavedPhotosAlbum(self.item.lImage ,
                                       self,
                                       @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:),
                                       NULL);
    }
}

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Save Failed"
                                      message:@""
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Save Successful"
                                      message:@""
                                      preferredStyle:
                                      UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        [alert addAction:ok];

        [self presentViewController:alert animated:YES completion:nil];
    }
}


- (IBAction)hitFlickr:(id)sender {
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showWebview"]) {
        WebViewController *destViewController = segue.destinationViewController;
        destViewController.item = self.item;
    }

}


@end
