//
//  QuadTree.m
//  BoardGameLibrary
//
//  Created by Benjamin Wishart on 2015-04-13.
//  Copyright (c) 2015 Benjamin Wishart. All rights reserved.
//

#import "QuadTree.h"

@implementation QuadTree

-(id)initWithCurrentLevel:(int)currentLevel bounds:(CGRect)_bounds {
   if (self = [super init]) {
      level = currentLevel;
      objects = [[NSMutableArray alloc] init];
      bounds = _bounds;
      nodes = [[NSMutableArray alloc] initWithCapacity:4];
   }
   
   return self;
}

-(void)clear {
   [objects removeAllObjects];
   
   for (int i = 0; i < nodes.count; i++) {
      if ([nodes objectAtIndex:i] != nil) {
         QuadTree *nodeAtI = (QuadTree *)[nodes objectAtIndex:i];
         [nodeAtI clear];
         [nodes removeObjectAtIndex:i];
      }
   }
}

-(void)split {
   int subWidth = (int)(bounds.size.width / 2);
   int subHeight = (int)(bounds.size.height / 2);
   int x = (int)bounds.origin.x;
   int y = (int)bounds.origin.y;

   [nodes addObject:[[QuadTree alloc] initWithCurrentLevel:level + 1 bounds:CGRectMake(x + subWidth, y, subWidth, subHeight)]];
   [nodes addObject:[[QuadTree alloc] initWithCurrentLevel:level + 1 bounds:CGRectMake(x, y, subWidth, subHeight)]];
   [nodes addObject:[[QuadTree alloc] initWithCurrentLevel:level + 1 bounds:CGRectMake(x, y + subHeight, subWidth, subHeight)]];
   [nodes addObject:[[QuadTree alloc] initWithCurrentLevel:level + 1 bounds:CGRectMake(x + subWidth, y + subHeight, subWidth, subHeight)]];
}

-(int)indexByRect:(CGRect)rect {
   int index = -1;
   double verticalMidpoint = bounds.origin.x + (bounds.size.width / 2);
   double horizontalMidpoint = bounds.origin.y + (bounds.size.height / 2);
   
   // Object can completely fit within the top quadrants
   BOOL topQuadrant = (rect.origin.y < horizontalMidpoint && rect.origin.y + rect.size.height < horizontalMidpoint);
   // Object can completely fit within the bottom quadrants
   BOOL bottomQuadrant = (rect.origin.y > horizontalMidpoint);
   
   // Object can completely fit within the left quadrants
   if (rect.origin.x < verticalMidpoint && rect.origin.x + rect.size.width < verticalMidpoint) {
      if (topQuadrant) {
         index = 1;
      }
      else if (bottomQuadrant) {
         index = 2;
      }
   }
   // Object can completely fit within the right quadrants
   else if (rect.origin.x > verticalMidpoint) {
      if (topQuadrant) {
         index = 0;
      }
      else if (bottomQuadrant) {
         index = 3;
      }
   }
   
   return index;
}

-(int)indexByPoint:(CGPoint)point {
   BOOL isInTopQuadrant = (point.y < bounds.origin.y + (bounds.size.height / 2));
   BOOL isInLeftQuadrant = (point.x <  bounds.origin.x + (bounds.size.width / 2));
   
   if (isInLeftQuadrant) {
      if (isInTopQuadrant) {
         return 1;
      } else {
         return 2;
      }
   } else {
      if (isInTopQuadrant) {
         return 0;
      } else {
         return 3;
      }
   }
   return -1;
}

-(void)insertSlotView:(SlotView *) slotView {
   if ([nodes objectAtIndex:0] != nil) {
      int index = [self indexByRect:slotView.frame];
      
      if (index != -1) {
         QuadTree *node = (QuadTree *)[nodes objectAtIndex:index];
         [node insertSlotView:slotView];
         return;
      }
   }
   
   [objects addObject:slotView];
   
   if (objects.count > MAX_OBJECTS && level < MAX_LEVELS) {
      if ([nodes objectAtIndex:0] == nil) {
         [self split];
      }
      
      int i = 0;
      while (i < objects.count) {
         SlotView *slotViewInObjects = (SlotView *)[objects objectAtIndex:i];
         int index = [self indexByRect:slotViewInObjects.frame];
         if (index != -1) {
            QuadTree *node = (QuadTree *)[nodes objectAtIndex:index];
            [node insertSlotView:[objects objectAtIndex:i]];
            [objects removeObjectAtIndex:i];
         }
         else {
            i++;
         }
      }
   }
}

-(NSMutableArray *)objects:(NSMutableArray *)returnObjects atPoint:(CGPoint)point {
   int index = [self indexByPoint:point];
   if (index != -1 && [nodes objectAtIndex:0] != nil) {
      QuadTree *node = (QuadTree *)[nodes objectAtIndex:index];
      [returnObjects addObjectsFromArray:[node objects:returnObjects atPoint:point]];
   }
   
   [returnObjects addObjectsFromArray:objects];
   
   return returnObjects;
}

@end
