@interface SBDeviceLockController
+(id)sharedController;
-(BOOL)attemptDeviceUnlockWithPassword:(NSString *)passcode appRequested:(BOOL)requested;
@end

NSString* passcode;
BOOL hasCachedPasscode;
BOOL isParanoiaUnlock;

%hook SBDeviceLockController

- (BOOL)attemptDeviceUnlockWithPassword:(NSString *)pass appRequested:(BOOL)requested {
	BOOL r = %orig;
	//if (isParanoiaUnlock) return %orig(passcode, nil);
	if (!hasCachedPasscode || !passcode || isParanoiaUnlock) {
		if (r) {
			passcode = pass;
			if (passcode) {
				hasCachedPasscode = YES;
			}
		}
		return r;
	}
	return NO;
}

%end

%hook TPNumberPad

- (id)initWithButtons:(NSArray *)arg1 {
	id r = %orig;
	isParanoiaUnlock = NO;
	if (r) {
		if (hasCachedPasscode) {
			for (UIView* button in arg1) {
				UILongPressGestureRecognizer* holdGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(unlock)];
				holdGestureRecognizer.numberOfTouchesRequired = 1;
				holdGestureRecognizer.numberOfTapsRequired = 1;
				//stupid sexy view heirarchy
				[[button superview] addGestureRecognizer:holdGestureRecognizer];
			}
		}
	}
	return r;
}

%new
-(void)unlock {
	isParanoiaUnlock = YES;
	NSLog(@"[Paranoia] %i", [[%c(SBDeviceLockController) sharedController] attemptDeviceUnlockWithPassword:passcode appRequested:nil]);
}

%end

%hook SBUIPasscodeLockViewWithKeypad
- (id)statusTitleView {
	if (!hasCachedPasscode || !passcode) {
		UILabel *label = MSHookIvar<UILabel *>(self, "_statusTitleView");
		label.text = @"Enter passcode before using Paranoia";
	}
    return %orig;
}
%end