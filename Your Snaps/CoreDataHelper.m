//
//  CoreDataHelper.m
//  YourSnaps
//
//  Created by Hicham Chourak on 19/07/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

+ (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }   
    
    return context;
}

@end
