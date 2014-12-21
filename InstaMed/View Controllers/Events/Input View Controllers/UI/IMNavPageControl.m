//
//  IMNavPageControl.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 26/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMNavPageControl.h"
#import "IMInputParentViewController.h"
#import "IMMedicineInputViewController.h"
#import "IMMealInputViewController.h"
#import "IMBGInputViewController.h"
#import "IMActivityInputViewController.h"
#import "IMNoteInputViewController.h"

#define kIconSpacing 7.0f

@interface IMNavPageControl ()
@property (nonatomic, retain) NSMutableArray *icons;

@end

@implementation IMNavPageControl
@synthesize viewControllers = _viewControllers;
@synthesize icons = _icons;
@synthesize currentPage = _currentPage;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _icons = [NSMutableArray array];
        _viewControllers = nil;
        _currentPage = 0;
    }
    return self;
}

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(self.icons && [self.icons count])
    {
        CGSize iconSize = CGSizeMake(10.0f, 11.0f);
        CGFloat x = self.bounds.size.width/2.0f - (((iconSize.width+kIconSpacing)*[self.icons count])-kIconSpacing)/2.0f;
        
        for(UIImageView *icon in self.icons)
        {
            icon.frame = CGRectMake(x, 0.0f, iconSize.width, iconSize.height);
            x += iconSize.width + kIconSpacing;
        }
    }
}
- (void)setCurrentPage:(NSInteger)page
{
    _currentPage = page;
    
    NSInteger pageIndex = 0;
    for(UIImageView *icon in self.icons)
    {
        [icon setImage:[UIImage imageNamed:[self iconForPage:pageIndex]]];
        pageIndex ++;
    }
}

#pragma mark - Accessors
- (void)setViewControllers:(NSArray *)controllers
{
    // Remove previous icons
    for(UIImageView *icon in self.icons)
    {
        [icon removeFromSuperview];
    }
    [self.icons removeAllObjects];
    
    _viewControllers = controllers;
    for(IMInputBaseViewController *vc in _viewControllers)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 11.0f)];
        [self addSubview:imageView];
        [self.icons addObject:imageView];
    }
    
    [self setNeedsLayout];
}

#pragma mark - Helper
- (NSString *)iconForPage:(NSInteger)page
{
    IMInputBaseViewController *vc = (IMInputBaseViewController  *)[self.viewControllers objectAtIndex:page];
    
    NSString *filename = @"";
    if([vc isKindOfClass:[IMMedicineInputViewController class]])
    {
        filename = @"NavBarIconMedicine";
    }
    else if([vc isKindOfClass:[IMNoteInputViewController class]])
    {
        filename = @"NavBarIconNote";
    }
    else if([vc isKindOfClass:[IMMealInputViewController class]])
    {
        filename = @"NavBarIconMeal";
    }
    else if([vc isKindOfClass:[IMBGInputViewController class]])
    {
        filename = @"NavBarIconBlood";
    }
    else if([vc isKindOfClass:[IMActivityInputViewController class]])
    {
        filename = @"NavBarIconActivity";
    }
    
    if(page == self.currentPage)
    {
        return filename;
    }
    else
    {
        return [filename stringByAppendingString:@"Inactive"];
    }
}

@end
