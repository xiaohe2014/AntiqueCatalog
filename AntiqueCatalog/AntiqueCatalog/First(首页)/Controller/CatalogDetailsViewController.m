//
//  CatalogDetailsViewController.m
//  AntiqueCatalog
//
//  Created by Cangmin on 16/1/8.
//  Copyright © 2016年 Cangmin. All rights reserved.
//

#import "CatalogDetailsViewController.h"

#import "catalogdetailsdata.h"
#import "commentData.h"
#import "catalogdetailsTableViewCell.h"
#import "CatalogIntroduceTableViewCell.h"
#import "catalogdetailsTagTableViewCell.h"
#import "catalogdetailsUserTableViewCell.h"
#import "catalogCommentTableViewCell.h"
#import "catalogMoreTableViewCell.h"

#import "ReadingViewController.h"
#import "CatalogGetListViewController.h"
#import "TagViewController.h"

#import "CommenListViewController.h"
#import "CommenListViewController2.h"
#import "UserSpaceViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "AFHTTPRequestOperation.h"
#import "FMDB.h"
#import "MF_Base64Additions.h"
#import "FileModel.h"
#import "DownFileMannger.h"
#import "LoginViewController.h"
#import "RegistrationPageViewController.h"

@interface CatalogDetailsViewController ()<UITableViewDataSource,UITableViewDelegate,CatalogIntroduceTableViewCellDelegate,catalogdetailsUserTableViewCellDelegate,catalogMoreTableViewCellDelegate,catalogdetailsTableViewCellDelegate,catalogdetailsTagTableViewCellDelegate,catalogCommentTableViewCellDelegate>{
    FMDatabase *db;
    NSMutableDictionary *dicOperation;
    NSOperationQueue *operationQueue;
    NSInteger downImageCount;
}

@property (nonatomic,strong)catalogdetailsdata *catalogdetailsData;
@property (nonatomic,strong)NSMutableArray *commentArray;
@property (nonatomic,strong)NSMutableArray *commentCellArray;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,assign)BOOL isOpen;
@property (nonatomic, assign) NSInteger ImageCount;
@property (nonatomic, strong) NSMutableArray * childImageArray;
@property (nonatomic, strong) NSMutableArray * countImageArray;
@property (nonatomic,strong) NSMutableArray * queueArray;

@end

@implementation CatalogDetailsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [db open];
    
    FMResultSet * rs = [Api queryTableIsOrNotInTheDatebaseWithDatabase:db AndTableName:TABLE_ACCOUNTINFOS];
    if(![rs next]){
        NSString *sqlCreateTable =  [Api creatTable_TeacherAccountSq];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating TABLE_ACCOUNTINFOS");
        } else {
            NSLog(@"success to creating TABLE_ACCOUNTINFOS");
        }
        
    }else{
        
    }
    
    FMResultSet * resOne = [Api queryTableIsOrNotInTheDatebaseWithDatabase:db AndTableName:DOWNTABLE_NAME];
    if(![resOne next]){
        NSString *sqlCreateTableOne =  [Api creatTable_DownAccountSq];
        BOOL resone = [db executeUpdate:sqlCreateTableOne];
        if (!resone) {
            NSLog(@"error when creating DOWNTABLE_NAME");
        } else {
            NSLog(@"success to creating DOWNTABLE_NAME");
        }
        
    }else{
        
    }
    
    [db close];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
//    [db close];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.queueArray = [NSMutableArray array];
   operationQueue = [[NSOperationQueue alloc] init];
    
    [operationQueue setMaxConcurrentOperationCount:1];
    
    self.childImageArray = [NSMutableArray array];
    self.countImageArray = [NSMutableArray array];
    db = [Api initTheFMDatabase];
//    [db open];
    
    dicOperation = [[NSMutableDictionary alloc]init];

    self.titleLabel.text = @"图录详情";
    [self.rightButton setTitle:@"目录" forState:UIControlStateNormal];
    [self.rightButton setTitleColor:Blue_color forState:UIControlStateNormal];
    
    _isOpen = NO;
    _commentArray = [[NSMutableArray alloc]init];
    _commentCellArray = [[NSMutableArray alloc]init];
    
    
    [self CreatUI];
    [self loaddata];
    // Do any additional setup after loading the view.
}
-(void)rightButtonClick:(id)sender{
    CatalogGetListViewController *cataloggetlist = [[CatalogGetListViewController alloc]init];
    cataloggetlist.ID = _ID;
    [self.navigationController pushViewController:cataloggetlist animated:YES];
}
- (void)CreatUI{
    
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, UI_SCREEN_WIDTH, UI_SCREEN_SHOW) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsHorizontalScrollIndicator=NO;
    _tableView.showsVerticalScrollIndicator=NO;
    _tableView.allowsMultipleSelection = NO;
    _tableView.backgroundColor = [UIColor colorWithConvertString:Background_Color];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];

}

