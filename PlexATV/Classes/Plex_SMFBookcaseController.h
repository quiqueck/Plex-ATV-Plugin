//
//  Plex_SMFBookcaseController.h
//  SMFramework
//
//  Created by Chris Jensen on 2/26/11.
//

#import <Backrow/Backrow.h>
@class Plex_SMFBookcaseController;

@protocol Plex_SMFBookcaseControllerDatasource
- (NSString *)headerTitleForBookcaseController:(Plex_SMFBookcaseController *)bookcaseController;
- (NSInteger)numberOfShelfsInBookcaseController:(Plex_SMFBookcaseController *)bookcaseController;
- (BRPhotoDataStoreProvider *)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController datastoreProviderForShelfAtIndex:(NSInteger)index;
@optional
- (BRImage *)headerIconForBookcaseController:(Plex_SMFBookcaseController *)bookcaseController;
- (NSString *)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController titleForShelfAtIndex:(NSInteger)index;
@end

@protocol Plex_SMFBookcaseControllerDelegate
-(BOOL)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController allowSelectionForShelf:(BRMediaShelfControl *)shelfControl atIndex:(NSInteger)index;
@optional
-(void)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController selectionWillOccurInShelf:(BRMediaShelfControl *)shelfControl atIndex:(NSInteger)index;
-(void)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController selectionDidOccurInShelf:(BRMediaShelfControl *)shelfControl atIndex:(NSInteger)index;
@end

@interface Plex_SMFBookcaseController : BRController {
	NSObject<SMFMoviePreviewControllerDatasource> *datasource;
    NSObject<SMFMoviePreviewControllerDelegate> *delegate;
	
@private
	//datasource variables
	NSInteger numberOfShelfControls;
	NSMutableArray *_shelfTitles;
	
	//ui controls
	NSMutableArray *_shelfControls;
	BRPanelControl *_panelControl;
}
@property (retain) NSObject <Plex_SMFBookcaseControllerDatasource> *datasource;
@property (retain) NSObject <Plex_SMFBookcaseControllerDelegate> *delegate;
- (void)reload;
- (void)reloadDataForAllShelfControls;
- (void)reloadDataForShelfAtIndex:(NSInteger)index;

@end

