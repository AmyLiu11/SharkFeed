//
//  FlickerFetcherOperation.m
//  SharkFeed_XiaofenLiu
//
//  Created by Xiaofen Liu on 11/13/15.
//  Copyright © 2015 Xiaofen Liu. All rights reserved.
//

#import "FlickerFetcherOperation.h"
#import "PhotoItem.h"
#import "SharkDefines.h"

@interface FlickerFetcherOperation()

@property (nonatomic, strong) NSArray * photoList;

@property (nonatomic, strong) NSData *dataToParse;

@property (nonatomic, strong) NSMutableArray *workingArray;

@property (nonatomic, strong) PhotoItem * currentItem;


@end

@implementation FlickerFetcherOperation

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self != nil)
    {
        _dataToParse = data;
        _workingArray = [NSMutableArray array];
    }
    return self;
}

- (void)main
{
    NSError * error = nil;
    NSDictionary * results = _dataToParse ? [NSJSONSerialization JSONObjectWithData:_dataToParse options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error: &error] : nil;
    NSArray * temp = [results valueForKeyPath:@"photos.photo"];
    
    for (NSDictionary * dic in temp) {
        self.currentItem = [[PhotoItem alloc] init];
        self.currentItem.title = [dic objectForKey:FLICKR_PHOTO_TITLE];
        self.currentItem.thumbnailURLString = [NSURL URLWithString:[dic objectForKey:FLICKR_PHOTO_URL_Thumbnail]];
        self.currentItem.regularURLString = [NSURL URLWithString:[dic objectForKey:FLICKR_PHOTO_URL_Large]];
        [self.workingArray addObject:self.currentItem];
        self.currentItem = nil;
    }
    
    if (![self isCancelled])
    {
        // Set appRecordList to the result of our parsing
        self.photoList = [NSArray arrayWithArray:self.workingArray];
    }
    
    self.workingArray = nil;
    self.dataToParse = nil;
}


@end
