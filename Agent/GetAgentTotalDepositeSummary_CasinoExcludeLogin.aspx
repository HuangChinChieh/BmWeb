<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GetAgentTotalDepositeSummary_CasinoExcludeLogin.aspx.cs" Inherits="GetAgentTotalDepositeSummary_CasinoExcludeLogin" %>

<%
    string AgentVersion = EWinWeb.AgentVersion;
%>
<!doctype html>
<html lang="zh-Hant-TW" class="innerHtml">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>團隊出入金數據</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/basic.min.css?<%:AgentVersion%>">
    <link rel="stylesheet" href="css/main2.css?<%:AgentVersion%>">
    <script src="js/jquery-3.3.1.min.js"></script>
    <style>
         #idList {
            background-color:black;
        }

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

        .splitIcon {
            padding-left: 5px;
            padding-right: 5px;
            font-weight: 900;
            color: rgba(227, 195, 141, 0.8);
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
<script type="text/javascript" src="js/date.js"></script>
<script>
    var ApiUrl = "GetAgentTotalDepositeSummary_CasinoExcludeLogin.aspx";
    var c = new common();
    var ac = new AgentCommon();
    var mlp;
    var EWinInfo;
    var lang;
    var startDate;
    var endDate;
    var currencyType = "PHP";
    var mainLoginAccount;
    
    function agentExpand(SortKey, UserAccountID) {
        var expandBtn = event.currentTarget;
        if (expandBtn) {
            var exists = !(expandBtn.classList.toggle("agentPlus"));
            if (exists) {
                var isLoaded = expandBtn.dataset.isloaded;
                expandBtn.innerText = "-";

                if (isLoaded == "Y") {
                    checkParentLoginAccountExists(SortKey);
                } else {
                    queryData(UserAccountID, expandBtn.parentElement.parentElement.parentElement);
                }
            } else {
                //c
                expandBtn.innerText = "+";
                hideChildAllRow(SortKey);
            }
        }
    }

    function checkParentLoginAccountExists(SortKey) {
        var doms = document.querySelectorAll(".row_s_" + SortKey);
        for (var ii = 0; ii < doms.length; ii++) {
            var dom = doms[ii];
            dom.style.display = "table-row";
        }
    }

    function hideChildAllRow(SortKey) {
        var doms = document.querySelectorAll(".row_c_" + SortKey);
        for (var i = 0; i < doms.length; i++) {
            var dom = doms[i];
            var btn = dom.querySelector('.Expand');

            dom.style.display = "none";
            if (btn) {
                btn.classList.add("agentPlus");
                btn.innerText = "+";
            }
        }
    }

    function toggleAllRow(isExpand) {
        var doms = document.querySelectorAll(".row_child");
        for (var i = 0; i < doms.length; i++) {
            var dom = doms[i];
            var btn = dom.querySelector('.Expand');

            if (isExpand) {
                dom.style.display = "table-row";

                if (btn) {
                    btn.classList.remove("agentPlus");
                    btn.innerText = "-";
                }
            } else {
                dom.style.display = "none";

                if (btn) {
                    btn.classList.add("agentPlus");
                    btn.innerText = "+";
                }
            }
        }

        doms = document.querySelectorAll(".row_top");

        for (var i = 0; i < doms.length; i++) {
            var dom = doms[i];
            var btn = dom.querySelector('.Expand');

            if (isExpand) {
                if (btn) {
                    btn.classList.remove("agentPlus");
                    btn.innerText = "-";
                }
            } else {
                if (btn) {
                    btn.classList.add("agentPlus");
                    btn.innerText = "+";
                }
            }
        }
    }


    function moreBtnClick(userAccountID) {
        var targetBtn = event.currentTarget;
        var targetDom = targetBtn.parentElement.parentElement;
        //var page = Number(targetBtn.dataset.page);
        //queryData(userAccountID, (page + 1), targetDom);
    }
    function querySelfData() {
        var currencyTypeDom = "";

        startDate = document.getElementById("startDate");
        endDate = document.getElementById("endDate");
        currencyTypeDom = document.getElementsByName("chkCurrencyType");

        if (currencyTypeDom) {
            if (currencyTypeDom.length > 0) {
                for (i = 0; i < currencyTypeDom.length; i++) {
                    if (currencyTypeDom[i].checked == true) {
                        currencyType = currencyTypeDom[i].value;
                        break;
                    }
                }
            }
        }

        mainLoginAccount = $('#mainLoginAccount').val();
        if (mainLoginAccount.trim() == '') {
            alert("帳號不能為空");
            return;
        }

        if (loginAccount.value.trim() != '') {
            querySearchData(loginAccount.value);
        } else {
            queryData(0, null);
        }
    }

    function queryData(targetUserAccountID, targetDom) {
        if (currencyType != "") {
            var UserAccountID;

            if (targetUserAccountID) {
                UserAccountID = targetUserAccountID;
            } else {
                UserAccountID = 0;
            }

            var postData = {
                LoginAccount: mainLoginAccount,
                TargetUserAccountID: UserAccountID,
                QueryBeginDate: startDate.value,
                QueryEndDate: endDate.value,
                CurrencyType: currencyType,
            };

            if (new Date(postData.QueryBeginDate) <= new Date(postData.QueryEndDate)) {

              ShowLoading();
                c.callService(ApiUrl + "/GetAgentTotalDepositeSummary", postData, function (success, o) {
                    if (success) {
                        var obj = c.getJSON(o);

                        if (obj.Result == 0) {
                            updateList(obj, UserAccountID, targetDom);
                        } else {
                            alert("錯誤:" + obj.Message);
          
                        }
                    } else {
                        if (o == "Timeout") {
                            alert("錯誤:" + "網路異常, 請稍後重新嘗試");
                        } else {
                            alert("錯誤:" + o);
                        }
                    }

                    CloseLoading();
                });
            } else {
                alert("錯誤:" + "結束日期不可小於起起始日期");
  
            }
        }
        else {
            alert("錯誤:" + "請至少選擇一個幣別!!");
        }
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

    function querySearchData(LoginAccount) {
        if (currencyType != "") {
            var postData = {
                LoginAccount: mainLoginAccount,
                TargetLoginAccount: LoginAccount,
                QueryBeginDate: startDate.value,
                QueryEndDate: endDate.value,
                CurrencyType: currencyType
            };

            if (new Date(postData.QueryBeginDate) <= new Date(postData.QueryEndDate)) {

              ShowLoading();
                c.callService(ApiUrl + "/GetAgentTotalDepositeSummaryBySearch", postData, function (success, o) {
                    if (success) {
                        var obj = c.getJSON(o);

                        if (obj.Result == 0) {
                            updateSearchList(obj);
                        } else {
                            alert("錯誤:" + obj.Message);
                        }
                    } else {
                        if (o == "Timeout") {
                            alert("錯誤:" + "網路異常, 請稍後重新嘗試");
                        } else {
                            alert("錯誤:" + o);
                        }
                    }

                    CloseLoading();
                });
            } else {
                alert("錯誤:" + "結束日期不可小於起起始日期");
            }
        }
        else {
            alert("錯誤:" + "請至少選擇一個幣別");
        }
    }



    function updateList(o, userAccountID, targetDom) {
        var idList = document.getElementById("idList");


        if (userAccountID == 0) {
            basicInsideLevel = o.SelfInsideLevel;
            basicSortKey = o.SelfSortKey;
        }

        var moreBtnRowDom;
        var moreBtnDom;


        if (o.SummaryList && o.SummaryList.length > 0) {
            if (targetDom) {
                //page == 1 =>  targetDom =加號按鈕的Row
                moreBtnRowDom = c.getTemplate("templateMoreRow");
                moreBtnDom = moreBtnRowDom.querySelector(".moreBtn");
                moreBtnDom.dataset.page = "1";
                moreBtnDom.onclick = new Function("moreBtnClick('" + userAccountID + "')");
                moreBtnDom.style.marginLeft = ((o.SelfInsideLevel + 1) * 20) + "px";
                idList.insertBefore(moreBtnRowDom, targetDom.nextSibling);

                targetDom.querySelector(".Expand").dataset.isloaded = "Y";


                moreBtnRowDom.style.display = "none";



            } else {

                //初始化
                c.clearChildren(idList);

                moreBtnRowDom = c.getTemplate("templateMoreRow");
                moreBtnDom = moreBtnRowDom.querySelector(".moreBtn");
                moreBtnDom.dataset.page = "1";
                moreBtnDom.onclick = new Function("moreBtnClick('" + userAccountID + "')");
                moreBtnDom.style.marginLeft = ((o.SelfInsideLevel + 1) * 20) + "px";
                idList.appendChild(moreBtnRowDom);
                moreBtnRowDom.style.display = "none";
            }


            document.getElementById("idResultTable").classList.remove("MT_tableDiv__hasNoData");
            idList.classList.remove("tbody__hasNoData");
            //expandDiv.style.display = "block";
            for (var i = 0; i < o.SummaryList.length; i++) {
                var item = o.SummaryList[i];
                var DealUserAccountInsideLevel = item.UserAccountInsideLevel - basicInsideLevel;
                var DealUserAccountSortKey = item.UserAccountSortKey.substring(basicSortKey.length);
                var t = c.getTemplate("templateTableItem");
                var expandBtn;
                var parentSortKey = "";

                c.setClassText(t, "LoginAccount", null, item.LoginAccount);
                c.setClassText(t, "ParentLoginAccount", null, item.ParentLoginAccount);
                c.setClassText(t, "InsideLevel", null, DealUserAccountInsideLevel);
                c.setClassText(t, "CurrencyType", null, item.CurrencyType);
                c.setClassText(t, "DepositValue", null, c.toCurrency(item.DepositValue));
                c.setClassText(t, "FirstDepositValue", null, c.toCurrency(item.FirstDepositValue));;
                c.setClassText(t, "DepositPaymentCount", null, item.DepositPaymentCount);
                c.setClassText(t, "FirstDepositPaymentCount", null, item.FirstDepositPaymentCount);
                c.setClassText(t, "WithdrawValue", null, c.toCurrency(item.WithdrawValue));
                c.setClassText(t, "FirstWithdrawValue", null, c.toCurrency(item.FirstWithdrawValue));
                c.setClassText(t, "WithdrawPaymentCount", null, item.WithdrawPaymentCount);
                c.setClassText(t, "FirstWithdrawPaymentCount", null, item.FirstWithdrawPaymentCount);
                c.setClassText(t, "SelfDepositValue", null, c.toCurrency(item.SelfDepositValue));
                c.setClassText(t, "SelfFirstDepositValue", null, c.toCurrency(item.SelfFirstDepositValue));
                c.setClassText(t, "SelfDepositPaymentCount", null, item.SelfDepositPaymentCount);
                c.setClassText(t, "SelfWithdrawValue", null, c.toCurrency(item.SelfWithdrawValue));
                c.setClassText(t, "SelfFirstWithdrawValue", null, c.toCurrency(item.SelfFirstWithdrawValue));
                c.setClassText(t, "SelfWithdrawPaymentCount", null, item.SelfWithdrawPaymentCount);

                expandBtn = t.querySelector(".Expand");
                t.querySelector(".Space").style.paddingLeft = ((DealUserAccountInsideLevel - 1) * 20) + "px";

                if (item.HasChild) {
                    expandBtn.onclick = new Function("agentExpand('" + DealUserAccountSortKey + "', " + item.UserAccountID.toString() + ")");
                    expandBtn.classList.add("agentPlus");
                    expandBtn.dataset.isloaded = "N";
                } else {
                    expandBtn.style.display = "none";
                    t.querySelector(".noChild").style.display = "inline-block";
                }

                if (DealUserAccountInsideLevel != 1) {
                    if (DealUserAccountInsideLevel % 2 == 0) {
                        t.classList.add("switch_tr");
                    }


                    for (var ii = 1; ii < (DealUserAccountSortKey.length / 6); ii++) {
                        var tempClass = DealUserAccountSortKey.substring(0, ii * 6);
                        t.classList.add("row_c_" + tempClass);

                        if (ii == ((DealUserAccountSortKey.length / 6) - 1)) {
                            parentSortKey = tempClass;
                            t.classList.add("row_s_" + tempClass);
                        }
                    }

                    t.classList.add("row_child");
                } else {
                    t.classList.add("row_top");
                }

                idList.insertBefore(t, moreBtnRowDom);
            }
        } else {
            if (!targetDom) {
                //var div = document.createElement("DIV");

                //div.id = "hasNoData_DIV"
                //div.innerHTML = mlp.getLanguageKey("無數據");
                //div.classList.add("td__content", "td__hasNoData");
                //document.getElementById("idResultTable").classList.add("MT_tableDiv__hasNoData");
                //idList.classList.add("tbody__hasNoData");
                //idList.appendChild(div);
                alert("提醒:" + "無數據");
            }           
        }
    }
    function updateSearchList(o) {
        var idList = document.getElementById("idList");
        c.clearChildren(idList);

        if (o.SummaryList && o.SummaryList.length > 0) {
            document.getElementById("idResultTable").classList.remove("MT_tableDiv__hasNoData");
            idList.classList.remove("tbody__hasNoData");
            //expandDiv.style.display = "block";
            for (var i = 0; i < o.SummaryList.length; i++) {
                var item = o.SummaryList[i];

                if (item.UserAccountSortKey == o.TopSortKey) {
                    continue;
                }

                var DealUserAccountInsideLevel = item.UserAccountInsideLevel - o.TopInsideLevel;
                var DealUserAccountSortKey = item.UserAccountSortKey.substring(o.TopSortKey.length);
                var t = c.getTemplate("templateTableItem");
                var expandBtn;
                c.setClassText(t, "LoginAccount", null, item.LoginAccount);
                c.setClassText(t, "ParentLoginAccount", null, item.ParentLoginAccount);
                c.setClassText(t, "InsideLevel", null, DealUserAccountInsideLevel);
                c.setClassText(t, "CurrencyType", null, item.CurrencyType);
                c.setClassText(t, "DepositValue", null, c.toCurrency(item.DepositValue));
                c.setClassText(t, "FirstDepositValue", null, c.toCurrency(item.FirstDepositValue));;
                c.setClassText(t, "DepositPaymentCount", null, item.DepositPaymentCount);
                c.setClassText(t, "FirstDepositPaymentCount", null, item.FirstDepositPaymentCount);
                c.setClassText(t, "WithdrawValue", null, c.toCurrency(item.WithdrawValue));
                c.setClassText(t, "FirstWithdrawValue", null, c.toCurrency(item.FirstWithdrawValue));
                c.setClassText(t, "WithdrawPaymentCount", null, item.WithdrawPaymentCount);
                c.setClassText(t, "FirstWithdrawPaymentCount", null, item.FirstWithdrawPaymentCount);
                c.setClassText(t, "SelfDepositValue", null, c.toCurrency(item.SelfDepositValue));
                c.setClassText(t, "SelfFirstDepositValue", null, c.toCurrency(item.SelfFirstDepositValue));
                c.setClassText(t, "SelfDepositPaymentCount", null, item.SelfDepositPaymentCount);
                c.setClassText(t, "SelfWithdrawValue", null, c.toCurrency(item.SelfWithdrawValue));
                c.setClassText(t, "SelfFirstWithdrawValue", null, c.toCurrency(item.SelfFirstWithdrawValue));
                c.setClassText(t, "SelfWithdrawPaymentCount", null, item.SelfWithdrawPaymentCount);

                expandBtn = t.querySelector(".Expand");
                t.querySelector(".Space").style.paddingLeft = ((DealUserAccountInsideLevel - 1) * 20) + "px";


                if (item.UserAccountInsideLevel <= o.SelfInsideLevel) {
                    expandBtn.onclick = new Function("agentExpand('" + DealUserAccountSortKey + "', " + item.UserAccountID.toString() + ")");
                    expandBtn.innerText = "-";
                    expandBtn.dataset.isloaded = "Y";
                } else {
                    expandBtn.style.display = "none";
                    t.querySelector(".noChild").style.display = "inline-block";
                }

                if (DealUserAccountInsideLevel != 1) {
                    if (DealUserAccountInsideLevel % 2 == 0) {
                        t.classList.add("switch_tr");
                    }


                    for (var ii = 1; ii < (DealUserAccountSortKey.length / 6); ii++) {
                        var tempClass = DealUserAccountSortKey.substring(0, ii * 6);
                        t.classList.add("row_c_" + tempClass);

                        if (ii == ((DealUserAccountSortKey.length / 6) - 1)) {
                            parentSortKey = tempClass;
                            t.classList.add("row_s_" + tempClass);
                        }
                    }

                    t.classList.add("row_child");
                } else {
                    t.classList.add("row_top");
                }


                if (item.UserAccountSortKey == o.SelfSortKey) {
                    t.style.display = "table-row";
                    t.classList.add("searchTarget");
                }

                idList.appendChild(t);
            }
        } else {
                //var div = document.createElement("DIV");

                //div.id = "hasNoData_DIV"
                //div.innerHTML = mlp.getLanguageKey("無數據");
                //div.classList.add("td__content", "td__hasNoData");
                //document.getElementById("idResultTable").classList.add("MT_tableDiv__hasNoData");
                //idList.classList.add("tbody__hasNoData");
                //idList.appendChild(div);
                 alert("提醒:" + "無數據");
            
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
        alert("提醒:" + "請輸入完整帳號");
    }

    function init() {
        var d = new Date();

        EWinInfo = window.parent.EWinInfo;
        setSearchFrame();

        lang = window.localStorage.getItem("agent_lang");
        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
            //queryOrderSummary(qYear, qMon);
            CloseLoading();
            //querySelfData();
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
                    <h2 class="collapse-header has-arrow zIndex_overMask_SafariFix" onclick="ac.dataToggleCollapse(this)" data-toggle="collapse" data-target="#searchList" aria-controls="searchList" aria-expanded="true" aria-label="searchList">
                        <span class="language_replace">團隊出入金數據</span>
                        <i class="arrow"></i>
                    </h2>
                    <!-- collapse內容 由此開始 ========== -->
                    <div id="searchList" class="collapse-content collapse show">
                        <div id="divSearchContent" class="row searchListContent">
                            <div id="idSearchButton" class="col-12 col-md-4 col-lg-2 col-xl-2">
                                <div class="form-group form-group-s2 ">
                                      <div class="form-group form-group-s2 ">
                                    <div class="title hidden shown-md"><span class="language_replace">主帳號</span></div>

                                    <div class="form-control-underline iconCheckAnim placeholder-move-right zIndex_overMask_SafariFix">
                                        <input type="text" class="form-control" id="mainLoginAccount" value="" />
                                        <label for="member" class="form-label"><span class="language_replace">主帳號</span></label>
                                    </div>

                                </div>

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
               <%--             <div id="expandDiv" class="col-12 col-md-3 col-lg-1 col-xl-1">
                                <div class="form-group wrapper_center row">
                                    <button class="btn2 btn-outline-main language_replace col-6 col-md-12 col-lg-12" onclick="toggleAllRow(true)">展開</button>
                                    <button class="btn2 btn-outline-main language_replace col-6 col-md-12 col-lg-12" onclick="toggleAllRow(false)">收合</button>
                                </div>
                            </div>--%>

                            <div class="col-12 col-md-12 col-lg-5 col-xl-6">
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
                            <div class="tbody__td date td-100 nonTitle expand_tr">
                                <span class="td__title"><span class="language_replace">帳號</span></span>
                                <span class="td__content Space">
                                    <span class="noChild" style="padding: 0px 12px; display: none"></span>
                                    <button class="tree-btn Expand">+</button>
                                    <span class="LoginAccount">CON5</span>
                                </span>
                            </div>
                            <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">上線帳號</span></span>
                                <span class="td__content"><i class="icon icon-s icon-before"></i><span class="ParentLoginAccount"></span></span>
                            </div>
                            <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">層級</span></span>
                                <span class="td__content"><i class="icon icon-s icon-before"></i><span class="InsideLevel"></span></span>
                            </div>
                            <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">貨幣</span></span>
                                <span class="td__content"><i class="icon icon-ewin-default-currencyType icon-s icon-before"></i><span class="CurrencyType"></span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
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
                            </div>
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
                            <div class="thead__th"><span class="language_replace">團隊入金/出金</span></div>
                            <div class="thead__th"><span class="language_replace">團隊首次入金/出金</span></div>
                            <div class="thead__th"><span class="language_replace">團隊入金/出金筆數</span></div>
                            <div class="thead__th"><span class="language_replace">團隊首次入金/出金筆數</span></div>
                            <div class="thead__th"><span class="language_replace">個人入金/出金</span></div>
                            <div class="thead__th"><span class="language_replace">個人首次入金/出金</span></div>
                            <div class="thead__th"><span class="language_replace">個人入金/出金筆數</span></div>
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
