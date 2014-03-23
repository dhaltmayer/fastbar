//
//  FirstViewController.m
//  FastBar
//
//  Created by Chris Li on 3/21/14.
//  Copyright (c) 2014 Chris Li. All rights reserved.
//

#import "FirstViewController.h"
#import "FBProduct.h"
#import "ZBarSDK.h"
#include "TargetConditionals.h"

@interface FirstViewController ()
@property (strong,nonatomic) NSArray *products;
@property (strong,nonatomic) NSMutableArray *cart;

@property (strong,nonatomic) NSString *currentBarCode;

@property (strong,nonatomic) UIPopoverController *cartPopoverController;
@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.products = @[
                      [[FBProduct alloc] initWithName:@"Orange Juice" price:100],
                      [[FBProduct alloc] initWithName:@"Screwdriver" price:500],
                      [[FBProduct alloc] initWithName:@"Rum and Coke" price:500],
                      [[FBProduct alloc] initWithName:@"Vodka Cranberry" price:500],
                      [[FBProduct alloc] initWithName:@"Vodka Shot" price:300],
                      [[FBProduct alloc] initWithName:@"Cranberry Juice" price:100]
                    ];
    self.cart = [[NSMutableArray alloc] init];
    
    [self.barcodeEntryTextField becomeFirstResponder];
    self.collectionView.alwaysBounceVertical = YES;
    
    [self updateCheckoutButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addProductToCart:(FBProduct*)prod
{
    // Try to find existing prod in O(n) yay
    NSArray *existing = [self.cart bk_select:^BOOL(FBProduct *p) {
        return [p.name isEqualToString:prod.name];
    }];
    
    if (existing.count == 0) {
        // Not found, we should add
        [self.cart addObject:prod];
    } else {
        FBProduct *p = existing[0];
        p.quantity += 1;
    }
    
    [self.tableView reloadData];
    [self updateTotal];
}

-(void)updateTotal
{
    if (!self.currentBarCode) {
        return;
    }

    __block NSInteger price = 0;
    
    [self.cart bk_each:^(FBProduct *p) {
        price += p.quantity * p.price;
    }];

    [self.grandTotalLabel setText:[NSString stringWithFormat:@"$%d", price/100]];
}

-(void)updateCheckoutButton
{
    [self.clearButton setHidden:(self.currentBarCode == nil)];
    
    [self.checkoutButton setEnabled:(self.currentBarCode != nil)];
    if (self.currentBarCode) {
        [self.checkoutButton setBackgroundColor:[UIColor colorWithRed:23 green:173 blue:3 alpha:1]];
    } else {
        [self.checkoutButton setBackgroundColor:[UIColor colorWithRed:235 green:235 blue:241 alpha:1]];
    }
    
    if (self.currentBarCode) {
        [self.cartDetails setText:[NSString stringWithFormat:@"ID: %@", self.currentBarCode]];
    } else {
        [self.cartDetails setText:@"Scan FastBar to Continue..."];
    }
}

#pragma mark collectionview
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.products.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    FBProduct *prod = self.products[indexPath.row];
    
    UILabel *name = (UILabel*)[cell viewWithTag:100];
    
    [name setText:prod.name];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FBProduct *prod = self.products[indexPath.row];
    [self addProductToCart:prod];
}

#pragma mark tableview
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CartCell" forIndexPath:indexPath];
    
    FBProduct *prod = self.cart[indexPath.row];
    
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:100];
    UILabel *priceLabel = (UILabel*)[cell viewWithTag:300];

    NSString *name = prod.name;
    if (prod.quantity != 1) {
        name = [NSString stringWithFormat:@"%dx %@", prod.quantity, prod.name];
    }

    [nameLabel setText:name];
    [priceLabel setText:[NSString stringWithFormat:@"$%d", (prod.quantity * prod.price / 100)]];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cart.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        FBProduct *prod = self.cart[indexPath.row];
        prod.quantity = 1; // reset to 1

        [self.cart removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
        [self updateTotal];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    FBProduct *prod = self.cart[indexPath.row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    assert(storyboard);
    CartDetailPopoverController *controller = (CartDetailPopoverController*)[storyboard instantiateViewControllerWithIdentifier:@"DetailPopover"];
    [controller setDelegate:self];
    [controller setContent:prod];

    self.cartPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    
    [self.cartPopoverController presentPopoverFromRect:cell.frame inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

#pragma mark content changed
-(void)contentChanged
{
    [self.tableView reloadData];
}

#pragma mark bluetooth scanner input
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
#if (TARGET_OS_IPHONE)
    return YES;
#else
    return NO;
#endif
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.currentBarCode = textField.text;
    [textField setText:@""];
    NSLog(@"Got bar code: %@", self.currentBarCode);
    
    [self updateCheckoutButton];
    
    return YES;
}

#pragma mark actions
-(void)clearCurrentBarcode:(id)sender
{
    self.currentBarCode = nil;
    [self updateCheckoutButton];
}

-(void)checkout:(id)sender
{
    NSLog(@"Checkout");
    
    // Cleanup afterwards
    [self.products bk_each:^(FBProduct *p) {
        p.quantity = 1;
    }];
    [self.cart removeAllObjects];
    [self clearCurrentBarcode:self];
    [self.tableView reloadData];
}

@end
