/*
 *  HWAppliance.h
 *  atvTwo
 *
 *  Created by Frank Bauer on 15.01.11.
 *
 */


#import "BackRowExtras.h"
@class TopShelfController, PlexMediaContainer;

@interface PlexAppliance: BRBaseAppliance <MachineManagerDelegate> {
	TopShelfController *_topShelfController;
	NSMutableArray *_applianceCategories;
	NSMutableArray *_machines;
	
	BRApplianceCategory *otherServersApplianceCategory;
	BRApplianceCategory *settingsApplianceCategory;
}
@property(nonatomic, readonly, retain) id topShelfController;
@property(retain) NSMutableArray *applianceCat;
@property(nonatomic, retain) NSMutableArray *machines;

- (void)loadInPersistentMachines;
- (Machine *)machineFromUid:(NSString *)uid;
- (void)showGridListControl:(PlexMediaContainer *)movieCategory;

- (void)retrieveNewPlexCategories:(Machine *)m;
- (void)addNewApplianceWithDict:(NSDictionary *)dict;
- (void)addNewApplianceWithCompoundIdentifier:(NSDictionary *)compoundIdentifier;
- (void)removeAppliancesBelongingToMachineWithUid:(NSString *)uid;
@end