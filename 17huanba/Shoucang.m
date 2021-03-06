//
//  Shoucang.m
//  17huanba
//
//  Created by Chen Hao on 13-2-5.
//  Copyright (c) 2013年 Chen Hao. All rights reserved.
//

#import "Shoucang.h"
#import "Save_CartCell.h"
#import "Xiangxi.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "SVProgressHUD.h"

#define DELET @"/phone/plogined/Delcoll.html"

@interface Shoucang ()

@end

@implementation Shoucang
@synthesize shoucangTableView;
@synthesize shouArray,refreshing;
@synthesize theIndexPath,shareVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.shouArray = [NSMutableArray array];
        page = 0;
    }
    return self;
}

-(void)dealloc{
    [theIndexPath release];
    [shareVC release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIImageView *navIV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"top_nav.png"]];
    navIV.userInteractionEnabled=YES;
    navIV.frame = CGRectMake(0, 0, 320, 44);
    
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame=CGRectMake(5, 10, 57, 27);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back_gray_btn.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(fanhui) forControlEvents:UIControlEventTouchUpInside];
    [navIV addSubview:backBtn];
    
    UILabel *nameL=[[UILabel alloc]initWithFrame:CGRectMake(100, 10, 120, 24)];
    nameL.font=[UIFont systemFontOfSize:17];
    nameL.backgroundColor = [UIColor clearColor];
    nameL.textAlignment = UITextAlignmentCenter;
    nameL.textColor = [UIColor whiteColor];
    nameL.text = @"收藏的宝贝";
    [navIV addSubview:nameL];
    [nameL release];
    [self.view addSubview:navIV];
    [navIV release];
    
    UIButton *deleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleBtn.frame = CGRectMake(258, 10, 57, 27);
    deleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [deleBtn setBackgroundImage:[UIImage imageNamed:@"tab_bg.png"] forState:UIControlStateNormal];
    [deleBtn setTitle:@"删除" forState:UIControlStateNormal];
    [deleBtn setTitle:@"完成" forState:UIControlStateSelected];
    [deleBtn addTarget:self action:@selector(toDelete:) forControlEvents:UIControlEventTouchUpInside];
    [navIV addSubview:deleBtn];
    
     self.shoucangTableView = [[PullingRefreshTableView alloc]initWithFrame:CGRectMake(0, 44, kDeviceWidth, KDeviceHeight-44-20) pullingDelegate:self];
    shoucangTableView.delegate = self;
    shoucangTableView.dataSource = self;
    [self.view addSubview:shoucangTableView];
    [shoucangTableView release];
    
    [self getShoucangList:0];
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}

-(void)getShoucangList:(int)p{
    [SVProgressHUD showWithStatus:@"加载中.."];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    NSURL *newUrl = [NSURL URLWithString:THEURL(@"/phone/logined/Colect.html")];
    ASIFormDataRequest *form_request = [ASIFormDataRequest requestWithURL:newUrl];
    [form_request setDelegate:self];
    [form_request setPostValue:token forKey:@"token"];
    [form_request setPostValue:[NSString stringWithFormat:@"%d",p] forKey:@"p"];
    [form_request setDidFinishSelector:@selector(finishGetTheShoucang:)];
    [form_request setDidFailSelector:@selector(loginFailed:)];
    [form_request startAsynchronous];
}

-(void)finishGetTheShoucang:(ASIHTTPRequest *)request{ //请求成功后的方法
    NSData *data = request.responseData;
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"收藏 str    is   %@",str);
    NSDictionary *dic = [str JSONValue];
    [str release];
//    NSLog(@"dic is %@",dic);
    NSArray *array = [dic objectForKey:@"data"];
    [self.shouArray addObjectsFromArray:array];
    [shoucangTableView reloadData];
    
    [shoucangTableView tableViewDidFinishedLoading];
    [SVProgressHUD dismiss];
}

#pragma mark - 请求失败代理
-(void)loginFailed:(ASIHTTPRequest *)formRequest{
//    NSLog(@"formRequest.error-------------%@",formRequest.error);
    NSString *errorStr = [NSString stringWithFormat:@"%@",formRequest.error];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"错误" message:errorStr delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
    [alert show];
    [alert release];
    [shoucangTableView tableViewDidFinishedLoading];
}

