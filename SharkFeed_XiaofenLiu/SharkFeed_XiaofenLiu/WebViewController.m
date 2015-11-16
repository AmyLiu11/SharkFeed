//
//  WebViewController.m
//  SharkFeed_XiaofenLiu
//
//  Created by Xiaofen Liu on 11/14/15.
//  Copyright © 2015 Xiaofen Liu. All rights reserved.
//

#import "WebViewController.h"
#import "DetailImageViewController.h"

@interface WebViewController()

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UINavigationBar *bar;


@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bar.barTintColor = [UIColor blueColor];
    
    if (self.item != nil) {
        NSString *request = [NSString stringWithFormat:@"https://flickr.com/photo.gne?id=%ld", self.item.pID];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:request]];
        [self.webView loadRequest:requestObj];
    }
}

- (IBAction)backClicked:(id)sender {
    [self performSegueWithIdentifier:@"backImageView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"backImageView"]) {
        DetailImageViewController *destViewController = segue.destinationViewController;
        destViewController.item = self.item;
    }
}


@end
