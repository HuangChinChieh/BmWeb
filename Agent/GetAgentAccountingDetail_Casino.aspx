<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GetAgentAccountingDetail_Casino.aspx.cs" Inherits="GetAgentAccountingDetail_Casino" %>

<%
    string LoginAccount = "";
    string ASID = Request["ASID"];
    string DefaultCompany = "";
    string SearchCurrencyType = "";
    string AccountingID = Request["AccountingID"];
    string CurrencyType = Request["CurrencyType"];
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
<script src="js/jquery-3.3.1.min.js"></script>
<script>
    var ApiUrl = "GetAgentAccountingDetail_Casino.aspx";
    var c = new common();
    var ac = new AgentCommon();
    var mlp;
    var EWinInfo;
    var api;
    var lang;
    var accountingID = <%=AccountingID%>;
    var CurrencyType = "<%=CurrencyType%>";
    var SelectedWallet;

    function agentExpand(SortKey) {
        var expandBtn = event.currentTarget;
        if (expandBtn) {
            var exists = !(expandBtn.classList.toggle("agentPlus"));
            if (exists) {
                //s
                expandBtn.innerText = "-";
                checkParentLoginAccountExists(SortKey)
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

    function queryData() {
        var idList = document.getElementById("idList");
        var currencyType = "";
        var currencyTypeStr = "";

        c.clearChildren(idList);
        currencyType = CurrencyType;

        strCheckCurrency = currencyTypeStr;
        postData = {
            AID: EWinInfo.ASID,
            AccountingID: accountingID,
            CurrencyType: SelectedWallet,
            LoginAccount: EWinInfo.UserInfo.LoginAccount
        };

        window.parent.API_ShowLoading();
        c.callService(ApiUrl + "/GetAgentAccountingDetail", postData, function (success, o) {
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

        var div = document.createElement("DIV");

        div.id = "hasNoData_DIV"
        div.innerHTML = mlp.getLanguageKey("無數據");
        div.classList.add("td__content", "td__hasNoData");
        document.getElementById("idResultTable").classList.add("MT_tableDiv__hasNoData");
        idList.classList.add("tbody__hasNoData");
        idList.appendChild(div); 
        if (o != null) {
            if (o.ADList != null) {
                let hasChild = false;
                let childBonusPointValue = 0;

                for (var i = 0; i < o.ADList.length; i++) {

                    let data = o.ADList[i];
                    let t = c.getTemplate("templateTableItem");
                    let expandBtn;
                    let parentSortKey = "";

                    c.setClassText(t, "LoginAccount", null, data.LoginAccount);
                    c.setClassText(t, "CurrencyType", null, data.CurrencyType);
                    c.setClassText(t, "SelfRewardValue", null, toCurrency((data.SelfRewardValue)));
                    c.setClassText(t, "SelfValidBetValue", null, toCurrency((data.SelfValidBetValue)));
                    c.setClassText(t, "TotalLineRebate", null, toCurrency((data.TotalLineRebate)));
                        //c.setClassText(t, "CommissionValue", null, toCurrency((data.CommissionValue)));
                        //c.setClassText(t, "ChildenRebateCommission", null, toCurrency((data.ChildenRebateCommission)));
                    c.setClassText(t, "UserRate", null, data.UserRate + "%");
                    c.setClassText(t, "BuyChipRate", null, data.BuyChipRate + "%");
                    c.setClassText(t, "AccountingOPValue", null, toCurrency((data.UserRebate)));

                    expandBtn = t.querySelector(".Expand");
                    
                    if (data.ChildUser.length > 0) {
                        hasChild = true;
                        expandBtn.onclick = new Function("agentExpand('" + data.UserAccountSortKey + "')");
                        expandBtn.classList.add("agentPlus");
                    } else {
                        expandBtn.style.display = "none";
                        t.querySelector(".noChild").style.display = "inline-block";
                    }

                    t.classList.add("row_top");

                    idList.appendChild(t);

                    document.getElementById("hasNoData_DIV").style.display = "none";
                    idList.classList.remove("tbody__hasNoData");
                    document.getElementById("idResultTable").classList.remove("MT_tableDiv__hasNoData");
                }

                if (hasChild) {
                    for (var ii = 0; ii < o.ADList[0].ChildUser.length; ii++) {

                        let data = o.ADList[0].ChildUser[ii];
                        let t = c.getTemplate("templateTableItem");
                        let expandBtn;
                        let parentSortKey = "";
                        childBonusPointValue = childBonusPointValue + data.BonusPointValue;
                        
                        c.setClassText(t, "LoginAccount", null, data.LoginAccount);
                        c.setClassText(t, "CurrencyType", null, data.CurrencyType);
                        c.setClassText(t, "SelfRewardValue", null, toCurrency((data.SelfRewardValue)));
                        c.setClassText(t, "SelfValidBetValue", null, toCurrency((data.SelfValidBetValue)));
                        c.setClassText(t, "TotalLineRebate", null, toCurrency((data.TotalLineRebate)));
                        //c.setClassText(t, "CommissionValue", null, toCurrency((data.CommissionValue)));
                        //c.setClassText(t, "ChildenRebateCommission", null, toCurrency((data.ChildenRebateCommission)));
                        c.setClassText(t, "UserRate", null, data.UserRate + "%");
                        c.setClassText(t, "BuyChipRate", null, data.BuyChipRate + "%");
                        c.setClassText(t, "AccountingOPValue", null, toCurrency((data.UserRebate)));

                        expandBtn = t.querySelector(".Expand");

                        t.querySelector(".Space").style.paddingLeft = "20px";

                        expandBtn.style.display = "none";
                        t.querySelector(".noChild").style.display = "inline-block";

                        if (data.UserAccountInsideLevel % 2 == 0) {
                            t.classList.add("switch_tr");
                        }

                        t.classList.add("row_c_" + data.ParentUserAccountSortKey);
                        t.classList.add("row_s_" + data.ParentUserAccountSortKey);

                        t.classList.add("row_child");
                        t.style.display = "none";

                        idList.appendChild(t);
                    }
                }

                if (childBonusPointValue != 0) {
                    $(".row_top .BonusValue_Own").text(toCurrency((childBonusPointValue)));
                }
            }
        }
    }

    function toCurrency(num) {

        num = parseFloat(Number(num).toFixed(4));
        var parts = num.toString().split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        return parts.join('.');
    }

    function init() {
        EWinInfo = window.parent.EWinInfo;
        api = window.parent.API_GetAgentAPI();

        lang = window.localStorage.getItem("agent_lang");
        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
            window.parent.API_CloseLoading();
            SelectedWallet = parent.API_GetSelectedWallet();
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
            case "SelectedWallet":
                SelectedWallet = param;
                queryData();
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

                          <div id="expandDiv" class="col-12 col-md-3 col-lg-1 col-xl-1" style="padding-left:5px">
                                <div class="form-group wrapper_center row">
                                    <button class="btn2 btn-outline-main language_replace col-6 col-md-12 col-lg-12" onclick="toggleAllRow(true)">展開</button>
                                    <button class="btn2 btn-outline-main language_replace col-6 col-md-12 col-lg-12" onclick="toggleAllRow(false)">收合</button>
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
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">幣別</span></span>
                                <span class="td__content"><span class="CurrencyType"></span></span>
                            </div>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">佔成率</span></span>
                                <span class="td__content"><span class="UserRate"></span></span>
                            </div>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">轉碼率</span></span>
                                <span class="td__content"><span class="BuyChipRate"></span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">個人上下數</span></span>
                                <span class="td__content"><span class="SelfRewardValue"></span></span>
                            </div>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">個人轉碼數</span></span>
                                <span class="td__content"><span class="SelfValidBetValue"></span></span>
                            </div>
<%--                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">總洗碼佣金</span></span>
                                <span class="td__content"><span class="CommissionValue"></span></span>
                            </div>--%>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">總線佣金</span></span>
                                <span class="td__content"><span class="TotalLineRebate"></span></span>
                            </div>
<%--                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">下線洗碼佣金</span></span>
                                <span class="td__content"><span class="ChildenRebateCommission"></span></span>
                            </div>--%>
                              <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">應付傭金</span></span>
                                <span class="td__content"><span class="AccountingOPValue"></span></span>
                            </div>
                        </div>
                    </div>
                    <!-- 標題項目  -->
                    <div class="thead">
                        <!--標題項目單行 -->
                        <div class="thead__tr">
                            <div class="thead__th"><span class="language_replace">帳號</span></div>
                            <div class="thead__th"><span class="language_replace">幣別</span></div>
                            <div class="thead__th"><span class="language_replace">佔成率</span></div>
                            <div class="thead__th"><span class="language_replace">轉碼率</span></div>
                            <div class="thead__th"><span class="language_replace">個人上下數</span></div>
                            <div class="thead__th"><span class="language_replace">個人轉碼數</span></div>
                            <%--<div class="thead__th"><span class="language_replace">總洗碼佣金</span></div>--%>
                            <div class="thead__th"><span class="language_replace">總線佣金</span></div>
                            <%--<div class="thead__th"><span class="language_replace">下線洗碼佣金</span></div>--%>
                            <div class="thead__th"><span class="language_replace">應付傭金</span></div>
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
