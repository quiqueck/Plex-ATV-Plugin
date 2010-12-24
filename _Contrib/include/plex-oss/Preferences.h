//
//  PlexPrefs.h
//  PlexPad
//
//  Created by Frank Bauer on 13.06.10.
//  Copyright 2010 F. Bauer. All rights reserved.
//
// Redistribution and use of the code or any derivative works are 
// permitted provided that the following conditions are met:
//   - Redistributions may not be sold, nor may they be used in 
//     a commercial product or activity.
//   - Redistributions must reproduce the above copyright notice, 
//     this list of conditions and the following disclaimer in the 
//     documentation and/or other materials provided with the 
//     distribution.
//   - It is not permitted to redistribute a modified version of 
//     this file
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
// ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
// POSSIBILITY OF SUCH DAMAGE.
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

-(void)setServerList:(NSArray*)serializedServers;
-(NSArray*)serverList;
-(void)setLocalServer:(NSDictionary*)s;
-(NSDictionary*)localServer;


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
