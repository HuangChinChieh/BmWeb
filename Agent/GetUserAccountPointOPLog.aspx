<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GetUserAccountPointOPLog.aspx.cs" Inherits="Agent_GetUserAccountPointOPLog" %>

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
    var ApiUrl = "GetUserAccountPointOPLog.aspx";
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
        var idList = document.getElementById("idList");

        c.clearChildren(idList);
        startDate = document.getElementById("startDate");

        postData = {
            AID: EWinInfo.ASID,
            QueryBeginDate: startDate.value,
            CurrencyType: SelectedWallet
        };

        window.parent.API_ShowLoading();
        c.callService(ApiUrl + "/GetPointOPLog", postData, function (success, o) {
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

        var div = document.createElement("DIV");

        div.id = "hasNoData_DIV"
        div.innerHTML = mlp.getLanguageKey("無數據");
        div.classList.add("td__content", "td__hasNoData");
        document.getElementById("idResultTable").classList.add("MT_tableDiv__hasNoData");
        idList.classList.add("tbody__hasNoData");
        idList.appendChild(div);

        if (o != null) {
            if (o.Data != null) {
                for (var i = 0; i < o.Data.length; i++) {
                    var item = o.Data[i];
                    var t = c.getTemplate("templateTableItem");
                    $(t).attr("data-OPType", item.OPType);
                    c.setClassText(t, "CreateDate", null, item.CreateDate);
                    c.setClassText(t, "CurrencyType", null, item.CurrencyType);
                    c.setClassText(t, "OPType", null, mlp.getLanguageKey(item.OPType));

                    if (parseFloat(item.Amount) < 0) {
                        t.getElementsByClassName("Amount")[0].classList.add("num-negative");
                    }
                    c.setClassText(t, "Amount", null, toCurrency(item.Amount));

                    if (parseFloat(item.BeforeValue) < 0) {
                        t.getElementsByClassName("BeforeValue")[0].classList.add("num-negative");
                    }
                    c.setClassText(t, "BeforeValue", null, toCurrency(item.BeforeValue));

                    if (parseFloat(item.AfterValue) < 0) {
                        t.getElementsByClassName("AfterValue")[0].classList.add("num-negative");
                    }
                    c.setClassText(t, "AfterValue", null, toCurrency(item.AfterValue));

                    c.setClassText(t, "Description", null, item.Description);

                    t.style.display = "none";
                    idList.appendChild(t);
                    t.style.display = "";
                    document.getElementById("hasNoData_DIV").style.display = "none";
                    idList.classList.remove("tbody__hasNoData");
                    document.getElementById("idResultTable").classList.remove("MT_tableDiv__hasNoData");

                }
            }
        }
    }

    function setSearchFrame() {
        var nowDate = new Date();
        var startDate = new Date();
        var month = "";
        var date = "";

        startDate.setDate(startDate.getDate());
        month = (startDate.getMonth() + 1);
        if (month < 10) {
            month = "0" + month;
        }
        date = startDate.getDate();
        if (date < 10) {
            date = "0" + date;
        }
        document.getElementById("startDate").value = startDate.getFullYear() + "-" + month + "-" + date;
    }

    function toCurrency(num) {

        num = Math.floor(Number(num) * 10000) / 10000;
        var parts = num.toString().split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        return parts.join('.');
    }

    function SelectOPTypeMethod() {
        let SelectOPType = $("#SelectOPType").val();

        if (SelectOPType == "All") {
            $("#idList .result").show();
        } else {
            $("#idList .result").hide();
            $('div[data-optype="' + SelectOPType + '"]').show();
        }
    }

    function showNote() {
        window.event.stopPropagation();
        window.parent.API_ShowMessageOK(mlp.getLanguageKey("提醒"),mlp.getLanguageKey("注意事項")
        );
    }

    function init() {
        var d = new Date();

        EWinInfo = window.parent.EWinInfo;
        api = window.parent.API_GetAgentAPI();
        setSearchFrame();

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
                        <span class="language_replace">錢包點數異動記錄</span>
                        <btn style="font-size: 12px;right: 40px;position: absolute;border: 2px solid;width: 22px;text-align: center;border-radius: 11px;color: #bba480;cursor: pointer;" onclick="showNote()">!</btn>
                        <i class="arrow"></i>
                    </h2>
                    <!-- collapse內容 由此開始 ========== -->
                    <div id="searchList" class="collapse-content collapse show">
                        <div id="divSearchContent" class="row searchListContent">
                            <div class="col-12 col-md-6 col-lg-4 col-xl-auto">
                                <!-- 起始日期 / 結束日期 -->
                                <div class="">
                                    <div class="starDate">
                                        <div class="title"><span class="language_replace">起始日期</span></div>

                                        <div class="form-control-default">
                                            <input id="startDate" type="date" class="form-control custom-date" />
                                            <label for="" class="form-label"><i class="icon icon2020-calendar-o"></i></label>
                                        </div>

                                    </div>

                                </div>

                            </div>


                            <div class="col-12 col-md-6 col-lg-4 col-xl-auto">
                                <!-- 模式 -->
                                <div class="title"><span class="language_replace">篩選類型</span></div>
                                <ul class="nav">
                                    <li id="btnWallet" class="navbar-member nav-item submenu dropdown">
                                        <select class="custom-select" id="SelectOPType" onchange="SelectOPTypeMethod()">
                                            <option style="zoom: 1.1" class="language_replace" value="All">全部</option>
                                            <option style="zoom: 1.1" class="language_replace" value="UserTransferOut">UserTransferOut</option>
                                            <option style="zoom: 1.1" class="language_replace" value="UserTransferIn">UserTransferIn</option>
                                            <option style="zoom: 1.1" class="language_replace" value="Withdrawal">Withdrawal</option>
                                            <option style="zoom: 1.1" class="language_replace" value="Deposit">Deposit</option>
                                            <option style="zoom: 1.1" class="language_replace" value="Manual">Manual</option>
                                            <option style="zoom: 1.1" class="language_replace" value="Accounting">Accounting</option>
                                        </select>
                                    </li>
                                </ul>
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
            <div class="MT__tableDiv" id="idResultTable">
                <!-- 自訂表格 -->
                <div class="MT__table table-col-8 w-200">
                    <div id="templateTableItem" style="display: none">
                        <div class="tbody__tr td-non-underline-last-2 result">
                            <div class="tbody__td date td-100 nonTitle">
                                <span class="td__title"><span class="language_replace">日期</span></span>
                                <span class="td__content"><span class="CreateDate">CON5</span></span>
                            </div>
                            <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">貨幣</span></span>
                                <span class="td__content"><i class="icon icon-ewin-default-currencyType icon-s icon-before"></i><span class="CurrencyType">CON3</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><i class="icon icon-ewin-default-totalWinLose icon-s icon-before"></i><span class="language_replace">類型</span></span>
                                <span class="td__content"><span class="OPType">CON4</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical td_DepositValue">
                                <span class="td__title"><i class="icon icon-ewin-default-totalRolling icon-s icon-before"></i><span class="language_replace">點數</span></span>
                                <span class="td__content"><span class="Amount">CON4</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical td_DepositValue">
                                <span class="td__title"><i class="icon icon-ewin-default-totalRolling icon-s icon-before"></i><span class="language_replace">扣點前額度</span></span>
                                <span class="td__content"><span class="BeforeValue">CON4</span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical td_DepositValue">
                                <span class="td__title"><i class="icon icon-ewin-default-totalRolling icon-s icon-before"></i><span class="language_replace">扣點後額度</span></span>
                                <span class="td__content"><span class="AfterValue">CON4</span></span>
                            </div>
                            <div class="tbody__td td-3 ">
                                <span class="td__title"><span class="language_replace">描述</span></span>
                                <span class="td__content"><span class="Description">CON3</span></span>
                            </div>

                        </div>
                    </div>
                    <!-- 標題項目  -->
                    <div class="thead">
                        <!--標題項目單行 -->
                        <div class="thead__tr">
                            <div class="thead__th"><span class="language_replace">日期</span></div>
                            <div class="thead__th"><span class="language_replace">貨幣</span></div>
                            <div class="thead__th"><span class="language_replace">類型</span></div>
                            <div class="thead__th"><span class="language_replace">點數</span></div>
                            <div class="thead__th"><span class="language_replace">扣點前額度</span></div>
                            <div class="thead__th"><span class="language_replace">扣點後額度</span></div>
                            <div class="thead__th"><span class="language_replace">描述</span></div>
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
