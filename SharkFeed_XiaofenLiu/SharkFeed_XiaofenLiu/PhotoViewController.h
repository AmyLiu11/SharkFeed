//
//  PhotoNavigationController.h
//  SharkFeed_XiaofenLiu
//
//  Created by Xiaofen Liu on 11/12/15.
//  Copyright © 2015 Xiaofen Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UICollectionView *SharkFeedView;

@property (strong, nonatomic) NSMutableArray * entries;

@end
