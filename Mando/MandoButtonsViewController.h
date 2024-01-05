//
//  MandoButtonsViewController.h
//  MandoButtonPrototype
//
//  Created by Mario Diana on 5/31/21.
//

#import <UIKit/UIKit.h>

@protocol MandoButtonsViewDelegate <NSObject>
- (void)play:(id)sender;
@end


@interface MandoButtonsViewController : UIViewController

@property (nonatomic, weak) id<MandoButtonsViewDelegate> delegate;

- (void)setButtonsInteractionEnabled:(BOOL)enabled;
- (NSArray *)buttons;

@end
