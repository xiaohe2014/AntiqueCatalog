//
//  ReadingViewController.h
//  AntiqueCatalog
//
//  Created by Cangmin on 16/1/16.
//  Copyright © 2016年 Cangmin. All rights reserved.
//

#import "BaseViewController.h"
#import "catalogdetailsdata.h"
@interface ReadingViewController : BaseViewController

@property (nonatomic,copy)NSString *ID;
@property (nonatomic,strong)catalogdetailsdata * catalogdetailsData;
@end
