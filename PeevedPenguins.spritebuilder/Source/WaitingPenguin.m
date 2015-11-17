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
    // generate a random number between 0.0 and 2.0
    float delay = (arc4random() % 2000) / 1000.f;
    // call method to start animation after random delay
    [self performSelector:@selector(startWaitingPenguin) withObject:nil afterDelay:delay];
}

- (void)startWaitingPenguin
{
    // the animation manager of each node is stored in the 'animationManager' property
    CCAnimationManager* animationManager = self.animationManager;
    // timelines can be referenced and run by name
    [animationManager runAnimationsForSequenceNamed:@"WaitingPenguin"];
}

@end
