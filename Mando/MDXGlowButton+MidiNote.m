//
//  MDXGlowButton+MidiNote.m
//  Mando
//
//  Created by Mario Diana on 4/27/21.
//

#import "MDXGlowButton+MidiNote.h"

@implementation MDXGlowButton (MidiNote)

- (int)midiNote
{
    return (int)[self tag];
}

@end