- (void)loaddata{
    
    NSDictionary *prams = [NSDictionary dictionary];
    prams = @{@"id":_ID};
    [Api requestWithbool:YES withMethod:@"get" withPath:API_URL_Catalog_getCatalog withParams:prams withSuccess:^(id responseObject) {
        if (DIC_NOT_EMPTY(responseObject)) {
            _catalogdetailsData = [catalogdetailsdata WithcatalogdetailsdataDataDic:responseObject];
            if (ARRAY_NOT_EMPTY(_catalogdetailsData.comment)) {
                for (NSDictionary *dic in _catalogdetailsData.comment) {
                    commentData *commentdata = [commentData WithcommentDataDic:dic];
                    [_commentArray addObject:commentdata];
                    catalogCommentTableViewCell *commentcell = [[catalogCommentTableViewCell alloc]init];
                    [_commentCellArray addObject:commentcell];
                }
            }
            
        }
        [_tableView reloadData];
        
        
    } withError:^(NSError *error) {
        
    }];
    
    
       
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];// 响应
//    NSString *urlstr = [NSString stringWithFormat:@"%@/%@&id=%@&&oauth_token=%@&oauth_token_secret=%@",HEADURL,API_URL_Catalog_getCatalog,_ID,Oauth_token,Oauth_token_secret];
//    NSURL *url = [NSURL URLWithString:urlstr];
//    
//    [manager GET:url.absoluteString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
////        NSLog(@"JSON: %@", responseObject);
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
//        if (DIC_NOT_EMPTY(dic)) {
//            _catalogdetailsData = [catalogdetailsdata WithcatalogdetailsdataDataDic:dic];
//            if (ARRAY_NOT_EMPTY(_catalogdetailsData.comment)) {
//                for (NSDictionary *dic in _catalogdetailsData.comment) {
//                    commentData *commentdata = [commentData WithcommentDataDic:dic];
//                    [_commentArray addObject:commentdata];
//                    catalogCommentTableViewCell *commentcell = [[catalogCommentTableViewCell alloc]init];
//                    [_commentCellArray addObject:commentcell];
//                }
//            }
//            
//        }
//        [_tableView reloadData];
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
    
    
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            if (ARRAY_NOT_EMPTY(_catalogdetailsData.tag)) {
                return 4;
            }else{
                return 3;
            }
        }
            
            break;
        case 1:
        {
            if (ARRAY_NOT_EMPTY(_catalogdetailsData.comment)) {
                return _catalogdetailsData.comment.count;
            }else{
                return 0;
            }
        }
            break;
        case 2:
        {
            return 2;
        }
            break;
            
        default:
            break;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0) {
        static NSString *identifier = @"celldetails";
        catalogdetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[catalogdetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell initSubView];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.catalogdetailsData = _catalogdetailsData;
        cell.delegate = self;
        return cell;
    }else if (indexPath.row == 1 && indexPath.section == 0){
        static NSString *identifier = @"cellIntroduce";
        CatalogIntroduceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[CatalogIntroduceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
//        cell.backgroundColor = [UIColor redColor];
        [cell updateCellWithData:_catalogdetailsData andmore:_isOpen andIndexPath:indexPath];
        return cell;
        
    }else if (indexPath.row == 2 && indexPath.section == 0) {
        if (ARRAY_NOT_EMPTY(_catalogdetailsData.tag)) {
            static NSString *identifier = @"celltag";
            catalogdetailsTagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[catalogdetailsTagTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            cell.catalogdetailsData = _catalogdetailsData;
            return cell;
        }else{
            static NSString *identifier = @"celluser";
            catalogdetailsUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[catalogdetailsUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell loadCatalogdetailsData:_catalogdetailsData andindexPath:indexPath];
            cell.delegate = self;
            return cell;

        }
        
    }else if (indexPath.row == 3 && indexPath.section == 0 && ARRAY_NOT_EMPTY(_catalogdetailsData.tag)){
        static NSString *identifier = @"celluser";
        catalogdetailsUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[catalogdetailsUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell loadCatalogdetailsData:_catalogdetailsData andindexPath:indexPath];
        cell.delegate = self;
        return cell;
        
    }else if (indexPath.section == 1){
        if (ARRAY_NOT_EMPTY(_catalogdetailsData.comment)) {
            /*
            if (indexPath.row < _commentArray.count) {
                static NSString *identifier = @"cellcomment";
                catalogCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                if (!cell) {
                    cell = [[catalogCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.delegate = self;
                [cell loadWithCommentArray:_commentArray[indexPath.row] andWithIndexPath:indexPath];
                return cell;
            }else{
                static NSString *identifier = @"cell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"查看更多";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.font = [UIFont systemFontOfSize:Nav_title_font];
                return cell;
                
            }
            */
            static NSString *identifier = @"cellcomment";
            catalogCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[catalogCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            [cell loadWithCommentArray:_commentArray[indexPath.row] andWithIndexPath:indexPath];
            return cell;
        }
        
    }else if (indexPath.section == 2){
        
        static NSString *identifier = @"cellmore";
        catalogMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[catalogMoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        switch (indexPath.row) {
            case 0:
            {
                if([_catalogdetailsData isEqual:[NSNull null]] || _catalogdetailsData == NULL){
                    [cell loadWithstring:[NSString stringWithFormat:@""] andWitharray:_catalogdetailsData.userInfo_moreCatalog andWithIndexPath:indexPath];

                }else{
                    if ([_catalogdetailsData.author isEqual:[NSNull null]] || [_catalogdetailsData.author isEqualToString:@""] || _catalogdetailsData.author.length == 0) {
                        [cell loadWithstring:@"其他图录" andWitharray:_catalogdetailsData.userInfo_moreCatalog andWithIndexPath:indexPath];

                    }else{
//                        if ([_catalogdetailsData.author ]) {
//                            <#statements#>
//                        }
//                        NSLog(@"rrrrrrrrrr:%@  %d",_catalogdetailsData.author,_catalogdetailsData.author.length);
                        if (![_catalogdetailsData.author isEqualToString:@"<null>"]) {
                            [cell loadWithstring:[NSString stringWithFormat:@"%@的其他图录",_catalogdetailsData.author] andWitharray:_catalogdetailsData.userInfo_moreCatalog andWithIndexPath:indexPath];

                        }else{
                            [cell loadWithstring:@"其他图录" andWitharray:_catalogdetailsData.userInfo_moreCatalog andWithIndexPath:indexPath];

                        }

                    }

                }
            }
                break;
            case 1:
            {
                [cell loadWithstring:@"你可能感兴趣的图录" andWitharray:_catalogdetailsData.moreCatalog andWithIndexPath:indexPath];
            }
                break;
                
            default:
                break;
        }
        return cell;
    }
    
    return nil;
    
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    //return 40+116+40+40+16+1;
                    return 40+116+60+60+40+16+1;
                }
                    break;
                case 1:
                {
                    UILabel *lable = [[UILabel alloc]init];
                    CGSize infosize = [Allview String:_catalogdetailsData.info Withfont:Catalog_Cell_info_Font WithCGSize:UI_SCREEN_WIDTH - 64 Withview:lable Withinteger:0];
                    if ([_catalogdetailsData.type isEqualToString:@"0"]) {
                        
                        if (_isOpen) {
                            return 16+15*4+5*4+infosize.height+30;
                            
                        }else{
                            if (infosize.height > 156.0f) {
                                return 16+15*4+5*4+156.0+30;
                            }else{
                                return 16+15*4+5*4+infosize.height+10;
                            }
                        }
                        
                    }else{
                        
//                        if (_isOpen) {
//                            
//                            return 16+infosize.height+30;
//                            
//                        }else{
//                            if (infosize.height > 35.0f) {
//                                return 16+35+30;
//                            }else{
//                                return 16+infosize.height+10;
//                            }
//                        }
                        if (_isOpen) {
                            
                            return 16+infosize.height+30;
                            
                        }else{
                            if (infosize.height > 156.0f) {
                                return 16+156+30;
                            }else{
                                return 16+infosize.height+10;
                            }
                        }

                        
                        
                    }
                }
                    break;
                case 2:
                {
                    if (ARRAY_NOT_EMPTY(_catalogdetailsData.tag)) {
                        return 50 + 30 + 10;
                    }else{
                        return 64 + 1 + 1;
                    }
                    
                }
                    break;
                case 3:
                {
                    return 64 + 10 + 10;
                }
                    break;
                    
                default:
                    break;
            }

        }
            break;
        case 1:
        {
            if (ARRAY_NOT_EMPTY(_catalogdetailsData.comment)) {
                if (indexPath.row < _commentArray.count) {
                    catalogCommentTableViewCell *commenttableviewcell = _commentCellArray[indexPath.row];
                    [commenttableviewcell loadWithCommentArray:_commentArray[indexPath.row] andWithIndexPath:indexPath];
                    return commenttableviewcell.height;
                }else{
                    return 30.f;
                }
                
            }else{
                
                return 56;
            }
        }
            break;
         
        case 2:
        {
            return 20+30+116+12+25+20;
        }
            break;
            
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (section == 1) {
        if (_catalogdetailsData.comment.count) {
            return 32.f;
        }else{
            //return 56.f;
            return 0.0f;
        }
    }
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 1 && _commentArray.count>=3){
        return 32.f;
    }else{
        return 0.0f;
    }
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        /*
        if (!ARRAY_NOT_EMPTY(_catalogdetailsData.comment)) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 10, UI_SCREEN_WIDTH, 56)];
            view.backgroundColor = White_Color;
            UILabel *label = [Allview Withstring:@"精彩评论" Withcolor:Deputy_Colour Withbgcolor:Clear_Color Withfont:Catalog_Cell_info_Font WithLineBreakMode:1 WithTextAlignment:NSTextAlignmentLeft];
            label.frame = CGRectMake(16, 0, UI_SCREEN_WIDTH - 32, 24);
            UILabel *commentlabel = [Allview Withstring:@"点击发布第一条评论" Withcolor:Blue_color Withbgcolor:Clear_Color Withfont:Catalog_Cell_uname_Font WithLineBreakMode:1 WithTextAlignment:NSTextAlignmentLeft];
            commentlabel.frame = CGRectMake(16, CGRectGetMaxY(label.frame), UI_SCREEN_WIDTH - 32, 32);
            commentlabel.tag = 1;
            [view addSubview:label];
            [view addSubview:commentlabel];
            
            //开启交互功能
            commentlabel.userInteractionEnabled = YES;
            
            
            //添加点击动作
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
            tap.numberOfTouchesRequired = 1;
            tap.numberOfTapsRequired = 1;
            [commentlabel addGestureRecognizer:tap];
            
            return view;
        }else{
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 32)];
            view.backgroundColor = White_Color;
            UILabel *label = [Allview Withstring:@"精彩评论" Withcolor:Deputy_Colour Withbgcolor:Clear_Color Withfont:Catalog_Cell_info_Font WithLineBreakMode:1 WithTextAlignment:NSTextAlignmentLeft];
            label.frame = CGRectMake(16, 0, UI_SCREEN_WIDTH - 32, 32);
            [view addSubview:label];
            return view;
        }
         */
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 32)];
        view.backgroundColor = White_Color;
        UILabel *label = [Allview Withstring:@"精彩评论" Withcolor:Deputy_Colour Withbgcolor:Clear_Color Withfont:Catalog_Cell_info_Font WithLineBreakMode:1 WithTextAlignment:NSTextAlignmentLeft];
        label.frame = CGRectMake(16, 0, UI_SCREEN_WIDTH - 32, 32);
        [view addSubview:label];
        return view;
    }
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(section == 1 && _commentArray.count >= 3){
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 32)];
        view.backgroundColor = White_Color;
        UILabel *label = [Allview Withstring:@"查看全部评论" Withcolor:Deputy_Colour Withbgcolor:Clear_Color Withfont:Catalog_Cell_info_Font WithLineBreakMode:1 WithTextAlignment:NSTextAlignmentLeft];
        label.frame = CGRectMake(16, 0, UI_SCREEN_WIDTH - 32, 32);
        [view addSubview:label];
        UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = view.bounds;
        [button addTarget:self action:@selector(lookAll:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        return view;
    }else{
        return nil;
    }
}

