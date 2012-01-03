#import <SenTestingKit/SenTestingKit.h>
#import "Rump.h"

@interface RumpTests : SenTestCase<RumpDelegate> {
    BOOL _noMatchCalled;
    NSSet* _matches;
    NSError* _error;
}

@property BOOL noMatchCalled;
@property (retain, nonatomic) NSSet* matches;
@property (retain, nonatomic) NSError* error;

@end
