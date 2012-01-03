#import "RumpTests.h"

@implementation RumpTests

@synthesize noMatchCalled = _noMatchCalled;
@synthesize matches = _matches;
@synthesize error = _error;

- (void)testParseEmptyRumpResponse {
    Rump* rump = [[Rump alloc]init];
    NSError* error;
    NSSet* buddies = [rump parseRumpResponse:[@"" dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    STAssertTrue(0 == [buddies count], @"buddies not empty");
}

- (void)testParseRumpResponse {
    NSString* rumpResponse = @"[{ \"userId\" : \"john\", \"displayName\" : \"John Kennedy\", \"location\": { \"latitude\": 51.0, \"longitude\": -0.1 } }, { \"userId\" : \"jack\", \"displayName\" : \"Jack Bauer\", \"location\": { \"latitude\": 51.0, \"longitude\": -0.1 } }]";
    
    Rump* rump = [[Rump alloc]init];
    NSError* error = nil;
    NSSet* results = [rump parseRumpResponse:[rumpResponse dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    STAssertTrue(2 == [results count], @"wrong number of users returned");
    STAssertNil(error, @"error not nil");
}

- (void)testParseInvalidRumpResponse {
    NSString* rumpResponse = @"foobar";
    Rump* rump = [[Rump alloc]init];
    NSError* error;
    NSSet* results = [rump parseRumpResponse:[rumpResponse dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    STAssertTrue(nil == results, @"matches not nil");
    STAssertNotNil(error, @"no error reported");
    NSLog(@"%@", error);
}

- (void)testCreateRumpRequest {
    Rump* rump = [[Rump alloc]init];
    CLLocationCoordinate2D coords;
    coords.longitude = 51.0;
    coords.latitude = -0.1;
    NSData* json = [rump createRumpRequest:coords user:@"john" nickname:@"John Kennedy"];
    NSString* jsonString = [[NSString alloc]initWithData:json encoding:NSUTF8StringEncoding];
    NSRange locPos = [jsonString rangeOfString:@"\"location\":{\"longitude\":51,\"latitude\":-0.1}"];
    STAssertTrue(NSNotFound != locPos.location, @"location not found");
    NSRange nickPos = [jsonString rangeOfString:@"\"displayName\":\"John Kennedy\""];
    STAssertTrue(NSNotFound != nickPos.location, @"nick not found");
    NSRange idPos = [jsonString rangeOfString:@"\"userId\":\"john\""];
    STAssertTrue(NSNotFound != idPos.location, @"user id not found");
}

- (void)testNoFriendsFound {
    self.noMatchCalled = NO;
    NSString* rumpResponse = @"[{ \"userId\" : \"user\", \"displayName\" : \"nick\", \"location\": { \"latitude\": 51.0, \"longitude\": -0.1 } }]";
    
    Rump* rump = [[Rump alloc]initWithBaseUrl:[NSURL URLWithString:@""] user:@"user" nickname:@"nick" delegate:self];
    
    [rump handleResponse:[rumpResponse dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertTrue(self.noMatchCalled, @"onNoMatch not called");
}

-(void)testFriendsFound {
    self.noMatchCalled = NO;
    NSString* rumpResponse = @"[{ \"userId\" : \"john\", \"displayName\" : \"John Kennedy\", \"location\": { \"latitude\": 51.0, \"longitude\": -0.1 } }, { \"userId\" : \"jack\", \"displayName\" : \"Jack Bauer\", \"location\": { \"latitude\": 51.0, \"longitude\": -0.1 } },{ \"userId\" : \"user\", \"displayName\" : \"nick\", \"location\": { \"latitude\": 51.0, \"longitude\": -0.1 } }]";

    Rump* rump = [[Rump alloc]initWithBaseUrl:[NSURL URLWithString:@""] user:@"user" nickname:@"nick" delegate:self];
    [rump handleResponse:[rumpResponse dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertFalse(self.noMatchCalled, @"noMatch called");
    STAssertTrue([self.matches count] == 2, @"no buddies found");
}

-(void)testInvalidResponse {
    NSString* rumpResponse = @"[foobar";
    
    Rump* rump = [[Rump alloc]initWithBaseUrl:[NSURL URLWithString:@""] user:@"user" nickname:@"nick" delegate:self];
    [rump handleResponse:[rumpResponse dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertNotNil(self.error, @"no error occured");
    
}

-(void)connectedWith:(NSSet *)others {
    self.matches = others;
}

-(void)onNoMatch {
    self.noMatchCalled = YES;
}

-(void)onFailedWithError:(NSError *)error {
    _error = error;
}

@end