-(void)lookAll:(UIButton*)sender{
    NSLog(@"查看全部评论");
    [self centerViewDidClick];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"我点击了查看更多");
    if(indexPath.section == 1){
        if([UserModel checkLogin]){
            commentData * item = _commentArray[indexPath.row];
            CommenListViewController2 * commenlist = [[CommenListViewController2 alloc]init];
            commenlist.ID = _ID;
            commenlist.ID2 = item.ID;
            [self.navigationController pushViewController:commenlist animated:YES];
        }else{
            [self showHudInView:self.view showHint:@"请先登陆"];
            [self performSelector:@selector(goLogin) withObject:self afterDelay:1];
        }

    }
    
    /*
    if ( _catalogdetailsData.author.length == 0) {
        _catalogdetailsData.author = [NSString stringWithFormat:@"%@",self.catalogData.uname];

    }
    commenlist.catalogData = _catalogdetailsData;
    */
}

#pragma mark-catalogCommentTableViewCellDelegate
-(void)hanisdigg:(NSIndexPath *)indexPath
{
    NSLog(@"%ld",(long)indexPath.row);
    NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
    NSDictionary *param = [NSDictionary dictionary];
    NSString *isdiggurl;
    commentData *commentdata = [_commentArray objectAtIndex:indexPath.row];
    if (commentdata.is_digg) {
        param = @{@"comment_id":commentdata.ID};
        isdiggurl = API_URL_Catalog_undiggComment;
    }else{
        param = @{@"comment_id":commentdata.ID};
        isdiggurl = API_URL_Catalog_diggComment;
    }
    
    [Api requestWithbool:YES withMethod:@"get" withPath:isdiggurl withParams:param withSuccess:^(id responseObject) {
        if ([[responseObject objectForKey:@"status"] integerValue] == 1) {
            
            if (commentdata.is_digg) {
                commentdata.is_digg = NO;
                NSInteger commentcount = [commentdata.digg_count integerValue];
                commentdata.digg_count = [NSString stringWithFormat:@"%ld",commentcount-1];
            }else{
                commentdata.is_digg = YES;
                NSInteger commentcount = [commentdata.digg_count integerValue];
                commentdata.digg_count = [NSString stringWithFormat:@"%ld",commentcount+1];
            }
            [_commentArray removeObjectAtIndex:indexPath.row];
            [_commentArray insertObject:commentdata atIndex:indexPath.row];
            
            [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }

        
    } withError:^(NSError *error) {
        NSLog(@"%@",error);
        
    }];
    
    
}

#pragma mark-CatalogIntroduceTableViewCellDelegate
- (void)han:(BOOL)more andIndexPath:(NSIndexPath *)indexPath{
    
    _isOpen = !_isOpen;
    NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
    [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}
#pragma mark-catalogdetailsUserTableViewCellDelegate
-(void)follow:(catalogdetailsdata *)catalogdetailsData andIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];

    NSDictionary *param = [NSDictionary dictionary];
    NSString *followurl;
    if (_catalogdetailsData.userInfo_following) {
        param = @{@"user_id":_catalogdetailsData.userInfo_uid};
        followurl = API_URL_USER_UNFollow;
    }else{
        param = @{@"user_id":_catalogdetailsData.userInfo_uid};
        followurl = API_URL_USER_Follow;
    }
    [Api requestWithbool:YES withMethod:@"get" withPath:followurl withParams:param withSuccess:^(id responseObject) {
        
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"status"] integerValue] == 1) {
            if (!_catalogdetailsData.userInfo_following) {
                _catalogdetailsData.userInfo_following = YES;
            }else{
                _catalogdetailsData.userInfo_following = NO;
                
            }
            [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];

        }
        
    } withError:^(NSError *error) {
        
//        NSLog(@"%@",error);
        
    }];
    
}

