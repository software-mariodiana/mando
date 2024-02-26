//
//  MDXGlowButton+MidiNote.m
//  Mando
//
//  Created by Mario Diana on 4/27/21.
//

#import "MDXGlowButton+MidiNote.h"

const double kFlashDuration = 0.2;


@implementation MDXGlowButton (MidiNote)

- (int)midiNote
{
    return (int)[self tag];
}


- (void)flash
{
    dispatch_time_t interval = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kFlashDuration * NSEC_PER_SEC));
    
    [self showHighlightColor];
    
    dispatch_after(interval, dispatch_get_main_queue(), ^{
        [self hideHighlightColor];
    });
}

@end
