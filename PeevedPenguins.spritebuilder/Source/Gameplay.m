//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Matt H on 2015-11-15.
//  Copyright © 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"

static const float MIN_SPEED = 5.f;

@implementation Gameplay {
    
    //Connects objects from Spritebuilder to code variables.
    CCPhysicsNode *_physicsNode;
    CCNode *_catapultArm;
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCNode *_pullbackNode;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    Penguin *_currentPenguin;
    CCPhysicsJoint *_penguinCatapultJoint;
    CCAction *_followPenguin;
    
}

- (void)didLoadFromCCB {
    
    //Tells this scene to accept touches.
    self.userInteractionEnabled = TRUE;
    
    //This will load level1 and add it as a child to the levelNode.
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    
    //Ensures nothing will collide with the invisible nodes created in Spritebuilder.
    _pullbackNode.physicsBody.collisionMask = @[];
    _mouseJointNode.physicsBody.collisionMask = @[];
    
    _physicsNode.collisionDelegate = self;
  
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    //Starts dragging the catapult arm when a touch inside of the catapult arm occurs.
    if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation))
    {
        //Moves the mouseJointNode to the touch position.
        _mouseJointNode.position = touchLocation;
        
        //Sets up a spring joint between the mouseJointNode and the catapultArm.
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0, 0) anchorB:ccp(34, 138) restLength:0.f stiffness:3000.f damping:150.f];
        
        //Creates a penguin from the Spritebuilder file.
        _currentPenguin = (Penguin*)[CCBReader load:@"Penguin"];
        
        //Initially positions the penguin on the scoop.
        CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(34, 138)];
        
        //Transforms the world position to the physicsNode space to which the penguin will be added.
        _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
        
        //Adds the penguin to the physics world.
        [_physicsNode addChild:_currentPenguin];
        
        //Ensures the penguin doesn't rotate while it's in the scoop.
        _currentPenguin.physicsBody.allowsRotation = FALSE;
        
        //Creates a joint to keep the penguin fixed to the scoop until the catapult is released.
        _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
    }
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    //Whenever touches move, this updates the position of the mouseJointNode to the touch position.
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
}

- (void)releaseCatapult {
    if (_mouseJoint != nil)
    {
        //Releases the joint and lets the catapult snap forward.
        [_mouseJoint invalidate];
        _mouseJoint = nil;
        
        //Releases the joint and lets the penguin fly.
        [_penguinCatapultJoint invalidate];
        _penguinCatapultJoint = nil;
        
        //Allows rotation of the penguin after being released.
        _currentPenguin.physicsBody.allowsRotation = TRUE;
        
        //Camera follows the flying penguin.
        _followPenguin = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
        [_contentNode runAction:_followPenguin];
        
        _currentPenguin.launched = TRUE;
    }
}

-(void) touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    //When touches end, release the catapult.
    [self releaseCatapult];
}

-(void) touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    //When touches are cancelled, meaning the user drags their finger off the screen or onto something else, release the catapult.
    [self releaseCatapult];
}

- (void)launchPenguin {
    
    //Loads the Penguin that was created in Spritebuilder.
    CCNode* penguin = [CCBReader load:@"Penguin"];
    
    //Positions the penguin at the bowl of the catapult.
    penguin.position = ccpAdd(_catapultArm.position, ccp(16, 50));
    
    //Adds the penguin to the physicsNode of this scene.
    [_physicsNode addChild:penguin];
    
    //Creates and applies a force to launch the penguin.
    CGPoint launchDirection = ccp(1, 0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [penguin.physicsBody applyForce:force];
    
    //Ensures the penguin is visible before the camera follows it.
    self.position = ccp(0, 0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin worldBoundary:self.boundingBox];
    [_contentNode runAction:follow];
}

//If the energy created during a collision with a seal is large enough, remove the seal.
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    float energy = [pair totalKineticEnergy];
    
    if (energy > 5000.f) {
        [[_physicsNode space] addPostStepBlock:^{
            [self sealRemoved:nodeA];
        } key:nodeA];
    }
}

- (void)sealRemoved:(CCNode *)seal {
    
    //Loads the smoke particle effect created in Spritebuilder.
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"SealExplosion"];
    
    //Makes the particle effect clean itself up once completed.
    explosion.autoRemoveOnFinish = TRUE;
    
    //Places the particle effect on the seal's position.
    explosion.position = seal.position;
    
    //Adds the particle effect to the same node the seal is on.
    [seal.parent addChild:explosion];
    
    //Removes the destroyed seal.
    [seal removeFromParent];
}

//Resets the camera position after the launched penguin's movement has slowed to a certain amount.
- (void)nextAttempt {
    _currentPenguin = nil;
    [_contentNode stopAction:_followPenguin];
    
    CCActionMoveTo *actionMoveTo = [CCActionMoveTo actionWithDuration:1.f position:ccp(0, 0)];
    [_contentNode runAction:actionMoveTo];
}

- (void)update:(CCTime)delta
{
    if (_currentPenguin.launched)
    {
        if (ccpLength(_currentPenguin.physicsBody.velocity) < MIN_SPEED){
            [self nextAttempt];
            return;
        }
    
        int xMin = _currentPenguin.boundingBox.origin.x;
    
        if (xMin < self.boundingBox.origin.x) {
            [self nextAttempt];
            return;
        }
    
        int xMax = xMin + _currentPenguin.boundingBox.size.width;
    
        if (xMax > (self.boundingBox.origin.x + self.boundingBox.size.width)) {
            [self nextAttempt];
            return;
        }
    }
}

//Resets the level.
- (void)retry {

    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

@end
