//
//  IMEventPhotoImageView.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 04/08/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "IMEventPhotoImageView.h"
#import "TGRImageViewController.h"

@interface IMEventPhotoImageView ()
@property (nonatomic, strong) UIButton *overlayButton;
@end

@implementation IMEventPhotoImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor redColor];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        _overlayButton = [[UIButton alloc] initWithFrame:self.bounds];
        [_overlayButton addTarget:self action:@selector(didTapImage:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_overlayButton];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
    self.overlayButton.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
}

- (void)didTapImage:(id)sender
{
    NSLog(@"Bonk");
}

@end
