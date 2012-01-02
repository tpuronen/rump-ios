#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface RumpUser : NSObject {
    NSString* _userId;
    NSString* _name;
    CLLocationCoordinate2D _coordinate;
}

/**
 * User ID
 */
@property (nonatomic, retain) NSString* userId;

/**
 * User friendly name
 */
@property (nonatomic, retain) NSString* name;

/**
 * Location of the user
 */
@property CLLocationCoordinate2D coordinate;

@end

@protocol RumpDelegate <NSObject>

@required
/**
 * Called when Rump connection is made
 * Argument does not contain caller
 */
-(void)connectedWith:(NSSet*)others;

/**
 * Called when no match is made
 */
-(void)onNoMatch;

@optional
/**
 * Called if an error occured in Rump server communication
 */
-(void)onFailedWithError:(NSError*)error;

@end

@interface Rump : NSObject<NSURLConnectionDataDelegate> {
    NSURL* _baseUrl;
    id<RumpDelegate> _delegate;
    NSMutableData* _responseData;
    NSString* _myUserId;
}

/**
 * Initialize Rump client with give Rump server URL
 */
-(id)initWithBaseUrl:(NSURL*)baseUrl;

/**
 * Send Rump request to server. Delegate will be notified of the result
 */
-(void)rumpInLocation:(CLLocationCoordinate2D)coordinate user:(NSString*)user nickname:(NSString*)nickname delegate:(id<RumpDelegate>)delegate;

-(NSData*)createRumpRequest:(CLLocationCoordinate2D)coordinate user:(NSString*)user nickname:(NSString*)nickname;
-(NSSet*)parseRumpResponse:(NSData*)response;
-(NSSet*)others:(NSSet*)everybody;

@end