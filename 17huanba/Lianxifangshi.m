//
//  Lianxifangshi.m
//  17huanba
//
//  Created by Chen Hao on 13-3-11.
//  Copyright (c) 2013年 Chen Hao. All rights reserved.
//

#import "Lianxifangshi.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "SVProgressHUD.h"

#define GETMY @"/phone/plogined/Getusinfo.html"

@interface Lianxifangshi ()

@end

@implementation Lianxifangshi
@synthesize LianxiTableView,phoneF,emailF;
@synthesize phoneL,emailL;
//@synthesize QQL,weixinL,QQF,weixinF;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //注册键盘出现和消失的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

-(void)dealloc{
    [super dealloc];
    RELEASE_SAFELY(phoneL);
    RELEASE_SAFELY(emailL);
//    RELEASE_SAFELY(QQL);
//    RELEASE_SAFELY(weixinL);
    RELEASE_SAFELY(phoneF);
    RELEASE_SAFELY(emailF);
//    RELEASE_SAFELY(QQF);
//    RELEASE_SAFELY(weixinF);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil]; //移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidUnload{
    [super viewDidUnload];
    RELEASE_SAFELY(phoneL);
    RELEASE_SAFELY(emailL);
//    RELEASE_SAFELY(QQL);
//    RELEASE_SAFELY(weixinL);
    RELEASE_SAFELY(phoneF);
    RELEASE_SAFELY(emailF);
//    RELEASE_SAFELY(QQF);
//    RELEASE_SAFELY(weixinF);
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
    
    UILabel *nameL=[[UILabel alloc]initWithFrame:CGRectMake(90, 10, 140, 24)];
    nameL.font=[UIFont boldSystemFontOfSize:20];
    nameL.backgroundColor = [UIColor clearColor];
    nameL.textAlignment = UITextAlignmentCenter;
    nameL.textColor = [UIColor whiteColor];
    nameL.text = @"联系方式";
    [navIV addSubview:nameL];
    [nameL release];
    [self.view addSubview:navIV];
    [navIV release];
    
//    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    saveBtn.frame = CGRectMake(258, 10, 57, 27);
//    saveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
//    [saveBtn setBackgroundImage:[UIImage imageNamed:@"tab_bg.png"] forState:UIControlStateNormal];
//    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
//    [saveBtn addTarget:self action:@selector(toSaveTheEdit) forControlEvents:UIControlEventTouchUpInside];
//    [navIV addSubview:saveBtn];
    
    self.LianxiTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, kDeviceWidth, KDeviceHeight-20-44) style:UITableViewStyleGrouped];
    LianxiTableView.delegate = self;
    LianxiTableView.dataSource = self;
    [self.view addSubview:LianxiTableView];
    [LianxiTableView release];
//    LianxiTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"detail_bg.png"]];
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"detail_bg.png"]];
    LianxiTableView.backgroundView = view;
    [view release];
    
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 38.0f)];
    keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *spaceBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];
    
    UIBarButtonItem *doneBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", @"")
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(resignKeyboard)];
    [keyboardToolbar setItems:[NSArray arrayWithObjects:spaceBarItem,doneBarItem, nil]];
    [spaceBarItem release];
    [doneBarItem release];
    
    self.phoneL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    phoneL.textAlignment = UITextAlignmentCenter;
    phoneL.backgroundColor = [UIColor clearColor];
    phoneL.text = @"*手机";
    
    self.phoneF = [[UITextField alloc]initWithFrame:CGRectMake(90, 10, 220, 40)];
    phoneF.inputAccessoryView = keyboardToolbar;
    [keyboardToolbar release];
    phoneF.enabled = NO;
    
    self.emailL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    emailL.textAlignment = UITextAlignmentCenter;
    emailL.backgroundColor = [UIColor clearColor];
    emailL.text = @"*邮箱";
    
    self.emailF = [[UITextField alloc]initWithFrame:CGRectMake(90, 10, 220, 40)];
    emailF.inputAccessoryView = keyboardToolbar;
    [keyboardToolbar release];
    emailF.enabled = NO;
    
//    self.QQL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
//    QQL.textAlignment = UITextAlignmentCenter;
//    QQL.backgroundColor = [UIColor clearColor];
//    QQL.text = @"*QQ号";
//    
//    self.QQF = [[UITextField alloc]initWithFrame:CGRectMake(90, 10, 220, 40)];
//    QQF.inputAccessoryView = keyboardToolbar;
//    [keyboardToolbar release];
//    
//    self.weixinL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
//    weixinL.textAlignment = UITextAlignmentCenter;
//    weixinL.backgroundColor = [UIColor clearColor];
//    weixinL.text = @"微信ID";
//    
//    self.weixinF = [[UITextField alloc]initWithFrame:CGRectMake(90, 10, 220, 40)];
//    weixinF.inputAccessoryView = keyboardToolbar;
//    [keyboardToolbar release];
    [self getMyLianxi];
}


#pragma mark - 获取当前用户信息
-(void)getMyLianxi{
    [SVProgressHUD showWithStatus:@"加载中.."];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    NSURL *newUrl = [NSURL URLWithString:THEURL(GETMY)];
    ASIFormDataRequest *form_request = [ASIFormDataRequest requestWithURL:newUrl];
    [form_request setDelegate:self];
    [form_request setPostValue:token forKey:@"token"];
    [form_request setDidFinishSelector:@selector(finishGetMyXinxi:)];
    [form_request setDidFailSelector:@selector(loginFailed:)];
    [form_request startAsynchronous];
}

