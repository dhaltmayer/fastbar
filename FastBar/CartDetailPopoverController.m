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
    [self.stepper setValue:self.content.count];
    [self.stepper addTarget:self action:@selector(stepperChanged:) forControlEvents:UIControlEventValueChanged];
}

-(void)stepperChanged:(id)sender
{
    
}

@end
