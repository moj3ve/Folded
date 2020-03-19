#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListItemsController.h>
#import <Preferences/PSSliderTableCell.h>

@interface OPERootListController : PSListController{
        UITableView * _table;
}
@property (nonatomic, retain) NSMutableDictionary *mySavedSpecifiers;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *iconView;
@end

@interface PSListController (iOS12Plus)
-(BOOL)containsSpecifier:(id)arg1;
@end

@interface Thomz_TwitterCell : PSTableCell
@end

@interface Burrit0z_TitleCell : PSTableCell
@end

@interface FoldedHeaderCell : PSTableCell
@end

@interface NSTask : NSObject
@property(copy) NSArray *arguments;
@property(copy) NSString *launchPath;
- (id)init;
- (void)launch;
@end