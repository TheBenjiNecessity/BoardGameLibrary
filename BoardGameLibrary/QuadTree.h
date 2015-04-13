//
//  QuadTree.h
//  BoardGameLibrary
//
//  Created by Benjamin Wishart on 2015-04-13.
//  Copyright (c) 2015 Benjamin Wishart. All rights reserved.
//

#define MAX_OBJECTS        100
#define MAX_LEVELS         5

#import <Foundation/Foundation.h>
#import "SlotView.h"

@interface QuadTree : NSObject
{
   int level;
   NSMutableArray *objects;
   CGRect bounds;
   NSMutableArray *nodes;
}

-(id)initWithCurrentLevel:(int)currentLevel
                   bounds:(CGRect)_bounds;

-(void)insertSlotView:(SlotView *)slotView;
-(void)clear;
-(NSMutableArray *)objects:(NSMutableArray *)returnObjects
                   atPoint:(CGPoint)point;

@end
