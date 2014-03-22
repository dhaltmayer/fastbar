//
//  FBProduct.h
//  FastBar
//
//  Created by Chris Li on 3/22/14.
//  Copyright (c) 2014 Chris Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBProduct : NSObject

@property (strong,nonatomic) NSString *name;
@property (assign,nonatomic) NSInteger price;

-initWithName:(NSString*)name price:(NSInteger)price;

@end