-(void)finishGetMyXinxi:(ASIHTTPRequest *)request{ //请求成功后的方法
    NSData *data = request.responseData;
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"联系方式  str    is   %@",str);
    NSDictionary *dic = [str JSONValue];
    [str release];
    NSDictionary *dataDic = [dic objectForKey:@"data"];
    NSDictionary *userInfoDic = [dataDic objectForKey:@"usinfo"];
    
    phoneF.text = [userInfoDic objectForKey:@"tel"];
    
    emailF.text = [userInfoDic objectForKey:@"email"];
    
    [SVProgressHUD dismiss];
    
//    NSString *urlStr = [userInfoDic objectForKey:@"headimg"];
//    if (![urlStr isEqualToString:@" "]) {
//        head.urlString = THEURL(urlStr);
//    }
//    nichengF.text = [userInfoDic objectForKey:@"uname"];
//    trueNameF.text = [userInfoDic objectForKey:@"realname"];
//    NSString *sexStr = [userInfoDic objectForKey:@"sex"];
//    if ([sexStr isEqualToString:@"1"]) {
//        sexF.text = @"男";
//    }
//    else{
//        sexF.text = @"女";
//    }
//    addressF.text = SHENG_SHI_XIAN([userInfoDic objectForKey:@"sheng"], [userInfoDic objectForKey:@"shi"], [userInfoDic objectForKey:@"xian"]);
}

#pragma mark - 请求失败代理
-(void)loginFailed:(ASIHTTPRequest *)formRequest{
    NSLog(@"formRequest.error-------------%@",formRequest.error);
    NSString *errorStr = [NSString stringWithFormat:@"%@",formRequest.error];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"错误" message:errorStr delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark - UItableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headV = [[UIView alloc]init];
//    headV.backgroundColor = [UIColor colorWithRed:0.2 green:0.5 blue:0.1 alpha:1];
    headV.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"section_bar.png"]];
    
    UILabel *noticeL = [[UILabel alloc]initWithFrame:CGRectMake(50, 5, 150, 20)];
    noticeL.backgroundColor = [UIColor clearColor];
    noticeL.font = [UIFont systemFontOfSize:15];
    noticeL.text = @"带*号的为必填项";
    [headV addSubview:noticeL];
    [noticeL release];
    
    return [headV autorelease];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        UIImageView *cellIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"release_list_top_.png"]];
        cell.backgroundView = cellIV;
        [cellIV release];
        
        [cell.contentView addSubview:phoneL];
        [cell.contentView addSubview:phoneF];
    }
    else if (indexPath.row == 1) {
        
        UIImageView *cellIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"release_list_bottom1_.png"]];
        cell.backgroundView = cellIV;
        [cellIV release];
        
        [cell.contentView addSubview:emailL];
        [cell.contentView addSubview:emailF];
    }
//    else if (indexPath.row == 2) {
//        UIImageView *cellIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"release_list_mid.png"]];
//        cell.backgroundView = cellIV;
//        [cellIV release];
//        
//        [cell.contentView addSubview:QQL];
//        [cell.contentView addSubview:QQF];
//    }
//    else if (indexPath.row == 3) {
//        UIImageView *cellIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"release_list_bottom1_.png"]];
//        cell.backgroundView = cellIV;
//        [cellIV release];
//        
//        [cell.contentView addSubview:weixinL];
//        [cell.contentView addSubview:weixinF];
//    }
    
    return cell;
}


-(void)resignKeyboard{
    [phoneF resignFirstResponder];
    [emailF resignFirstResponder];
//    [QQF resignFirstResponder];
//    [weixinF resignFirstResponder];
}

#pragma mark - 键盘通知
-(void)keyboardWasShown:(NSNotification *) notif{
    NSDictionary *info = [notif userInfo];
    
    NSValue *value = [info objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGSize keyboardSize = [value CGRectValue].size;
    NSLog(@"----%@",NSStringFromCGSize(keyboardSize));
    LianxiTableView.frame = CGRectMake(0, 44, kDeviceWidth, KDeviceHeight-20-44-keyboardSize.height);
}

- (void) keyboardWasHidden:(NSNotification *) notif{
    LianxiTableView.frame = CGRectMake(0, 44, kDeviceWidth, KDeviceHeight-20-44);
}


#pragma mark - 编辑联系方式页面导航栏
-(void)fanhui{
    [self.navigationController popViewControllerAnimated:YES];
}

//-(void)toSaveTheEdit{
//    NSLog(@"保存提交更改过的联系方式");
//    NSURL *newUrl = [NSURL URLWithString:THEURL(@"/phone/default/index.html")];
//    ASIFormDataRequest *form_request = [ASIFormDataRequest requestWithURL:newUrl];
//    [form_request setDelegate:self];
//    //    [form_request setPostValue:[NSNumber numberWithInt:newsPage] forKey:@"p"];
//    [form_request setDidFinishSelector:@selector(finishTheNewGoods:)];
//    [form_request setDidFailSelector:@selector(loginFailed:)];
//    [form_request startAsynchronous];
//}
//
//-(void)finishTheNewGoods:(ASIHTTPRequest *)request{ //请求成功后的方法
//    NSData *data = request.responseData;
//    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"str     is     %@",str);
//    NSArray *array = [str JSONValue];
//    NSLog(@"array is %@",array);
//    //    [timeLineArray addObjectsFromArray:array];
//    //    [timeLineTable reloadData];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
