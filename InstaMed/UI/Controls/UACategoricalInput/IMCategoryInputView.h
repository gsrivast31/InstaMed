//
//  IMCategoryInputView.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 02/02/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMCategorySelectorButton.h"

@class IMCategoryInputView;
@protocol IMCategoryInputViewDelegate <NSObject>

@optional
- (void)categoryInputView:(IMCategoryInputView *)categoryInputView didSelectOption:(NSUInteger)index;

@end

@interface IMCategoryInputView : UIView <UIActionSheetDelegate>
@property (nonatomic, weak) id<IMCategoryInputViewDelegate> delegate;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) IMCategorySelectorButton *selectorButton;
@property (nonatomic, assign) NSUInteger selectedIndex;

// Setup
- (id)initWithCategories:(NSArray *)categories;

@end
