#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListItemsController.h>
#import <Preferences/PSSliderTableCell.h>

@interface OPERootListController : PSListController
@property (nonatomic, retain) NSMutableDictionary *mySavedSpecifiers;
@end

@interface PSListController (iOS12Plus)
-(BOOL)containsSpecifier:(id)arg1;
@end

@interface Thomz_TwitterCell : PSTableCell
@end

@interface Burrit0z_TitleCell : PSTableCell
@end
