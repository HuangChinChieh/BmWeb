<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GetPlayerTotalDepositSummary_Casino.aspx.cs" Inherits="GetPlayerTotalDepositSummary_Casino" %>

<%
    string LoginAccount = Request["LoginAccount"];
    string ASID = Request["ASID"];
    string AgentVersion = EWinWeb.AgentVersion;
    EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
    EWin.BmAgent.AgentSessionResult ASR = null;
    EWin.BmAgent.AgentSessionInfo ASI = null;

    ASR = api.GetAgentSessionByID(ASID);

    if (ASR.Result != EWin.BmAgent.enumResult.OK) {
        Response.Redirect("login.aspx");
    } else {
        ASI = ASR.AgentSessionInfo;
    }

%>
<!doctype html>
<html lang="zh-Hant-TW" class="innerHtml">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>會員出入金數據</title>
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
    var ApiUrl = "GetPlayerTotalDepositSummary_Casino.aspx";
    var c = new common();
    var ac = new AgentCommon();
    var mlp;
    var EWinInfo;
    var api;
    var lang;
    var RowsPage = 50;
    var PageNumber = 1;
    var SelectedWallet;
    function querySelfData() {
        PageNumber = 1;
        queryData(EWinInfo.UserInfo.LoginAccount);
    }


    function showNextData() {
        PageNumber = PageNumber + 1;
        queryData(EWinInfo.UserInfo.LoginAccount);
    }

    function queryData(LoginAccount) {
        var startDate;
        var endDate;
        var targetLoginAccount = null;
        var idList = document.getElementById("idList");
        var currencyTypeDom = "";
        var currencyType = "";

        startDate = document.getElementById("startDate");
        endDate = document.getElementById("endDate");
        targetLoginAccount = document.getElementById("loginAccount").value.trim();

        if (SelectedWallet != "") {
            postData = {
                AID: EWinInfo.ASID,
                TargetLoginAccount: targetLoginAccount,
                QueryBeginDate: startDate.value,
                QueryEndDate: endDate.value,
                CurrencyType: SelectedWallet
            };

            if (new Date(postData.QueryBeginDate) <= new Date(postData.QueryEndDate)) {

                window.parent.API_ShowLoading();

                if (targetLoginAccount) {

                    c.callService(ApiUrl + "/GetSearchPlayerTotalDepositSummary", postData, function (success, o) {
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
                } else {
                    postData = {
                        AID: EWinInfo.ASID,
                        LoginAccount: LoginAccount,
                        QueryBeginDate: startDate.value,
                        QueryEndDate: endDate.value,
                        CurrencyType: SelectedWallet,
                        RowsPage: RowsPage, //一頁顯示的比數
                        PageNumber: PageNumber
                    };

                    c.callService(ApiUrl + "/GetPlayerTotalDepositSummary", postData, function (success, o) {
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
            } else {
                window.parent.API_ShowMessageOK(mlp.getLanguageKey("提醒"), mlp.getLanguageKey("結束日期不可小於起起始日期"));
            }
        }
        else {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("提醒"), mlp.getLanguageKey("請至少選擇一個幣別!!"));
        }
    }

    function updateList(o) {
        var idList = document.getElementById("idList");
        var hasData = false;

        if (PageNumber == 1) {
            c.clearChildren(idList);
        }

        if (o) {
            if (o.SummaryList && o.SummaryList.length > 0) {
                hasData = true;
            }
        }

        if (hasData) {
            document.getElementById("idResultTable").classList.remove("MT_tableDiv__hasNoData");
            idList.classList.remove("tbody__hasNoData");

            for (var i = 0; i < o.SummaryList.length; i++) {
                var item = o.SummaryList[i];
                var t = c.getTemplate("templateTableItem");
                var DealUserAccountInsideLevel = item.UserAccountInsideLevel - o.TopInsideLevel;
                c.setClassText(t, "LoginAccount", null, item.LoginAccount);
                c.setClassText(t, "ParentLoginAccount", null, item.ParentLoginAccount);
                c.setClassText(t, "InsideLevel", null, DealUserAccountInsideLevel);
                c.setClassText(t, "CurrencyType", null, SelectedWallet);
                //c.setClassText(t, "DepositValue", null, c.toCurrency(item.DepositValue));
                //c.setClassText(t, "FirstDepositValue", null, c.toCurrency(item.FirstDepositValue));;
                //c.setClassText(t, "DepositPaymentCount", null, item.DepositPaymentCount);
                //c.setClassText(t, "FirstDepositPaymentCount", null, item.FirstDepositPaymentCount);
                //c.setClassText(t, "WithdrawValue", null, c.toCurrency(item.WithdrawValue));
                //c.setClassText(t, "FirstWithdrawValue", null, c.toCurrency(item.FirstWithdrawValue));
                //c.setClassText(t, "WithdrawPaymentCount", null, item.WithdrawPaymentCount);
                //c.setClassText(t, "FirstWithdrawPaymentCount", null, item.FirstWithdrawPaymentCount);
                c.setClassText(t, "SelfDepositValue", null, c.toCurrency(item.SelfDepositValue));
                c.setClassText(t, "SelfFirstDepositValue", null, c.toCurrency(item.SelfFirstDepositValue));
                c.setClassText(t, "SelfDepositPaymentCount", null, item.SelfDepositPaymentCount);
                c.setClassText(t, "SelfWithdrawValue", null, c.toCurrency(item.SelfWithdrawValue));
                c.setClassText(t, "SelfFirstWithdrawValue", null, c.toCurrency(item.SelfFirstWithdrawValue));
                c.setClassText(t, "SelfWithdrawPaymentCount", null, item.SelfWithdrawPaymentCount);

                //expandBtn = t.querySelector(".Expand");
                //t.querySelector(".Space").style.paddingLeft = ((item.DealUserAccountInsideLevel - 1) * 20) + "px";


                //if (item.HasChild) {
                //    expandBtn.onclick = new Function("agentExpand('" + item.DealUserAccountSortKey + "')");
                //    expandBtn.classList.add("agentPlus");
                //} else {
                //    expandBtn.style.display = "none";
                //    t.querySelector(".noChild").style.display = "inline-block";
                //}

                //if (item.DealUserAccountInsideLevel != 1) {
                //    if (item.DealUserAccountInsideLevel % 2 == 0) {
                //        t.classList.add("switch_tr");
                //    }

                //    for (var ii = 1; ii < (item.DealUserAccountSortKey.length / 6) - 1; ii++) {
                //        var tempClass = item.DealUserAccountSortKey.substring(0, (ii + 1) * 6);
                //        t.classList.add("row_c_" + tempClass);

                //        if (ii == ((item.DealUserAccountSortKey.length / 6) - 2)) {
                //            parentSortKey = tempClass;
                //            t.classList.add("row_s_" + tempClass);
                //        }
                //    }

                //    t.classList.add("row_child");
                //    t.style.display = "none";
                //} else {
                //    t.classList.add("row_top");
                //}

                ////有搜尋的結果處理
                //if (o.SearchLoginAccount) {

                //    if (item.IsTarget) {
                //        t.style.display = "table-row";
                //        t.classList.add("searchTarget");
                //    } else {
                //        if (o.SearchParentSortKeys && o.SearchParentSortKeys.length > 0) {
                //            for (var ii = 0; ii < o.SearchParentSortKeys.length; ii++) {
                //                switch (o.SearchParentSortKeys[ii]) {
                //                    case parentSortKey:
                //                        t.style.display = "table-row";
                //                        break;
                //                    case item.DealUserAccountSortKey:
                //                        t.style.display = "table-row";
                //                        expandBtn.classList.remove("agentPlus");
                //                        expandBtn.innerText = "-";
                //                        break;
                //                    default:
                //                }
                //            }
                //        }
                //    }
                //}


                idList.appendChild(t);
            }

            if (o.Message == "HasNextPage") {
                $("#btnShowNextData").show();
            } else {
                $("#btnShowNextData").hide();
            }
        } else {
            var div = document.createElement("DIV");
            c.clearChildren(idList);

            div.id = "hasNoData_DIV"
            div.innerHTML = mlp.getLanguageKey("無數據");
            div.classList.add("td__content", "td__hasNoData");
            document.getElementById("idResultTable").classList.add("MT_tableDiv__hasNoData");
            idList.classList.add("tbody__hasNoData");
            idList.appendChild(div);

            window.parent.API_ShowMessageOK(mlp.getLanguageKey("提醒"), mlp.getLanguageKey("無數據"));
        }
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

    function setSearchFrame() {
        var pi = null;
        var templateDiv;
        var CurrencyTypeDiv = document.getElementById("CurrencyTypeDiv");
        var tempCurrencyRadio;
        var tempCurrencyName;


        document.getElementById("startDate").value = getFirstDayOfWeek(Date.today()).toString("yyyy-MM-dd");
        document.getElementById("endDate").value = getLastDayOfWeek(Date.today()).toString("yyyy-MM-dd");
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

    function disableDateSel() {
        var tabItem = document.getElementById("idTabMainContent").getElementsByClassName("nav-link");

        for (var i = 0; i < tabItem.length; i++) {
            //tabItem[i].classList.remove('active');
            tabItem[i].classList.remove('active');
            tabItem[i].parentNode.classList.remove('active');

            //tabItem[i].setAttribute("aria-selected", "false");
        }
        document.getElementById("sliderDate").style.display = "none";
    }

    function showSearchAccountPrecautions() {
        window.parent.API_ShowMessageOK(mlp.getLanguageKey("提醒"), mlp.getLanguageKey("請輸入完整帳號"));
    }

    function init() {
        var d = new Date();

        EWinInfo = window.parent.EWinInfo;
        api = window.parent.API_GetAgentAPI();
        setSearchFrame();

        lang = window.localStorage.getItem("agent_lang");
        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
            //queryOrderSummary(qYear, qMon);
            window.parent.API_CloseLoading();
            SelectedWallet = parent.API_GetSelectedWallet();
            queryData(EWinInfo.UserInfo.LoginAccount);
            ac.dataToggleCollapseInit();
        });
    }

    function EWinEventNotify(eventName, isDisplay, param) {
        switch (eventName) {
            case "WindowFocus":
                //updateBaseInfo();
                ac.dataToggleCollapseInit();
                break;
            case "SelectedWallet":
                SelectedWallet = param;
                queryData(EWinInfo.UserInfo.LoginAccount);
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
                        <span class="language_replace">會員出入金數據</span>
                        <i class="arrow"></i>
                    </h2>
                    <!-- collapse內容 由此開始 ========== -->
                    <div id="searchList" class="collapse-content collapse show">
                        <div id="divSearchContent" class="row searchListContent">
                            <div id="idSearchButton" class="col-12 col-md-6 col-lg-3 col-xl-2">
                                <div class="form-group form-group-s2 ">
                                    <div class="title hidden shown-md">
                                        <span class="language_replace">帳號</span>
                                        <btn style="font-size: 12px; right: 5px; position: absolute; border: 2px solid; width: 22px; text-align: center; border-radius: 11px; color: #bba480; cursor: pointer;" onclick="showSearchAccountPrecautions()">!</btn>
                                    </div>

                                    <div class="form-control-underline iconCheckAnim placeholder-move-right zIndex_overMask_SafariFix">
                                        <input type="text" class="form-control" id="loginAccount" value="" />
                                        <label for="member" class="form-label"><span class="language_replace">帳號</span></label>
                                    </div>

                                </div>
                            </div>
                            <div class="col-12 col-md-6 col-lg-4 col-xl-3">
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

                            <div class="col-12 col-md-6 col-lg-4 col-xl-auto" style="display: none">
                                <!-- 幣別 -->
                                <div class="form-group form-group-s2 ">
                                    <div class="title"><span class="language_replace">幣別</span></div>
                                    <div id="CurrencyTypeDiv" class="content">
                                    </div>
                                </div>

                                <div id="templateDiv" style="display: none">
                                    <div class="custom-control custom-checkboxValue custom-control-inline check-bg">
                                        <label class="custom-label">
                                            <input type="radio" class="custom-control-input-hidden tempRadio">
                                            <div class="custom-input checkbox"><span class="language_replace tempName">Non</span></div>
                                        </label>
                                    </div>
                                </div>
                            </div>
                            <div class="col-12">
                                <div class="form-group wrapper_center dataList-process">
                                    <%--<button class="btn btn-outline-main" onclick="MaskPopUp(this)">取消</button>--%>
                                    <button class="btn btn-full-main btn-roundcorner " onclick="querySelfData()"><i class="icon icon-before icon-ewin-input-submit"></i><span class="language_replace">確認</span></button>
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
                            <div class="tbody__td date td-100 nonTitle">
                                <span class="td__title"><span class="language_replace">帳號</span></span>
                                <span class="td__content Space">
                                    <span class="noChild" style="padding: 0px 12px; display: none"></span>
                                    <span class="LoginAccount">CON5</span>
                                </span>
                            </div>
                            <div class="tbody__td date td-100 nonTitle">
                                <span class="td__title"><span class="language_replace">上線帳號</span></span>
                                <span class="td__content Space">
                                    <span class="noChild" style="padding: 0px 12px; display: none"></span>
                                    <span class="ParentLoginAccount">CON5</span>
                                </span>
                            </div>
                            <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">層級</span></span>
                                <span class="td__content"><i class="icon icon-s icon-before"></i><span class="InsideLevel"></span></span>
                            </div>
                            <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">貨幣</span></span>
                                <span class="td__content"><i class="icon icon-ewin-default-currencyType icon-s icon-before"></i><span class="CurrencyType"></span></span>
                            </div>
                            <%--                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><i class="icon icon-ewin-default-totalWinLose icon-s icon-before"></i><span class="language_replace">團隊入金/出金</span></span>
                                <span class="td__content"><span class="DepositValue"></span><span class="splitIcon">/</span><span class="WithdrawValue num-negative"></span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><i class="icon icon-ewin-default-totalRolling icon-s icon-before"></i><span class="language_replace">>團隊首次入金/出金</span></span>
                                <span class="td__content"><span class="FirstDepositValue"></span><span class="splitIcon">/</span><span class="FirstWithdrawValue num-negative"></span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><i class="icon icon-ewin-default-totalWinLose icon-s icon-before"></i><span class="language_replace">團隊入金/出金筆數</span></span>
                                <span class="td__content"><span class="DepositPaymentCount"></span><span class="splitIcon">/</span><span class="WithdrawPaymentCount num-negative"></span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><i class="icon icon-ewin-default-totalRolling icon-s icon-before"></i><span class="language_replace">團隊首次入金/出金筆數</span></span>
                                <span class="td__content"><span class="FirstDepositPaymentCount"></span><span class="splitIcon">/</span><span class="FirstWithdrawPaymentCount num-negative"></span></span>
                            </div>--%>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><i class="icon icon-ewin-default-totalRolling icon-s icon-before"></i><span class="language_replace">個人入金/出金</span></span>
                                <span class="td__content"><span class="SelfDepositValue"></span><span class="splitIcon">/</span><span class="SelfWithdrawValue num-negative"></span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><i class="icon icon-ewin-default-accountWinLose icon-s icon-before"></i><span class="language_replace">個人首次入金/出金</span></span>
                                <span class="td__content"><span class="SelfFirstDepositValue"></span><span class="splitIcon">/</span><span class="SelfFirstWithdrawValue num-negative"></span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><i class="icon icon-ewin-default-accountRolling icon-s icon-before"></i><span class="language_replace">個人入金/出金筆數</span></span>
                                <span class="td__content"><span class="SelfDepositPaymentCount"></span><span class="splitIcon">/</span><span class="SelfWithdrawPaymentCount num-negative"></span></span>
                            </div>
                        </div>
                    </div>
                    <!-- 標題項目  -->
                    <div class="thead">
                        <!--標題項目單行 -->
                        <div class="thead__tr">
                            <div class="thead__th"><span class="language_replace">帳號</span></div>
                            <div class="thead__th"><span class="language_replace">上線帳號</span></div>
                            <div class="thead__th"><span class="language_replace">層級</span></div>
                            <div class="thead__th"><span class="language_replace">貨幣</span></div>
                            <%--                            <div class="thead__th"><span class="language_replace">團隊入金/出金</span></div>
                            <div class="thead__th"><span class="language_replace">團隊首次入金/出金</span></div>
                            <div class="thead__th"><span class="language_replace">團隊入金/出金筆數</span></div>
                            <div class="thead__th"><span class="language_replace">團隊首次入金/出金筆數</span></div>--%>
                            <div class="thead__th"><span class="language_replace">個人入金/出金</span></div>
                            <div class="thead__th"><span class="language_replace">個人首次入金/出金</span></div>
                            <div class="thead__th"><span class="language_replace">個人入金/出金筆數</span></div>
                        </div>
                    </div>
                    <!-- 表格上下滑動框 -->
                    <div class="tbody" id="idList">
                    </div>
                    <div class="row" style="position: absolute; left: 0; right: 0; margin: 0 auto; padding-top: 40px;">
                        <div class="col-12" id="btnShowNextData" style="display: none;">
                            <div class="form-group wrapper_center dataList-process">
                                <button style="max-width: 30%;" class="btn btn-full-main btn-roundcorner " onclick="showNextData()"><i class="icon icon-before icon-ewin-input-submit"></i><span class="language_replace">查看更多</span></button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</body>
<script type="text/javascript">
    ac.listenScreenMove();

    function clickMask() {
        // document.getElementById("div_MaskSafariFix").style.display = "none";
        document.getElementById("div_MaskSafariFix").classList.remove("show");
    }
</script>
</html>
