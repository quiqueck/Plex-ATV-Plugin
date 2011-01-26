//
//  PlexPrefs.h
//  PlexPad
//
//  Created by Frank Bauer on 13.06.10.
//  Copyright 2010 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef int ContentRating;
@interface PlexPrefs : NSObject {

}
+ (PlexPrefs *)defaultPreferences;
-(void)syncSettings;

@property (readwrite) NSInteger lastSeenDBVersion;
@property (readwrite) NSInteger lastSeenLocalPort;
@property (readwrite) BOOL enableCaching; 
@property (readwrite) BOOL enableShadows;

-(NSString*)filterForSection:(NSString*)section;
-(void)setFilter:(NSString*)val forSection:(NSString*)section;
-(void)setLastPosition:(NSArray*)pos forHost:(NSString*)host;
-(NSArray*)lastPositionOnHost:(NSString*)host;
-(void)setLastSearchQuerry:(NSString*)q forSection:(NSString*)section;
-(NSString*)lastSearchQuerryForSection:(NSString*)section;

-(void)setServerList:(NSData*)serializedServers;
-(NSData*)serverList;
-(void)setLocalServer:(NSData*)s;
-(NSData*)localServer;


-(BOOL)enableShadows;
-(void)setEnableShadows:(BOOL)v;

-(BOOL)enableCaching;
-(void)setEnableCaching:(BOOL)v;

-(BOOL)enableResponseCaching;
-(void)setEnableResponseCaching:(BOOL)v;

-(BOOL)playThemes;
-(void)setPlayThemes:(BOOL)v;

-(BOOL)seasonOverlays;
-(void)setSeasonOverlays:(BOOL)v;

-(BOOL)downloadEverything;
-(void)setDownloadEverything:(BOOL)v;

-(BOOL)allwaysAskToContinue;
-(void)setAllwaysAskToContinue:(BOOL)v;

-(BOOL)broadcastLocalServer;
-(void)setBroadcastLocalServer:(BOOL)v;

-(BOOL)allowDirectPlayback;
-(void)setAllowDirectPlayback:(BOOL)v;

/*-(NSTimeInterval)contentCachingTimeout;
-(void)setContentCachingTimeout:(NSTimeInterval)v;*/

-(void)setValue:(NSString*)v forProductID:(NSString*)pid;
-(NSString*)valueForProductID:(NSString*)pid;

-(void)setSelectionIndex:(CGFloat)idx forHost:(NSString*)host key:(NSString*)key;
-(CGFloat)selectionIndexForHost:(NSString*)host key:(NSString*)key;

-(void)setContentRatingRestriction:(ContentRating)cr;
-(ContentRating)contentRatingRestriction;
-(void)setContentPassword:(NSString*)pwd;
-(NSString*)contentPassword;
-(BOOL)disableMusic;
-(void)setDisableMusic:(BOOL)v;
-(BOOL)disablePlugins;
-(void)setDisablePlugins:(BOOL)v;

-(NSString*)fallbackPasswordID;
-(NSString*)fallbackPasswordForID:(NSString*)pwid deviceID:(NSString*)uid;
-(NSString*)fallbackPassword;
@end
