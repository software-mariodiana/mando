//
//  MandoPlaybackViewController.h
//  Mando
//
//  Created by Mario Diana on 6/6/21.
//

#import <UIKit/UIKit.h>

#import "MandoGameLeader.h"
#import "MDXSynth.h"


@interface MandoPlaybackViewController : UIViewController

@property (nonatomic, strong) id<MandoGameLeader> game;
@property (nonatomic, weak) MDXSynth* synth;

@end
