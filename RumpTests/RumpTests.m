#import "RumpTests.h"

@implementation RumpTests

@synthesize noMatchCalled = _noMatchCalled;
@synthesize matches = _matches;

- (void)testParseEmptyRumpResponse {
    Rump* rump = [[Rump alloc]init];
    NSSet* buddies = [rump parseRumpResponse:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertTrue(0 == [buddies count], @"buddies not empty");
}

- (void)testParseRumpResponse {
    NSString* rumpResponse = @"[{ \"userId\" : \"john\", \"displayName\" : \"John Kennedy\", \"location\": { \"latitude\": 51.0, \"longitude\": -0.1 } }, { \"userId\" : \"jack\", \"displayName\" : \"Jack Bauer\", \"location\": { \"latitude\": 51.0, \"longitude\": -0.1 } }]";
    
    Rump* rump = [[Rump alloc]init];
    NSSet* buddies = [rump parseRumpResponse:[rumpResponse dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertTrue(2 == [buddies count], @"wrong number of users returned");
}

- (void)testParseInvalidRumpResponse {
    NSString* rumpResponse = @"foobar";
    Rump* rump = [[Rump alloc]init];
    NSSet* buddies = [rump parseRumpResponse:[rumpResponse dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertTrue(0 == [buddies count], @"buddies count not zero");
}

- (void)testCreateRumpRequest {
    Rump* rump = [[Rump alloc]init];
    CLLocationCoordinate2D coords;
    coords.longitude = 51.0;
    coords.latitude = -0.1;
    NSData* json = [rump createRumpRequest:coords user:@"john" nickname:@"John Kennedy"];
    NSString* jsonString = [[NSString alloc]initWithData:json encoding:NSUTF8StringEncoding];
    NSLog(@"JSON: %@", jsonString);
    NSRange locPos = [jsonString rangeOfString:@"\"location\":{\"longitude\":51,\"latitude\":-0.1}"];
    STAssertTrue(NSNotFound != locPos.location, @"location not found");
    NSRange nickPos = [jsonString rangeOfString:@"\"displayName\":\"John Kennedy\""];
    STAssertTrue(NSNotFound != nickPos.location, @"nick not found");
    NSRange idPos = [jsonString rangeOfString:@"\"userId\":\"john\""];
    STAssertTrue(NSNotFound != idPos.location, @"user id not found");
}

- (void)testNoFriendsFound {
    Rump* rump = [[Rump alloc]init];
    CLLocationCoordinate2D coord;
    coord.latitude = 10;
    coord.longitude = 20;
    [rump rumpInLocation:coord user:@"user" nickname:@"nick" delegate:self];
}

-(void)connectedWith:(NSSet *)others {
    
}

-(void)onNoMatch {
    self.noMatchCalled = YES;
}

@end
