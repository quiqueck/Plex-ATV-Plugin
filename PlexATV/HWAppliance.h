/*
 *  HWAppliance.h
 *  atvTwo
 *
 *  Created by Frank Bauer on 15.01.11.
 *
 */


#import "BackRowExtras.h"
@class TopShelfController;

@interface PlexAppliance: BRBaseAppliance <MachineManagerDelegate> {
	TopShelfController *_topShelfController;
	NSMutableArray *_applianceCategories;
	NSMutableArray *_machines;
}
@property(nonatomic, readonly, retain) id topShelfController;
@property(retain) NSMutableArray *applianceCat;
@property(nonatomic, retain) NSMutableArray *machines;

- (void)retrieveNewPlexCategories:(Machine *)m;
- (void)addNewApplianceWithDict:(NSDictionary *)dict;
- (void)addNewApplianceWithName:(NSString *)name identifier:(id)ident;
- (void)removeAppliancesWithIdentifier:(id)ident;
@end