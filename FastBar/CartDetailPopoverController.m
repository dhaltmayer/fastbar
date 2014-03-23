//
//  CartDetailPopoverController.m
//  FastBar
//
//  Created by Chris Li on 3/22/14.
//  Copyright (c) 2014 Chris Li. All rights reserved.
//

#import "CartDetailPopoverController.h"

@implementation CartDetailPopoverController

-(void)viewDidLoad
{
    [self.stepper setValue:self.content.quantity];
    [self.stepper addTarget:self action:@selector(stepperChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self updateLabels];
}

-(void)updateLabels
{
    [self.priceEachLabel setText:[NSString stringWithFormat:@"$%d", self.content.price/100]];
    [self.quantityLabel setText:[NSString stringWithFormat:@"%d", self.content.quantity]];
}

-(void)stepperChanged:(id)sender
{
    self.content.quantity = self.stepper.value;
    [self updateLabels];
    [self.delegate contentChanged];
}

@end
