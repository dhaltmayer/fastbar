//
//  FirstViewController.h
//  FastBar
//
//  Created by Chris Li on 3/21/14.
//  Copyright (c) 2014 Chris Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CartDetailPopoverController.h"

@interface FirstViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate,CartDetailPopoverControllerDelegate>

@property (strong,nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong,nonatomic) IBOutlet UILabel *cartDetails;
@property (strong,nonatomic) IBOutlet UIButton *checkoutButton;

@end
