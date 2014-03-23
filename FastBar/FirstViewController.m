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
#import "AFNetworking.h"

@interface FirstViewController ()
@property (assign,readonly) NSInteger totalPrice;

@property (strong,nonatomic) NSArray *products;
@property (strong,nonatomic) NSMutableArray *cart;

@property (strong,nonatomic) NSString *currentBarCode;
@property (strong,atomic) NSString *currentUserName;

@property (strong,nonatomic) UIPopoverController *cartPopoverController;
@end

#define GET_USER_URL @"http://www.fastbar.co/api_getuser.json"
#define POST_TRANSACTION_URL @"http://www.fastbar.co/api_transaction.json"

@implementation FirstViewController

-(void)setCurrentBarCode:(NSString *)currentBarCode
{
    _currentBarCode = currentBarCode;
    self.currentUserName = @"Scanned";
    
    // Get the user name
    if (currentBarCode) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSDictionary *params = @{@"barcode": currentBarCode};
            [manager GET:GET_USER_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
                
                if (responseObject[@"name"]) {
                    self.currentUserName = responseObject[@"name"];
                } else {
                    self.currentUserName = @"Unknown";
                }

                // Run UI update
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self updateUI];
                });
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                self.currentUserName = @"Unknown";
            }];
            
        });
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.currentBarCode = @"602652170584";
    
    // Toolbar setup
    UIImage *fastbarlogo = [UIImage imageNamed:@"FastBarLogo"];
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    face.bounds = CGRectMake( 0, 0, fastbarlogo.size.width, fastbarlogo.size.height );
    [face setImage:fastbarlogo forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:face];

    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil];
    
    NSArray *items = [[NSArray alloc] initWithObjects:spacer, item, spacer, nil];
    
    [self.toolbar setItems:items];
    self.toolbar.userInteractionEnabled = NO;
    self.toolbar.delegate = self;
    
    self.products = @[
      [[FBProduct alloc] initWithName:@"Beer" price:100 image:[UIImage imageNamed:@"DrinkBeer"]],
      [[FBProduct alloc] initWithName:@"Wine" price:100 image:[UIImage imageNamed:@"DrinkWine"]],
      [[FBProduct alloc] initWithName:@"Rum and Coke" price:100 image:[UIImage imageNamed:@"DrinkRumCoke"]],
      
      [[FBProduct alloc] initWithName:@"Tequila Shot" price:1200 image:[UIImage imageNamed:@"TequilaShot"]],
      [[FBProduct alloc] initWithName:@"Johnny Walker Blue" price:5500 image:[UIImage imageNamed:@"WalkerBlue"]],
      [[FBProduct alloc] initWithName:@"Ace of Spades" price:50000 image:[UIImage imageNamed:@"AceSpades"]],
      
      [[FBProduct alloc] initWithName:@"Screwdriver" price:100 image:[UIImage imageNamed:@"DrinkScrewdriver"]],
      [[FBProduct alloc] initWithName:@"Vodka Cranberry" price:100 image:[UIImage imageNamed:@"DrinkVodkaCran"]],
      [[FBProduct alloc] initWithName:@"Other" price:100 image:[UIImage imageNamed:@"DrinkGeneric"]]
    ];
    self.cart = [[NSMutableArray alloc] init];
    
    // To get keyboard input for barcode scanner
    [self.barcodeEntryTextField becomeFirstResponder];
    
    // CollectionView
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    
    // Adds margin to top
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    flow.sectionInset = UIEdgeInsetsMake(54, 0, 0, 10);

    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self updateUI];
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
    [self updateUI];
}

-(NSInteger)totalPrice
{
    __block NSInteger price = 0;
    
    [self.cart bk_each:^(FBProduct *p) {
        price += p.quantity * p.price;
    }];

    return price;
}

-(void)updateUI
{
    [self.clearButton setHidden:(self.currentBarCode == nil)];
    
    [self.checkoutButton setEnabled:(self.currentBarCode != nil)];
    if (self.currentBarCode) {
        [self.checkoutButton setBackgroundColor:[UIColor colorWithRed:27/255.0 green:117/255.0 blue:187/255.0 alpha:255.0]];
    } else {
        [self.checkoutButton setBackgroundColor:[UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:255.0]];
    }
    
    NSString *btnTitle = [NSString stringWithFormat:@"Add to Tab: $%d", self.totalPrice/100];
    [self.checkoutButton setTitle:btnTitle forState:UIControlStateNormal];
    [self.checkoutButton setTitle:[NSString stringWithFormat:@"$%d", self.totalPrice/100] forState:UIControlStateDisabled];
    
    if (self.currentBarCode) {
        [self.barCodeLabel setText:[NSString stringWithFormat:@"#%@", self.currentBarCode]];
    } else {
        [self.barCodeLabel setText:@"Pending Scan..."];
    }
    
    if (self.currentBarCode) {
        [self.userNameLabel setText:self.currentUserName];
    } else {
        [self.userNameLabel setText:@"Scan FastBar"];
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
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:200];
    UILabel *priceLabel = (UILabel*)[cell viewWithTag:300];
    
    [name setText:prod.name];
    [imageView setImage:prod.image];
    [priceLabel setText:[NSString stringWithFormat:@"$%d", prod.price/100]];
    
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
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:400];

    NSString *name = prod.name;
    if (prod.quantity != 1) {
        name = [NSString stringWithFormat:@"%@ (x%d)", prod.name, prod.quantity];
    }

    [nameLabel setText:name];
    [priceLabel setText:[NSString stringWithFormat:@"$%d", (prod.quantity * prod.price / 100)]];
    [imageView setImage:prod.image];
    
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
        [self updateUI];
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
    
    [self updateUI];
    
    return YES;
}

#pragma mark actions
-(void)clearCurrentBarcode:(id)sender
{
    self.currentBarCode = nil;
    [self.products bk_each:^(FBProduct *p) {
        p.quantity = 1;
    }];
    [self.cart removeAllObjects];

    [self updateUI];
    
    [self.tableView reloadData];
}

-(void)checkout:(id)sender
{
    NSLog(@"Checkout");
    
    if (!self.currentBarCode) {
        NSLog(@"No bar code");
        return;
    }
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [self.cart bk_each:^(FBProduct *p) {
        for (int i=0; i < p.quantity; i++) {
            [params addObject:@{@"barcode": self.currentBarCode, @"product": p.name, @"price": @(p.price)}];
        }
    }];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        for (NSDictionary *param in params) {
            [manager POST:POST_TRANSACTION_URL parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        }
    });
    
    // Cleanup afterwards
    [self clearCurrentBarcode:self];
}

@end
