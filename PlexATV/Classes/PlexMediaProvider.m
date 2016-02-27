//
//  PlexMediaProvider.m
//  atvTwo
//
//  Created by Frank Bauer on 27.10.10.
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  

#import "PlexMediaProvider.h"
#import "PlexMediaAsset.h"
#import "PlexMediaAssetOld.h"
enum
{
    kBRMediaProviderNetworkWaitingState = 440,
    kBRMediaProviderNetworkDoneState,
    kBRMediaProviderLoadingState,
    kBRMediaProviderLoadedState,
    kBRMediaProviderUnloadingState,
    kBRMediaProviderUnloadedState
	
};

@implementation PlexMediaProvider
- (id) init
{
    if ( [super init] == nil )
        return ( nil );
	
    prov = [[BRBaseMediaProvider alloc] init];
    [self load];
	
    return ( self );
}

- (void) dealloc
{
	[prov release];
    [super dealloc];
}


- (long)countOfObjectsWithMediaType:(id)mediaType{
	NSLog(@"Retuning Count");
	return 1;
}


- (NSSet *) mediaTypes
{
    NSMutableArray * types = [[NSMutableArray alloc] init];
	
    // types handled by MEITunesMediaProvider
    [types addObject: [BRMediaType movie]];
    [types addObject: [BRMediaType streamingVideo]];
    [types addObject: [BRMediaType TVShow]];
    [types addObject: [BRMediaType song]];
	
    NSSet * result = [NSSet setWithArray: types];
    [types release];
	
	NSLog(@"Returning Types %@", result);
	
    return ( result );
}

- (id)objectsWithEntityName:(id)entityName qualifiedByPredicate:(id)predicate sortDescriptors:(id)descriptors excludeHiddenObjects:(BOOL)objects error:(id *)error{
	NSLog(@"entityName=%@, pred=%@, desc=%@", entityName, predicate, descriptors);
  if ([[[UIDevice currentDevice] systemVersion] isEqualToString:@"4.1"]){
    PlexMediaAssetOld* pma = [[PlexMediaAssetOld alloc] initWithURL:nil mediaProvider:self mediaObject:nil];
    return [pma autorelease];
  } else {
    PlexMediaAsset* pma = [[PlexMediaAsset alloc] initWithURL:nil mediaProvider:self mediaObject:nil];
    return [pma autorelease];
  }
}

- (id)objectsWithEntityName:(id)entityName qualifiedByPredicate:(id)predicate sortDescriptors:(id)descriptors error:(id *)error{
	return [self objectsWithEntityName:entityName 
				  qualifiedByPredicate:predicate 
					   sortDescriptors:descriptors 
				  excludeHiddenObjects:YES 
								 error:error];
}





- (id)providerID{
	return @"com.myplex.atv.movies.provider";
}

- (void)reset{
	NSLog(@"Did Reset Provider");
	[self unload];
    [self load];
}



- (int) load
{
    [prov setStatus: kBRMediaProviderLoadingState];
    [NSTimer scheduledTimerWithTimeInterval: 0.5
                                     target: self
                                   selector: @selector(_loadTimerCallback:)
                                   userInfo: nil
                                    repeats: NO];
    return ( kBRMediaProviderLoadingState );
}

- (int) unload
{
    [prov setStatus: kBRMediaProviderUnloadingState];
    [NSTimer scheduledTimerWithTimeInterval: 0.5
                                     target: self
                                   selector: @selector(_unloadTimerCallback:)
                                   userInfo: nil
                                    repeats: NO];
    return ( kBRMediaProviderUnloadingState );
}


- (void) _loadTimerCallback: (NSTimer *) timer
{
	NSLog(@"Finished load");
    [prov setStatus: kBRMediaProviderLoadedState];
}

- (void) _unloadTimerCallback: (NSTimer *) timer
{
	NSLog(@"Finished unload");
    [prov setStatus: kBRMediaProviderUnloadedState];
}
@end
