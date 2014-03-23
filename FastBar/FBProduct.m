//
//  FBProduct.m
//  FastBar
//
//  Created by Chris Li on 3/22/14.
//  Copyright (c) 2014 Chris Li. All rights reserved.
//

#import "FBProduct.h"

@implementation FBProduct

-(id)initWithName:(NSString *)name price:(NSInteger)price image:(UIImage*)img;
{
    self = [self init];
    if (self) {
        self.name = name;
        self.price = price;
        self.quantity = 1;
        self.image = img;
    }
    return self;
}

@end
