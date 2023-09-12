02<%@ Page Language="C#" AutoEventWireup="true" CodeFile="BankCard_Maint.aspx.cs" Inherits="BankCard_Maint" %>

<%
    string LoginAccount = Request["LoginAccount"];
    string ASID = Request["ASID"];
    EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
    EWin.BmAgent.AgentSessionResult ASR = null;
    EWin.BmAgent.AgentSessionInfo ASI = null;
    string AgentVersion = EWinWeb.AgentVersion;
    EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
    ASR = api.GetAgentSessionByID(ASID);
    string Token;
    int RValue;
    Random R = new Random();
    RValue = R.Next(100000, 9999999);
    string GUID = Guid.NewGuid().ToString();
    Token = EWinWeb.CreateToken(EWinWeb.PrivateKey, EWinWeb.APIKey, RValue.ToString());

    if (ASR.Result != EWin.BmAgent.enumResult.OK) {
        Response.Redirect("login.aspx");
    } else {
        ASI = ASR.AgentSessionInfo;
    }
    bool IsSetWalletPassword = false;
    string Path;
    string BankData = "";

    Path = HttpContext.Current.Server.MapPath("/App_Data/EPay/" + "BankSetting.json");

    Newtonsoft.Json.Linq.JObject o = null;

    if (System.IO.File.Exists(Path))
    {
        string SettingContent;

        SettingContent = System.IO.File.ReadAllText(Path);

        if (string.IsNullOrEmpty(SettingContent) == false)
        {
            try { o = Newtonsoft.Json.JsonConvert.DeserializeObject<Newtonsoft.Json.Linq.JObject>(SettingContent); } catch (Exception ex) { }
        }
    }

    if (o != null)
    {
        BankData = o["BankCodeSettings"].ToString();
    }

    var Ret = lobbyAPI.GetUserAccountProperty(Token, GUID, EWin.Lobby.enumUserTypeParam.ByLoginAccount, ASI.LoginAccount, "IsSetWalletPassword");

    if (Ret.Result== EWin.Lobby.enumResult.OK)
    {
        if (Ret.PropertyValue!=null&&Ret.PropertyValue.ToString().ToUpper()=="TRUE")
        {
            IsSetWalletPassword = true;
        }
    }
%>
<!doctype html>
<html lang="zh-Hant-TW" class="innerHtml">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>銀行卡設定</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/basic.min.css?<%:AgentVersion%>">
    <link rel="stylesheet" href="css/main2.css?<%:AgentVersion%>">
    <style>
        .tree-btn {
            padding: 0px 9px;
            border: none;
            display: inline-block;
            vertical-align: middle;
            overflow: hidden;
            text-decoration: none;
            color: inherit;
            background-color: inherit;
            text-align: center;
            cursor: pointer;
            white-space: nowrap;
            user-select: none;
            border-radius: 50%;
            font-size: 14px;
            font-weight: bold;
            border: 3px solid rgba(227, 195, 141, 0.8);
        }

        .agentPlus {
            padding: 0px 7px;
        }

        .tree-btn:hover {
            color: #fff;
            background-color: rgba(227, 195, 141, 0.8);
        }



        .MT2__table .tbody .tbody__tr:nth-child(2n) {
            /*background-color: rgba(0, 0, 0, 0.2);*/
        }

        .switch_tr {
            background-color: rgba(0, 0, 0, 0.2);
        }

        @keyframes searchTarget {
            0% {
                background-color: indianred;
            }

            50% {
                background-color: #607d8b;
            }

            100% {
                background-color: indianred;
            }
        }

        .searchTarget {
            background-color: indianred;
            animation-name: searchTarget;
            animation-duration: 4s;
            animation-delay: 2s;
            animation-iteration-count: infinite;
        }
    </style>
