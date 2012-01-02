#import <SenTestingKit/SenTestingKit.h>
#import "Rump.h"

@interface RumpTests : SenTestCase<RumpDelegate> {
    BOOL _noMatchCalled;
    NSSet* _matches;
}

@property BOOL noMatchCalled;
@property (retain, nonatomic) NSSet* matches;

@end
