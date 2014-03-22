//
//  FirstViewController.m
//  FastBar
//
//  Created by Chris Li on 3/21/14.
//  Copyright (c) 2014 Chris Li. All rights reserved.
//

#import "FirstViewController.h"
#import "FBProduct.h"

@interface FirstViewController ()
@property (strong,nonatomic) NSArray *products;
@property (strong,nonatomic) NSMutableArray *cart;

@property (strong,nonatomic) NSString *currentBarCode;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addProductToCart:(FBProduct*)prod
{
    // Try to find existing prod in O(n) yay
    NSArray *selections = [self.cart bk_select:^BOOL(NSArray *arr) {
        FBProduct *firstProd = arr[0];
        return [firstProd.name isEqualToString:prod.name];
    }];
    
    if (selections.count == 0) {
        // Not found, we should add
        NSArray *newProdArray = [[NSMutableArray alloc] initWithObjects:prod, nil];
        [self.cart addObject:newProdArray];
    } else {
        NSMutableArray *selection = selections[0];
        [selection addObject:prod];
    }
    
    [self.tableView reloadData];
    [self updateTotal];
}

-(void)updateTotal
{
    if (!self.currentBarCode) {
        [self.cartDetails setText:@"Scan FastBar to Continue..."];
        return;
    }

    __block NSInteger price = 0;
    
    [self.cart bk_each:^(NSArray *selection) {
        [selection bk_each:^(FBProduct *prod) {
            price += prod.price;
        }];
    }];

    [self.cartDetails setText:[NSString stringWithFormat:@"$%d", price/100]];
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
    
    NSArray *prods = self.cart[indexPath.row];
    FBProduct *prod = prods[0];
    
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:100];
    UILabel *priceLabel = (UILabel*)[cell viewWithTag:300];

    NSString *name = prod.name;
    if (prods.count > 1) {
        name = [NSString stringWithFormat:@"%dx %@", prods.count, prod.name];
    }

    [nameLabel setText:name];
    [priceLabel setText:[NSString stringWithFormat:@"$%d", (prods.count * prod.price / 100)]];
    
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
        [self.cart removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
        [self updateTotal];
    }
}


@end
