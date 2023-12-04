<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GetAgentAccounting_Casino.aspx.cs" Inherits="GetAgentAccounting_Casino" %>

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
    <title>傭金結算查詢</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/basic.min.css?<%:AgentVersion%>">
    <link rel="stylesheet" href="css/main2.css?<%:AgentVersion%>">
</head>
<!-- <script type="text/javascript" src="js/AgentCommon.js"></script> -->
<script type="text/javascript" src="js/AgentCommon.js"></script>
<script type="text/javascript" src="/Scripts/Common.js"></script>
<script type="text/javascript" src="/Scripts/bignumber.min.js"></script>
<script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
<script type="text/javascript" src="Scripts/MultiLanguage.js"></script>
<script type="text/javascript" src="js/date.js"></script>
<script src="js/jquery-3.3.1.min.js"></script>
<script>
    var ApiUrl = "GetAgentAccounting_Casino.aspx";
    var c = new common();
    var ac = new AgentCommon();
    var mlp;
    var EWinInfo;
    var api;
    var lang;
    var qYear;
    var qMon;
    var SelectedWallet;

    function queryData() {
        var idList = document.getElementById("idList");
        var CurrencyType = $("input[name='chkCurrencyType']").val();
        var startDate = $('#startDate').val();
        var endDate = $('#endDate').val();
        var postData = {
            AID: EWinInfo.ASID,
            CurrencyType: SelectedWallet,
            StartDate: startDate,
            EndDate: endDate
        };

        window.parent.API_ShowLoading();
        $("#btnSearch").prop('disabled', true);
        c.callService(ApiUrl + "/GetAccountingItem", postData, function (success, o) {
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

            $("#btnSearch").prop('disabled', false);
            window.parent.API_CloseLoading();
        });
    }

    function updateList(o) {

        $('#idList').empty();
        $('#idList').removeClass('tbody__hasNoData');

        if (o != null) {
            if (o.AccountingList != null && o.AccountingList.length > 0) {
                var CurrencyType = $("input[name='chkCurrencyType']").val();
                //只顯示個人投注
                for (var i = 0; i < o.AccountingList.length; i++) {

                    var data = o.AccountingList[i];
                    let RebateStatus = mlp.getLanguageKey("已派發");
                    let FailureCondition = "";

                    if (data.RebateStatus == 2) {
                        RebateStatus = mlp.getLanguageKey("條件不足");
                    }

                    if (data.FailureCondition) {
                        if (data.FailureCondition.indexOf("ActiveUser") > -1) {
                            FailureCondition += mlp.getLanguageKey("ActiveUser") + ";";
                        }
                        if (data.FailureCondition.indexOf("RebateAmountMin") > -1) {
                            FailureCondition += mlp.getLanguageKey("RebateAmountMin") + ";";
                        }
                    } else {
                        FailureCondition = "--";
                    }

                    var doc = ` <div class="tbody__tr td-non-underline-last-2">
                            <div class="tbody__td td-function-execute floatT-right">
                                <!-- <span class="td__title"><span class="language_replace"></span></span> -->
                                <span class="td__content">
                                    <button onclick="btnDetail_Click(${data.AccountingID},'${SelectedWallet}','${data.StartDate}','${data.EndDate}')" class="btnAgentDetail btn btn-icon"><i class="icon icon-ewin-input-betDetail icon-before icon-line-vertical"></i><span class="language_replace">${mlp.getLanguageKey("結算細節")}</span></button></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">結算名稱</span></span>
                                <span class="td__content"><span class="AccountingName">${data.AccountingName}</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">幣別</span></span>
                                <span class="td__content"><span class="CurrencyType">${SelectedWallet}</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">團隊輸贏數</span></span>
                                <span class="td__content"><span class="RewardValue">${toCurrency(data.RewardValue)}</span></span>
                            </div>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">團隊轉碼數</span></span>
                                <span class="td__content"><span class="ValidBetValue">${toCurrency(data.ValidBetValue)}</span></span>
                            </div>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">應得佣金</span></span>
                                <span class="td__content"><span class="AccountingOPValue">${toCurrency(data.AccountingOPValue)}</span></span>
                            </div>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">個人已付佣金</span></span>
                                <span class="td__content"><span class="PaidOPValue">${toCurrency(data.PaidOPValue)}</span></span>
                            </div>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">派發狀態</span></span>
                                <span class="td__content"><span class="BonusValue_Own">${RebateStatus}</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">結算開始日期</span></span>
                                <span class="td__content"><span class="StartDate">${data.StartDate}</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">結算結束日期</span></span>
                                <span class="td__content"><span class="EndDate">${data.EndDate}</span></span>
                            </div>
                                <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">建立時間</span></span>
                                <span class="td__content"><span class="CreateDate">${data.CreateDate}</span></span>
                            </div>
                        </div>`;


                    $('#idList').append(doc);
                }
            } else {
                $('#idList').append('<div class="td__content td__hasNoData">' + mlp.getLanguageKey("無數據") + '</div>');
                $('#idList').addClass('tbody__hasNoData');
            }
        } else {
            $('#idList').append('<div class="td__content td__hasNoData">' + mlp.getLanguageKey("無數據") + '</div>');
            $('#idList').addClass('tbody__hasNoData');
        }
    }

    function toCurrency(num) {

        num = parseFloat(Number(num).toFixed(4));
        var parts = num.toString().split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        return parts.join('.');
    }

    function btnDetail_Click(accountingID, CurrencyType, StartDate, EndDate) {
        window.parent.API_NewWindow(mlp.getLanguageKey("結算細節"), "GetAgentAccountingDetail_Casino.aspx?AccountingID=" + accountingID + "&CurrencyType=" + SelectedWallet + "&StartDate=" + StartDate + "&EndDate=" + EndDate);
    }

    function init() {

        $('#ToggleCollapse').click();
        $('#ToggleCollapse').click();
        EWinInfo = window.parent.EWinInfo;
        api = window.parent.API_GetAgentAPI();

        lang = window.localStorage.getItem("agent_lang");
        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
            SelectedWallet = parent.API_GetSelectedWallet();
            setSearchFrame();
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
                queryData();
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

        if (EWinInfo.UserInfo != null) {
            if (EWinInfo.UserInfo.WalletList != null) {
                pi = EWinInfo.UserInfo.WalletList;
                if (pi.length > 0) {
                    for (var i = 0; i < pi.length; i++) {
                        templateDiv = c.getTemplate("templateDiv");

                        tempCurrencyRadio = c.getFirstClassElement(templateDiv, "tempRadio");
                        tempCurrencyName = c.getFirstClassElement(templateDiv, "tempName");
                        tempCurrencyRadio.value = pi[i].CurrencyType;
                        tempCurrencyRadio.name = "chkCurrencyType";
                        tempCurrencyName.innerText = pi[i].CurrencyType;

                        if (i == 0) {
                            tempCurrencyRadio.checked = true;
                        }

                        tempCurrencyRadio.classList.remove("tempRadio");
                        tempCurrencyName.classList.remove("tempName");

                        CurrencyTypeDiv.appendChild(templateDiv);
                    }
                }
            }
        }

        queryData();
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

    function showNote() {
        window.parent.API_ShowMessageOK(mlp.getLanguageKey("提醒"),

            `${mlp.getLanguageKey("總佔成佣金: (-1*總上下數)*自身佔成率")}<br />
                    ${mlp.getLanguageKey("總洗碼佣金: 總洗碼數*自身轉碼率")}<br />
                    ${mlp.getLanguageKey("洗碼佣金成本: 總洗碼佣金*自身佔成率")}<br />
                    ${mlp.getLanguageKey("下線佔成佣金加總: 指下線的佔成佣金數合計")}<br />
                    ${mlp.getLanguageKey("下線洗碼佣金加總: 指下線的轉碼佣金數合計")}<br />
                    ${mlp.getLanguageKey("佔成佣金: 總佔成佣金-下線佔成佣金加總")}<br />
                    ${mlp.getLanguageKey("轉碼佣金: 總洗碼佣金-下線洗碼佣金加總-洗碼佣金成本")}<br />
                    ${mlp.getLanguageKey("已付佣金: 指已經收到的佣金")}<br />
                    ${mlp.getLanguageKey("應付佣金: 佔成佣金+轉碼佣金")}<br />`
        );
    }

    window.onload = init;
</script>
<body class="innerBody">
    <main>
        <div class="dataList dataList-box fixed top real-fixed">
            <div class="container-fluid">
                <div class="collapse-box">
                    <h2 id="ToggleCollapse" class="collapse-header has-arrow zIndex_overMask_SafariFix" onclick="ac.dataToggleCollapse(this)" data-toggle="collapse" data-target="#searchList" aria-controls="searchList" aria-expanded="true" aria-label="searchList">
                        <span class="language_replace">佣金結算報表</span>
                        <i class="arrow"></i>
                    </h2>
                    <!-- collapse內容 由此開始 ========== -->
                    <div id="searchList" class="collapse-content collapse show">
                        <div id="divSearchContent" class="row searchListContent">
                            <div class="col-12 col-md-6 col-lg-4 col-xl-4">
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

                            <div class="col-12 col-md-12 col-lg-8 col-xl-8">
                                <div id="idTabMainContent">
                                    <ul class="nav-tabs-block nav nav-tabs tab-items-4" role="tablist">
                                        <li class="nav-item">
                                            <a onclick="changeDateTab(this,0)" class="nav-link language_replace" data-toggle="tab" href="" role="tab" aria-selected="true">本日</a>
                                        </li>
                                        <li class="nav-item">
                                            <a onclick="changeDateTab(this,1)" class="nav-link language_replace" data-toggle="tab" href="" role="tab" aria-selected="true">昨天</a>
                                        </li>
                                        <li class="nav-item active">
                                            <a onclick="changeDateTab(this,2)" class="nav-link language_replace active" data-toggle="tab" href="" role="tab" aria-selected="true">本週</a>
                                        </li>
                                        <%--<li class="nav-item">
                                            <a onclick="changeDateTab(this,3)" class="nav-link language_replace" data-toggle="tab" href="" role="tab" aria-selected="true">上週</a>
                                        </li>--%>
                                        <li class="nav-item">
                                            <a onclick="changeDateTab(this,4)" class="nav-link language_replace" data-toggle="tab" href="" role="tab" aria-selected="true">本月</a>
                                        </li>
                                        <%--<li class="nav-item">
                                            <a onclick="changeDateTab(this,5)" class="nav-link language_replace" data-toggle="tab" href="" role="tab" aria-selected="true">上月</a>
                                        </li>--%>
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
                                    <%--<button class="btn btn-outline-main" onclick="showNote()">!</button>--%>
                                    <button class="btn btn-full-main btn-roundcorner " onclick="queryData()" id="btnSearch"><i class="icon icon-before icon-ewin-input-submit"></i><span class="language_replace">確認</span></button>
                                    <button class=" btn-outline-main" style="width:10%;border-radius: 11px;margin-left:5px" onclick="showNote()">!</button>
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
        <div class="container-fluid wrapper__TopCollapse orderHistory_userAccount top_collapse">
            <div class="MT__tableDiv" id="idResultTable">
                <!-- 自訂表格 -->
                <div class="MT__table table-col-8 w-200">
                    <div id="templateTableItem" style="display: none">
                        <div class="tbody__tr td-non-underline-last-2">
                            <div class="tbody__td td-function-execute floatT-right">
                                <!-- <span class="td__title"><span class="language_replace"></span></span> -->
                                <span class="td__content">
                                    <button class="btnAgentDetail btn btn-icon"><i class="icon icon-ewin-input-betDetail icon-before icon-line-vertical"></i><span class="language_replace">結算細節</span></button></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">結算名稱</span></span>
                                <span class="td__content"><span class="AccountingName"></span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">幣別</span></span>
                                <span class="td__content"><span class="CurrencyType"></span></span>
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
                                <span class="td__title"><span class="language_replace">個人已付佣金</span></span>
                                <span class="td__content"><span class="PaidOPValue"></span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">結算開始日期</span></span>
                                <span class="td__content"><span class="StartDate">CON5</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">結算結束日期</span></span>
                                <span class="td__content"><span class="EndDate">CON5</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">建立時間</span></span>
                                <span class="td__content"><span class="CreateDate">CON5</span></span>
                            </div>
                        </div>
                    </div>
                    <!-- 標題項目  -->
                    <div class="thead">
                        <!--標題項目單行 -->
                        <div class="thead__tr">
                            <div class="thead__th"><span class="language_replace">結算細節</span></div>
                            <div class="thead__th"><span class="language_replace">結算名稱</span></div>
                            <div class="thead__th"><span class="language_replace">幣別</span></div>
                            <div class="thead__th"><span class="language_replace">總輸贏</span></div>
                            <div class="thead__th"><span class="language_replace">總轉碼</span></div>
                            <div class="thead__th"><span class="language_replace">應付傭金</span></div>
                            <div class="thead__th"><span class="language_replace">個人已付佣金</span></div>
                            <div class="thead__th"><span class="language_replace">派發狀態</span></div>
                            <div class="thead__th"><span class="language_replace">結算開始日期</span></div>
                            <div class="thead__th"><span class="language_replace">結算結束日期</span></div>
                            <div class="thead__th"><span class="language_replace">建立時間</span></div>
                        </div>
                    </div>
                    <!-- 表格上下滑動框 -->
                    <div class="tbody" id="idList">
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
