<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PaymentHistory.aspx.cs" Inherits="PaymentHistory" %>

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
    var ApiUrl = "PaymentHistory.aspx";
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

    

    function queryData() {
            var startDate = $('#startDate').val();
            var endDate = $('#endDate').val();

            var postData = {
                AID: EWinInfo.ASID,
                StartDate: startDate,
                EndDate: endDate
            };
            window.parent.API_ShowLoading();
            c.callService(ApiUrl + "/GetPaymentHistory", postData, function (success, o) {
                if (success) {
                    var o = c.getJSON(o);

                    if (o.Result == 0) {
                        updateList(o);
                    } else {

                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o.Message));
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

        if (o.NotFinishDatas.length > 0) {
            for (var j = 0; j < o.NotFinishDatas.length; j++) {
                var record = o.NotFinishDatas[j];
                var RecordDom = c.getTemplate("templateTableItem");
                var Amount;
                var paymentRecordText;
                var BasicType;

                paymentRecordStatus = 0;
                paymentRecordText = mlp.getLanguageKey('進行中');

                var splitPaymentMethodName = record.PaymentMethodName.split('.');
                if (splitPaymentMethodName.length == 2) {
                    if (splitPaymentMethodName[1] == 'BANK') {
                        BasicType = mlp.getLanguageKey('銀行卡');
                    } else {
                        BasicType = mlp.getLanguageKey('GCash');
                    }
                } else {
                    BasicType = mlp.getLanguageKey('區塊鏈');
                }
           
                if (record.PaymentType == 0) {
                    Amount = record.Amount;
                } else {
                    Amount = record.Amount * -1;
                }

                //金額處理
                var countDom = RecordDom.querySelector(".amount");
                if (Amount >= 0) {
                    countDom.classList.add("positive");
                    countDom.innerText = "+ " + new BigNumber(Math.abs(Amount)).toFixed(2);
                } else {
                    countDom.classList.add("negative");
                    countDom.innerText = "- " + new BigNumber(Math.abs(Amount)).toFixed(2);
                }

                c.setClassText(RecordDom, "PaymentStatus", null, paymentRecordText);
                c.setClassText(RecordDom, "FinishDate", null, record.CreateDate);
                c.setClassText(RecordDom, "BasicType", null, BasicType);
                c.setClassText(RecordDom, "PaymentSerial", null, record.PaymentSerial);

                idList.appendChild(RecordDom);
            }
        }

        if (o.Datas.length > 0) {
            for (var i = 0; i < o.Datas.length; i++) {
                var record = o.Datas[i];
                var RecordDom = c.getTemplate("templateTableItem");

              
                    var paymentRecordText;
                    var BasicType;

                    switch (record.PaymentFlowType) {
                        case 2:
                            paymentRecordStatus = 2;
                            paymentRecordText = mlp.getLanguageKey('完成');
                     
                            break;
                        case 3:
                            if (record.BasicType == 1) {
                                paymentRecordText = mlp.getLanguageKey('審核拒絕');
                            } else {
                                paymentRecordText = mlp.getLanguageKey('主動取消');
                            }
                            paymentRecordStatus = 3;
                            break;
                        case 4:
                            paymentRecordStatus = 4;
                            paymentRecordText = mlp.getLanguageKey('審核拒絕');
                            break;
                    }


                    var splitPaymentMethodName = record.PaymentMethodName.split('.');
                    if (splitPaymentMethodName.length == 2) {
                        if (splitPaymentMethodName[1] == 'Bank') {
                            BasicType = mlp.getLanguageKey('銀行卡');
                        } else {
                            BasicType = mlp.getLanguageKey('GCash');
                        }
                    } else {
                        BasicType = mlp.getLanguageKey('區塊鏈');
                    }

                    if (record.PaymentType == 0) {
                        Amount = record.Amount;
                    } else {
                        Amount = record.Amount * -1;
                    }

                    //金額處理
                    var countDom = RecordDom.querySelector(".amount");
                    if (Amount >= 0) {
                        countDom.classList.add("positive");
                        countDom.innerText = "+ " + new BigNumber(Math.abs(Amount)).toFixed(2);
                    } else {
                        countDom.classList.add("negative");
                        countDom.innerText = "- " + new BigNumber(Math.abs(Amount)).toFixed(2);
                    }

                    c.setClassText(RecordDom, "PaymentStatus", null, paymentRecordText);
                    c.setClassText(RecordDom, "FinishDate", null, record.FinishDate);
                    c.setClassText(RecordDom, "BasicType", null, BasicType);
                    c.setClassText(RecordDom, "PaymentSerial", null, record.PaymentSerial);


                idList.appendChild(RecordDom);
            }
        }
 
        if (o.Datas.length == 0 && o.NotFinishDatas.length == 0) {
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

    function setSearchFrame() {
    
        document.getElementById("startDate").value = getFirstDayOfWeek(Date.today()).toString("yyyy-MM-dd");
        document.getElementById("endDate").value = getLastDayOfWeek(Date.today()).toString("yyyy-MM-dd");

    }

    function changeDateTab(e, type) {
        window.event.stopPropagation();
        window.event.preventDefault();
        var beginDate;
        var endDate;
        var tabMainContent = document.getElementById("idTabMainContent");
        var tabItem = tabMainContent.getElementsByClassName("nav-link");
        for (var i = 0; i < tabItem.length; i++) {
            tabItem[i].classList.remove('active');
            tabItem[i].parentNode.classList.remove('active');

            //tabItem[i].setAttribute("aria-selected", "false");

        }

        document.getElementById("sliderDate").style.display = "block";

        e.parentNode.classList.add('active');
        e.classList.add('active');
        //e.setAttribute("aria-selected", "true");
        switch (type) {
            case 0:
                //本日
                beginDate = Date.today().toString("yyyy-MM-dd");
                endDate = Date.today().toString("yyyy-MM-dd");
                document.getElementById("startDate").value = beginDate;
                document.getElementById("endDate").value = endDate;
                break;
            case 1:
                //昨日
                beginDate = Date.today().addDays(-1).toString("yyyy-MM-dd");
                endDate = Date.today().addDays(-1).toString("yyyy-MM-dd");
                document.getElementById("startDate").value = beginDate;
                document.getElementById("endDate").value = endDate;
                break;
            case 2:
                //本周
                beginDate = getFirstDayOfWeek(Date.today()).toString("yyyy-MM-dd");
                endDate = getLastDayOfWeek(Date.today()).toString("yyyy-MM-dd");
                document.getElementById("startDate").value = beginDate;
                document.getElementById("endDate").value = endDate;
                break;
            case 3:
                //上週  
                beginDate = getFirstDayOfWeek(Date.today().addDays(-7)).toString("yyyy-MM-dd");
                endDate = getLastDayOfWeek(Date.today().addDays(-7)).toString("yyyy-MM-dd");
                document.getElementById("startDate").value = beginDate;
                document.getElementById("endDate").value = endDate;
                break;
            case 4:
                //本月
                beginDate = Date.today().moveToFirstDayOfMonth().toString("yyyy-MM-dd");
                endDate = Date.today().moveToLastDayOfMonth().toString("yyyy-MM-dd");
                document.getElementById("startDate").value = beginDate;
                document.getElementById("endDate").value = endDate;
                break;
            case 5:
                //上月
                beginDate = Date.today().addMonths(-1).moveToFirstDayOfMonth().toString("yyyy-MM-dd");
                endDate = Date.today().addMonths(-1).moveToLastDayOfMonth().toString("yyyy-MM-dd");
                document.getElementById("startDate").value = beginDate;
                document.getElementById("endDate").value = endDate;
                break;
        }
    }

    function getFirstDayOfWeek(d) {
        let date = new Date(d);
        let day = date.getDay();

        let diff = date.getDate() - day + (day === 0 ? -6 : 1);

        return new Date(date.setDate(diff));
    }

    function getLastDayOfWeek(d) {
        let firstDay = getFirstDayOfWeek(d);
        let lastDay = new Date(firstDay);

        return new Date(lastDay.setDate(lastDay.getDate() + 6));
    }


    function init() {
       
        document.getElementById("startDate").value = getFirstDayOfWeek(Date.today()).toString("yyyy-MM-dd");
        document.getElementById("endDate").value = getLastDayOfWeek(Date.today()).toString("yyyy-MM-dd");
     
        EWinInfo = window.parent.EWinInfo;
        api = window.parent.API_GetAgentAPI();
   
        lang = window.localStorage.getItem("agent_lang");
        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
                window.parent.API_CloseLoading();
                queryData();

        
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

    window.onload = init;
</script>
<body class="innerBody">
    <main>
        <div class="dataList dataList-box fixed top real-fixed">
            <div class="container-fluid">
                <div class="collapse-box">
                    <h2 class="collapse-header has-arrow zIndex_overMask_SafariFix" onclick="ac.dataToggleCollapse(this)" data-toggle="collapse" data-target="#searchList" aria-controls="searchList" aria-expanded="true" aria-label="searchList">
                        <span class="language_replace">出款紀錄</span>
                        <i class="arrow"></i>
                    </h2>
                    <!-- collapse內容 由此開始 ========== -->
                       <div id="searchList" class="collapse-content collapse show">
                        <div id="divSearchContent" class="row searchListContent">
                         
                            <div class="col-12 col-md-6 col-lg-4 col-xl-3" style="display:none">
                                <!-- 起始日期 / 結束日期 -->
                                <div class="form-group search_date">
                                    <div class="starDate">
                                        <div class="title"><span class="language_replace">起始日期</span></div>

                                        <div class="form-control-default">
                                            <input id="startDate" type="date" class="form-control custom-date" onchange="disableDateSel()">
                                            <label for="" class="form-label"><i class="icon icon2020-calendar-o"></i></label>
                                            <%--<input id="startDateChk" type="checkbox" style="position:relative;opacity:0.5;width:50px;height:50px;top:-30px">--%>
                                        </div>

                                    </div>
                                    <div class="endDate">
                                        <div class="title"><span class="language_replace">結束日期</span></div>

                                        <div class="form-control-default">
                                            <input id="endDate" type="date" class="form-control custom-date" onchange="disableDateSel()">
                                            <label for="" class="form-label"><i class="icon icon2020-calendar-o"></i></label>
                                        </div>

                                    </div>

                                </div>

                            </div>

                             <div class="col-12 col-md-12 col-lg-5 col-xl-7">
                                <div id="idTabMainContent">
                                    <ul class="nav-tabs-block nav nav-tabs tab-items-6" role="tablist">
                                        <li class="nav-item">
                                            <a onclick="changeDateTab(this,0)" class="nav-link language_replace" data-toggle="tab" href="" role="tab" aria-selected="true">本日</a>
                                        </li>
                                        <li class="nav-item">
                                            <a onclick="changeDateTab(this,1)" class="nav-link language_replace" data-toggle="tab" href="" role="tab" aria-selected="true">昨天</a>
                                        </li>
                                        <li class="nav-item active">
                                            <a onclick="changeDateTab(this,2)" class="nav-link language_replace active" data-toggle="tab" href="" role="tab" aria-selected="true">本週</a>
                                        </li>
                                        <li class="nav-item">
                                            <a onclick="changeDateTab(this,3)" class="nav-link language_replace" data-toggle="tab" href="" role="tab" aria-selected="true">上週</a>
                                        </li>
                                        <li class="nav-item">
                                            <a onclick="changeDateTab(this,4)" class="nav-link language_replace" data-toggle="tab" href="" role="tab" aria-selected="true">本月</a>
                                        </li>
                                        <li class="nav-item">
                                            <a onclick="changeDateTab(this,5)" class="nav-link language_replace" data-toggle="tab" href="" role="tab" aria-selected="true">上月</a>
                                        </li>
                                        <li class="tab-slide" id="sliderDate"></li>
                                    </ul>
                                </div>
                            </div>

                         
                            <div class="col-12">
                                <div class="form-group wrapper_center dataList-process">
                                    <%--<button class="btn btn-outline-main" onclick="MaskPopUp(this)">取消</button>--%>
                                    <button class="btn btn-full-main btn-roundcorner " onclick="queryData()"><i class="icon icon-before icon-ewin-input-submit"></i><span class="language_replace">確認</span></button>
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
                             <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">日期</span></span>
                                <span class="td__content"><i class="icon icon-ewin-default-currencyType icon-s icon-before"></i><span class="FinishDate"></span></span>
                            </div>
                            <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">金額</span></span>
                                <span class="td__content"><i class="icon icon-ewin-default-currencyType icon-s icon-before"></i><span class="amount"></span></span>
                            </div>
                       
                             <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">出款類型</span></span>
                                <span class="td__content"><i class="icon icon-ewin-default-currencyType icon-s icon-before"></i><span class="BasicType"></span></span>
                            </div>
                            <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">訂單編號</span></span>
                                <span class="td__content"><i class="icon icon-ewin-default-currencyType icon-s icon-before"></i><span class="PaymentSerial"></span></span>
                            </div>
                               <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">訂單狀態</span></span>
                                <span class="td__content"><i class="icon icon-ewin-default-currencyType icon-s icon-before"></i><span class="PaymentStatus"></span></span>
                            </div>
                        </div>
                    </div>
                    <!-- 標題項目  -->
                    <div class="thead">
                        <!--標題項目單行 -->
                        <div class="thead__tr">
                            <div class="thead__th"><span class="language_replace">日期</span></div>
                   <%--         <div class="thead__th"><span class="language_replace">狀態</span></div>--%>
                             <div class="thead__th"><span class="language_replace">金額</span></div>
                            <div class="thead__th"><span class="language_replace">出款類型</span></div>
                            <div class="thead__th"><span class="language_replace">訂單編號</span></div>
                            <div class="thead__th"><span class="language_replace">訂單狀態</span></div>
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
