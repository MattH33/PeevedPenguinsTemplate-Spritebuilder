//
//  Seal.m
//  PeevedPenguins
//
//  Created by Matt H on 2015-11-15.
//  Copyright © 2015 Apportable. All rights reserved.
//

#import "Seal.h"

@implementation Seal

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"seal";
}

@end
