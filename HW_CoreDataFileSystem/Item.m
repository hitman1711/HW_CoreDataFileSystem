//
//  Item.m
//  HW_CoreDataFileSystem
//
//  Created by Артур Сагидулин on 17.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "Item.h"

@implementation Item

@dynamic title;
@dynamic text;
@dynamic img;
@dynamic type;
@dynamic order;
@dynamic children;
@dynamic parent;

+ (instancetype)insertItemWithTitle:(NSString*)title type:(ushort)type
                             parent:(Item*)parent
             inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSUInteger order = parent.numberOfChildren;
    Item* item = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                               inManagedObjectContext:managedObjectContext];
    item.title = title;
    item.parent = parent;
    item.order = @(order);
    item.type = [NSNumber numberWithShort:type];
    [[CoreDataManager shared] save];
    return item;
}

+ (instancetype)insertItemWithTitle:(NSString*)title type:(ushort)type text:(NSString*)text photo:(NSData*)data parent:(Item*)parent
             inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSUInteger order = parent.numberOfChildren;
    Item* item = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                               inManagedObjectContext:managedObjectContext];
    item.title = title;
    item.parent = parent;
    item.order = @(order);
    item.type = [NSNumber numberWithShort:type];
    item.text = text;
    item.img = data;
    [[CoreDataManager shared] save];
    return item;
}

+ (NSString*)entityName
{
    return @"Item";
}

- (NSUInteger)numberOfChildren
{
    return self.children.count;
}

- (NSFetchedResultsController*)childrenFetchedResultsController
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.predicate = [NSPredicate predicateWithFormat:@"parent = %@", self];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (void)prepareForDeletion
{
    if (self.parent.isDeleted) return;
    
    NSSet* siblings = self.parent.children;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"order > %@", self.order];
    NSSet* itemsAfterSelf = [siblings filteredSetUsingPredicate:predicate];
    [itemsAfterSelf enumerateObjectsUsingBlock:^(Item* sibling, BOOL* stop)
     {
         sibling.order = @(sibling.order.integerValue - 1);
     }];
}

@end
