#include "Tweak.h"

%group universal

%hook SBFolderIconImageView

-(void)layoutSubviews { 
  %orig; //I want to run the original stuff first
  if(enabled && colorFolderIconBackground) {
	self.backgroundView.blurView.hidden = 1;
    self.backgroundView.backgroundColor = [UIColor cscp_colorFromHexString:folderIconColor];
  }
  else if (enabled && hideFolderIconBackground) {
    self.backgroundView.alpha = 0;
    self.backgroundView.hidden = 1;
  }
}

%end

%hook SBFloatyFolderView

-(void)setBackgroundAlpha:(double)arg1 { // returning the value from the slider cell in the settings for the bg alpha

	if(enabled && backgroundAlphaEnabled){
		%orig(backgroundAlpha);
	}
}

-(void)setCornerRadius:(double)arg1 { // returning the value from the slider cell in the settings for the corner radius
	if(enabled && cornerRadiusEnabled) {
		%orig(cornerRadius);
	} else if (!cornerRadiusEnabled) {
		%orig(38);
	}
}

-(CGRect)_frameForScalingView { // modyfing the frame with the values from the settings, iOS 12

if(enabled && customFrameEnabled){
		if(customCenteredFrameEnabled){
			return CGRectMake((self.bounds.size.width - frameWidth)/2, (self.bounds.size.height - frameHeight)/2,frameWidth,frameHeight); // simple calculation to center things
		} else if(!customCenteredFrameEnabled){
			if(frameWidth == 0 || frameHeight == 0){
				return %orig;
			} else {
				return CGRectMake(frameX,frameY,frameWidth,frameHeight);
			}
		} else {return %orig;}
	} else {return %orig;}
}

-(BOOL)_showsTitle { // simply hide the title

	if(enabled && hideTitleEnabled){
		return NO;
	} else {
		return YES;
	}
}

-(double)_titleFontSize { // return the value from the slider for the font size

	if(enabled && customTitleFontSizeEnabled){
		return customTitleFontSize;
	} else {return %orig;}
}

-(BOOL)_tapToCloseGestureRecognizer:(id)arg1 shouldReceiveTouch:(id)arg2 {
  %orig;
  if (enabled && tapToCloseEnabled) {
    return (YES); //This lets the tap recognizer recieve touch everywhere, even on the folder background itself.
  } else {
    return %orig;
  }
}

