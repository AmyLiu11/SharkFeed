//
//  PhotoItem.h
//  SharkFeed_XiaofenLiu
//
//  Created by Xiaofen Liu on 11/12/15.
//  Copyright © 2015 Xiaofen Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PhotoItem : NSObject

@property (nonatomic, strong) NSString * photoDescription;
@property (nonatomic, strong) NSURL * thumbnailURLString;
@property (nonatomic, strong) NSURL * regularURLString;
@property (nonatomic, strong) NSString * author;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) UIImage * lImage;
@property (nonatomic, readonly) BOOL hasImage; // Return YES if image is downloaded.
@property (nonatomic, getter = isFailed) BOOL failed; // Return Yes if image failed to be downloaded

@end
