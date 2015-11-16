//
//  SharkDefines.h
//  SharkFeed_XiaofenLiu
//
//  Created by Xiaofen Liu on 11/13/15.
//  Copyright © 2015 Xiaofen Liu. All rights reserved.
//

#ifndef SharkDefines_h
#define SharkDefines_h

#define ThumbPhotoSize 100
#define IMAGE_TYPE_THUMB 200
#define IMAGE_TYPE_LARGE 300
#define SCREEN_WIDTH_BEFORE_IPHONE6 320

#define SCREEN_WIDTH (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

#define FLICKR_PHOTO_TITLE @"title"
#define FLICKR_PHOTO_URL_Large @"url_l"
#define FLICKR_PHOTO_URL_Thumbnail @"url_t"
#define FLICKR_PHOTO_ID @"id"
#define FlickrAPIKey @"949e98778755d1982f537d56236bbb42"

#define kCustomCount 18

#endif /* SharkDefines_h */
