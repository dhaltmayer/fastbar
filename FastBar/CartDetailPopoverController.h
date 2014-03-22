//
//  CartDetailPopoverController.h
//  FastBar
//
//  Created by Chris Li on 3/22/14.
//  Copyright (c) 2014 Chris Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CartDetailPopoverControllerDelegate <NSObject>
-(void)contentChanged;
@end

@interface CartDetailPopoverController : UIViewController
@property (strong, nonatomic) NSMutableArray *content;
@property (weak, nonatomic) id<CartDetailPopoverControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIStepper *stepper;
@property (strong, nonatomic) IBOutlet UILabel *priceEachLabel;
@end