</head>
<!-- <script type="text/javascript" src="js/AgentCommon.js"></script> -->
<script type="text/javascript" src="js/AgentCommon.js"></script>
<script type="text/javascript" src="/Scripts/Common.js"></script>
<script type="text/javascript" src="/Scripts/bignumber.min.js"></script>
<script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
<script type="text/javascript" src="Scripts/MultiLanguage.js"></script>
<script type="text/javascript" src="../Scripts/jquery-3.3.1.min.js"></script>
<script type="text/javascript" src="js/date.js"></script>
<script>
    var ApiUrl = "BankCard_Maint.aspx";
    var c = new common();
    var ac = new AgentCommon();
    var mlp;
    var EWinInfo;
    var api;
    var lang;
    var startDate;
    var endDate;
    var currencyType = "";
    var PageNumber = 1;
    var BankData = JSON.parse(`<%=BankData%>`);
    var IsSetWalletPassword = "<%=IsSetWalletPassword%>";
    //var hasDataExpand;

    function createBankSelect() {
        if (BankData) {
            if (BankData.length > 0) {
                var strSelectBank = mlp.getLanguageKey("選擇銀行");
                $('#selectedBank').append(`<option  value="-1" selected="">${strSelectBank}</option>`);
                for (var i = 0; i < BankData.length; i++) {
                    $('#selectedBank').append(`<option  value="${BankData[i].BankName}">${BankData[i].BankName}</option>`);
                }
            } else {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("尚未設定銀行列表"), function () {
                    window.parent.API_Home();
                });
            }
        } else {
            window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("尚未設定銀行列表"), function () {
                window.parent.API_Home();
            });
        }
   
    }

    function queryData() {
            var postData = {
                AID: EWinInfo.ASID
            };
            window.parent.API_ShowLoading();
            c.callService(ApiUrl + "/GetUserBankCard", postData, function (success, o) {
                if (success) {
                    var obj = c.getJSON(o);

                    if (obj.Result == 0) {
                        updateList(obj);
                    } else {

                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(obj.Message));
                    }
                } else {
                    if (o == "Timeout") {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後重新嘗試"));
                    } else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), o);
                    }
                }

                window.parent.API_CloseLoading();
            });
    }

    function updateList(o) {
        var idList = document.getElementById("idList");
 
        c.clearChildren(idList);
 
        if (o.BankCardList && o.BankCardList.length > 0) {
            document.getElementById("idResultTable").classList.remove("MT_tableDiv__hasNoData");
            idList.classList.remove("tbody__hasNoData");
            for (var i = 0; i < o.BankCardList.length; i++) {
                var item = o.BankCardList[i];
                if (item.BankCardState == 0) {

                    var t = c.getTemplate("templateTableItem");

                    if (item.PaymentMethod == 0) {
                        PaymentMethod = mlp.getLanguageKey("銀行卡");
                        c.setClassText(t, "BranchName", null, item.BranchName);
                    } else if (item.PaymentMethod == 4) {
                        PaymentMethod = mlp.getLanguageKey("GCASH");
                    }

                    c.setClassText(t, "BankCardGUID", null, item.BankCardGUID);
                    c.setClassText(t, "BankNumber", null, item.BankNumber);
                    c.setClassText(t, "AccountName", null, item.AccountName);
                    c.setClassText(t, "PaymentMethod", null, PaymentMethod);
                    c.setClassText(t, "BankName", null, item.BankName);

              

                    idList.appendChild(t);
                }
            }

        } else {
            var div = document.createElement("DIV");

            div.id = "hasNoData_DIV"
            div.innerHTML = mlp.getLanguageKey("無數據");
            div.classList.add("td__content", "td__hasNoData");
            document.getElementById("idResultTable").classList.add("MT_tableDiv__hasNoData");
            idList.classList.add("tbody__hasNoData");
            idList.appendChild(div);

            window.parent.API_ShowMessageOK(mlp.getLanguageKey("提醒"), mlp.getLanguageKey("無數據"));
        }
    }

    function showForgetPassWord() {
        if ($('#idList').children().length >= 10) {
            window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("最多只能新增10張卡片"));
        } else {
            $('#idSelectPaymentMethod').val('BANK');
            SelectPaymentMethod();
            $("#idPopUpForgetPassWord").addClass("show");
        }
    }

    function closeForgetPassWord() {
        $("#idPopUpForgetPassWord").removeClass("show");
    }

    function init() {
        var d = new Date();
     
        EWinInfo = window.parent.EWinInfo;
        api = window.parent.API_GetAgentAPI();
   
        lang = window.localStorage.getItem("agent_lang");
        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
            if (IsSetWalletPassword.toUpperCase() == "TRUE") {
                window.parent.API_CloseLoading();
                createBankSelect();
                queryData();
            } else {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("尚未設定錢包密碼"), function () {
                    window.parent.API_MainWindow(mlp.getLanguageKey("設定錢包密碼"), "SetWalletPassword.aspx");
                });
            }
        
        });
    }

    function EWinEventNotify(eventName, isDisplay, param) {
        switch (eventName) {
            case "WindowFocus":
                //updateBaseInfo();
                ac.dataToggleCollapseInit();
                break;
        }
    }

    function SelectPaymentMethod() {
        if ($('#idSelectPaymentMethod').val() == 'BANK') {

            $('#BankModel').show();
            $('#GCashModel').hide();
            $('#idBankCardName').val('');
            $('#selectedBank').val('-1');
            $('#idBankBranch').val('');
            $('#idWalletPassword').val('');
        } else {
            $('#GCashModel').show();
            $('#BankModel').hide();
            $('#idGCashAccount').val('');
            $('#idPhoneNumber').val('');
            $('#idWalletPassword2').val('');
        }
    }

    function BankCardSave() {
        if ($('#swiperBankCardContent').next().children().length >= 10) {
            window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("最多只能新增10張卡片"));
            return false;
        }

        var BankCardName = $('#idBankCardName').val().trim();
        var BankCard = $('#idBankCard').val().trim();
        var WalletPassword = $('#idWalletPassword').val().trim();
        var BankBranch = $('#idBankBranch').val().trim();
        var Bank = $('#selectedBank').val();

        if (BankCardName == '') {
            window.parent.showMessageOK(mlp.getLanguageKey(""), mlp.getLanguageKey("尚未輸入姓名"));
            return;
        }

        if (BankCard == '') {
            window.parent.showMessageOK(mlp.getLanguageKey(""), mlp.getLanguageKey("尚未輸入卡號"));
            return;
        }

        if (BankBranch == '') {
            window.parent.showMessageOK(mlp.getLanguageKey(""), mlp.getLanguageKey("尚未輸入支行"));
            return;
        } 

        if (Bank == '-1') {
            window.parent.showMessageOK(mlp.getLanguageKey(""), mlp.getLanguageKey("尚未選擇銀行"));
            return;
        } 

        if (WalletPassword == '') {
            window.parent.showMessageOK(mlp.getLanguageKey(""), mlp.getLanguageKey("尚未輸入錢包密碼"));
            return;
        }

        var postData = {
            AID: EWinInfo.ASID,
            Password: WalletPassword
        }

        c.callService(ApiUrl + "/CheckPassword", postData, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);
                if (obj.Result == 0) {
                    var postData2 = {
                        AID: EWinInfo.ASID,
                        PaymentMethod: 0,
                        BankName: Bank,
                        BranchName: BankBranch,
                        BankNumber: BankCard,
                        AccountName: BankCardName,
                        BankProvince: '',
                        BankCity: '',
                        Description: ''
                    }

                    c.callService(ApiUrl + "/AddUserBankCard", postData2, function (success2, o2) {
                        if (success2) {
                            var obj = c.getJSON(o2);
                            if (obj.Result == 0) {
                                closeForgetPassWord();
                                window.parent.API_ShowMessageOK(mlp.getLanguageKey(""), mlp.getLanguageKey('新增成功'), function () {
                                    queryData();
                                });
                            } else {
                                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(obj.Message));
                            }
                        } else {
                            if (o == "Timeout") {
                                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後重新嘗試"));
                            } else {
                                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), o2);
                            }
                        }

                        window.parent.API_CloseLoading();
                    });
                } else {
                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(obj.Message));
                }
            } else {
                if (o == "Timeout") {
                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後重新嘗試"));
                } else {
                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), o);
                }
            }

            window.parent.API_CloseLoading();
        });
    }

    function GCashSave() {
        var GCashAccount = $('#idGCashAccount').val().trim();
        var PhoneNumber = $('#idPhoneNumber').val().trim();
        var WalletPassword = $('#idWalletPassword2').val().trim();

        var boolChecked = true;
        if (GCashAccount == '') {
            window.parent.showMessageOK(mlp.getLanguageKey(""), mlp.getLanguageKey("尚未輸入帳戶名稱"));
            return;
        } 

        if (PhoneNumber == '') {
            window.parent.showMessageOK(mlp.getLanguageKey(""), mlp.getLanguageKey("尚未輸入電話號碼"));
            return;
        }
        else if (PhoneNumber[0] != "0") {
            window.parent.showMessageOK(mlp.getLanguageKey(""), mlp.getLanguageKey("電話號碼必須以0開頭"));
            return;
        } else if (PhoneNumber.length != 11) {
            window.parent.showMessageOK(mlp.getLanguageKey(""), mlp.getLanguageKey("電話號碼長度為11碼"));
            return;
        }


        if (WalletPassword == '') {
            window.parent.showMessageOK(mlp.getLanguageKey(""), mlp.getLanguageKey("尚未輸入錢包密碼"));
            return;
        }

        var postData = {
            AID: EWinInfo.ASID,
            Password: WalletPassword
        }

        c.callService(ApiUrl + "/CheckPassword", postData, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);
                if (obj.Result == 0) {
                    var postData2 = {
                        AID: EWinInfo.ASID,
                        PaymentMethod: 4,
                        BankName: 'GCash',
                        BranchName: '',   
                        BankNumber: PhoneNumber,
                        AccountName: GCashAccount,
                        BankProvince: '',
                        BankCity: '',
                        Description: ''
                    }
                    c.callService(ApiUrl + "/AddUserBankCard", postData2, function (success2, o2) {
                        if (success2) {
                            var obj = c.getJSON(o2);
                            if (obj.Result == 0) {
                                closeForgetPassWord();
                                window.parent.API_ShowMessageOK(mlp.getLanguageKey(""), mlp.getLanguageKey('新增成功'), function () {
                                    queryData();
                                });
                            } else {
                                if (obj.Message == "BankNumberExist") {
                                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("電話號碼已存在"));
                                } else {
                                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(obj.Message));
                                }
                              
                            }
                        } else {
                            if (o == "Timeout") {
                                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後重新嘗試"));
                            } else {
                                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), o2);
                            }
                        }

                        window.parent.API_CloseLoading();
                    });
                } else {
                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(obj.Message));
                }
            } else {
                if (o == "Timeout") {
                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後重新嘗試"));
                } else {
                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), o);
                }
            }

            window.parent.API_CloseLoading();
        });

    }

    function SetUserBankCardState(doc) {
        var BankCardGUID = $(doc).parent().parent().parent().find('.BankCardGUID').eq(0).text();
        var BankNumber = $(doc).parent().parent().parent().find('.BankNumber').eq(0).text();
        var postData2 = {
            AID: EWinInfo.ASID,
            BankCardGUID: BankCardGUID,
            BankCardState: 1
        }
        window.parent.API_ShowMessage('', mlp.getLanguageKey('確認刪除此卡片')+":" + BankNumber + "?", function () {
            c.callService(ApiUrl + "/SetUserBankCardState", postData2, function (success2, o2) {
                if (success2) {
                    var obj = c.getJSON(o2);
                    if (obj.Result == 0) {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey(""), mlp.getLanguageKey('刪除成功'), function () {
                            queryData();
                        });
                    } else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(obj.Message));
                    }
                } else {
                    if (o == "Timeout") {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後重新嘗試"));
                    } else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), o2);
                    }
                }

                window.parent.API_CloseLoading();
            });
        });
      
      
    }

    window.onload = init;
