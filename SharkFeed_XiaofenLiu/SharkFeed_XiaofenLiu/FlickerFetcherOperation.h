//
//  FlickerFetcherOperation.h
//  SharkFeed_XiaofenLiu
//
//  Created by Xiaofen Liu on 11/13/15.
//  Copyright © 2015 Xiaofen Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickerFetcherOperation : NSOperation

@property (nonatomic, copy) void (^errorHandler)(NSError *error);

@property (nonatomic, strong, readonly) NSArray *photoList;



- (instancetype)initWithData:(NSData *)data;


@end