#pragma mark = UITableViewDelegate methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [shouArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indef = @"shoucangCell";
    Save_CartCell *cell = [tableView dequeueReusableCellWithIdentifier:indef];
    if (!cell) {
        cell = [[[Save_CartCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indef] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    NSDictionary *shoucangDic = [shouArray objectAtIndex:indexPath.row];
    NSString *urlStr = [shoucangDic objectForKey:@"img"];
    if (![urlStr isKindOfClass:[NSNull class]]) {
        cell.head.urlString = THEURL(urlStr);
    }
    NSString *goodsName = [shoucangDic objectForKey:@"goods_name"];
    cell.nameL.text = goodsName;
    
    NSString *timeStr = [shoucangDic objectForKey:@"add_time"];
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:[timeStr doubleValue]];
    NSString *timeStrr = [NSString stringWithFormat:@"%@",timeDate];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss zzz"];   //zzz代表+0000 时区格式
    NSDate *date=[dateformatter dateFromString:timeStrr];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString=[dateformatter stringFromDate:date];
    [dateformatter release];
    cell.fangshiL.text = dateString;
    
    [cell.accessBtn setTitle:@"分享" forState:UIControlStateNormal];
    [cell.accessBtn addTarget:self action:@selector(toShare:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    NSLog(@"didSelect--didSelect--didSelect");
    Xiangxi *xiangxiVC = [[Xiangxi alloc]init];
    
    NSDictionary *dic = [shouArray objectAtIndex:indexPath.row];
    NSString *gdidStr = [dic objectForKey:@"goods_id"];
//    NSLog(@"gdidStr   is     %@",gdidStr);
    xiangxiVC.gdid = gdidStr;
    
    [self.navigationController pushViewController:xiangxiVC animated:YES];
    xiangxiVC.navigationController.navigationBarHidden = YES;
    [xiangxiVC release];
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *shouDic = [shouArray objectAtIndex:indexPath.row];
    NSString *ridStr = [shouDic objectForKey:@"rec_id"];
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    NSURL *newUrl = [NSURL URLWithString:THEURL(DELET)];
    
    ASIFormDataRequest *form_request = [ASIFormDataRequest requestWithURL:newUrl];
    [form_request setDelegate:self];
    [form_request setPostValue:ridStr forKey:@"rid"]; //当前收记录的rec_id
    [form_request setPostValue:token forKey:@"token"];
    [form_request setDidFinishSelector:@selector(finishDeleteTheFriend:)];
    [form_request setDidFailSelector:@selector(loginFailed:)];
    [form_request startAsynchronous];
    
    [shouArray removeObject:shouDic];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

-(void)finishDeleteTheFriend:(ASIHTTPRequest *)request{ //请求成功后的方法
    NSData *data = request.responseData;
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"删除情况 str    is   %@",str);
    NSDictionary *dic = [str JSONValue];
    [str release];
//    NSLog(@"dic is %@",dic);
    
    NSString *info = [dic objectForKey:@"info"];
//    NSLog(@"%@",info);
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:info delegate:self cancelButtonTitle:nil otherButtonTitles:@"是",nil];
    [alert show];
    [alert release];
}



-(void)fanhui{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)toDelete:(UIButton *)sender{
    if (sender.selected == NO) {
        sender.selected = YES;
        shoucangTableView.editing = YES;
    }
    else{
        sender.selected = NO;
        shoucangTableView.editing = NO;
    }
}

-(void)toShare:(UIButton *)sender{
    NSLog(@"%s",__FUNCTION__);
    
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    self.theIndexPath = [shoucangTableView indexPathForCell:cell]; //获取相应的Cell的indexPath，之后从数组中取值得到该好友的ID
    
    NSDictionary *goodDic = [shouArray objectAtIndex:theIndexPath.row];
    NSString *gidStr = [goodDic objectForKey:@"goods_id"];
    NSString *goodsName = [goodDic objectForKey:@"goods_name"];
    NSString *urlStr = [NSString stringWithFormat:@"http://www.17huanba.com/view/%@.html",gidStr];
    
    self.shareVC = [[KYShareViewController alloc] init];
    shareVC.shareText = [NSString stringWithFormat:@"偶有闲置%@一枚，求置换哦，不知道亲们是否喜欢？%@",goodsName,urlStr];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"分享到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"新浪微博", @"腾讯微博", @"人人网",@"我的动态",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    [actionSheet release];
}

#pragma mark - uiactionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        shareVC.shareType = SinaWeibo;
        shareVC.title = @"分享到新浪微博";
        [self.navigationController pushViewController:shareVC animated:YES];
    }
    else if (buttonIndex == 1) {
        shareVC.shareType = Tencent;
        shareVC.title = @"分享到腾讯微博";
        [self.navigationController pushViewController:shareVC animated:YES];
    }
    else if (buttonIndex == 2) {
        shareVC.shareType = RenrenShare;
        shareVC.title = @"分享到人人网";
        [self.navigationController pushViewController:shareVC animated:YES];
    }
    else if (buttonIndex == 3) {
        NSDictionary *dic = [shouArray objectAtIndex:theIndexPath.row];
        NSString *gid = [dic objectForKey:@"goods_id"];
        
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
        NSURL *newUrl = [NSURL URLWithString:THEURL(@"/phone/plogined/Share.html")]; //分享
        ASIFormDataRequest *form_request = [ASIFormDataRequest requestWithURL:newUrl];
        [form_request setDelegate:self];
        [form_request setPostValue:gid forKey:@"gid"]; //商品ID
        [form_request setPostValue:token forKey:@"token"];
        [form_request setDidFinishSelector:@selector(finishFenxiangTheShoucang:)];
        [form_request setDidFailSelector:@selector(loginFailed:)];
        [form_request startAsynchronous];
    }
}

-(void)finishFenxiangTheShoucang:(ASIHTTPRequest *)request{ //请求成功后的方法
        NSData *data = request.responseData;
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"分享收藏 str    is   %@",str);
        NSDictionary *dic = [str JSONValue];
        [str release];
        NSLog(@"dic is %@",dic);
        NSString *info = [dic objectForKey:@"info"];
        NSLog(@"%@",info);

        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:info delegate:self cancelButtonTitle:nil otherButtonTitles:@"是",nil];
        [alert show];
        [alert release];
    }

#pragma mark - Scroll
//会在视图滚动时收到通知。包括一个指向被滚动视图的指针，从中可以读取contentOffset属性以确定其滚动到的位置。
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.shoucangTableView tableViewDidScroll:scrollView];
}


//当用户抬起拖动的手指时得到通知。还会得到一个布尔值，知名报告滚动视图最后位置之前，是否需要减速。
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.shoucangTableView tableViewDidEndDragging:scrollView];
}
#pragma mark - PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView
{
    self.refreshing = YES;
    [self performSelector:@selector(refreshPage) withObject:nil afterDelay:1.f];
}
- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView
{
    
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.f];
}

-(void)loadData
{
    refreshing = NO;
    page++;
    [self getShoucangList:page];
}

-(void)refreshPage{
    refreshing = NO;
    page = 0;
    [shouArray removeAllObjects];
    [self getShoucangList:0];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
