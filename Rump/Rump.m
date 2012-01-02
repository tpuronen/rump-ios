#import "Rump.h"

@implementation RumpUser

@synthesize userId = _userId;
@synthesize name = _name;
@synthesize coordinate = _coordinate;

@end

@implementation Rump

-(id)init {
    self = [super init];
    if(self) {
        _responseData = [[NSMutableData alloc]init];
    }
    return self;
}

-(void)rumpInLocation:(CLLocationCoordinate2D)coordinate user:(NSString*)user nickname:(NSString*)nickname delegate:(id<RumpDelegate>)delegate {
    _delegate = delegate;
    _myUserId = user;
    NSData* json = [self createRumpRequest:coordinate user:user nickname:nickname];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://rump.demo.reaktor.fi/karma"]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:json];

    [NSURLConnection connectionWithRequest:request delegate:self];    
}

-(NSData*)createRumpRequest:(CLLocationCoordinate2D)coordinate user:(NSString*)user nickname:(NSString*)nickname {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:user forKey:@"userId"];
    [dict setValue:nickname forKey:@"displayName"];
    NSMutableDictionary* location = [NSMutableDictionary dictionary];
    [location setValue:[NSNumber numberWithFloat:coordinate.latitude] forKey:@"latitude"];
    [location setValue:[NSNumber numberWithFloat:coordinate.longitude] forKey:@"longitude"];
    [dict setValue:location forKey:@"location"];
    
    NSError* error;
    NSData* result = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    
    return result;
}

-(NSSet*)parseRumpResponse:(NSData*)response {
    NSMutableSet* resultSet = [NSMutableSet set];
    NSError* error;
    NSArray* result = [NSJSONSerialization JSONObjectWithData:response options:0 error:&error];
    if (error) {
        return nil;
    }
    for (NSDictionary* dict in result) {
        RumpUser* user = [[RumpUser alloc]init];
        user.userId = [dict objectForKey:@"userId"];
        user.name = [dict objectForKey:@"displayName"];
        NSDictionary* location = [dict objectForKey:@"location"];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[location objectForKey:@"latitude"] floatValue];
        coordinate.longitude = [[location objectForKey:@"longitude"] floatValue];
        user.coordinate = coordinate;
        [resultSet addObject:user];
    }
    return resultSet;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [_responseData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"fail: %@", error);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSSet* result = [self parseRumpResponse:_responseData];
    NSSet* others = [self others:result];
    if ([others count] > 1) {
        [_delegate connectedWith:others];        
    } else {
        [_delegate onNoMatch];
    }    
}

-(NSSet*)others:(NSSet*)everybody {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId != %@", _myUserId];
    NSSet* others = [everybody filteredSetUsingPredicate:predicate];
    return others;
}

@end