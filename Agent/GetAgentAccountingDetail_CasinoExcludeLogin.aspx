<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GetAgentAccountingDetail_CasinoExcludeLogin.aspx.cs" Inherits="GetAgentAccountingDetail_CasinoExcludeLogin" %>

<%
    string LoginAccount = Request["LoginAccount"];

    string AccountingID = Request["AccountingID"];
    string StartDate = Request["StartDate"];
    string EndDate = Request["EndDate"];
    string AgentVersion = EWinWeb.AgentVersion;

%>
<!doctype html>
<html lang="zh-Hant-TW" class="innerHtml">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>投注記錄</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/basic.min.css?<%:AgentVersion%>">
    <link rel="stylesheet" href="css/main2.css?<%:AgentVersion%>">
       <style>
        #idList {
            background-color:black;
        }
    </style>
</head>
<!-- <script type="text/javascript" src="js/AgentCommon.js"></script> -->
<script type="text/javascript" src="js/AgentCommon.js"></script>
<script type="text/javascript" src="/Scripts/Common.js"></script>
<script type="text/javascript" src="/Scripts/bignumber.min.js"></script>
<script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
<script type="text/javascript" src="Scripts/MultiLanguage.js"></script> 
<script type="text/javascript" src="js/AgentAPI.js"></script>
<script src="js/jquery-3.3.1.min.js"></script>
<script>
    var ApiUrl = "GetAgentAccountingDetail_CasinoExcludeLogin.aspx";
    var c = new common();
    var ac = new AgentCommon();
    var mlp;
    var EWinInfo;
    var api;
    var lang;
    var accountingID = <%=AccountingID%>;
    var StartDate = "<%=StartDate%>";
    var EndDate = "<%=EndDate%>";
    var LoginAccount = "<%=LoginAccount%>";
    var apiUrl = "/API/AgentAPI.asmx";
    function queryData() {
        var idList = document.getElementById("idList");


        c.clearChildren(idList);

        postData = {
            AccountingID: accountingID,
            LoginAccount: LoginAccount
        };

        ShowLoading();
        c.callService(ApiUrl + "/GetAgentAccountingDetail", postData, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);

                if (obj.Result == 0) {
                    updateList(obj);
                } else {
                    alert("錯誤:" + obj.Message);
                }
            } else {
                if (o == "Timeout") {
                    alert("錯誤:網路異常, 請稍後重新嘗試");
                } else {
                    alert("錯誤:" + o);
                }
            }

            CloseLoading();
        });
    }

    function ShowLoading(showText) {
        var idShowLoading = document.getElementById("idShowLoading");

        if (showText == "" || showText == null) {
            showText = "Loading";
        }
        document.getElementsByClassName("loading_text")[0].innerText = showText;
        c.addClassName(idShowLoading, "show");
    }

    function CloseLoading() {
        var idShowLoading = document.getElementById("idShowLoading");

        c.removeClassName(idShowLoading, "show");
    }

    function updateList(o) {
     
        if (o != null) {
            if (o.ADList != null) {
                let childBonusPointValue = 0;
                let strChild = "";

                for (var i = 0; i < o.ADList.length; i++) {
                    var data = o.ADList[i];
                    childBonusPointValue = 0;
                    strChild = "";

                    if (data.ChildUser.length > 0) {
                        for (var i = 0; i < data.ChildUser.length; i++) {
                            let k = data.ChildUser[i];
                            if (k.UserAccountType != 0) {
                                childBonusPointValue += k.BonusPointValue;

                                strChild += ` <div class="tbody__tr td-non-underline-last-2">
                            <div class="tbody__td date td-100 nonTitle">
                                <span class="td__title"><span class="language_replace">帳號</span></span>
                                <span class="td__content"><span class="LoginAccount">${k.LoginAccount}</span></span>
                            </div>
                             <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">團隊輸贏數</span></span>
                                <span class="td__content"><span class="RewardValue">${toCurrency(k.TotalRewardValue)}</span></span>
                            </div>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">團隊轉碼數</span></span>
                                <span class="td__content"><span class="ValidBetValue">${toCurrency(k.TotalValidBetValue)}</span></span>
                            </div>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">應得佣金</span></span>
                                <span class="td__content"><span class="AccountingOPValue">${toCurrency(k.UserRebate)}</span></span>
                            </div>
                           <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">總紅利</span></span>
                                <span class="td__content"><span class="TotalBonusValue">${toCurrency(k.BonusPointValue)}</span></span>
                            </div>
                           <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">佔成紅利</span></span>
                                <span class="td__content"><span class="BonusValue_Own">${toCurrency(k.BonusPointValue)}</span></span>
                            </div>
                           <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">團隊投注筆數</span></span>
                                <span class="td__content"><span class="AccountingOPValue">${toCurrency(k.TotalOrderCount)}</span></span>
                            </div>
                        </div>`;
                            }
                        }
                    }

                    var doc = ` <div class="tbody__tr td-non-underline-last-2">
                            <div class="tbody__td date td-100 nonTitle">
                                <span class="td__title"><span class="language_replace">帳號</span></span>
                                <span class="td__content"><span class="LoginAccount">${data.LoginAccount}</span></span>
                            </div>
                             <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">團隊輸贏數</span></span>
                                <span class="td__content"><span class="RewardValue">${toCurrency(data.TotalRewardValue)}</span></span>
                            </div>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">團隊轉碼數</span></span>
                                <span class="td__content"><span class="ValidBetValue">${toCurrency(data.TotalValidBetValue)}</span></span>
                            </div>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">應得佣金</span></span>
                                <span class="td__content"><span class="AccountingOPValue">${toCurrency(data.UserRebate)}</span></span>
                            </div>
                           <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">總紅利</span></span>
                                <span class="td__content"><span class="TotalBonusValue">${toCurrency(data.BonusPointValue)}</span></span>
                            </div>
                           <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">佔成紅利</span></span>
                                <span class="td__content"><span class="BonusValue_Own">${toCurrency(data.BonusPointValue - childBonusPointValue)}</span></span>
                            </div>
                           <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">團隊投注筆數</span></span>
                                <span class="td__content"><span class="AccountingOPValue">${toCurrency(data.TotalOrderCount)}</span></span>
                            </div>
                        </div>`;

                    $('#idList').append(doc);
                    if (strChild != "") {
                        $('#idList').append(strChild);
                    }
                }
            } 
        }
    }

    function toCurrency(num) {

        num = parseFloat(Number(num).toFixed(2));
        var parts = num.toString().split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        return parts.join('.');
    }

    function init() {
        $('#ToggleCollapse').click();
        EWinInfo = window.parent.EWinInfo;
        api = new AgentAPI(apiUrl);

        lang = window.localStorage.getItem("agent_lang");
        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
            CloseLoading();
            queryData();
            ac.dataToggleCollapseInit();
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
                    <h2 id="ToggleCollapse" class="collapse-header has-arrow zIndex_overMask_SafariFix" onclick="ac.dataToggleCollapse(this)" data-toggle="collapse" data-target="#searchList" aria-controls="searchList" aria-expanded="true" aria-label="searchList">
                        <span class="language_replace">佣金結算細節</span>
                        <i class="arrow"></i>
                    </h2>
                    <!-- collapse內容 由此開始 ========== -->
                    <div id="searchList" class="collapse-content collapse show">
                        <div id="divSearchContent" class="row searchListContent">
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
                <div class="MT__table table-col-8 w-200">
                    <div id="templateTableItem" style="display: none">
                        <div class="tbody__tr td-non-underline-last-2">
                            <div class="tbody__td date td-100 nonTitle">
                                <span class="td__title"><span class="language_replace">帳號</span></span>
                                <span class="td__content"><span class="LoginAccount">CON5</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">總輸贏</span></span>
                                <span class="td__content"><span class="RewardValue"></span></span>
                            </div>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">總轉碼</span></span>
                                <span class="td__content"><span class="ValidBetValue"></span></span>
                            </div>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">應付傭金</span></span>
                                <span class="td__content"><span class="AccountingOPValue"></span></span>
                            </div>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">總紅利</span></span>
                                <span class="td__content"><span class="TotalBonusValue"></span></span>
                            </div>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">佔成紅利</span></span>
                                <span class="td__content"><span class="BonusValue_Own"></span></span>
                            </div>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">團隊投注筆數</span></span>
                                <span class="td__content"><span class="OrderCount"></span></span>
                            </div>
                        </div>
                    </div>
                    <!-- 標題項目  -->
                    <div class="thead">
                        <!--標題項目單行 -->
                        <div class="thead__tr">
                            <div class="thead__th"><span class="language_replace">帳號</span></div>
                            <div class="thead__th"><span class="language_replace">總輸贏</span></div>
                            <div class="thead__th"><span class="language_replace">總轉碼</span></div>
                            <div class="thead__th"><span class="language_replace">應付傭金</span></div>
                            <div class="thead__th"><span class="language_replace">總紅利</span></div>
                            <div class="thead__th"><span class="language_replace">佔成紅利</span></div>
                            <div class="thead__th"><span class="language_replace">團隊投注筆數</span></div>
                        </div>
                    </div>
                    <!-- 表格上下滑動框 -->
                    <div class="tbody" id="idList" style="background-color:black;">
                    </div>
                </div>
            </div>
        </div>
    </main>
        <!-- Loading PopUp 要放在 message 及 toast 前面  -->
    <div class="popUp loading" id="idShowLoading">
        <div class="global__loading">
            <!-- <div class="logo"><img src="Images/theme/dark/img/logo_eWin.svg" alt=""></div> -->
            <div class="gooey">
                <span class="dot"></span>
                <div class="dots">
                    <span></span>
                    <span></span>
                    <span></span>
                </div>
            </div>
            <div class="loading_text">Loading</div>
        </div>
        <div id="mask_overlay_popup" class="mask_overlay_popup mask_overlay_loading"></div>
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
