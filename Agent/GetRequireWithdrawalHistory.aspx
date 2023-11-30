<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GetRequireWithdrawalHistory.aspx.cs" Inherits="GetRequireWithdrawalHistory" %>

<%
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
    <link rel="stylesheet" href="css/layoutADJ.css?<%:AgentVersion%>">
</head>
<script type="text/javascript" src="/Scripts/Common.js?20191127"></script>
<script type="text/javascript" src="/Scripts/UIControl.js"></script>
<script type="text/javascript" src="Scripts/MultiLanguage.js"></script>
<script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
<script type="text/javascript" src="/Scripts/bignumber.min.js"></script>
<script type="text/javascript" src="/Scripts/SelectItem.js"></script>
<script type="text/javascript" src="js/AgentCommon.js"></script>
<script type="text/javascript" src="../Scripts/jquery-3.3.1.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/google-libphonenumber/3.2.31/libphonenumber.min.js"></script>
<script>
    var ApiUrl = "GetRequireWithdrawalHistory.aspx";
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
        var startDate;
        var endDate;
        var idList = document.getElementById("idList");
        var type = 0;
        var typeDoms = document.getElementsByName("type");

        c.clearChildren(idList);

        if (typeDoms) {
            if (typeDoms.length > 0) {
                for (i = 0; i < typeDoms.length; i++) {
                    if (typeDoms[i].checked == true) {
                        type = typeDoms[i].value;

                        break;
                    }
                }
            }
        }

        startDate = document.getElementById("startDate");
        endDate = document.getElementById("endDate");

        postData = {
            AID: EWinInfo.ASID,
            QueryBeginDate: startDate.value,
            QueryEndDate: endDate.value,
            SearchState: type,
            CurrencyType: SelectedWallet
        };

        window.parent.API_ShowLoading();
        c.callService(ApiUrl + "/GetOrderSummary", postData, function (success, o) {
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
        var OrderType = 0;
        var hasNoData = true;
        let sumAmount = 0;

        var div = document.createElement("DIV");

        div.id = "hasNoData_DIV"
        div.innerHTML = mlp.getLanguageKey("無數據");
        div.classList.add("td__content", "td__hasNoData");
        document.getElementById("idResultTable").classList.add("MT_tableDiv__hasNoData");
        idList.classList.add("tbody__hasNoData");
        idList.appendChild(div);

        if (o != null) {
            if (o.Datas != null) {
                //c.clearChildren(idList);
                //只顯示個人投注
                for (var i = 0; i < o.Datas.length; i++) {
                    var item = o.Datas[i];
                    var t = c.getTemplate("templateTableItem");
                    var btn;

                    c.setClassText(t, "CreateDate", null, item.CreateDate);
                    c.setClassText(t, "LoginAccountU", null, item.LoginAccountU);
                    c.setClassText(t, "LoginAccountP", null, item.LoginAccountP);
                    c.setClassText(t, "ProcessStatus", null, item.ProcessStatus == 0 ? mlp.getLanguageKey("申請提款") : (item.ProcessStatus == 1 ? mlp.getLanguageKey("完成轉帳") : mlp.getLanguageKey("拒絕")));
                    c.setClassText(t, "CurrencyType", null, item.CurrencyType);

                    if (parseFloat(item.Amount) < 0) {
                        t.getElementsByClassName("Amount")[0].classList.add("num-negative");
                    }
                    c.setClassText(t, "Amount", null, c.toCurrency(item.Amount));
                    c.setClassText(t, "Description", null, item.Description);

                    t.style.display = "none";
                    idList.appendChild(t);
                    sumAmount = sumAmount + item.Amount;
                    t.style.display = "";
                    document.getElementById("hasNoData_DIV").style.display = "none";
                    idList.classList.remove("tbody__hasNoData");
                    document.getElementById("idResultTable").classList.remove("MT_tableDiv__hasNoData");

                }
            }
        }

        $(".sumAmount").text(sumAmount);
    }

    function setSearchFrame() {
        var nowDate = new Date();
        var startDate = new Date();
        var month = "";
        var date = "";

        startDate.setDate(startDate.getDate() - 7);
        month = (startDate.getMonth() + 1);
        if (month < 10) {
            month = "0" + month;
        }
        date = startDate.getDate();
        if (date < 10) {
            date = "0" + date;
        }
        document.getElementById("startDate").value = startDate.getFullYear() + "-" + month + "-" + date;

        month = (nowDate.getMonth() + 1);
        if (month < 10) {
            month = "0" + month;
        }
        date = nowDate.getDate();
        if (date < 10) {
            date = "0" + date;
        }
        document.getElementById("endDate").value = nowDate.getFullYear() + "-" + month + "-" + date;
    }

    function init() {
        var d = new Date();
        lang = window.localStorage.getItem("agent_lang");
        EWinInfo = window.parent.EWinInfo;
        api = window.parent.API_GetAgentAPI();
        setSearchFrame();

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
<script type="text/javascript">
    function chkData(el) {
        var i;
        var groupEl = document.getElementsByName(el.name);

        if (el.value == "all") {
            if (el.checked == true) {
                for (i = 0; i < groupEl.length; i++) {
                    groupEl[i].checked = true;
                }
            }
            else {
                for (i = 0; i < groupEl.length; i++) {
                    groupEl[i].checked = false;
                }
            }
        }
        else {
            for (i = 0; i < groupEl.length; i++) {
                if (groupEl[i].value == "all") {
                    groupEl[i].checked = false;
                    break;
                }
            }
        }
    }
</script>
<body class="innerBody">
    <main>
        <div class="dataList dataList-box fixed top real-fixed">
            <div class="container-fluid">
                <div class="collapse-box">
                    <h2 class="collapse-header has-arrow zIndex_overMask_SafariFix" onclick="ac.dataToggleCollapse(this)" data-toggle="collapse" data-target="#searchList" aria-controls="searchList" aria-expanded="true" aria-label="searchList">
                        <span class="language_replace">出款申請記錄</span>
                        <i class="arrow"></i>
                    </h2>
                    <!-- collapse內容 由此開始 ========== -->
                    <div id="searchList" class="collapse-content collapse show">
                        <div id="divSearchContent" class="row searchListContent">
                            <div class="col-12 col-md-6 col-lg-4 col-xl-auto">
                                <!-- 起始日期 / 結束日期 -->
                                <div class="form-group search_date">
                                    <div class="starDate">
                                        <div class="title"><span class="language_replace">起始日期</span></div>

                                        <div class="form-control-default">
                                            <input id="startDate" type="date" class="form-control custom-date" />
                                            <label for="" class="form-label"><i class="icon icon2020-calendar-o"></i></label>
                                        </div>

                                    </div>
                                    <div class="endDate">
                                        <div class="title"><span class="language_replace">結束日期</span></div>

                                        <div class="form-control-default">
                                            <input id="endDate" type="date" class="form-control custom-date" />
                                            <label for="" class="form-label"><i class="icon icon2020-calendar-o"></i></label>
                                        </div>

                                    </div>

                                </div>

                            </div>

                            <div class="col-12 col-md-6 col-lg-4 col-xl-auto">
                                <!-- 模式 -->
                                <div class="form-group form-group-s2 ">
                                    <div class="title"><span class="language_replace">搜尋條件</span></div>
                                    <div id="TypeDiv" class="content">
                                        <div class="custom-control custom-checkboxValue custom-control-inline check-bg">
                                            <label class="custom-label">
                                                <input type="radio" name="type" value="99" class="custom-control-input-hidden" checked>
                                                <div class="custom-input checkbox"><span class="language_replace tempName">全部</span></div>
                                            </label>
                                        </div>
                                        <div class="custom-control custom-checkboxValue custom-control-inline check-bg">
                                            <label class="custom-label">
                                                <input type="radio" name="type" value="0" class="custom-control-input-hidden">
                                                <div class="custom-input checkbox"><span class="language_replace tempName">申請提款</span></div>
                                            </label>
                                        </div>
                                        <div class="custom-control custom-checkboxValue custom-control-inline check-bg">
                                            <label class="custom-label">
                                                <input type="radio" name="type" value="1" class="custom-control-input-hidden">
                                                <div class="custom-input checkbox"><span class="language_replace tempName">完成轉帳</span></div>
                                            </label>
                                        </div>
                                        <div class="custom-control custom-checkboxValue custom-control-inline check-bg">
                                            <label class="custom-label">
                                                <input type="radio" name="type" value="2" class="custom-control-input-hidden">
                                                <div class="custom-input checkbox"><span class="language_replace tempName">拒絕</span></div>
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-12">
                                <div class="form-group wrapper_center dataList-process">
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
            <h2 class="collapse-header has-arrow zIndex_overMask_SafariFix">
                <span class="language_replace">總金額</span>
                <span class="language_replace sumAmount">0</span>
            </h2>
            <div class="MT__tableDiv" id="idResultTable">
                <!-- 自訂表格 -->
                <div class="MT__table table-col-8 w-200">
                    <div id="templateTableItem" style="display: none">
                        <div class="tbody__tr td-non-underline-last-2">
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">交易日期</span></span>
                                <span class="td__content"><span class="CreateDate">CON5</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">申請帳戶</span></span>
                                <span class="td__content"><span class="LoginAccountU">CON5</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">審核帳戶</span></span>
                                <span class="td__content"><span class="LoginAccountP">CON5</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">狀態</span></span>
                                <span class="td__content"><span class="ProcessStatus">CON5</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">貨幣</span></span>
                                <span class="td__content"><span class="CurrencyType">CON3</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">額度</span></span>
                                <span class="td__content"><span class="Amount">CON4</span></span>
                            </div>
                            <div class="tbody__td td-3 ">
                                <span class="td__title"><span class="language_replace">備註</span></span>
                                <span class="td__content"><span class="Description">CON3</span></span>
                            </div>
                        </div>
                    </div>
                    <!-- 標題項目  -->
                    <div class="thead">
                        <!--標題項目單行 -->
                        <div class="thead__tr">
                            <div class="thead__th"><span class="language_replace">交易日期</span></div>
                            <div class="thead__th"><span class="language_replace">申請帳戶</span></div>
                            <div class="thead__th"><span class="language_replace">審核帳戶</span></div>
                            <div class="thead__th"><span class="language_replace">狀態</span></div>
                            <div class="thead__th"><span class="language_replace">貨幣</span></div>
                            <div class="thead__th"><span class="language_replace">額度</span></div>
                            <div class="thead__th"><span class="language_replace">備註</span></div>
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
</html>
