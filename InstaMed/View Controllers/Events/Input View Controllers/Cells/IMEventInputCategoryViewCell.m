//
//  IMEventInputCategoryViewCell.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 02/02/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMEventInputCategoryViewCell.h"
#import "IMCategoryInputView.h"

@implementation IMEventInputCategoryViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.control = [[IMCategoryInputView alloc] initWithCategories:@[NSLocalizedString(@"units", nil), NSLocalizedString(@"mg", nil), NSLocalizedString(@"pills", nil), NSLocalizedString(@"puffs", nil)]];
    }
    return self;
}

@end
