<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UserAccount_RequireWithdrawal.aspx.cs" Inherits="UserAccount_RequireWithdrawal" %>

<%
    string AgentVersion = EWinWeb.AgentVersion;
%>
<!doctype html>
<html lang="zh-Hant-TW" class="innerHtml">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>下線出款申請</title>
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
    var c = new common();
    var ac = new AgentCommon();
    var ApiUrl = "UserAccount_RequireWithdrawal.aspx";
    var mlp;
    var EWinInfo;
    var api;
    var lang;
    var mlp;
    var processing = false;

    function queryData() {
        var i;
        var postData;
        var loginAccount = "";
        var startDate = "";
        var endDate = "";
        var txType = "";
        var txTypeStr = "";
        var currencyType = "";
        var currencyTypeStr = "";
        var idList = document.getElementById("idList");

        //startDate = document.getElementById("startDate");
        //endDate = document.getElementById("endDate");
        loginAccount = document.getElementById("loginAccount").value;

        c.clearChildren(idList);
        postData = {
            AID: EWinInfo.ASID,
            LoginAccount: loginAccount
        };

        c.callService(ApiUrl + "/GetRequireWithdrawal", postData, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);

                if (obj.Result == 0) {
                    updateList(obj);
                } else {

                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), obj.Message);
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

    function btnOK(RequireWithdrawalID) {
        var postData;
        var idMessageConfirm = document.getElementById("idMessageConfirm");

        postData = {
            AID: EWinInfo.ASID,
            RequireID: RequireWithdrawalID
        };


        c.setClassText(idMessageConfirm, "msgLoginAccount", null, document.getElementsByClassName(RequireWithdrawalID + "_LoginAccount")[0].innerText);
        c.setClassText(idMessageConfirm, "msgCurrencyType", null, document.getElementsByClassName(RequireWithdrawalID + "_CurrencyType")[0].innerText);
        c.setClassText(idMessageConfirm, "msgTransOut", null, c.toCurrency(document.getElementsByClassName(RequireWithdrawalID + "_Amount")[0].innerText));

        window.parent.API_ShowMessage("", idMessageConfirm.innerHTML, function () {
            if (processing == false) {
                processing = true;

                c.callService(ApiUrl + "/RequireWithdrawalSuccess", postData, function (success, o) {
                    if (success) {
                        var obj = c.getJSON(o);

                        if (obj.Result == 0) {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("完成"), mlp.getLanguageKey("出款完成"), function () {
                                processing = false;
                                queryData();

                            });

                        } else {
                            processing = false;
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(obj.Message));
                        }
                    } else {
                        if (o == "Timeout") {
                            processing = false;
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後重新嘗試"));
                        } else {
                            processing = false;
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), o);
                        }
                    }
                });

            }
            else {
                window.parent.API_ShowToastMessage(mlp.getLanguageKey("作業進行中"));
            }
        }, null);
    }

    function btnCancel(RequireWithdrawalID) {
        var postData;

        postData = {
            AID: EWinInfo.ASID,
            RequireID: RequireWithdrawalID
        };

        if (processing == false) {
            processing = true;

            c.callService(ApiUrl + "/RequireWithdrawalCancel", postData, function (success, o) {
                if (success) {
                    var obj = c.getJSON(o);

                    if (obj.Result == 0) {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("取消1"), mlp.getLanguageKey("出款取消"), function () {
                            queryData();
                            processing = false;
                        });
                    } else {
                        processing = false;
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(obj.Message));
                    }
                } else {
                    if (o == "Timeout") {
                        processing = false;
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後重新嘗試"));
                    } else {
                        processing = false;
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), o);
                    }
                }
            });

        }
        else {
            window.parent.API_ShowToastMessage(mlp.getLanguageKey("作業進行中"));
        }
    }

    function updateList(o) {
        var idList = document.getElementById("idList");
        var hasNoData = true;

        if (o != null) {
            if (o.RequireWithdrawalList != null) {

                //排序
                o.RequireWithdrawalList.sort(function (a, b) {
                    var DateA = a.CreateDate;
                    var DateB = b.CreateDate;
                    if (DateB < DateA) {
                        return -1;
                    }
                    if (DateB > DateA) {
                        return 1;
                    }

                    return 0;
                });

                for (var i = 0; i < o.RequireWithdrawalList.length; i++) {
                    var item = o.RequireWithdrawalList[i];
                    var t = c.getTemplate("templateTableItem");
                    var btn;

                    c.setClassText(t, "DateInfo", null, item.CreateDate);
                    c.setClassText(t, "LoginAccount", null, item.LoginAccount);
                    t.getElementsByClassName("LoginAccount")[0].classList.add(item.RequireWithdrawalID + "_LoginAccount");

                    c.setClassText(t, "CurrencyType", null, item.CurrencyType);
                    t.getElementsByClassName("CurrencyType")[0].classList.add(item.RequireWithdrawalID + "_CurrencyType");

                    c.setClassText(t, "Amount", null, c.toCurrency(item.Amount));
                    t.getElementsByClassName("Amount")[0].classList.add(item.RequireWithdrawalID + "_Amount");

                    c.setClassText(t, "Description", null, item.Description);

                    btn = c.getFirstClassElement(t, "btnOK");
                    btn.onclick = new Function("btnOK('" + item.RequireWithdrawalID + "')");

                    btn = c.getFirstClassElement(t, "btnCancel");
                    btn.onclick = new Function("btnCancel('" + item.RequireWithdrawalID + "')");


                    idList.appendChild(t);

                    hasNoData = false;
                }
            }
        }

        idList.classList.remove("tbody__hasNoData");
        document.getElementById("idResultTable").classList.remove("MT_tableDiv__hasNoData");
        if (hasNoData) {
            var div = document.createElement("DIV");

            div.innerHTML = mlp.getLanguageKey("無數據");
            div.classList.add("td__content", "td__hasNoData");
            document.getElementById("idResultTable").classList.add("MT_tableDiv__hasNoData");
            idList.classList.add("tbody__hasNoData");
            idList.appendChild(div);
        }
    }


    function setSearchFrame() {
        var i;
        var pi = null;
        var templateDiv;
        var CurrencyTypeDiv = document.getElementById("CurrencyTypeDiv");
        var tempCurrencyRadio;
        var tempCurrencyName;
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

    function showNote() {
        window.event.stopPropagation();
        window.parent.API_ShowMessageOK(mlp.getLanguageKey("提醒"),mlp.getLanguageKey("注意事項")
        );
    }

    function init() {

        EWinInfo = window.parent.EWinInfo;
        api = window.parent.API_GetAgentAPI();
        setSearchFrame();


        lang = window.localStorage.getItem("agent_lang");
        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
            queryData();
        });
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
        <div class="dataList dataList-box fixed top">
            <div class="container-fluid">
                <div class="collapse-box">
                    <h2 class="collapse-header has-arrow" onclick="ac.dataToggleCollapse(this)" data-toggle="collapse" data-target="#searchList" aria-controls="searchList" aria-expanded="true" aria-label="searchList">
                        <span class="language_replace">下線出款記錄</span>
                        <btn style="font-size: 12px;right: 40px;position: absolute;border: 2px solid;width: 22px;text-align: center;border-radius: 11px;color: #bba480;cursor: pointer;" onclick="showNote()">!</btn>
                        <i class="arrow"></i>
                    </h2>
                    <!-- collapse內容 由此開始 ========== -->
                    <div id="searchList" class="collapse-content collapse show">
                        <div id="divSearchContent" class="row searchListContent">
                            <div class="col-12 col-md-6 col-lg-4 col-xl-3">
                                <div class="form-group form-group-s2 ">
                                    <div class="title hidden shown-md"><span class="language_replace">會員帳號</span></div>
                                    <div class="form-control-underline iconCheckAnim placeholder-move-right">
                                        <input type="text" class="form-control" id="loginAccount" required>
                                        <label for="member" class="form-label"><span class="language_replace">會員帳號</span></label>
                                    </div>
                                </div>
                            </div>
                            <div style="display:none" class="col-12 col-md-6 col-lg-4 col-xl-auto">
                                <!-- 起始日期 / 結束日期 -->
                                <div class="form-group search_date">
                                    <div class="starDate">
                                        <div class="title"><span class="language_replace">起始日期</span></div>

                                        <div class="form-control-default">
                                            <input id="startDate" type="date" class="form-control custom-date">
                                            <label for="" class="form-label"><i class="icon icon2020-calendar-o"></i></label>
                                        </div>

                                    </div>
                                    <div class="endDate">
                                        <div class="title"><span class="language_replace">結束日期</span></div>

                                        <div class="form-control-default">
                                            <input id="endDate" type="date" class="form-control custom-date">
                                            <label for="" class="form-label"><i class="icon icon2020-calendar-o"></i></label>
                                        </div>

                                    </div>

                                </div>

                            </div>

                            

                            <div class="col-12">
                                <div class="form-group wrapper_center dataList-process">
                                    <%--<button class="btn btn-outline-main" onclick="MaskPopUp(this)">取消</button>--%>
                                    <button class="btn btn-full-main btn-roundcorner language_replace" onclick="queryData()"><i class="icon icon-before icon-ewin-input-submit"></i><span class="language_replace" langkey="確認">送出</span></button>
                                </div>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 表格 由此開始 ========== -->
        <div class="container-fluid">
            <div class="MT__tableDiv" id="idResultTable">
                <!-- 自訂表格 -->
                <div class="MT__table table-col-7 w-200">
                    <div id="templateTableItem" style="display: none">
                        <div class="tbody__tr td-non-underline-last-2">
                            <div class="tbody__td date td-100 td-auto-title nonTitle ">
                                <span class="td__title"><span class="language_replace">時間</span></span>
                                <span class="td__content"><span class="DateInfo">CON5</span></span>
                            </div>
                            <div class="tbody__td account nonTitle td-3 td-icon">
                                <span class="td__title"><span class="language_replace">帳號</span></span>
                                <span class="td__content"><i class="icon icon-ewin-default-user icon-s icon-before"></i><span class="LoginAccount">CON3</span></span>
                            </div>
                            <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">幣別</span></span>
                                <span class="td__content"><i class="icon icon-ewin-default-currencyType icon-s icon-before"></i><span class="CurrencyType">CON3</span></span>
                            </div>
                            <div class="tbody__td td-3 td-number td-vertical">
                                <span class="td__title"><i class="icon icon-ewin-default-amount icon-s icon-before"></i><span class="language_replace">金額</span></span>
                                <span class="td__content"><span class="Amount">CON4</span></span>
                            </div>
                            <div class="tbody__td td-3 td-vertical td-icon">
                                <span class="td__title"><i class="icon icon-ewin-default-notebook icon-s icon-before"></i><span class="language_replace">備註</span></span>
                                <span class="td__content"><span class="Description">CON5</span></span>
                            </div>
                            <div class="tbody__td nonTitle td-function-execute td-100">
                                <span class="td__content">
                                    <button type="button" class="btn btn-outline-main btnCancel btn-cancel" ><i class="icon icon-before icon-ewin-input-cancel"></i><span class="language_replace">取消</span></button>
                                    <button type="button" class="btn btn-full-main btnOK btn-ok" ><i class="icon icon-before icon-ewin-input-cashOut"></i><span class="language_replace">出款</span></button>
                                </span>
                            </div>
                        </div>
                    </div>
                    <!-- 標題項目  -->
                    <div class="thead">
                        <!--標題項目單行 -->
                        <div class="thead__tr">
                            <div class="thead__th"><span class="language_replace">時間</span></div>
                            <div class="thead__th"><span class="language_replace">帳號</span></div>
                            <div class="thead__th"><span class="language_replace">幣別</span></div>
                            <div class="thead__th"><span class="language_replace">金額</span></div>
                            <div class="thead__th"><span class="language_replace">備註</span></div>
                            <div class="thead__th"><span class="language_replace"></span></div>
                        </div>
                    </div>
                    <!-- 表格上下滑動框 -->
                    <div class="tbody" id="idList">
                    </div>
                </div>
            </div>
        </div>
        <div id="idMessageConfirm" style="display: none">
            <div class="dataList">
                <fieldset class="dataFieldset">
                    <div class="row dataFieldset-content">
                        <div class="col-12 col-sm-6 col-md-4 col-lg-6 form-group row no-gutters  data-item ">
                            <div class="col-12 data-title">
                                <label class="title"><span class="title_name"><i class="icon icon-ewin-default-account icon-s icon-before"></i><span class="language_replace">出款帳號</span></span></label>
                            </div>
                            <div class="col-12 data-content form-line">
                                <span class="DateInfo msgLoginAccount">--</span>
                            </div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4 col-lg-6 form-group row no-gutters  data-item ">
                            <div class="col-12 data-title">
                                <label class="title"><span class="title_name"><i class="icon icon-ewin-default-currencyType icon-s icon-before"></i><span class="language_replace">出款錢包</span></span></label>
                            </div>
                            <div class="col-12 data-content form-line">
                                <span class="DateInfo msgCurrencyType">--</span>
                            </div>
                        </div>
                        <div class="col-12 col-sm-12 col-md-4 col-lg-6 form-group row no-gutters  data-item ">
                            <div class="col-12 data-title">
                                <label class="title"><span class="title_name"><i class="icon icon-ewin-default-amount icon-s icon-before"></i><span class="language_replace">出款金額</span></span></label>
                            </div>
                            <div class="col-12 data-content form-line">
                                <span class="DateInfo msgTransOut">--</span>
                            </div>
                        </div>
                    </div>
                </fieldset>
            </div>
        </div>

    </main>
</body>
<script type="text/javascript">
    ac.listenScreenMove();

</script>
</html>
