//
//  PlexDirectory.h
//  PlexPad
//
//  Created by Frank Bauer on 17.04.10.
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
#import "PlexObject.h"

extern const NSString* PlexMediaToken;
extern const NSString* PlexMediaPartToken;

@class PlexImage;

@interface PlexDirectory : PlexObject<NSXMLParserDelegate>  {
	PlexMediaContainer* mediaContainer;
	PlexDirectory* parentDirectory;
	BOOL localKey;
	
	BOOL hasMedia;
	NSMutableDictionary* subObjects;
}

@property (readonly) PlexDirectory* parentDirectory;
@property (readwrite, assign) PlexMediaContainer* mediaContainer;
@property (readonly) NSMutableDictionary* subObjects;
@property (readonly) BOOL hasMedia;
@property (readonly) BOOL localKey;

-(id)initWithAttributes:(NSDictionary*)dict parentMediaContainer:(PlexMediaContainer*)mc parentObject:(PlexDirectory*)pmo containerType:(NSString*)ct;

-(NSString*)listSubObjects:(NSString*)type usingKey:(NSString*)k;
-(PlexDirectory*)mediaResource;
-(NSString*)debugSummary;
-(PlexImage*)plexImageFromKey;
@end