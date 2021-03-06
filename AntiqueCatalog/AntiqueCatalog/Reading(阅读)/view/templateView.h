//
//  templateView.h
//  AntiqueCatalog
//
//  Created by Cangmin on 16/1/21.
//  Copyright © 2016年 Cangmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol templateViewDelegate <NSObject>

@optional
- (void)handTapVeiw:(UITapGestureRecognizer *)tap;

@end

@interface templateView : UIView

@property (nonatomic, assign)BOOL isNigth;
@property (nonatomic, assign) CGFloat fontInt;
@property (nonatomic,assign) CGFloat titlFontInt;
@property (nonatomic, strong) UITextView * contentTextView;
@property (nonatomic, strong) UITextView * headTextView;


@property (nonatomic,strong)NSMutableArray *dataarray;
@property (nonatomic,strong)NSArray * imagtDataArray;
@property (nonatomic,strong) NSString * readPath;
@property (nonatomic,assign)id <templateViewDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame andWithmutbleArray:(NSMutableArray *)array withImagePatjh:(NSString*)imagePath;
- (instancetype)initWithFrame:(CGRect)frame andWithmutbleArray:(NSMutableArray *)array withContentFont:(CGFloat)contentfont withTitlFont:(CGFloat)titlFont;

- (void)goNumberofpages:(NSString *)string;

-(void)reloadData;

@end
