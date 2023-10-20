<%@ Page Language="C#" %>

<%
    string AgentVersion = EWinWeb.AgentVersion;
%>
<!doctype html>
<html lang="zh-Hant-TW" class="innerHtml">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>代理網</title>
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
    var mlp;
    var EWinInfo;
    var api;
    var lang;
    var mlp;

    function queryData() {
        var i;
        var postData;
        var loginAccount = "";
        var startDate = "";
        var endDate = "";
        var actionType = "";
        var actionTypeStr = "";
        var currencyType = "";
        var currencyTypeStr = "";

        startDate = document.getElementById("startDate");
        endDate = document.getElementById("endDate");
        currencyType = document.getElementsByName("chkCurrencyType");
        actionType = document.getElementsByName("chkActionType");

        if (currencyType) {
            if (currencyType.length > 0) {
                for (i = 0; i < currencyType.length; i++) {
                    if (currencyType[i].checked == true) {
                        if (currencyTypeStr == "") {
                            currencyTypeStr = currencyType[i].value;
                        }
                        else {
                            currencyTypeStr = currencyTypeStr + "," + currencyType[i].value;
                        }
                    }
                }
            }
        }

        if (actionType) {
            if (actionType.length > 0) {
                for (i = 0; i < actionType.length; i++) {
                    if (actionType[i].checked == true) {
                        if (actionTypeStr == "") {
                            actionTypeStr = actionType[i].value;
                        }
                        else {
                            actionTypeStr = actionTypeStr + "," + actionType[i].value;
                        }
                    }
                }
            }
        } 

        if (currencyTypeStr != "" && actionTypeStr != "") {
            postData = {
                AID: EWinInfo.ASID,
                LoginAccount: loginAccount,
                StartDate: startDate.value,
                EndDate: endDate.value,
                ActionType: actionTypeStr,
                CurrencyType: currencyTypeStr
            };

            queryWalletHistory(postData)

        }
        else {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("提醒"), mlp.getLanguageKey("請至少選擇一個幣別以及類型!!"));
        }

    }


    function queryWalletHistory(postData) {
        //startDate = "2020/01/01";
        //endDate = "2020/12/31";
        //actionType = "TransactionOut";
        //currencyType = "CNY";
        window.parent.API_ShowLoading();
        api.GetWalletHistory(EWinInfo.ASID, Math.uuid(), postData.LoginAccount, postData.StartDate, postData.EndDate, postData.ActionType, postData.CurrencyType , function (success, o) {
            if (success) {
                if (o.ResultState == 0) {
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
        var hasNoData = true;

        c.setElementText("idLoginAccount", null, EWinInfo.LoginAccount);
        //c.setElementText("idCurrencyType", null, currencyType);
        //c.setElementText("idQueryDate", null, queryDate);


        if (o != null) {
            if (o.WalletHistoryList != null) {
                c.clearChildren(idList);

                //排序
                o.WalletHistoryList.sort(function (a, b) {
                    var DateA = a.Date + " " + a.Time;
                    var DateB = b.Date + " " + b.Time;
                    if (DateB < DateA) {
                        return -1;
                    }
                    if (DateB > DateA) {
                        return 1;
                    }

                    return 0;
                });

                for (var i = 0; i < o.WalletHistoryList.length; i++) {
                    var item = o.WalletHistoryList[i];
                    var t = c.getTemplate("templateTableItem");
                    var Description = "";

                    c.setClassText(t, "DateInfo", null, item.Date + " " + item.Time);
                    c.setClassText(t, "ActionType", null, mlp.getLanguageKey(item.ActionType));
                    c.setClassText(t, "CurrencyType", null, item.CurrencyType);

                    if (parseFloat(item.Amount) < 0) {
                        t.getElementsByClassName("Amount")[0].classList.add("num-negative");
                    }
                    c.setClassText(t, "Amount", null, c.toCurrency(item.Amount));

                    if (parseFloat(item.Balance) < 0) {
                        t.getElementsByClassName("Balance")[0].classList.add("num-negative");
                    }
                    c.setClassText(t, "Balance", null, c.toCurrency(item.Balance));

                    Description = item.Description;
                    if (Description.indexOf("Require Of Withdrawal") != -1) {
                        Description = Description.replace("Require Of Withdrawal", mlp.getLanguageKey("Require Of Withdrawal"))
                    }
                    else if (Description.indexOf("Require Withdrawal") != -1) {
                        Description = Description.replace("Require Withdrawal", mlp.getLanguageKey("Require Withdrawal"))
                    }
                    else if (Description.indexOf("Manual:") != -1) {
                        Description = Description.replace("Manual:", mlp.getLanguageKey("Manual"))
                    }

                    if (item.ActionType == "TransactionOut") {

                        c.setClassText(t, "Description", null, item.LoginAccount + " -> " + Description);

                    }
                    else if (item.ActionType == "TransactionIn") {
                        c.setClassText(t, "Description", null, Description + " -> " + item.LoginAccount);
                    }
                    else {
                        c.setClassText(t, "Description", null, mlp.getLanguageKey(Description));
                    }
                        

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

        if (EWinInfo.UserInfo != null) {
            if (EWinInfo.UserInfo.WalletList != null) {
                pi = EWinInfo.UserInfo.WalletList;
                if (pi.length > 0) {
                    for (i = 0; i < pi.length; i++) {
                        templateDiv = document.getElementById("templateDiv");
                        CurrencyTypeDiv.insertAdjacentHTML("beforeend", templateDiv.innerHTML);

                        tempCurrencyRadio = c.getFirstClassElement(CurrencyTypeDiv, "tempRadio");
                        tempCurrencyName = c.getFirstClassElement(CurrencyTypeDiv, "tempName");

                        tempCurrencyRadio.value = pi[i].CurrencyType;
                        tempCurrencyRadio.name = "chkCurrencyType";
                        tempCurrencyName.innerText = pi[i].CurrencyType;

                        tempCurrencyRadio.classList.remove("tempRadio");
                        tempCurrencyName.classList.remove("tempName");
                    }
                }
            }
        }
    }

    function init() {

        EWinInfo = window.parent.EWinInfo;
        api = window.parent.API_GetAgentAPI();
        setSearchFrame();


        lang = window.localStorage.getItem("agent_lang");
        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
            //queryWalletHistory();
            window.parent.API_CloseLoading();
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
                    <h2 class="collapse-header has-arrow zIndex_overMask_SafariFix" onclick="ac.dataToggleCollapse(this)" data-toggle="collapse" data-target="#searchList" aria-controls="searchList" aria-expanded="true" aria-label="searchList">
                        <span class="language_replace">交易明細</span>
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
                                        <div class="form-group">
                                            <div class="form-control-default">
                                                <input id="startDate" type="date" class="form-control custom-date">
                                                <label for="" class="form-label"><i class="icon icon2020-calendar-o"></i></label>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="endDate">
                                        <div class="title"><span class="language_replace">結束日期</span></div>
                                        <div class="form-group">
                                            <div class="form-control-default">
                                                <input id="endDate" type="date" class="form-control custom-date">
                                                <label for="" class="form-label"><i class="icon icon2020-calendar-o"></i></label>
                                            </div>
                                        </div>
                                    </div>

                                </div>
                            </div>
                            <div class="col-12 col-md-6 col-lg-4 col-xl-auto">
                                <!-- 幣別 -->
                                <div class="form-group form-group-s2 ">
                                    <div class="title"><span class="language_replace">幣別</span></div>

                                    <div id="CurrencyTypeDiv" class="content">
                                        <div class="custom-control custom-checkboxValue custom-control-inline check-all">
                                            <label class="custom-label">
                                                <input type="checkbox" name="chkCurrencyType" class="custom-control-input-hidden" onclick="chkData(this)" value="all" checked>
                                                <div class="custom-input checkbox"><span class="language_replace">全選</span></div>
                                            </label>
                                        </div>
                                        
                                    </div>

                                </div>

                                <div id="templateDiv" style="display: none">
                                    <div class="custom-control custom-checkboxValue custom-control-inline check-bg">
                                        <label class="custom-label">
                                            <input type="checkbox" class="custom-control-input-hidden tempRadio" onclick="chkData(this)" checked>
                                            <div class="custom-input checkbox"><span class="language_replace tempName">Non</span></div>
                                        </label>
                                    </div>
                                </div>
                            </div>
                            <div class="col-12 col-md-6 col-lg-4 col-xl-auto">
                                <!-- 投注類型 -->
                                <div class="form-group form-group-s2 ">
                                    <span class="title"><span class="language_replace">類型</span></span>
                                    <div class="content">
                                        <div class="custom-control custom-checkboxValue custom-control-inline check-all">
                                            <label class="custom-label">
                                                <input type="checkbox" name="chkActionType" class="custom-control-input-hidden" value="all" onclick="chkData(this)" checked>
                                                <div class="custom-input checkbox"><span class="language_replace">全選</span></div>
                                            </label>
                                        </div>
                                        <div class="custom-control custom-checkboxValue custom-control-inline check-bg">
                                            <label class="custom-label">
                                                <input type="checkbox" name="chkActionType" class="custom-control-input-hidden" value="TransactionOut,Withdrawal" onclick="chkData(this)" checked>
                                                <div class="custom-input checkbox"><span class="language_replace">轉出</span></div>
                                            </label>
                                        </div>
                                        <div class="custom-control custom-checkboxValue custom-control-inline check-bg">
                                            <label class="custom-label">
                                                <input type="checkbox" name="chkActionType" class="custom-control-input-hidden" value="TransactionIn,Deposit" onclick="chkData(this)" checked>
                                                <div class="custom-input checkbox"><span class="language_replace">轉入</span></div>
                                            </label>
                                        </div>
                                        <div class="custom-control custom-checkboxValue custom-control-inline check-bg">
                                            <label class="custom-label">
                                                <input type="checkbox" name="chkActionType" class="custom-control-input-hidden" value="Commission" onclick="chkData(this)" checked>
                                                <div class="custom-input checkbox"><span class="language_replace">佣金</span></div>
                                            </label>
                                        </div>
                                        <div class="custom-control custom-checkboxValue custom-control-inline check-bg">
                                            <label class="custom-label">
                                                <input type="checkbox" name="chkActionType" class="custom-control-input-hidden" value="Manual" onclick="chkData(this)" checked>
                                                <div class="custom-input checkbox"><span class="language_replace">公司加扣點</span></div>
                                            </label>
                                        </div>
                                   <%--     <div class="custom-control custom-checkboxValue custom-control-inline check-bg">
                                            <label class="custom-label">
                                                <input type="checkbox" name="chkActionType" class="custom-control-input-hidden" value="Withdrawal" onclick="chkData(this)" checked>
                                                <div class="custom-input checkbox"><span class="language_replace">Withdrawal</span></div>
                                            </label>
                                        </div>
                                        <div class="custom-control custom-checkboxValue custom-control-inline check-bg">
                                            <label class="custom-label">
                                                <input type="checkbox" name="chkActionType" class="custom-control-input-hidden" value="Deposit" onclick="chkData(this)" checked>
                                                <div class="custom-input checkbox"><span class="language_replace">Deposit</span></div>
                                            </label>
                                        </div>--%>
                                    </div>

                                </div>
                            </div>
                            <div class="col-12">
                                <div class="form-group wrapper_center dataList-process">
                                    <%--<button class="btn btn-outline-main" onclick="MaskPopUp(this)">取消</button>--%>
                                    <button class="btn btn-full-main btn-roundcorner" onclick="queryData()"><i class="icon icon-before icon-ewin-input-submit"></i><span class="language_replace">確認</span></button>
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
                        <div class="tbody__tr">
                            <div class="tbody__td date td-100 td-auto-title nonTitle ">
                                <span class="td__title"><span class="language_replace">時間</span></span>
                                <span class="td__content"><span class="DateInfo">CON5</span></span>
                            </div>

                            <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">類型</span></span>
                                <span class="td__content"><i class="icon icon-ewin-default-transitionType icon-s icon-before"></i><span class="ActionType">CON3</span></span>
                            </div>

                            <div class="tbody__td td-3 nonTitle">
                                <span class="td__title"><span class="language_replace">幣別</span></span>
                                <span class="td__content"><i class="icon icon-ewin-default-currencyType icon-s icon-before"></i><span class="CurrencyType">CON3</span></span>
                            </div>
                            <div class="tbody__td td-3 td-number td-vertical">
                                <span class="td__title"><i class="icon icon-ewin-default-amount icon-s icon-before"></i><span class="language_replace">金額</span></span>
                                <span class="td__content"><span class="Amount">CON4</span></span>
                            </div>
                            <div class="tbody__td td-3 td-number td-vertical">
                                <span class="td__title"><i class="icon icon-ewin-default-balance icon-s icon-before"></i><span class="language_replace">餘額</span></span>
                                <span class="td__content"><span class="Balance">CON4</span></span>
                            </div>
                            <div class="tbody__td date td-100 td-vertical td-icon">
                                <span class="td__title"><i class="icon icon-ewin-default-note icon-s icon-before"></i><span class="language_replace">備註</span></span>
                                <span class="td__content"><span class="Description">CON3</span></span>
                            </div>

                        </div>
                    </div>
                    <!-- 標題項目  -->
                    <div class="thead">
                        <!--標題項目單行 -->
                        <div class="thead__tr">
                            <div class="thead__th"><span class="language_replace">時間</span></div>
                            <div class="thead__th"><span class="language_replace">類型</span></div>
                            <div class="thead__th"><span class="language_replace">幣別</span></div>
                            <div class="thead__th"><span class="language_replace">金額</span></div>
                            <div class="thead__th"><span class="language_replace">餘額</span></div>
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
    <script type="text/javascript">
        ac.listenScreenMove();

    </script>
</html>