- (void)hanheadImage{
    
    UserSpaceViewController *userspaceVC = [[UserSpaceViewController alloc]init];
    userspaceVC.uid = _catalogdetailsData.userInfo_uid;
    [self.navigationController pushViewController:userspaceVC animated:YES];
    
}

#pragma mark - 精彩评论
-(void)handleTap:(UITapGestureRecognizer *)recognizer{
    
    CommenListViewController *commenlist = [[CommenListViewController alloc]init];
    commenlist.ID = _ID;
    if ( _catalogdetailsData.author.length == 0) {
        _catalogdetailsData.author = [NSString stringWithFormat:@"%@",self.catalogData.uname];
        
    }
    commenlist.catalogData = _catalogdetailsData;
    [self.navigationController pushViewController:commenlist animated:YES];
            
}

#pragma mark - 阅读按钮点击delegate
- (void)readingButtonDidClick{
    
    ReadingViewController *readingVC = [[ReadingViewController alloc]init];
    readingVC.catalogdetailsData = _catalogdetailsData;
    readingVC.ID = _ID;
    [self.navigationController pushViewController:readingVC animated:YES];
    
}

/**
 *  @author Jakey
 *
 *  @brief  下载文件
 *
 *  @param paramDic   附加post参数
 *  @param requestURL 请求地址
 *  @param savedPath  保存 在磁盘的位置
 *  @param success    下载成功回调
 *  @param failure    下载失败回调
 *  @param progress   实时下载进度回调
 */
- (void)downloadFileWithOption:(NSDictionary *)paramDic
                 withInferface:(NSString*)requestURL
                     savedPath:(NSString*)savedPath
               downloadSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               downloadFailure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
                      progress:(void (^)(float progress))progress

{
    
    //沙盒路径    //NSString *savedPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/xxx.zip"];
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request =[serializer requestWithMethod:@"POST" URLString:requestURL parameters:paramDic error:nil];
    
    //以下是手动创建request方法 AFQueryStringFromParametersWithEncoding有时候会保存
    //    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
    //   NSMutableURLRequest *request =[[[AFHTTPRequestOperationManager manager]requestSerializer]requestWithMethod:@"POST" URLString:requestURL parameters:paramaterDic error:nil];
    //
    //    NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    //
    //    [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
    //    [request setHTTPMethod:@"POST"];
    //
    //    [request setHTTPBody:[AFQueryStringFromParametersWithEncoding(paramaterDic, NSASCIIStringEncoding) dataUsingEncoding:NSUTF8StringEncoding]];
//    ASIHTTPRequesˆt *request = [[ASIHTTPRequest alloc] initWithURL:url];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:savedPath append:NO]];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float p = (float)totalBytesRead / totalBytesExpectedToRead;
        progress(p);
        NSLog(@"download：%f", (float)totalBytesRead / totalBytesExpectedToRead);
        
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
        NSLog(@"下载成功");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        success(operation,error);
        
        NSLog(@"下载失败");
        
    }];
    
    [operation start];
    
}

-(void)dowLoadImage:(NSString*)urlStr withArrayCount:(NSInteger)arrayCount withImageId:(NSString*)imageId withTag:(int)downTag{
    __block int tempDownTag = downTag;
    NSURL * url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSOperationQueue *que = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:que completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@" %@",[connectionError localizedDescription]);
            if (tempDownTag <= 105) {
                tempDownTag ++;
                [self dowLoadImage:(NSString*)urlStr withArrayCount:(NSInteger)arrayCount withImageId:(NSString*)imageId withTag:tempDownTag];

            }else{
                
                NSString *deletSql = [NSString stringWithFormat:
                                       @"DELETE FROM %@  WHERE %@ = %@",
                                       TABLE_ACCOUNTINFOS,DATAID,_ID];
                BOOL res = [db executeUpdate:deletSql];
                if (!res) {
                    NSLog(@"error when delet TABLE_ACCOUNTINFOS");
                } else {
                    NSLog(@"success to delet TABLE_ACCOUNTINFOS");
                    [Api alert4:@"下载失败!" inView:self.view offsetY:self.view.bounds.size.height -50];
                    
                }
                
            }
            
        }
        else{


           NSString * imageStr= [MF_Base64Codec base64StringFromData:data];
            NSDictionary * imageDict = [[NSDictionary alloc] initWithObjectsAndKeys:imageStr,@"ImageName", imageId,@"ImageId",nil];
            [self DataTOjsonString:imageDict];
            [self.childImageArray addObject:imageDict];
            if (self.childImageArray.count == arrayCount) {
                NSArray * child = [NSArray arrayWithArray:self.childImageArray];
                [self.countImageArray addObject:child];
                if (self.ImageCount == self.countImageArray.count) {
                    NSString * childImageStr = [self DataTOjsonString:self.countImageArray];
                    NSString *updateSql = [NSString stringWithFormat:
                                           @"UPDATE %@ SET  %@ = '%@' WHERE %@ = %@",
                                           TABLE_ACCOUNTINFOS,IMAGEDATA,childImageStr,DATAID,_ID];
                    BOOL res = [db executeUpdate:updateSql];
                    if (!res) {
                        NSLog(@"error when update TABLE_ACCOUNTINFOS");
                    } else {
                        NSLog(@"success to update TABLE_ACCOUNTINFOS");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // 更UI
                            UIAlertView * altView = [[UIAlertView alloc] initWithTitle:@"" message:@"下载完成" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                            [altView show];
                        });
                 

                    }
                    
                    
                }
                if (self.childImageArray.count) {
                    [self.childImageArray removeAllObjects];

                }


            }
            

          
        }
    }];

    
}


