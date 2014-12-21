//
//  IMPDFDocument.h
//  InstaMed
//
//  Created by GAURAV SRIVASTAVA on 13/04/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSString *IMPDFDocumentFontName = @"IMPDFDocumentFontName";
static const NSString *IMPDFDocumentFontSize = @"IMPDFDocumentFontSize";
static const NSString *IMPDFDocumentFontColor = @"IMPDFDocumentFontColor";

@class IMPDFDocument;
@protocol IMPDFDocumentDelegate <NSObject>

@required
- (void)drawPDFTableHeaderInDocument:(IMPDFDocument *)document
                      withIdentifier:(NSString *)identifier
                             content:(id)content
                   contentAttributes:(NSDictionary *)contentAttributes
                         contentRect:(CGRect)contentRect
                            cellRect:(CGRect)cellRect;
- (void)drawPDFTableCellInDocument:(IMPDFDocument *)document
                    withIdentifier:(NSString *)identifier
                           content:(id)content
                 contentAttributes:(NSDictionary *)contentAttributes
                       contentRect:(CGRect)contentRect
                          cellRect:(CGRect)cellRect
                      cellPosition:(CGPoint)position;
- (NSDictionary *)attributesForPDFCellInDocument:(IMPDFDocument *)document
                                  withIdentifier:(NSString *)identifier
                                        rowIndex:(NSInteger)rowIndex
                                     columnIndex:(NSInteger)columnIndex;

@end

@interface IMPDFDocument : NSObject
@property (nonatomic, assign) id<IMPDFDocumentDelegate> delegate;
@property (nonatomic, strong) NSMutableData *data;

@property (nonatomic, assign) CGRect pageFrame;
@property (nonatomic, assign) CGRect contentFrame;
@property (nonatomic, assign) CGFloat currentY;
@property (nonatomic, assign) NSInteger pageCount;

// Logic
- (void)close;
- (void)createNewPage;

// Drawing
- (void)drawImage:(UIImage *)image
       atPosition:(CGPoint)position;
- (void)drawTableWithRows:(NSArray *)rows
               andColumns:(NSArray *)columns
               atPosition:(CGPoint)position
                    width:(CGFloat)tableWidth
               identifier:(NSString *)identifier;
- (void)drawText:(NSString *)string
      atPosition:(CGPoint)position
        withFont:(UIFont *)font;
- (void)drawText:(NSString *)string
          inRect:(CGRect)rect
        withFont:(UIFont *)font
       alignment:(NSTextAlignment)alignment
   lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
