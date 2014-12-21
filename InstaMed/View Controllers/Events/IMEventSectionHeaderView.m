//
//  IMEventSectionHeaderView.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 09/08/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "IMEventSectionHeaderView.h"

@implementation IMEventSectionHeaderView

- (IBAction)deleteButtonPressed:(id)sender
{
    if(self.delegate)
    {
        [self.delegate headerDeleteButtonPressedForEventRepresentation:self.eventRepresentation];
    }
}

@end