-(void)downloadImage:(NSDictionary*)dic{
    NSString * imageUrl = dic[@"imageUrl"];
    NSString * downloadPath = dic[@"downloadPath"];
    NSString * imageId = dic[@"imageId"];
    int tag = [dic[@"tag"] intValue];
    [self dowImageUrl:imageUrl withSavePath:downloadPath withTag:tag withImageId:imageId];
}

- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}



-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}


-(void)hanMoreIndexPath:(NSString *)MoreindexPath{
    CatalogDetailsViewController *catalogVC = [[CatalogDetailsViewController alloc]init];
    
    catalogVC.ID = MoreindexPath;
    [self.navigationController pushViewController:catalogVC animated:YES];
}

#pragma mark - catalogdetailsTagTableViewCellDelegate
- (void)hanTapOne:(NSDictionary *)dic{
    
//    NSLog(@"%@",dic);
    
    TagViewController *tagVC = [[TagViewController alloc]init];
    tagVC.ID = [dic objectForKey:@"id"];
    tagVC.dic = dic;
    [self.navigationController pushViewController:tagVC animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)leftViewDidClick{
    if ([UserModel checkLogin]) {
        NSDictionary *prams = [NSDictionary dictionary];
        prams = @{@"cid":_ID};
        
        [Api requestWithbool:YES withMethod:@"get" withPath:API_URL_ADDTOBOOK withParams:prams withSuccess:^(id responseObject) {
            if([responseObject[@"status"] intValue] == 0){
                [self showHudInView:self.view showHint:@"该图录已经存在云库"];
            }
            if([responseObject[@"status"] intValue] == 1){
                [self showHudInView:self.view showHint:@"加入云库成功"];
            }
            
        } withError:^(NSError *error) {
            
        }];

    }else{
        [self showHudInView:self.view showHint:@"请先登陆"];
        [self performSelector:@selector(goLogin) withObject:self afterDelay:1];
    }
}

-(void)goLogin{
    RegistrationPageViewController * regsiVc = [[RegistrationPageViewController alloc] init];
    [self.navigationController pushViewController:regsiVc animated:YES];
//    LoginViewController *longinVC = [[LoginViewController alloc]init];
//    [self.navigationController pushViewController:longinVC animated:YES];

}

-(void)centerViewDidClick{
    if ([UserModel checkLogin]) {

    CommenListViewController *commenlist = [[CommenListViewController alloc]init];
    commenlist.ID = _ID;
    if ( _catalogdetailsData.author.length == 0) {
        _catalogdetailsData.author = [NSString stringWithFormat:@"%@",self.catalogData.uname];
        
    }
    commenlist.catalogData = _catalogdetailsData;
     [self.navigationController pushViewController:commenlist animated:YES];
    }else{
        [self showHudInView:self.view showHint:@"请先登陆"];
        [self performSelector:@selector(goLogin) withObject:self afterDelay:1];

    }
}
-(void)rightViewDidClick{
    [self showShareView];
}

-(void)showShareView{
    UIView * shareView = [[UIView alloc]init];
    shareView.backgroundColor = [UIColor colorWithConvertString:Background_Color];
    float littleButtonWidth = UI_SCREEN_WIDTH * 0.156;
    float shareViewHeight = 50 + littleButtonWidth * 1.4 + 20; //取消的高度+图标的高度+上下各10
    shareView.frame = CGRectMake(0, UI_SCREEN_HEIGHT-shareViewHeight, UI_SCREEN_WIDTH, shareViewHeight);
    shareView.tag = 1001;
    
    NSArray *array = [NSArray arrayWithObjects:@"Activity_pengyouquan", @"Activity_weixin", @"Activity_sina", @"Activity_qq", nil];
    float avrWidth = UI_SCREEN_WIDTH / 5;
    for(int i=0; i<4; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(avrWidth * (i + 1) - littleButtonWidth/2, 10, littleButtonWidth, littleButtonWidth * 1.4);
        [btn setBackgroundImage:[UIImage imageNamed:[array objectAtIndex:i]] forState:UIControlStateNormal];
        btn.tag = 100+i;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [ shareView addSubview:btn];
    }
    
    UILabel * downLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, shareView.bounds.size.height - 50, UI_SCREEN_WIDTH, 50)];
    downLabel.text = @"取消";
    downLabel.textAlignment = NSTextAlignmentCenter;
    downLabel.textColor = [UIColor whiteColor];
    downLabel.backgroundColor = [UIColor grayColor];
    UIButton * button  = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = downLabel.frame;
    [button addTarget:self action:@selector(cancelShareView:) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:downLabel];
    [shareView addSubview:button];
    
    [self.view addSubview:shareView];
}