%new
- (UIColor *)randomColor {

	int r = arc4random_uniform(256);
	int g = arc4random_uniform(256);
	int b = arc4random_uniform(256);

	return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

%end


%hook SBIconListPageControl

-(void)layoutSubviews {

	%orig;
	if(enabled && hideDotsPref==2 && isInAFolder ) { // not working (look below thomz :D)
		self.hidden = 1; //now this works :D
		isInAFolder = NO;
	} else if(enabled && hideDotsPref==3) {
		self.hidden=1;
	} else {
		return %orig;
	}

}

%end

%hook SBFolderTitleTextField
%property (nonatomic, strong) UILabel *newLabel;

-(void)layoutSubviews {

	isInAFolder = YES;

	%orig;

	UIColor *color = [UIColor cscp_colorFromHexString:titleColor];

	if(enabled && titleFontWeight == 1){
		// nothing
	} else if(enabled && titleFontWeight == 2){
		[self setFont:[UIFont systemFontOfSize:(self.font.pointSize)]]; // for some reason, systemFontOfSize is bigger than the title font
	} else if(enabled && titleFontWeight == 3){
		[self setFont:[UIFont boldSystemFontOfSize:(self.font.pointSize)]];
	}

	if(enabled && titleAlignment == 1){
		[self setTextAlignment:NSTextAlignmentLeft];
	} else if(enabled && titleAlignment == 2){
		// nothing
	} else if(enabled && titleAlignment == 3){
		[self setTextAlignment:NSTextAlignmentRight];
	}

	if(enabled && titleColorEnabled){
		[self setTextColor:color];
	}

	if (enabled && customTitleFontEnabled) {
    	[self setFont:[UIFont fontWithName:customTitleFont size:(self.font.pointSize)]];
	}

	CGFloat modifiedOriginX = self.frame.origin.x; //yeah, theres a reason this is frame and not bounds
	CGFloat modifiedOriginY = self.bounds.origin.y;

	if(enabled && customTitleXOffSetEnabled) {
		modifiedOriginX = customTitleXOffSet;
	} else {
		modifiedOriginX = self.frame.origin.x;
	}

	if(enabled && customTitleOffSetEnabled){
		modifiedOriginY = (modifiedOriginY + customTitleOffSet);
	} else {
		modifiedOriginY = self.bounds.origin.y;
	}

	if(enabled && (customTitleOffSetEnabled || customTitleXOffSetEnabled)) {
		[self setFrame: CGRectMake(
			modifiedOriginX,
			modifiedOriginY,
			self.bounds.size.width,
			self.bounds.size.height
		)];
	}

	if(enabled && folderAppCounterEnabled &&!([self.ab_text length] == 0) && !addedLabel) { //so we know the string has been set

		NSString *currentText = self.ab_text;
		//NSLog(@"[Folded]: %@", currentText);
		NSUInteger indexOfFolder;
		for(int i=0; i<[foldersThatExist count]; i++) {
			if([currentText isEqualToString:[foldersThatExist objectAtIndex:i]]) indexOfFolder=i;
		}
		NSString *labelText = [countOfIconsInFoldersThatExist objectAtIndex:indexOfFolder];

		UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake((titlePosition.origin.x),(self.bounds.origin.y - 50),(self.frame.size.width - 70),100)];
			[newLabel setText:[NSString stringWithFormat:@"%@ APPS IN", labelText]];
			if (customTitleFontEnabled) {
				[newLabel setFont:[UIFont fontWithName:customTitleFont size:20]];
			} else {
				[newLabel setFont:[newLabel.font fontWithSize:20]];
			}

			if(folderAppCounterFontSizeEnabled) {
				[newLabel setFont:[newLabel.font fontWithSize:folderAppCounterFontSize]];
			}

			if(titleColorEnabled) {
				[newLabel setTextColor:color];
			} else {
				[newLabel setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
			}

			if(titleAlignment == 1){
				[newLabel setTextAlignment:NSTextAlignmentLeft];
			} else if(titleAlignment == 3){
				[newLabel setTextAlignment:NSTextAlignmentRight];
			} else {
				[newLabel setTextAlignment:NSTextAlignmentCenter];
			}

			[self addSubview:newLabel];

		addedLabel=YES;
	}

}

-(void)removeFromSuperview {
	addedLabel = NO;
	%orig;
}

-(CGRect)textRectForBounds:(CGRect)arg1 {
	titlePosition = %orig(arg1);
	return %orig;
}


%end


%hook SBFolderBackgroundView
%property (nonatomic, strong) UIVisualEffectView *lightView;
%property (nonatomic, strong) UIVisualEffectView *darkView;
%property (nonatomic, strong) UIView *backgroundColorFrame;
%property (nonatomic, strong) CAGradientLayer *gradient;
-(void)layoutSubviews {

	%orig;

    self.lightView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
	self.lightView.frame = self.bounds;
	self.darkView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
	self.darkView.frame = self.bounds;
	self.backgroundColorFrame = [[UIView alloc] initWithFrame:self.bounds];
	UIColor *backgroundColor = [UIColor cscp_colorFromHexString:folderBackgroundColor];
	[self.backgroundColorFrame setBackgroundColor:backgroundColor];

	NSArray<id> *gradientColors = [StringForPreferenceKey(@"folderBackgroundColorWithGradient") cscp_gradientStringCGColors];

	self.gradient = [CAGradientLayer layer];
    self.gradient.frame = self.bounds;

	if(!folderBackgroundColorWithGradientVerticalGradientEnabled){
		self.gradient.startPoint = CGPointMake(0, 0.5);
		self.gradient.endPoint = CGPointMake(1, 0.5);
	} else if(folderBackgroundColorWithGradientVerticalGradientEnabled) {
		self.gradient.startPoint = CGPointMake(0.5, 0);
        self.gradient.endPoint = CGPointMake(0.5, 1);
	}

	self.gradient.colors = gradientColors;

	if(enabled && customBlurBackgroundEnabled && customBlurBackground == 1){
		MSHookIvar<UIVisualEffectView *>(self, "_blurView") = self.lightView;

		[[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
		[self addSubview:self.lightView];
	}

	if(enabled && customBlurBackgroundEnabled && customBlurBackground == 2){
		MSHookIvar<UIVisualEffectView *>(self, "_blurView") = self.darkView;

		[[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
		[self addSubview:self.darkView];
	}

	if(enabled && folderBackgroundColorEnabled){
		[[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
		[self addSubview:self.backgroundColorFrame];

		if(kCFCoreFoundationVersionNumber > 1600) {
			if(cornerRadiusEnabled) {
				[self.backgroundColorFrame.layer setCornerRadius:cornerRadius];
			} else {
				[self.backgroundColorFrame.layer setCornerRadius:38];
			}
		}
	}
	if(enabled &&  folderBackgroundColorWithGradientEnabled){
		[[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
		[self.layer insertSublayer:self.gradient atIndex:0];

		if(kCFCoreFoundationVersionNumber > 1600) {
			if(cornerRadiusEnabled) {
				[self.gradient setCornerRadius:cornerRadius];
			} else {
				[self.gradient setCornerRadius:38];
			}
		}
	}
}
%end

%hook SBFolderController
-(BOOL)_homescreenAndDockShouldFade {
  if (enabled && clearBackgroundIcons) {
    return YES;
  } else {
    return %orig;
  }
}
%end

%hook SBFolderControllerBackgroundView
%property (nonatomic, strong) UIView *maView;

-(void)layoutSubviews {
    %orig;
	if (enabled && customWallpaperBlurEnabled && !folderBackgroundBackgroundColorEnabled) self.alpha = customWallpaperBlurFactor;
	UIView *maView;
	maView = [[UIView alloc]initWithFrame:self.frame];
	if (kCFCoreFoundationVersionNumber > 1600) {
		if (enabled && folderBackgroundBackgroundColorEnabled && !randomColorBackgroundEnabled) {
			UIColor *color = [UIColor cscp_colorFromHexString:folderBackgroundBackgroundColor];
			[maView setBackgroundColor:color];
			[maView setAlpha:backgroundAlphaColor];
		} else if(enabled && folderBackgroundBackgroundColorEnabled && randomColorBackgroundEnabled) {
			UIColor *randomColorIGuess = [self randomColor];
			[maView setBackgroundColor:randomColorIGuess];
			[maView setAlpha:backgroundAlphaColor];
		}
	}
	[self addSubview:maView];
}

%new
- (UIColor *)randomColor {

	int r = arc4random_uniform(256);
	int g = arc4random_uniform(256);
	int b = arc4random_uniform(256);

	return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

%end


%end

%group ios12

%hook SBFolder
//%property (nonatomic, assign) BOOL hasStoredLists;
//Originally I tried using a property, but for some reason there were new instances of SBFolder each time...

//This is different than the method used on iOS 13

-(NSString *)displayName {
	NSString *name = %orig;
	BOOL isAlreadyStored = NO;
	NSUInteger indexToReplaceWithNew;
	for(int i=0; i<[foldersThatExist count]; i++) {
		if([[foldersThatExist objectAtIndex:i] isEqualToString:name]) {
			isAlreadyStored = YES;
			indexToReplaceWithNew = i;
		}
	}
	
	//NSString *countOfIcons = [NSString stringWithFormat:@"%ld", (long)[self.icons count]]; (iOS 13)
	//Here's where it's different

	@try {
		NSMutableArray *listsOfIcons;

		NSUInteger numericalCount;
		for(int x=0;x<[self.lists count]; x++) {
			SBIconListModel *currentModel = [self.lists objectAtIndex:x];

			for(int y=0;y<[listsOfIcons count]; y++) {
				if(!([listsOfIcons objectAtIndex:y] == currentModel.children)) {
				numericalCount = (numericalCount + currentModel.numberOfIcons);
				[listsOfIcons addObject:currentModel.children]; }
			}

			if([listsOfIcons count] == 0) {
				numericalCount = (numericalCount + currentModel.numberOfIcons);
				[listsOfIcons addObject:currentModel.children]; 
			}
		}

		NSString *countOfIcons = [NSString stringWithFormat:@"%ld", (long)numericalCount];
		

		if(!isAlreadyStored) {
			[foldersThatExist addObject:name];
			[countOfIconsInFoldersThatExist addObject:countOfIcons];
		} else if(isAlreadyStored && !([[countOfIconsInFoldersThatExist objectAtIndex:indexToReplaceWithNew] isEqualToString:countOfIcons])) { 
			//Allows the updating of the icon count without respringing.
			[countOfIconsInFoldersThatExist replaceObjectAtIndex:indexToReplaceWithNew withObject:countOfIcons];
		}
	} @catch (NSException *exception) {}
	return name;
}

%end

%hook SBFolderBackgroundMaterialSettings

-(UIColor *)baseOverlayColor { // this effect looks so sweet

	UIColor *color = [UIColor cscp_colorFromHexString:folderBackgroundBackgroundColor];

	if(enabled && folderBackgroundBackgroundColorEnabled && !randomColorBackgroundEnabled){
		return color;
	} else if(enabled && folderBackgroundBackgroundColorEnabled && randomColorBackgroundEnabled){
		return [self randomColor];
	} else {return %orig;}
}

-(double)baseOverlayTintAlpha {

	if(enabled && folderBackgroundBackgroundColorEnabled){
		return backgroundAlphaColor;
	} else if(enabled && randomColorBackgroundEnabled){
		return backgroundAlphaColor;
	} else {return %orig;}
}

%new
- (UIColor *)randomColor {

	int r = arc4random_uniform(256);
	int g = arc4random_uniform(256);
	int b = arc4random_uniform(256);

	return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

%end

%hook SBFolderSettings

-(BOOL)pinchToClose { // enable pinch to close

	if(enabled && pinchToCloseEnabled){
		return YES;
	} else {
		return NO;
	}
}

%end

%hook SBIconBlurryBackgroundView

-(BOOL)isBlurring {
  if (enabled && hideFolderIconBackground) {
    return NO;
  } else {
    return %orig;
  }
}

%end

%hook SBFolderIconListView // layout for iOS 12

+ (unsigned long long)maxVisibleIconRowsInterfaceOrientation:(long long)arg1 {

	if(enabled && customLayoutEnabled){
		return (customLayoutRows);
	} else {return %orig;}
}

+ (unsigned long long)iconColumnsForInterfaceOrientation:(long long)arg1 {

	if(enabled && customLayoutEnabled){
    	return (customLayoutColumns);
	} else {return %orig;}
}

-(double)sideIconInset {
	if(enabled && insetsEnabled) {return sideInset;} else {return %orig;}
}
-(double)topIconInset {
	if(enabled && insetsEnabled) {return topInset;} else {return %orig;}
}
-(double)bottomIconInset {
	if(enabled && insetsEnabled) {return bottomInset;} else {return %orig;}
}

%end

%hook SBIconGridImage

+ (CGSize)cellSize {
    CGSize orig = %orig;
	if(enabled && customLayoutEnabled){
    	if(customLayoutRows == 1 && customLayoutColumns == 1){
			return CGSizeMake(orig.width * 3.54, orig.height);
		} else if((customLayoutRows == 1 && customLayoutColumns == 2) || (customLayoutRows == 2 && customLayoutColumns == 1)){
			return CGSizeMake(orig.width * 1.62, orig.height * 0.44);
		} else if(customLayoutRows == 2 && customLayoutColumns == 2) {
			return CGSizeMake(orig.width * 1.54, orig.height);
		} else if((customLayoutRows == 3 && customLayoutColumns == 2) || (customLayoutRows == 2 && customLayoutColumns == 3)) {
			return CGSizeMake(orig.width, orig.height * 0.7);
		} else {return orig;}
	} else {return orig;}

	//return CGSizeMake(orig.width * 1.54, orig.height);
}


+ (unsigned long long)numberOfColumns {

	if(enabled && customLayoutEnabled){
		if(customLayoutRows == 2 && customLayoutColumns == 2){
    		return 2;
		} else {return %orig;}
	} else {
		return %orig;
	}
}

+ (unsigned long long)numberOfRowsForNumberOfCells:(unsigned long long)arg1 {
	if(enabled && customLayoutEnabled){
		if(customLayoutRows == 2 && customLayoutColumns == 2){
    		return 2;
		} else {return %orig;}
	} else {
		return %orig;
	}
}

+ (CGSize)cellSpacing {
    CGSize orig = %orig;
	if(enabled && customLayoutEnabled){
		if(customLayoutRows == 2 && customLayoutColumns == 2){
    		return CGSizeMake(orig.width * 1.5, orig.height);
		} else {return orig;}
	} else {
		return orig;
	}
}

%end

%end

/////////////////////////////////////////////////////////

%group ios13

%hook SBHFloatyFolderVisualConfiguration

-(CGFloat)continuousCornerRadius {
	if(enabled && cornerRadiusEnabled) {
			return (cornerRadius);
		} else {
			return %orig;
		}
}

%end

%hook SBIconGridImage

//Here is just the way we resize the icon spacing in 2x2 mode, meaning it looks just like it should, and won't be excessively small

+ (CGSize)cellSpacing {
    CGSize orig = %orig;
    if(enabled && twoByTwoIconEnabled){	
		return CGSizeMake(orig.width * 1.5, orig.height);
	} else {return %orig;}
}
//////////
//This method used to be at leas 3 times the size. I've simplified it to this

+(id)gridImageForLayout:(id)arg1 previousGridImage:(id)arg2 previousGridCellIndexToUpdate:(unsigned long long)arg3 pool:(id)arg4 cellImageDrawBlock:(id)arg5 {
  //I figured out the hard way that this is in fact a class method, and not an instance method.
  //This means we can't use instance logic to save the individual icon cache. However, this makes it
  //even easier, because all we need to do is store the working original value in one variable!
  //It will save the preview of all folder icons! In one neat variable package!
  if (enabled) {
		@try{
			return %orig;
			lastIconSucess = %orig;
		} @catch (NSException *exception) {
			NSLog(@"[Folded]: The following exception was caught:%@", exception);
			return lastIconSucess;
		}
  } else {
	return %orig;
  }
}

///////////////////

%end

%hook _SBIconGridWrapperView

-(void)layoutSubviews {
    %orig;
    if(enabled && hideFolderGridEnabled){
		[self setHidden:true];
	}
	if(resizeFolderIconEnabled) {
		CGAffineTransform originalIconView = (self.transform);
		self.transform = CGAffineTransformMake(
			resizeFactor,
			originalIconView.b,
			originalIconView.c,
			resizeFactor,
			originalIconView.tx,
			originalIconView.ty
		);
	} else if((twoByTwoIconEnabled || (folderIconColumns==2 && folderIconRows==2))&& kCFCoreFoundationVersionNumber > 1600) {
		CGAffineTransform originalIconView = (self.transform);
		self.transform = CGAffineTransformMake(
			1.5,
			originalIconView.b,
			originalIconView.c,
			1.5,
			originalIconView.tx,
			originalIconView.ty
		);
	}
}

%end


%hook SBHFolderSettings

-(BOOL)pinchToClose { // enable pinch to close again

	if(enabled && pinchToCloseEnabled){
		return YES;
	} else {
		return NO;
	}
}

%end

%hook SBIconListFlowLayout

-(unsigned long long)maximumIconCount { //Yes. This damn method is what prevented the addition of icons beyond what the folder icon was.
										//That's because, like the folder icon SBIconListGridLayoutConfiguration, this cannot be dynamically
										//adjusted. So, I hook it initially to allow for the extra icons.
	unsigned long long original = %orig;

	if(enabled && customFolderIconEnabled && ((original==9) || (original==folderIconRows*folderIconColumns))) {
		return(customLayoutRows*customLayoutColumns); //allows a ton of icons :D
	} else {
		return %orig;
	}
}

%end


%hook SBFolder
//%property (nonatomic, assign) BOOL hasStoredLists;
//Originally I tried using a property, but for some reason there were new instances of SBFolder each time...

-(NSString *)displayName {
	NSString *name = %orig;
	BOOL isAlreadyStored = NO;
	NSUInteger indexToReplaceWithNew;
	for(int i=0; i<[foldersThatExist count]; i++) {
		if([[foldersThatExist objectAtIndex:i] isEqualToString:name]) {
			isAlreadyStored = YES;
			indexToReplaceWithNew = i;
		}
	}
	
	NSString *countOfIcons = [NSString stringWithFormat:@"%ld", (long)[self.icons count]];

	if(!isAlreadyStored) {
		[foldersThatExist addObject:name];
		[countOfIconsInFoldersThatExist addObject:countOfIcons];
	} else if(isAlreadyStored && !([[countOfIconsInFoldersThatExist objectAtIndex:indexToReplaceWithNew] isEqualToString:countOfIcons])) { 
		//Allows the updating of the icon count without respringing.
		[countOfIconsInFoldersThatExist replaceObjectAtIndex:indexToReplaceWithNew withObject:countOfIcons];
	}
	return name;
}

%end

//This part is crucial to my methods :devil_face:
%hook SBIconController

-(void)viewDidAppear:(BOOL)arg1 {
  %orig;

  hasProcessLaunched = YES;

  UIAlertController* blankIconAlert = [UIAlertController alertControllerWithTitle:@"Folded"
                               message:@"Folded has blanked out some folder icons due to you editing icons in a folder (respring to fix.) Please note Folded has prevented a crash that would have occured due to this."
                               preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction* dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault
   		handler:^(UIAlertAction * action) {}];

		[blankIconAlert addAction:dismiss];

  UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Folded"
                               message:@"Folded has failed to inject a custom folder icon layout. This is due to another tweak interfering with Folded, or due to you editing icons in a folder (respring to fix.) Please note Folded has prevented a crash that would have occured due to this."
                               preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault
   		handler:^(UIAlertAction * action) {}];

		[alert addAction:defaultAction];

  if (enabled && hasInjectionFailed && showInjectionAlerts && (!hasShownFailureAlert)) {
		[self presentViewController:alert animated:YES completion:nil];
	  hasShownFailureAlert = YES;
  }
  if(enabled && showInjectionAlerts && blankIconAlertShouldShow) {
	  [self presentViewController:blankIconAlert animated:YES completion:nil];
  }

}
%end

%hook SBIconListGridLayoutConfiguration
%property (nonatomic, assign) BOOL isFolder;

%new
-(BOOL)getLocations {

  NSUInteger locationColumns = MSHookIvar<NSUInteger>(self, "_numberOfPortraitColumns");
  NSUInteger locationRows = MSHookIvar<NSUInteger>(self, "_numberOfPortraitRows");
  if (locationColumns == 3 && locationRows == 3) {
    self.isFolder = YES;
  } else {
    self.isFolder = NO;
  }
  return self.isFolder;
}

-(NSUInteger)numberOfPortraitColumns {
  //I rewrote this so many times, and ended up with this insanley dumb and long, but rock solid method
  //DON'T QUESTION IT. JUST DON'T!
  [self getLocations];
    if (self.isFolder && enabled) {
		NSUInteger returnThis;
		if (customFolderIconEnabled && customLayoutEnabled) {
			if (hasProcessLaunched) { 
				returnThis = (customLayoutColumns);
			} else {
				@try {
					returnThis = (folderIconColumns);
				} @catch (NSException *exception) {
				returnThis = %orig;
				hasInjectionFailed = YES;
				}	
			}
		} else if(customLayoutEnabled && !customFolderIconEnabled) {
			returnThis = customLayoutColumns;
		} else if(!customLayoutEnabled && customFolderIconEnabled) {
			if (!hasProcessLaunched) {
				@try {
						returnThis = (folderIconColumns);
					} @catch (NSException *exception) {
					returnThis = %orig;
					hasInjectionFailed = YES;
					}
			}
		}
		if(returnThis>1) {
	 	    return returnThis;
		} else {return 3;}
  } else {
    return (%orig);
  }
}

-(NSUInteger)numberOfPortraitRows {
  [self getLocations];
    if (self.isFolder && enabled) {
		NSUInteger returnThis;
		if (customFolderIconEnabled && customLayoutEnabled) {
			if (hasProcessLaunched) { 
				returnThis = (customLayoutRows);
			} else {
				@try {
					returnThis = (folderIconRows);
				} @catch (NSException *exception) {
				returnThis = %orig;
				hasInjectionFailed = YES;
				}	
			}
		} else if(customLayoutEnabled && !customFolderIconEnabled) {
			returnThis = customLayoutRows;
		} else if(!customLayoutEnabled && customFolderIconEnabled) {
			if (!hasProcessLaunched) {
				@try {
						returnThis = (folderIconRows);
					} @catch (NSException *exception) {
					returnThis = %orig;
					hasInjectionFailed = YES;
					}
			}
		}
		if(returnThis>1) {
	 	    return returnThis;
		} else {return 3;}
  } else {
    return (%orig);
  }
}

- (UIEdgeInsets)portraitLayoutInsets {
	[self getLocations];
	if(self.isFolder && enabled && insetsEnabled) {
		return UIEdgeInsetsMake(topInset,
								sideInset,
								bottomInset,
								sideInset);
	} else {return %orig;}
}

%end

%end

%ctor
{
    preferencesChanged();

    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        &observer,
        (CFNotificationCallback)preferencesChanged,
        kSettingsChangedNotification,
        NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately
    );
	hasProcessLaunched = NO;
	hasInjectionFailed = NO;
    hasShownFailureAlert = NO;
	%init(universal);
	if(kCFCoreFoundationVersionNumber < 1600){
		%init(ios12);
	} else {
		%init(ios13);
	}
	NSLog(@"[Folded]: Tweak initialized.");
}


//Well, that's all for now, folks! It's been awesome working with Thomz, I hope to make more tweaks with him!
//yeet :)
//Ah, I see you're a man of culture as well.
