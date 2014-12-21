//
//  IMTimelineStatView.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 24/11/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMTimelineStatView.h"

@implementation IMTimelineStatView

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imageView];
        
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [IMFont standardMediumFontWithSize:12.0f];
        self.textLabel.textColor = [UIColor colorWithRed:147.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
        [self addSubview:self.textLabel];
    }
    
    return self;
}

#pragma mark - Accessors
- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    
    [self layoutSubviews];
}
- (void)setText:(NSString *)text
{
    self.textLabel.text = text;
    
    [self layoutSubviews];
}

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // We layout our subviews without animation to avoid inadvertently animating when
    // wrapped inside of a UITableView delete animation context
    __weak typeof(self) weakSelf = self;
    [UIView performWithoutAnimation:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        CGSize textSize = [strongSelf.textLabel.text sizeWithAttributes:@{NSFontAttributeName: strongSelf.textLabel.font}];
        strongSelf.imageView.frame = CGRectMake(0.0f, 0.0f, strongSelf.imageView.image.size.width, strongSelf.imageView.image.size.height);
        strongSelf.textLabel.frame = CGRectMake(0.0f, 0.0f, textSize.width, textSize.height);
        
        CGFloat x = ceilf(strongSelf.bounds.size.width/2.0f - (strongSelf.textLabel.bounds.size.width + strongSelf.imageView.bounds.size.width + 5.0f)/2.0f);
        strongSelf.imageView.frame = CGRectMake(x, ceilf(strongSelf.bounds.size.height/2.0f - strongSelf.imageView.image.size.height/2.0f), strongSelf.imageView.image.size.width, strongSelf.imageView.image.size.height);
        strongSelf.textLabel.frame = CGRectMake(ceilf(x + strongSelf.imageView.bounds.size.width + 5.0f), ceilf(strongSelf.bounds.size.height/2.0f - self.textLabel.bounds.size.height/2.0f), self.textLabel.bounds.size.width, strongSelf.textLabel.bounds.size.height);
    }];
}

@end
