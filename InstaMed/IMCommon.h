//
//  IMCommon.h
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 12/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//
#import "NSString+Extension.h"
#import "NSDate+Extension.h"

#import "IMUI.h"
#import "IMBaseObject.h"
#import "IMCoreDataStack.h"

#ifndef HealthMemoir_UACommon_h
#define HealthMemoir_UACommon_h

#define kDefaultBarTintColor [UIColor colorWithRed:0/255.0 green:213/255.0 blue:161/255.0 alpha:1];
#define kDefaultTintColor [UIColor whiteColor];

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

enum ChTrackingUnit {
    ChTrackingUnitMG = 0,
    ChTrackingUnitMMO = 1
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
    BGReadingFilterType = 2,
    BPReadingFilterType = 4,
    CholesterolReadingFilterType = 8,
    WeightReadingFilterType = 16,
    MealFilterType = 32,
    SnackFilterType = 64,
    ActivityFilterType = 128,
    NoteFilterType = 256
} EventFilterType;

NS_ENUM(int16_t, IMEventType) {
    IMMedicineType = 0,
    IMBGReadingType = 1,
    IMBPReadingType = 2,
    IMCholesterolType = 3,
    IMWeightType = 4,
    IMFoodType = 5,
    IMActivityType = 6,
    IMNoteType = 7,
    IMNoneType = 8
};

// Constants
static NSString * const kErrorDomain = @"com.memoir.HealthMemoir";

// Notifications
static NSString * const kRemindersUpdatedNotification = @"com.memoir.reminders.updated";
static NSString * const kSettingsChangedNotification = @"com.memoir.settings.change";
static NSString * const kExportReportNotification = @"com.memoir.export.report";
static NSString * const kCurrentProfileChangedNotification = @"com.memoir.currentprofile.change";
static NSString * const kEntryAddUpdateNotification = @"com.memoir.entry.addedit";

// NSUserDefault keys
static NSString * const kHasRunBeforeKey = @"kHasRunBefore";
static NSString * const kUseSmartInputKey = @"kUseSmartInputKey";
static NSString * const kHasSeenAddDragUIHint = @"kHasSeenAddDragUIHint";
static NSString * const kFilterSearchResultsKey = @"kFilterSearchResultsKey";
static NSString * const kReportsDefaultKey = @"kReportsDefaultKey";
static NSString * const kShowInlineImages = @"kShowInlineImages";
static NSString * const kAutomaticallyGeotagEvents = @"kAutomaticallyGeotagEvents";

static NSString * const kMinHealthyBGKey = @"kMinHealthyBGKey";
static NSString * const kMaxHealthyBGKey = @"kMaxHealthyBGKey";
static NSString * const kBGTrackingUnitKey = @"kBGTrackingUnit";
static NSString * const kTargetBGKey = @"kTargetBGKey";

static NSString * const kMinHealthyChKey = @"kMinHealthyChKey";
static NSString * const kMaxHealthyChKey = @"kMaxHealthyChKey";
static NSString * const kChTrackingUnitKey = @"kChTrackingUnit";

static NSString * const kMinHealthyBPKey = @"kMinHealthyBPKey";
static NSString * const kMaxHealthyBPKey = @"kMaxHealthyBPKey";

static NSString * const kTargetWeightKey = @"kTargetWeightKey";

static NSString * const kCarbohydrateRatioKey = @"kCarbohydrateRatioKey";
static NSString * const kCorrectiveFactorKey = @"kCorrectiveFactorKey";

static NSString * const kCurrentProfileKey = @"kCurrentProfileKey";
static NSString * const kCurrentProfileName = @"kCurrentProfileName";

static NSString * const kCurrentProfileTrackingDiabetesKey = @"kCurrentProfileTrackingDiabetesKey";
static NSString * const kCurrentProfileTrackingCholesterolKey = @"kCurrentProfileTrackingCholesterolKey";
static NSString * const kCurrentProfileTrackingBPKey = @"kCurrentProfileTrackingBPKey";
static NSString * const kCurrentProfileTrackingWeightKey = @"kCurrentProfileTrackingWeightKey";

// Data Keys
static NSString *const kMinDateKey = @"min_date";
static NSString *const kMaxDateKey = @"max_date";
static NSString *const kTotalGramsKey = @"total_grams";
static NSString *const kTotalMinutesKey = @"total_minutes";
static NSString *const kBGReadingsDeviationKey = @"readings_bg_deviation";
static NSString *const kBGReadingsAverageKey = @"readings_bg_avg";
static NSString *const kBGReadingsTotalKey = @"total_bg_readings";
static NSString *const kBGReadingLowestKey = @"lowest_bg_reading";
static NSString *const kBGReadingHighestKey = @"highest_bg_reading";
static NSString *const kChReadingsDeviationKey = @"readings_ch_deviation";
static NSString *const kChReadingsAverageKey = @"readings_ch_avg";
static NSString *const kChReadingsTotalKey = @"total_ch_readings";
static NSString *const kChReadingLowestKey = @"lowest_ch_reading";
static NSString *const kChReadingHighestKey = @"highest_ch_reading";
static NSString *const kBPReadingLowestKey = @"lowest_bp_reading";
static NSString *const kBPReadingHighestKey = @"highest_bp_reading";
static NSString *const kWtReadingLowestKey = @"lowest_wt_reading";
static NSString *const kWtReadingHighestKey = @"highest_wt_reading";
static NSString *const kEventsKey = @"events";

#endif
