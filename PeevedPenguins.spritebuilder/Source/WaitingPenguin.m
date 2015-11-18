//
//  WaitingPenguin.m
//  PeevedPenguins
//
//  Created by Matt H on 2015-11-16.
//  Copyright © 2015 Apportable. All rights reserved.
//

#import "WaitingPenguin.h"

@implementation WaitingPenguin

- (void)didLoadFromCCB
{
    //Generates a random number between 0.0 and 2.0
    float delay = (arc4random() % 2000) / 1000.f;
    
    //Starts each penguin animation after a random time delay.
    [self performSelector:@selector(startBlinkAndJump) withObject:nil afterDelay:delay];
}

//Connects the penguin animation created in Spritebuilder to a method.
- (void)startBlinkAndJump
{
    CCAnimationManager* animationManager = self.animationManager;
    [animationManager runAnimationsForSequenceNamed:@"BlinkAndJump"];
}

@end
