<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GetGameSetResult.aspx.cs" Inherits="GetGameSetResult" %>

<%
    string LoginAccount = Request["LoginAccount"];
    string ASID = Request["ASID"];
    string AgentVersion = EWinWeb.AgentVersion;
    EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
    EWin.BmAgent.AgentSessionResult ASR = null;
    EWin.BmAgent.AgentSessionInfo ASI = null;

    ASR = api.GetAgentSessionByID(ASID);

    if (ASR.Result != EWin.BmAgent.enumResult.OK)
    {
        Response.Redirect("login.aspx");
    }
    else
    {
        ASI = ASR.AgentSessionInfo;
    }

%>
<!doctype html>
<html lang="zh-Hant-TW" class="innerHtml">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>團隊投注數據</title>
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
<script type="text/javascript" src="../Scripts/jquery-3.3.1.min.js"></script>
<script>
    var ApiUrl = "GetGameSetResult.aspx";
    var c = new common();
    var ac = new AgentCommon();
    var mlp;
    var EWinInfo;
    var api;
    var lang;
    var startDate;
    var endDate;
    var currencyType = "";
    var basicInsideLevel;
    var basicSortKey;    
    var SelectedWallet;

    function querySearchData() {
        if (SelectedWallet != "") {
            var postData = {
                AID: EWinInfo.ASID,
                TargetLoginAccount: $("#loginAccount").val(),
                QueryBeginDate:  $("#startDate").val(),
                QueryEndDate:  $("#endDate").val(),
                CurrencyType: SelectedWallet
            };

            if (new Date(postData.QueryBeginDate) <= new Date(postData.QueryEndDate)) {

                window.parent.API_ShowLoading();
                $("#btnSearch").prop('disabled', true);
                c.callService(ApiUrl + "/GetGameSetData", postData, function (success, o) {
                    if (success) {
                        var obj = c.getJSON(o);

                        if (obj.Result == 0) {
                            updateSearchList(obj);
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
            } else {
                window.parent.API_ShowMessageOK(mlp.getLanguageKey("提醒"), mlp.getLanguageKey("結束日期不可小於起起始日期"));
            }
        }
        else {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("提醒"), mlp.getLanguageKey("請至少選擇一個幣別!!"));
        }
    }

    function updateSearchList(o) {
        var idList = document.getElementById("idList");
        c.clearChildren(idList);

        if (o.Datas && o.Datas.length > 0) {
            document.getElementById("idResultTable").classList.remove("MT_tableDiv__hasNoData");
            idList.classList.remove("tbody__hasNoData");

            for (var i = 0; i < o.Datas.length; i++) {
                var item = o.Datas[i];
                var t = c.getTemplate("templateTableItem");
                 let btnDetail;
                var gameSetState = "";

                c.setClassText(t, "GameSetNumber", null, item.GameSetNumber);
                c.setClassText(t, "CurrencyType", null, item.CurrencyType);

                switch (item.GameSetState) {
                    case -1:
                        gameSetState = mlp.getLanguageKey("尚未建立");
                        break;
                    case 0:
                        gameSetState = mlp.getLanguageKey("建立");
                        break;
                    case 1:
                        gameSetState = mlp.getLanguageKey("進行中");
                        break;
                    case 2:
                        gameSetState = mlp.getLanguageKey("暫停");
                        break;
                    case 3:
                        gameSetState = mlp.getLanguageKey("完場");
                        break;
                    case 4:
                        gameSetState = mlp.getLanguageKey("結算完成");
                        break;
                    case 5:
                        gameSetState = mlp.getLanguageKey("取消");
                        break;
                }
                c.setClassText(t, "GameSetState", null, gameSetState);

                if (parseFloat(item.RewardValue) < 0) {
                    t.getElementsByClassName("RewardValue")[0].classList.add("num-negative");
                }
                c.setClassText(t, "RewardValue", null, toCurrency(item.RewardValue));

                c.setClassText(t, "LoginAccount", null, item.LoginAccount);
                c.setClassText(t, "CreateDate", null, item.CreateDate);
                
                btnDetail = t.querySelector(".btnDetail");
                btnDetail.onclick = new Function("btnDetail_Click('" + item.GameSetID + "')");

                idList.appendChild(t);
            }
        } else {
            c.clearChildren(idList);
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

    function btnDetail_Click(GameSetID) {
        window.parent.API_NewWindow(mlp.getLanguageKey("細節"), "GetGameSetDetail.aspx?GameSetID=" + GameSetID);
    }

    function toCurrency(num) {

        num = parseFloat(Number(num).toFixed(4));
        var parts = num.toString().split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        return parts.join('.');
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
            //queryData(EWinInfo.UserInfo.LoginAccount);
            SelectedWallet = parent.API_GetSelectedWallet();
            querySearchData();
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
                querySearchData();
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
                        <span class="language_replace">電投開工記錄</span>
                        <i class="arrow"></i>
                    </h2>
                    <!-- collapse內容 由此開始 ========== -->
                    <div id="searchList" class="collapse-content collapse show">
                        <div id="divSearchContent" class="row searchListContent">
                            <div id="idSearchButton" class="col-12 col-md-4 col-lg-2 col-xl-2">
                                <div class="form-group form-group-s2 ">
                                    <div class="title hidden shown-md"><span class="language_replace">帳號</span>
                                         <btn style="font-size: 12px; right: 5px; position: absolute; border: 2px solid; width: 22px; text-align: center; border-radius: 11px; color: #bba480; cursor: pointer;" onclick="showSearchAccountPrecautions()">!</btn>
										 </div>

                                    <div class="form-control-underline iconCheckAnim placeholder-move-right zIndex_overMask_SafariFix">
                                        <input type="text" class="form-control" id="loginAccount" value="" />
                                        <label for="member" class="form-label"><span class="language_replace">帳號</span></label>
                                    </div>

                                </div>
                            </div>
                            <div class="col-12 col-md-5 col-lg-4 col-xl-3">
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

                            <div class="col-12 col-md-12 col-lg-5 col-xl-6">
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
                                      <%--  <li class="nav-item">
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
                                    <button class="btn btn-full-main btn-roundcorner " onclick="querySearchData()" id="btnSearch"><i class="icon icon-before icon-ewin-input-submit"></i><span class="language_replace">確認</span></button>
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
                           <div class="tbody__td td-function-execute floatT-right">
                                <!-- <span class="td__title"><span class="language_replace"></span></span> -->
                                <span class="td__content">
                                    <button class="btnDetail btn btn-icon"><i class="icon icon-ewin-input-betDetail icon-before icon-line-vertical"></i><span class="language_replace">細節</span></button></span>
                            </div>
                            <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">單號</span></span>
                                <span class="td__content"><i class="icon icon-s icon-before"></i><span class="GameSetNumber"></span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><i class="icon icon-ewin-default-totalRolling icon-s icon-before"></i><span class="language_replace">帳號</span></span>
                                <span class="td__content"><span class="LoginAccount">CON4</span></span>
                            </div>
                            <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">幣別</span></span>
                                <span class="td__content"><i class="icon icon-s icon-before"></i><span class="CurrencyType"></span></span>
                            </div>
                            <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">狀態</span></span>
                                <span class="td__content"><i class="icon icon-ewin-default-currencyType icon-s icon-before"></i><span class="GameSetState">CON3</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><i class="icon icon-ewin-default-totalWinLose icon-s icon-before"></i><span class="language_replace">輸贏數</span></span>
                                <span class="td__content"><span class="RewardValue">CON4</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><i class="icon icon-ewin-default-totalRolling icon-s icon-before"></i><span class="language_replace">建立日期</span></span>
                                <span class="td__content"><span class="CreateDate">CON4</span></span>
                            </div>
                        </div>
                    </div>
                    <!-- 標題項目  -->
                    <div class="thead">
                        <!--標題項目單行 -->
                        <div class="thead__tr">
                            <div class="thead__th"><span class="language_replace">細節</span></div>
                            <div class="thead__th"><span class="language_replace">單號</span></div>
                            <div class="thead__th"><span class="language_replace">帳號</span></div>
                            <div class="thead__th"><span class="language_replace">貨幣</span></div>
                            <div class="thead__th"><span class="language_replace">狀態</span></div>
                            <div class="thead__th"><span class="language_replace">輸贏數</span></div>
                            <div class="thead__th"><span class="language_replace">建立日期</span></div>
                        </div>
                    </div>
                    <!-- 表格上下滑動框 -->
                    <div class="tbody" id="idList">
                    </div>
                </div>
            </div>
        </div>
        <div id="templateMoreRow" style="display: none;">
                   <div class="tbody__tr td-non-underline-last-2">
                            <div class="tbody__td date td-100 nonTitle expand_tr">
                                  <button class="moreBtn btn2 btn-outline-main language_replace">更多</button>
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
