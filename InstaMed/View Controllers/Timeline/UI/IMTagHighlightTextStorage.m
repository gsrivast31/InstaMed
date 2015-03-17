//
//  IMTagHighlightTextStorage.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 24/01/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMTagHighlightTextStorage.h"
#import "IMTagController.h"

@implementation IMTagHighlightTextStorage
{
    NSMutableAttributedString *_backingStore;
}

#pragma mark - Setup
- (id)init
{
    if(self = [super init])
    {
        _backingStore = [NSMutableAttributedString new];
    }
    return self;
}

#pragma mark - Reading
- (NSString *)string
{
    return [_backingStore string];
}
- (NSDictionary *)attributesAtIndex:(NSUInteger)location
                     effectiveRange:(NSRangePointer)range
{
    return [_backingStore attributesAtIndex:location effectiveRange:range];
}

#pragma mark - Writing
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [self beginEditing];
    [_backingStore replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters | NSTextStorageEditedAttributes range:range changeInLength:str.length - range.length];
    [self endEditing];
}
- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [self beginEditing];
    [_backingStore setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

#pragma mark - Tag highlighting logic
- (void)processEditing
{
    NSRegularExpression *regex = [IMTagController tagRegularExpression];
	NSRange paragraphRange = [self.string paragraphRangeForRange:self.editedRange];
	[self removeAttribute:NSForegroundColorAttributeName range:paragraphRange];
    [self removeAttribute:@"tag" range:paragraphRange];
    [self addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:163.0f/255.0f green:174.0f/255.0f blue:171.0f/255.0f alpha:1.0f] range:paragraphRange];
    
	[regex enumerateMatchesInString:self.string options:0 range:paragraphRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSString *tagValue = [[self.string substringWithRange:result.range] stringByReplacingOccurrencesOfString:@"#" withString:@""];
		[self addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f green:192.0f/255.0f blue:180.0f/255.0f alpha:1.0f] range:result.range];
        [self addAttribute:@"tag" value:tagValue range:result.range];
	}];
    
    [super processEditing];
}
@end
