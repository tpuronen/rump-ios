Rump-iOS
========

Rump-iOS is Rump client for iOS devices. For more information about Rump, see: https://github.com/raimohanska/rump

Using Rump-iOS
==============

Implement RumpDelegate methods to receive notification about response from Rump server.
```
-(void)connectedWith:(NSSet*)others {
  ...
}

-(void)onNoMatch {
  ...
}

-(void)onFailedWithError:(NSError*)error {
  ...
}
```

Use Rump:
```
CLLocation2DCoordinate loc = ...
Rump* rump = [[Rump alloc]init];
[rump rumpInLocation:loc user:@"username" nickname:@"nickname" delegate:self];
```