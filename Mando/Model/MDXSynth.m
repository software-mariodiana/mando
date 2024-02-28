//
//  MDXSynth.m
//  JohnnyOneNote
//
//  Created by Mario Diana on 4/24/21.
//  Copyright © 2021 Mario Diana. All rights reserved.
//

#import "MDXSynth.h"
#import "MDXAudioController.h"

#import <AVFoundation/AVFoundation.h>

const int MandoGreenNote = 60;
const int MandoRedNote = 65;
const int MandoOrangeNote = 69;
const int MandoBlueNote = 72;

@interface MDXSynth ()
@property (nonatomic, strong) AVAsset* errorNote;
@property (nonatomic, strong) AVAsset* greenNote;
@property (nonatomic, strong) AVAsset* redNote;
@property (nonatomic, strong) AVAsset* orangeNote;
@property (nonatomic, strong) AVAsset* blueNote;
@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) MDXAudioController* audioController;
@end

@implementation MDXSynth

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self initializeWAVPlayers];
    }
    
    return self;
}

- (void)initializeWAVPlayers
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL* green = [[NSBundle mainBundle] URLForResource:@"C" withExtension:@"wav"];
        NSURL* red = [[NSBundle mainBundle] URLForResource:@"F" withExtension:@"wav"];
        NSURL* orange = [[NSBundle mainBundle] URLForResource:@"A" withExtension:@"wav"];
        NSURL* blue = [[NSBundle mainBundle] URLForResource:@"C1" withExtension:@"wav"];
        NSURL* error = [[NSBundle mainBundle] URLForResource:@"Error" withExtension:@"wav"];
        
        self.greenNote = [AVAsset assetWithURL:green];
        self.redNote = [AVAsset assetWithURL:red];
        self.orangeNote = [AVAsset assetWithURL:orange];
        self.blueNote = [AVAsset assetWithURL:blue];
        self.errorNote = [AVAsset assetWithURL:error];
        
        self.player = [[AVPlayer alloc] init];
        
        self.audioController = [[MDXAudioController alloc] init];
        [[self audioController] setUpAudioSession];
    });
}

- (void)playNote:(int)midiNote
{
    AVPlayerItem* note = nil;
    
    switch (midiNote) {
        case MandoGreenNote:
            note = [AVPlayerItem playerItemWithAsset:[self greenNote]];
            break;
        case MandoRedNote:
            note = [AVPlayerItem playerItemWithAsset:[self redNote]];
            break;
        case MandoOrangeNote:
            note = [AVPlayerItem playerItemWithAsset:[self orangeNote]];
            break;
        case MandoBlueNote:
            note = [AVPlayerItem playerItemWithAsset:[self blueNote]];
            break;
        default:
            note = [AVPlayerItem playerItemWithAsset:[self errorNote]];
            break;
    }
    
    [[note asset] loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^{
        [[self player] replaceCurrentItemWithPlayerItem:note];
        [[self player] play];
    }];
}

@end