-(void)btnClicked:(UIButton*)sender{
    NSLog(@"%ld",sender.tag);
    switch (sender.tag) {
        case 100:
        {
            //构造分享内容
            id<ISSContent> publishContent = [ShareSDK content:@"推荐我发现的神器级APP！它能“发现属于你的艺术”，#到处是宝#官方APP"
                                               defaultContent:DEFAULTCONTENT
                                                        image:[ShareSDK imageWithPath:APPICON]
                                                        title:[NSString stringWithFormat:@"“%@”邀请你加入—到处是宝",[UserModel userUname]]
                                                          url:[NSString stringWithFormat:@"%@%@",API_URL_INVITATION,[UserModel userUname]]
                                                  description:nil
                                                    mediaType:SSPublishContentMediaTypeNews];
            
            [ShareSDK shareContent:publishContent
                              type:ShareTypeWeixiTimeline
                       authOptions:nil
                      shareOptions:nil
                     statusBarTips:YES
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%ld,错误描述:%@", (long)[error errorCode], [error errorDescription]);
                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享失败" message:[error errorDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                                    [alertView show];
                                }
                            }];
        }
            break;
        case 101:
        {
            //构造分享内容
            id<ISSContent> publishContent = [ShareSDK content:@"推荐我发现的神器级APP！它能“发现属于你的艺术”，#到处是宝#官方APP"
                                               defaultContent:DEFAULTCONTENT
                                                        image:[ShareSDK imageWithPath:APPICON]
                                                        title:[NSString stringWithFormat:@"“%@”邀请你加入—到处是宝",[UserModel userUname]]
                                                          url:[NSString stringWithFormat:@"%@%@", API_URL_INVITATION,[UserModel userUname]]
                                                  description:nil
                                                    mediaType:SSPublishContentMediaTypeNews];
            
            [ShareSDK shareContent:publishContent
                              type:ShareTypeWeixiSession
                       authOptions:nil
                      shareOptions:nil
                     statusBarTips:YES
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%ld,错误描述:%@", (long)[error errorCode], [error errorDescription]);
                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享失败" message:[error errorDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                                    [alertView show];
                                }
                            }];
        }
            break;
        case 102:
        {
            //构造分享内容
            id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"推荐我发现的神器级APP！它能“发现属于你的艺术”，#到处是宝#官方APP（“虎头”@到处是宝）下载：%@%@",API_URL_INVITATION,[UserModel userUname]]
                                               defaultContent:DEFAULTCONTENT
                                                        image:[ShareSDK imageWithPath:APPICON]
                                                        title:[NSString stringWithFormat:@"“%@”邀请你加入—到处是宝",[UserModel userUname]]
                                                          url:[NSString stringWithFormat:@"%@%@",API_URL_INVITATION,[UserModel userUname]]
                                                  description:nil
                                                    mediaType:SSPublishContentMediaTypeNews];
            
            [ShareSDK shareContent:publishContent
                              type:ShareTypeSinaWeibo
                       authOptions:nil
                      shareOptions:nil
                     statusBarTips:YES
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                    [self showHudInView:self.view showHint:@"分享成功"];
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%ld,错误描述:%@", (long)[error errorCode], [error errorDescription]);
                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享失败" message:[error errorDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                                    [alertView show];
                                }
                            }];
        }
            break;
        case 103:
        {
            //构造分享内容
            id<ISSContent> publishContent = [ShareSDK content:@"推荐我发现的神器级APP！它能“发现属于你的艺术”，#到处是宝#官方APP"
                                               defaultContent:DEFAULTCONTENT
                                                        image:[ShareSDK imageWithPath:APPICON]
                                                        title:[NSString stringWithFormat:@"“%@”邀请你加入—到处是宝",[UserModel userUname]]
                                                          url:[NSString stringWithFormat:@"%@%@",API_URL_INVITATION,[UserModel userUname]]
                                                  description:nil
                                                    mediaType:SSPublishContentMediaTypeNews];
            
            [ShareSDK shareContent:publishContent
                              type:ShareTypeQQ
                       authOptions:nil
                      shareOptions:nil
                     statusBarTips:YES
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    //                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%ld,错误描述:%@", (long)[error errorCode], [error errorDescription]);
                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享失败" message:[error errorDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                                    [alertView show];
                                }
                            }];
        }
            break;
        default:
            break;
    }

}
-(void)cancelShareView:(UIButton*)sender{
    UIView * shareView = [self.view viewWithTag:1001];
    [shareView removeFromSuperview];
}

#pragma mark - 下载按钮 点击

-(void)downloadButtonDidClick{
    NSLog(@"下载，下载!: %@",_mfileName);
    if ([UserModel checkLogin] ) {
        NSString *pathOne = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"DownLoad/%@_%@/Image",_ID,_mfileName] ];
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL bRet = [fileMgr fileExistsAtPath:pathOne];
        
        if (bRet) {
            [Api alert4:@"已经加入下载列表" inView:self.view offsetY:self.view.bounds.size.height - 50];
            
        }else{
            NSDictionary *prams = [NSDictionary dictionary];
            prams = @{@"id":_ID};
            [Api showLoadMessage:@"正在处理"];
            [Api requestWithbool:YES withMethod:@"get" withPath:API_URL_Catalog_getTemp withParams:prams withSuccess:^(id responseObject) {
                [Api hideLoadHUD];
                NSDictionary * responseDict = (NSDictionary*)responseObject;
                if (STRING_NOT_EMPTY(self.mfileName)) {
                    
                }else{
                    self.mfileName = [NSString stringWithFormat:@"%@",responseDict[@"catalog"][@"name"]];
                }
                
                [self inserNewData:responseDict withId:_ID];
                
            }withError:^(NSError *error) {
                [Api hideLoadHUD];
                
            }];
            
        }

        
    }else{
        [self showHudInView:self.view showHint:@"请先登陆"];
        [self performSelector:@selector(goLogin) withObject:self afterDelay:1];

    }
    
    
}

-(void)addToBookYun{
    NSDictionary *prams = [NSDictionary dictionary];
    prams = @{@"cid":_ID};
    
    [Api requestWithbool:YES withMethod:@"get" withPath:API_URL_ADDTOBOOK withParams:prams withSuccess:^(id responseObject) {
//        if([responseObject[@"status"] intValue] == 0){
//            [self showHudInView:self.view showHint:@"该图录已经存在云库"];
//        }
//        if([responseObject[@"status"] intValue] == 1){
//            [self showHudInView:self.view showHint:@"加入云库成功"];
//        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addmybook" object:nil userInfo:nil];
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addmybook:) name:@"addmybook" object:nil];

        
    } withError:^(NSError *error) {
        
    }];

}

