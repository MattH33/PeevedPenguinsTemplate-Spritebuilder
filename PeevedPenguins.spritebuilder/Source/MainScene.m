//
//  MainScene.m
//  PeevedPenguins
//
//  Created by Matt H on 2015-11-15.
//  Copyright © 2015 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene

- (void)play {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

@end
