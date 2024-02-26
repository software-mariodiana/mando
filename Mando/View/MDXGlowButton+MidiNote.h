//
//  MDXGlowButton+MidiNote.h
//  Mando
//
//  Created by Mario Diana on 4/27/21.
//

#import "MDXGlowButton.h"
#import "MandoMidiPlaying.h"

@interface MDXGlowButton (MidiNote) <MandoMidiPlaying>
- (int)midiNote;
- (void)flash;
@end


@interface MDXGlowButton ()
- (void)showHighlightColor;
- (void)hideHighlightColor;
@end
