//
//  SDWBaseView.m
//  Screenr
//
//  Created by alex on 6/29/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//

#import "SDWBaseView.h"

@implementation SDWBaseView

- (id)initWithFrame:(CGRect)frame delegate:(id<SDWViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

@end
