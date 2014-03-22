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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.products.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    FBProduct *prod = self.products[indexPath.row];
    UILabel *label = (UILabel*)[cell viewWithTag:100];
    [label setText:prod.name];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FBProduct *prod = self.products[indexPath.row];
    [self.cart addObject:prod];
    
    [self.tableView reloadData];
}

#pragma mark tableview
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CartCell" forIndexPath:indexPath];
    
    FBProduct *prod = self.cart[indexPath.row];
    UILabel *label = (UILabel*)[cell viewWithTag:100];
    [label setText:prod.name];
    
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
    }
}


@end
