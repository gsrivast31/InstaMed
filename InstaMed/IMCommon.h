//
//  IMCommon.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 12/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//
#import "NSString+Extension.h"
#import "NSDate+Extension.h"

#import "IMUI.h"
#import "IMBaseObject.h"
#import "IMCoreDataStack.h"
#import "IMCredentials.h"

#ifndef InstaMed_UACommon_h
#define InstaMed_UACommon_h

#define kDefaultBarTintColor [UIColor whiteColor];
#define kDefaultTintColor [UIColor colorWithRed:0.0f green:192.0f/255.0f blue:180.0f/255.0f alpha:1.0f];

// Macros
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

// Enums
enum TimeOfDay {
    Morning = 0,
    Afternoon = 1,
    Evening = 2
};

enum BGTrackingUnit {
    BGTrackingUnitMG = 0,
    BGTrackingUnitMMO = 1
};

enum {
    Everyday = 1,
    Monday = 2,
    Tuesday = 4,
    Wednesday = 8,
    Thursday = 16,
    Friday = 32,
    Saturday = 64,
    Sunday = 128
};

enum BackupFrequency {
    BackupOnClose = 0,
    BackupOnceADay = 86400, // 24 hours in seconds
    BackupOnceAWeek = 604800 // 1 week in seconds
};

typedef enum _EventFilterType {
    MedicineFilterType = 1,
    ReadingFilterType = 2,
    MealFilterType = 4,
    SnackFilterType = 8,
    ActivityFilterType = 16,
    NoteFilterType = 32
} EventFilterType;

NS_ENUM(int16_t, IMEventType) {
    IMMedicineType = 0,
    IMReadingType = 1,
    IMFoodType = 2,
    IMActivityType = 3,
    IMNoteType = 4,
    IMNoneType = 5
};

// Constants
static NSString * const kErrorDomain = @"com.memoir.instamed";

// Notifications
static NSString * const kRemindersUpdatedNotification = @"com.memoir.reminders.updated";
static NSString * const kSettingsChangedNotification = @"com.memoir.settings.change";
static NSString * const kDropboxLinkNotification = @"com.memoir.dropbox.linked";
static NSString * const kCurrentProfileChangedNotification = @"com.memoir.currentprofile.change";
// NSUserDefault keys
static NSString * const kHasRunBeforeKey = @"kHasRunBefore";
static NSString * const kUseSmartInputKey = @"kUseSmartInputKey";
static NSString * const kHasSeenStarterTooltip = @"kHasSeenStarterTooltip";
static NSString * const kHasSeenReminderTooltip = @"kHasSeenReminderTooltip";
static NSString * const kHasSeenExportTooltip = @"kHasSeenExportTooltip";
static NSString * const kHasSeenAddDragUIHint = @"kHasSeenAddDragUIHint";
static NSString * const kHasSeenInsulinCalculatorTooltip = @"kHasSeenInsulinCalculatorTooltip";
static NSString * const kFilterSearchResultsKey = @"kFilterSearchResultsKey";
static NSString * const kReportsDefaultKey = @"kReportsDefaultKey";
static NSString * const kShowInlineImages = @"kShowInlineImages";
static NSString * const kAutomaticallyGeotagEvents = @"kAutomaticallyGeotagEvents";

static NSString * const kMinHealthyBGKey = @"kMinHealthyBGKey";
static NSString * const kMaxHealthyBGKey = @"kMaxHealthyBGKey";
static NSString * const kBGTrackingUnitKey = @"kBGTrackingUnit";
static NSString * const kTargetBGKey = @"kTargetBGKey";
static NSString * const kCarbohydrateRatioKey = @"kCarbohydrateRatioKey";
static NSString * const kCorrectiveFactorKey = @"kCorrectiveFactorKey";

static NSString * const kCurrentProfileKey = @"kCurrentProfileKey";

#endif
