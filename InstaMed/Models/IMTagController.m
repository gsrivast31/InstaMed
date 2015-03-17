//
//  IMTagController.m
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 18/02/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMTagController.h"
#import "IMAppDelegate.h"

@interface IMTagController ()
@end

@implementation IMTagController

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark - String helpers
- (NSRange)rangeOfTagInString:(NSString *)string withCaretLocation:(NSUInteger)caretLocation
{
    NSRegularExpression *regex = [IMTagController tagRegularExpression];
    __block NSRange range = NSMakeRange(NSNotFound, 0);
    [regex enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result.range.location <= caretLocation && result.range.location+result.range.length >= caretLocation)
        {
            range = result.range;
            *stop = YES;
        }
    }];
    
    return range;
}

#pragma mark - Regular Expressions
+ (NSRegularExpression *)tagRegularExpression
{
    static NSRegularExpression *tagRegularExpression = nil;
    if(!tagRegularExpression)
    {
        NSError *error = nil;
        tagRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"#([\\w\\d\\-]+)"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:&error];
    }
    
    return tagRegularExpression;
}

#pragma mark - Helpers
- (NSArray *)fetchTagsInString:(NSString *)string
{
    __block NSMutableArray *tags = [NSMutableArray array];
    
    if(string && [string length])
    {
        NSRegularExpression *regex = [IMTagController tagRegularExpression];
        [regex enumerateMatchesInString:string
                                options:0
                                  range:NSMakeRange(0, string.length)
                             usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            
            NSString *tag = [string substringWithRange:[result rangeAtIndex:1]];

            // De-duplicate tags!
            BOOL tagAlreadyExists = NO;
            for(NSString *existingTag in tags)
            {
                if([[existingTag lowercaseString] isEqualToString:[tag lowercaseString]])
                {
                    tagAlreadyExists = YES;
                    break;
                }
            }               
            if(!tagAlreadyExists) [tags addObject:[tag lowercaseString]];
        }];
    }
    
    return [NSArray arrayWithArray:tags];
}
- (NSArray *)fetchAllTags
{
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
    NSMutableArray *tags = [NSMutableArray array];
    if(moc)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"IMTag" inManagedObjectContext:moc];
        [request setEntity:entity];
        
        NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        [request setSortDescriptors:@[nameSortDescriptor]];
        
        NSString* currentUserGuid = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userGuid = %@", currentUserGuid];
        [request setPredicate:predicate];

        // Execute the fetch.
        NSError *error = nil;
        NSArray *objects = [moc executeFetchRequest:request error:&error];
        if (objects != nil && [objects count] > 0)
        {
            for(IMTag *tag in objects)
            {
                [tags addObject:tag.name];
            }
        }
    }
    
    return [NSArray arrayWithArray:tags];
}
- (NSArray *)fetchExistingTagsWithStrings:(NSArray *)strings
{
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
    if(moc)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"IMTag" inManagedObjectContext:moc];
        [request setEntity:entity];
        
        NSString* currentUserGuid = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nameLC IN %@ && userGuid = %@", strings, currentUserGuid];
        [request setPredicate:predicate];
        
        // Execute the fetch.
        NSError *error = nil;
        NSArray *objects = [moc executeFetchRequest:request error:&error];
        if (objects != nil && [objects count] > 0)
        {
            return objects;
        }
    }
    
    return nil;
}
- (void)assignTags:(NSArray *)tags toEvent:(IMEvent *)event
{
    NSManagedObjectContext *moc = [[IMCoreDataStack defaultStack] managedObjectContext];
    if(moc)
    {
        // Remove any existing tags from this event
        if(event.tags.count)
        {
            NSSet *existingEventTags = [event.tags copy];
            for (IMTag *tag in existingEventTags)
            {
                [[event mutableSetValueForKey:@"tags"] removeObject:tag];
                if(tag.events.count <= 0)
                {
                    [moc deleteObject:tag];
                }
            }
        }
        
        // Now re-assign any applicable tags to this event
        for(NSString *tag in tags)
        {
            NSArray *existingTags = [self fetchExistingTagsWithStrings:@[[tag lowercaseString]]];
            if(existingTags && [existingTags count])
            {
                [event addTagsObject:(IMTag *)[existingTags objectAtIndex:0]];
            }
            else
            {
                NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IMTag" inManagedObjectContext:moc];
                IMTag *newTag = (IMTag *)[[IMBaseObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
                newTag.name = tag;
                [newTag addEventsObject:event];
            }
        }
    }
}

@end
