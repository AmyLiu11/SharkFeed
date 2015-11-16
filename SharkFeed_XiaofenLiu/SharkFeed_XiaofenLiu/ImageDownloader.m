//
//  ImageDownloader.m
//  SharkFeed_XiaofenLiu
//
//  Created by Xiaofen Liu on 11/12/15.
//  Copyright © 2015 Xiaofen Liu. All rights reserved.
//

#import "ImageDownloader.h"
#import "SharkDefines.h"


@interface ImageDownloader()
@property (nonatomic, strong) NSURLSessionDataTask *sessionTask;

@end

@implementation ImageDownloader

- (void)startDownload:(int)type
{
    NSURLRequest *request = nil;
    if (type == IMAGE_TYPE_THUMB) {
        request = [NSURLRequest requestWithURL:self.photoRecord.thumbnailURLString];
    } else {
        request = [NSURLRequest requestWithURL:self.photoRecord.regularURLString];
    }
    
    // create an session data task to obtain and download the app icon
   self.sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                       
       if (error != nil)
       {
             if ([error code] == NSURLErrorAppTransportSecurityRequiresSecureConnection)
             {
                abort();
             }
       }
                                            
       [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
           UIImage *image = [[UIImage alloc] initWithData:data];
           
           if (type == IMAGE_TYPE_THUMB) {
               
               if (image.size.width != ThumbPhotoSize || image.size.height != ThumbPhotoSize)
               {
                   CGSize itemSize = CGSizeMake(ThumbPhotoSize, ThumbPhotoSize);
                   UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
                   CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                   [image drawInRect:imageRect];
                   self.photoRecord.image = UIGraphicsGetImageFromCurrentImageContext();
                   UIGraphicsEndImageContext();
               }
               else
               {
                   self.photoRecord.image = image;
               }
               
           } else {
               
               if (image != nil && (image.size.width != SCREEN_WIDTH || image.size.height != SCREEN_HEIGHT))
               {
                   CGSize itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
                   UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
                   CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                   [image drawInRect:imageRect];
                   self.photoRecord.lImage = UIGraphicsGetImageFromCurrentImageContext();
                   UIGraphicsEndImageContext();
               }
               else
               {
                   self.photoRecord.lImage = image;
               }
           }
           
           // call our completion handler to tell our client that our icon is ready for display
           if (self.completionHandler != nil)
           {
               self.completionHandler();
           }
       }];
                                                       
    }];
    [self.sessionTask resume];
}

- (void)cancelDownload
{
    [self.sessionTask cancel];
    _sessionTask = nil;
}


@end
