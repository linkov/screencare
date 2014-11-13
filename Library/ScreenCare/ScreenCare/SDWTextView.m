//
//  SDWTextView.m
//  Screenr
//
//  Created by alex on 6/28/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//

#import "SDWTextView.h"

static CGFloat buttonSide = 40;

@implementation SDWTextView {

    UITextView *mainText;
    UIButton *doneButton;
    UIButton *cancelButton;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<SDWViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        [self setupView];
    }
    return self;
}

-(void)setNote:(NSString *)note {
    _note = note;
    mainText.text = note;
}

- (void)setupView {

    mainText = [[UITextView alloc]init];
    mainText.backgroundColor = [UIColor clearColor];
    [self addSubview:mainText];
    [mainText becomeFirstResponder];

    doneButton = [UIButton new];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [doneButton setTitleColor:[[UIColor blueColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];

    [doneButton addTarget:self action:@selector(finish) forControlEvents:UIControlEventTouchUpInside];

    cancelButton = [UIButton new];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[[UIColor redColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];

    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:doneButton];
    [self addSubview:cancelButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    mainText.frame = CGRectInset(self.bounds, 60, 60+64);
    doneButton.frame = CGRectMake(self.bounds.size.width-buttonSide-25, 10+64, buttonSide, buttonSide);
    cancelButton.frame = CGRectMake(25, 10+64, buttonSide, buttonSide);
}

-(void)cancel {

    mainText.hidden = doneButton.hidden = cancelButton.hidden = YES;

    [mainText resignFirstResponder];
    [self.delegate viewDidCancelText:self];
}

-(void)finish {

    mainText.hidden = doneButton.hidden = cancelButton.hidden = YES;

    if ([mainText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {

        [self cancel];
    }
    else {
        
        [mainText resignFirstResponder];
        [self.delegate view:self didProvideTextForNote:mainText.text];
    }

}

@end
