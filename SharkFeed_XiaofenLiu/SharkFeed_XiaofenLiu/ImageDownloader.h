//
//  ImageDownloader.h
//  SharkFeed_XiaofenLiu
//
//  Created by Xiaofen Liu on 11/12/15.
//  Copyright © 2015 Xiaofen Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PhotoItem.h"

@interface ImageDownloader : NSObject

@property (nonatomic, strong) PhotoItem * photoRecord;
@property (nonatomic, copy) void (^completionHandler)(void);

- (void)startDownload:(int)type;
- (void)cancelDownload;

@end
