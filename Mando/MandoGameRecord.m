//
//  MandoGameRecord.m
//  Mando
//
//  Created by Mario Diana on 6/7/21.
//

#import "MandoGameRecord.h"

@interface MandoGameRecord ()
@property (nonatomic, assign) NSInteger roundNumber;
@property (nonatomic, strong) NSArray* toneSequence;
@end

@implementation MandoGameRecord

- (instancetype)initWithGameRound:(id<MandoRound>)round
{
    self = [super init];
    
    if (self) {
        _roundNumber = [round roundNumber] - 1;
        
        NSRange range = NSMakeRange(0, [[round toneSequence] count] - 1);
        _toneSequence = [[round toneSequence] subarrayWithRange:range];
    }
    
    return self;
}

@end