//创建表、插入数据
-(void)inserNewData:(NSDictionary*)responseDict withId:(NSString*)tempId{
    [db open];
    NSString * josn = [self DataTOjsonString:responseDict];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];    //初始化临时文件路径
    NSString *folderPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"DownLoad/%@_%@",_ID,_mfileName]];
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断temp文件夹是否存在
    BOOL fileExists = [fileManager fileExistsAtPath:folderPath];
    
    if (!fileExists) {//如果不存在说创建,因为下载时,不会自动创建文件夹
        [fileManager createDirectoryAtPath:folderPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    NSString * writhPath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.txt",_ID,_mfileName]];
    if ( ![fileManager fileExistsAtPath:writhPath]) {
        [fileManager createFileAtPath:writhPath contents:nil attributes:nil];
    }
    BOOL iswrite= [josn writeToFile:writhPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (iswrite) {
        NSLog(@"写文件成功");
    }else{
        NSLog(@"写文件失败");
        
    }
    
    
    NSString *insertSql= [NSString stringWithFormat:
                          @"INSERT INTO '%@' ('%@', '%@') VALUES ('%@', '%@' )",
                          TABLE_ACCOUNTINFOS,DATAID,IMAGEDATA,tempId,@"BBB"];
    BOOL res = [db executeUpdate:insertSql];
    if (!res) {
        NSLog(@"error when TABLE_ACCOUNTINFOS");
    } else {
        NSLog(@"success to TABLE_ACCOUNTINFOS");
    }
    [db close];
    [db open];
    NSString * fileNameOne = [NSString stringWithFormat:@"%@_%@",_ID,_mfileName];
    FMResultSet * resTemp = [Api queryResultSetWithWithDatabase:db AndTable:DOWNTABLE_NAME AndWhereName:DOWNFILEID AndValue:tempId];
    if ([resTemp next]) {
        NSLog(@"success to downTableName");
        //查询数据库中是否有 该图录ID专属下载表
        NSString * tableImageName = [NSString stringWithFormat:@"%@_%@",DOWNFILEIMAGE_NAME,tempId];
        FMResultSet * resOne = [Api queryTableIsOrNotInTheDatebaseWithDatabase:db AndTableName:tableImageName];
        if(![resOne next]){
            //如果没有：创建一张
            NSString *sqlCreateTableOne =  [Api creatTable_DownImageSQl:tableImageName];
            BOOL resone = [db executeUpdate:sqlCreateTableOne];
            if (!resone) {
                NSLog(@"error when creating DOWNTABLE_ImageNAME_ID");
                [self showHudInView:self.view showHint:@"创建图片表失败！"];
                
            } else {
                NSLog(@"success to creating DOWNTABLE_ImageNAME_ID");
                NSDictionary * userDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           responseDict[@"list"],@"list",
                                           _ID,@"filedId",
                                           self.mfileName,@"fileName",
                                           nil];
                
                [self responseDictFinish:responseDict[@"list"] withDownName: self.mfileName];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AddFIFOF" object:nil userInfo:userDict];
                [self showHudInView:self.view showHint:@"下载并加入云库"];
                [self addToBookYun];
                
            }
        }
    }else{
        NSString *insertSqlOne= [NSString stringWithFormat:
                                 @"INSERT INTO '%@' ('%@', '%@','%@','%@') VALUES ('%@', '%@','%@','%@')",
                                 DOWNTABLE_NAME,DOWNFILEID,DOWNFILE_NAME,DOWNFILE_TYPE,DOWNFILE_Progress,tempId,fileNameOne,@"0",@"0.00%"];
        
        BOOL resOne = [db executeUpdate:insertSqlOne];
        if (!resOne) {
            NSLog(@"error when downTableName");
            [self showHudInView:self.view showHint:@"创建图片表失败！"];
        } else {
            NSLog(@"success to downTableName");
            //查询数据库中是否有 该图录ID专属下载表
            NSString * tableImageName = [NSString stringWithFormat:@"%@_%@",DOWNFILEIMAGE_NAME,tempId];
            FMResultSet * resOne = [Api queryTableIsOrNotInTheDatebaseWithDatabase:db AndTableName:tableImageName];
            if(![resOne next]){
                //如果没有：创建一张
                NSString *sqlCreateTableOne =  [Api creatTable_DownImageSQl:tableImageName];
                BOOL resone = [db executeUpdate:sqlCreateTableOne];
                if (!resone) {
                    NSLog(@"error when creating DOWNTABLE_ImageNAME_ID");
                    [self showHudInView:self.view showHint:@"创建图片表失败！"];
                    
                } else {
                    NSLog(@"success to creating DOWNTABLE_ImageNAME_ID");
                    NSDictionary * userDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                               responseDict[@"list"],@"list",
                                               _ID,@"filedId",
                                               self.mfileName,@"fileName",
                                               nil];
                    
                    [self responseDictFinish:responseDict[@"list"] withDownName: self.mfileName];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddFIFOF" object:nil userInfo:userDict];
                    [self showHudInView:self.view showHint:@"下载并加入云库"];
                    [self addToBookYun];
                    
                }
            }
        }

    }
    
        [db close];
    
}
//处理接口返回的数据 组合成统一样式
-(void)responseDictFinish:(NSArray*)responseArry withDownName:(NSString*)fileName{
    if (self.childImageArray) {
        [self.childImageArray removeAllObjects];
    }
    if (self.countImageArray) {
        [self.countImageArray removeAllObjects];
    }
    self.ImageCount = responseArry.count;
    [db open];
    NSString *pathOne = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"DownLoad/%@_%@/Image",_ID,fileName] ];
    for (NSDictionary * responseDict in responseArry) {
        if([[responseDict allKeys] containsObject:@"child"]){
            NSArray * childArray = responseDict[@"child"];
            NSArray * valueArray = responseDict[@"value"];
            if (ARRAY_NOT_EMPTY(childArray)) {
                int i = 0;
                int tag = 0;
                [db beginTransaction];
                @try{
                    for (NSDictionary * childDict in childArray) {
                        NSArray * cValueArray= childDict[@"value"];
                        downImageCount = cValueArray.count;
                        for (NSDictionary * cValueDict in cValueArray) {
                            NSString *imageUrl = cValueDict[@"cover"];
                            NSArray * array = [imageUrl componentsSeparatedByString:@"/"];
                            NSString * tempstr = @"";
                            for (int i =3; i < array.count; i ++) {
                                if (i < (array.count-1)) {
                                    tempstr = [tempstr stringByAppendingString:[NSString stringWithFormat:@"%@/",array[i]]];
                                    
                                }else{
                                    
                                }
                            }
                            
                            NSString * imageId = cValueDict[@"id"];
                            NSString * saveImagePath = [pathOne stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",tempstr]];
                            NSFileManager *fileManagerOne = [NSFileManager defaultManager];
                            //判断temp文件夹是否存在
                            BOOL fileExistsOne = [fileManagerOne fileExistsAtPath:saveImagePath];
                            
                            if (!fileExistsOne) {//如果不存在说创建,因为下载时,不会自动创建文件夹
                                [fileManagerOne createDirectoryAtPath:saveImagePath
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:nil];
                            }
                            
                            NSString *videoName = [array objectAtIndex:array.count-1];
                            NSString *downloadPath = [saveImagePath stringByAppendingPathComponent:videoName];
                            
                            if (STRING_NOT_EMPTY(imageUrl)) {
                                [self dowImageUrl:imageUrl withSavePath:downloadPath withTag:tag withImageId:imageId];
                                /*
                                 NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                                 dic[@"imageUrl"] = imageUrl;
                                 dic[@"downloadPath"] = downloadPath;
                                 dic[@"imageId"] = imageId;
                                 dic[@"tag"] = [NSString stringWithFormat:@"%d",tag];
                                 [NSThread detachNewThreadSelector:@selector(downloadImage:) toTarget:self withObject:dic];
                                 */
                                tag++;
                                
                            }else{
                                
                            }
                            
                        }
                        
                    }
                } @catch (NSException *exception) {
                    [db rollback];
                } @finally {
                    [db commit];
                }
                
                
            }else if (ARRAY_NOT_EMPTY(valueArray)){
                int i = 100;
                int tag = 0;
                downImageCount = valueArray.count;
                [db beginTransaction];
                @try {
                    for (NSDictionary * valueDict in valueArray) {
                        
                        NSString *imageUrl = valueDict[@"cover"];
                        NSArray * array = [imageUrl componentsSeparatedByString:@"/"];
                        NSString * tempstr = @"";
                        for (int i =3; i < array.count; i ++) {
                            if (i < (array.count-1)) {
                                tempstr = [tempstr stringByAppendingString:[NSString stringWithFormat:@"%@/",array[i]]];
                                
                            }else{
                                
                            }
                        }
                        
                        NSString * imageId = valueDict[@"id"];
                        NSString * saveImagePath = [pathOne stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",tempstr]];
                        NSFileManager *fileManagerOne = [NSFileManager defaultManager];
                        //判断temp文件夹是否存在
                        BOOL fileExistsOne = [fileManagerOne fileExistsAtPath:saveImagePath];
                        
                        if (!fileExistsOne) {//如果不存在说创建,因为下载时,不会自动创建文件夹
                            [fileManagerOne createDirectoryAtPath:saveImagePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
                        }
                        
                        NSString *videoName = [array objectAtIndex:array.count-1];
                        NSString *downloadPath = [saveImagePath stringByAppendingPathComponent:videoName];
                        
                        if (STRING_NOT_EMPTY(imageUrl)) {
                            //                        [self dowLoadImage:imageUrl withArrayCount:valueArray.count withImageId:imageId withTag:i];
                            [self dowImageUrl:imageUrl withSavePath:downloadPath withTag:tag withImageId:imageId];
                            tag++;
                            
                            
                        }else{
                            
                        }
                    }
                } @catch (NSException *exception) {
                    [db rollback];
                } @finally {
                    [db commit];
                }
                
                
            }
            
            
        }else if([[responseDict allKeys] containsObject:@"value"]){
            NSArray * valueArray = responseDict[@"value"];
            if (ARRAY_NOT_EMPTY(valueArray)){
                int tag = 0;
                int i = 100;
                downImageCount = valueArray.count;
                [db beginTransaction];
                @try {
                    for (NSDictionary * valueDict in valueArray) {
                        NSString *imageUrl = valueDict[@"cover"];
                        NSArray * array = [imageUrl componentsSeparatedByString:@"/"];
                        NSString * tempstr = @"";
                        for (int i =3; i < array.count; i ++) {
                            if (i < (array.count-1)) {
                                tempstr = [tempstr stringByAppendingString:[NSString stringWithFormat:@"%@/",array[i]]];
                                
                            }else{
                                
                            }
                        }
                        NSString * imageId = valueDict[@"id"];
                        NSString * saveImagePath = [pathOne stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",tempstr]];
                        NSFileManager *fileManagerOne = [NSFileManager defaultManager];
                        //判断temp文件夹是否存在
                        BOOL fileExistsOne = [fileManagerOne fileExistsAtPath:saveImagePath];
                        
                        if (!fileExistsOne) {//如果不存在说创建,因为下载时,不会自动创建文件夹
                            [fileManagerOne createDirectoryAtPath:saveImagePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
                        }
                        
                        NSString *videoName = [array objectAtIndex:array.count-1];
                        NSString *downloadPath = [saveImagePath stringByAppendingPathComponent:videoName];
                        
                        if (STRING_NOT_EMPTY(imageUrl)) {
                            //                        [self dowLoadImage:imageUrl withArrayCount:valueArray.count withImageId:imageId withTag:i];
                            
                            [self dowImageUrl:imageUrl withSavePath:downloadPath withTag:tag withImageId:imageId];
                            tag++;
                            
                            
                        }
                    }
                    
                } @catch (NSException *exception) {
                    [db rollback];
                    
                } @finally {
                    [db commit];
                }
                
                
            }
            
            
        }
        
    }
    [db close];
    
}
//对 图录ID专属表插入数据
-(void)dowImageUrl:(NSString*)imageUrl withSavePath:(NSString*)downloadPath withTag:(int)tag withImageId:(NSString*)imageId{
    
    //    FMDatabaseQueue *queue = [Api getSharedDatabaseQueue];
    //    [queue inDatabase:^(FMDatabase * _db) {
    //        //打开数据库
    //        if ([_db open]) {
    //数据库建表，插入语句
    NSString * tableImageName = [NSString stringWithFormat:@"%@_%@",DOWNFILEIMAGE_NAME,_ID];
    FMResultSet * tempRs = [Api queryResultSetWithWithDatabase:db AndTable:tableImageName AndWhereName:DOWNFILEIMAGE_ID AndValue:imageId];
    if([tempRs next]){
        
        
    }else{
        NSString *insertSql= [NSString stringWithFormat:
                              @"INSERT INTO '%@' ('%@', '%@','%@','%@','%@') VALUES ('%@', '%@','%@','%@','%@')",
                              tableImageName,DOWNFILEID,DOWNFILEIMAGE_ID,DOWNFILEIMAGE_STATE,DOWNFILEIMAGE_URL,DOWNIMAGEFailed_COUNT,_ID,imageId,@"NO",imageUrl,@"0"];
        
        BOOL res = [db executeUpdate:insertSql];
        if (!res) {
            NSLog(@"error when TABLE_ACCOUNTINFOS");
        } else {
            NSLog(@"success to 插入下载图片到相应的sqilte表里面");
        }
        
    }
    
}


@end