</script>
<body class="innerBody">
    <main>
        <div class="dataList dataList-box fixed top real-fixed">
            <div class="container-fluid">
                <div class="collapse-box">
                    <h2 class="collapse-header has-arrow zIndex_overMask_SafariFix" onclick="ac.dataToggleCollapse(this)" data-toggle="collapse" data-target="#searchList" aria-controls="searchList" aria-expanded="true" aria-label="searchList">
                        <span class="language_replace">卡片設定</span>
                        <i class="arrow"></i>
                    </h2>
                    <!-- collapse內容 由此開始 ========== -->
                    <div id="searchList" class="collapse-content collapse show">
                        <div id="divSearchContent" class="row searchListContent">
                            <div class="col-12">
                                <div class="form-group wrapper_center dataList-process">
                                    <button class="btn btn-full-main btn-roundcorner " onclick="showForgetPassWord()"><i class="icon icon-before icon-ewin-input-submit"></i><span class="language_replace">新增</span></button>
                                </div>
                            </div>
                            <!-- iOS Safari Virtual Keyboard Fix--------------->
                            <div id="div_MaskSafariFix" class="mask_Input_Safari" onclick="clickMask()"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 表格 由此開始 ========== -->
        <div class="container-fluid wrapper__TopCollapse orderHistory_userAccount">
            <div class="MT__tableDiv" id="idResultTable">
                <!-- 自訂表格 -->
                <div class="MT2__table table-col-8 w-200">
                    <div id="templateTableItem" style="display: none">
                        <div class="tbody__tr td-non-underline-last-2">
                            <span style="display:none;" class="BankCardGUID"></span>
                            <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">類型</span></span>
                                <span class="td__content"><i class="icon icon-s icon-before"></i><span class="PaymentMethod"></span></span>
                            </div>
                     <%--         <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><i class="icon icon-ewin-default-accountRolling icon-s icon-before"></i><span class="language_replace">狀態</span></span>
                                <span class="td__content"><span class="BankCardState"></span></span>
                            </div>--%>
                             <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">銀行名稱</span></span>
                                <span class="td__content"><i class="icon icon-ewin-default-currencyType icon-s icon-before"></i><span class="BankName"></span></span>
                            </div>
                            <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">卡號/帳號</span></span>
                                <span class="td__content"><i class="icon icon-ewin-default-currencyType icon-s icon-before"></i><span class="BankNumber"></span></span>
                            </div>
                       
                             <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">支行名稱</span></span>
                                <span class="td__content"><i class="icon icon-ewin-default-currencyType icon-s icon-before"></i><span class="BranchName"></span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><i class="icon icon-ewin-default-accountRolling icon-s icon-before"></i><span class="language_replace">持卡人名稱</span></span>
                                <span class="td__content"><span class="AccountName"></span></span>
                            </div>
                             <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><i class="icon icon-ewin-default-accountRolling icon-s icon-before"></i><span class="language_replace">刪除</span></span>
                                <span class="td__content"><button class="language_replace" onclick="SetUserBankCardState(this)" style="color: black;">刪除</button></span>
                            </div>
                        </div>
                    </div>
                    <!-- 標題項目  -->
                    <div class="thead">
                        <!--標題項目單行 -->
                        <div class="thead__tr">
                            <div class="thead__th"><span class="language_replace">類型</span></div>
                   <%--         <div class="thead__th"><span class="language_replace">狀態</span></div>--%>
                             <div class="thead__th"><span class="language_replace">銀行名稱</span></div>
                            <div class="thead__th"><span class="language_replace">卡號/帳號</span></div>
                            <div class="thead__th"><span class="language_replace">支行名稱</span></div>
                            <div class="thead__th"><span class="language_replace">持卡人名稱</span></div>
                            <div class="thead__th"><span class="language_replace"></span></div>
                        </div>
                    </div>
                    <!-- 表格上下滑動框 -->
                    <div class="tbody" id="idList">
                    </div>
  
                </div>
            </div>
        </div>
    </main>

        <div class="popUp" id="idPopUpForgetPassWord">
        <div class="popUpWrapper">
            <div class="popUp__close btn btn-close" onclick="closeForgetPassWord()"></div>
            <div class="popUp__title"><span class="language_replace">新增銀行卡</span></div>
            <div class="popUp__content">
                <div>
                    <div class="col-12 form-group row no-gutters data-item">
                        <div class="col-12 data-title">
                            <label class="title"><span class="title_name"><span class="language_replace" langkey="類型">類型</span></span></label>
                        </div>
                        <div class="col-12 data-content">
                            <div class="row no-gutters">
                                <div class="col-auto col-md-4 ">
                                    <div class="form-control-underline">
                                        <select name="idSelectPaymentMethod" id="idSelectPaymentMethod" class="custom-select" onchange="SelectPaymentMethod()">
                                            <option class="language_replace" value="BANK" langkey="BANK">BANK</option>
                                            <option class="language_replace" value="GCash" langkey="GCash">GCash</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="BankModel">
                          <div class="col-12 form-group row no-gutters data-item">
                        <div class="col-12 data-title">
                            <label class="title"><span class="title_name"><span class="language_replace" langkey="選擇銀行">選擇銀行</span></span></label>
                        </div>
                        <div class="col-12 data-content">
                            <div class="row no-gutters">
                                <div class="col-auto col-md-4 ">
                                    <div class="form-control-underline">
                                        <select name="ContactPhonePrefix" id="selectedBank" class="custom-select">
                                      <%--      <option class="language_replace" value="BANK" langkey="BANK">BANK</option>
                                            <option class="language_replace" value="GCash" langkey="GCash">GCash</option>--%>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                         <div class="col-12 col-md-6  col-lg-12  form-group row no-gutters data-item">
                        <div class="col-12 data-title">
                            <label class="title"><span class="title_name"><span class="language_replace" langkey="卡號">卡號</span></span></label>
                        </div>
                        <div class="col-12 data-content">
                            <div class="form-control-underline">
                                <input type="text" class="form-control" name="idBankCard" id="idBankCard" language_replace="placeholder" placeholder="請輸入卡號" langkey="請輸入卡號">
                                <label for="text" class="form-label "><span class="language_replace" langkey="請輸入卡號">請輸入卡號</span></label>
                            </div>
                        </div>
                    </div>
                        <div class="col-12 col-md-6  col-lg-12  form-group row no-gutters data-item">
                        <div class="col-12 data-title">
                            <label class="title"><span class="title_name"><span class="language_replace" langkey="持卡人姓名">持卡人姓名</span></span></label>
                        </div>
                        <div class="col-12 data-content">
                            <div class="form-control-underline">
                                <input type="text" class="form-control" name="idBankCardName" id="idBankCardName" language_replace="placeholder" placeholder="請輸入持卡人姓名" langkey="請輸入持卡人姓名">
                                <label for="text" class="form-label "><span class="language_replace" langkey="請輸入持卡人姓名">請輸入持卡人姓名</span></label>
                            </div>
                        </div>
                    </div>
                  

                    <div class="col-12 form-group row no-gutters data-item ">
                        <div class="col-12 data-title">
                            <label class="title"><span class="title_name"><span class="language_replace" langkey="支行名稱">支行名稱</span></span></label>
                        </div>
                        <div class="col-12 data-content">
                            <div class="form-control-underline">
                                <input type="text" class="form-control" name="idBankBranch" id="idBankBranch" language_replace="placeholder" placeholder="請輸入支行名稱" langkey="請輸入支行名稱">
                                    <label for="text" class="form-label "><span class="language_replace" langkey="請輸入支行名稱">請輸入支行名稱</span></label>
                            </div>
                        </div>
                    </div>

                    <div class="col-12 form-group row no-gutters data-item ">
                        <div class="col-12 data-title">
                            <label class="title"><span class="title_name"><span class="language_replace" langkey="錢包密碼">錢包密碼</span></span></label>
                        </div>
                        <div class="col-12 data-content">
                            <div class="form-control-underline">
                                <input type="password" class="form-control" name="idWalletPassword" id="idWalletPassword" language_replace="placeholder" placeholder="錢包密碼" langkey="錢包密碼">
                                    <label for="text" class="form-label "><span class="language_replace" langkey="請輸入錢包密碼">請輸入錢包密碼</span></label>
                            </div>
                        </div>
                    </div>

                    <div class="col-12 col-md-6  col-lg-12  form-group row no-gutters data-item">
                        <div class="col-12 data-title">
                            <div class="form-group form-group-btnLogin btn-group-lg" style="padding-top:0px !important">
                                <div class="btn btn-full-main" onclick="BankCardSave()"><span class="language_replace">確認</span></div>
                            </div>
                        </div>
                    </div>
                    </div>
                   
                    <div id="GCashModel">
                         <div class="col-12 col-md-6  col-lg-12  form-group row no-gutters data-item">
                        <div class="col-12 data-title">
                            <label class="title"><span class="title_name"><span class="language_replace" langkey="帳戶名稱">帳戶名稱</span></span></label>
                        </div>
                        <div class="col-12 data-content">
                            <div class="form-control-underline">
                                <input type="text" class="form-control" name="idGCashAccount" id="idGCashAccount" language_replace="placeholder" placeholder="請填寫帳戶名稱" langkey="請填寫帳戶名稱">
                                <label for="text" class="form-label "><span class="language_replace" langkey="請填寫帳戶名稱">請填寫帳戶名稱</span></label>
                            </div>
                        </div>
                    </div>
                    <div class="col-12 form-group row no-gutters data-item ">
                        <div class="col-12 data-title">
                            <label class="title"><span class="title_name"><span class="language_replace" langkey="手機電話號碼">手機電話號碼</span></span></label>
                        </div>
                        <div class="col-12 data-content">
                            <div class="form-control-underline">
                                <input type="text" class="form-control" name="idPhoneNumber" id="idPhoneNumber" language_replace="placeholder" placeholder="請輸入手機電話號碼" langkey="請輸入手機電話號碼">
                                    <label for="text" class="form-label "><span class="language_replace" langkey="請輸入手機電話號碼">請輸入手機電話號碼</span></label>
                            </div>
                        </div>
                    </div>

                    <div class="col-12 form-group row no-gutters data-item ">
                        <div class="col-12 data-title">
                            <label class="title"><span class="title_name"><span class="language_replace" langkey="錢包密碼">錢包密碼</span></span></label>
                        </div>
                        <div class="col-12 data-content">
                            <div class="form-control-underline">
                                <input type="password" class="form-control" name="idWalletPassword2" id="idWalletPassword2" language_replace="placeholder" placeholder="錢包密碼" langkey="錢包密碼">
                                    <label for="text" class="form-label "><span class="language_replace" langkey="請輸入錢包密碼">請輸入錢包密碼</span></label>
                            </div>
                        </div>
                    </div>

                    <div class="col-12 col-md-6  col-lg-12  form-group row no-gutters data-item">
                        <div class="col-12 data-title">
                            <div class="form-group form-group-btnLogin btn-group-lg" style="padding-top:0px !important">
                                <div class="btn btn-full-main" onclick="GCashSave()"><span class="language_replace">確認</span></div>
                            </div>
                        </div>
                    </div>
                    </div>

                </div>
            </div>
        </div>
        <!-- mask_overlay 半透明遮罩-->
        <div class="mask_overlay_popup mask_overlay_loading"></div>
    </div>
</body>
<script type="text/javascript">
    ac.listenScreenMove();

    function clickMask() {
        // document.getElementById("div_MaskSafariFix").style.display = "none";
        document.getElementById("div_MaskSafariFix").classList.remove("show");
    }
</script>
</html>
