<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GetGameSetDetail.aspx.cs" Inherits="GetGameSetDetail" %>

<%
    string ASID = Request["ASID"];
    string GameSetID = Request["GameSetID"];
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
</head>
<!-- <script type="text/javascript" src="js/AgentCommon.js"></script> -->
<script type="text/javascript" src="js/AgentCommon.js"></script>
<script type="text/javascript" src="/Scripts/Common.js"></script>
<script type="text/javascript" src="/Scripts/bignumber.min.js"></script>
<script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
<script type="text/javascript" src="Scripts/MultiLanguage.js"></script>
<script src="js/jquery-3.3.1.min.js"></script>
<script>
    var ApiUrl = "GetGameSetDetail.aspx";
    var c = new common();
    var ac = new AgentCommon();
    var mlp;
    var EWinInfo;
    var api;
    var lang;
    var GameSetID = <%=GameSetID%>;
    var SelectedWallet;

    function queryData() {
        var idList = document.getElementById("idList");

        postData = {
            AID: EWinInfo.ASID,
            GameSetID: GameSetID
        };

        window.parent.API_ShowLoading();
        c.callService(ApiUrl + "/GetGameSetDetailData", postData, function (success, o) {
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
            if (o.Datas != null) {
                for (var i = 0; i < o.Datas.length; i++) {
                    let data = o.Datas[i];
                    let t = c.getTemplate("templateTableItem");
                    let k = "";

                    c.setClassText(t, "OrderID", null, data.OrderID);
                    c.setClassText(t, "CurrencyType", null, data.CurrencyType);
                    c.setClassText(t, "RoadMapInfo", null, data.RoadMapInfo);
                    c.setClassText(t, "RoadMapNumber", null, data.RoadMapNumber);
                    //c.setClassText(t, "SummaryDate", null, data.SummaryDate);
                    //c.setClassText(t, "CreateDate", null, data.CreateDate);
                    c.setClassText(t, "LoginAccount", null, data.LoginAccount);
                    c.setClassText(t, "RewardValue", null, toCurrency((data.RewardValue)));

                    switch (data.Result) {
                        case "1":
                            k = mlp.getLanguageKey("莊");
                            break;
                        case "2":
                            k = mlp.getLanguageKey("閒");
                            break;
                        case "3":
                            k = mlp.getLanguageKey("和");
                            break;
                        case "5":
                            k = mlp.getLanguageKey("莊") + " / " + mlp.getLanguageKey("莊對");
                            break;
                        case "9":
                            k = mlp.getLanguageKey("莊") + " / "  + mlp.getLanguageKey("閒對");
                            break;
                        case "D":
                            k = mlp.getLanguageKey("莊") + " / "  + mlp.getLanguageKey("莊對") + " / "  + mlp.getLanguageKey("閒對");
                            break;
                        case "6":
                            k = mlp.getLanguageKey("閒") + " / "  + mlp.getLanguageKey("莊對");
                            break;
                        case "A":
                            k = mlp.getLanguageKey("閒") + " / "  + mlp.getLanguageKey("閒對");
                            break;
                        case "E":
                            k = mlp.getLanguageKey("閒") + " / "  + mlp.getLanguageKey("莊對") + " / "  + mlp.getLanguageKey("閒對");
                            break;
                        case "7":
                            k = mlp.getLanguageKey("和") + " / "  + mlp.getLanguageKey("莊對");
                            break;
                        case "B":
                            k = mlp.getLanguageKey("和") + " / "  + mlp.getLanguageKey("閒對");
                            break;
                        case "F":
                            k = mlp.getLanguageKey("和") + " / "  + mlp.getLanguageKey("莊對") + " / "  + mlp.getLanguageKey("閒對");
                            break;
                    }
                    c.setClassText(t, "Result", null, k);

                    idList.appendChild(t);

                    document.getElementById("hasNoData_DIV").style.display = "none";
                    idList.classList.remove("tbody__hasNoData");
                    document.getElementById("idResultTable").classList.remove("MT_tableDiv__hasNoData");
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

    window.onload = init;
</script>
<body class="innerBody">
    <main>
        <div class="dataList dataList-box fixed top real-fixed">
            <div class="container-fluid">
                <div class="collapse-box">
                    <h2 id="ToggleCollapse" class="collapse-header has-arrow zIndex_overMask_SafariFix" onclick="ac.dataToggleCollapse(this)" data-toggle="collapse" data-target="#searchList" aria-controls="searchList" aria-expanded="true" aria-label="searchList">
                        <span class="language_replace">電投開工細節</span>

                        <!-- collapse內容 由此開始 ========== -->
                        <div id="searchList" class="collapse-content collapse show">
                        </div>
                    </h2>
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
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">ID</span></span>
                                <span class="td__content"><span class="OrderID"></span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">帳號</span></span>
                                <span class="td__content"><span class="LoginAccount"></span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">桌靴局</span></span>
                                <span class="td__content"><span class="RoadMapInfo"></span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">幣別</span></span>
                                <span class="td__content"><span class="CurrencyType"></span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">輸贏數</span></span>
                                <span class="td__content"><span class="RewardValue"></span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">結果</span></span>
                                <span class="td__content"><span class="Result"></span></span>
                            </div>
                            <%--<div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">結算日期</span></span>
                                <span class="td__content"><span class="SummaryDate"></span></span>
                            </div>
                            <div class="tbody__td td-number td-3 td-vertical">
                                <span class="td__title"><span class="language_replace">建立日期</span></span>
                                <span class="td__content"><span class="CreateDate"></span></span>
                            </div>--%>
                        </div>
                    </div>
                    <!-- 標題項目  -->
                    <div class="thead">
                        <!--標題項目單行 -->
                        <div class="thead__tr">
                            <div class="thead__th"><span class="language_replace">ID</span></div>
                            <div class="thead__th"><span class="language_replace">帳號</span></div>
                            <div class="thead__th"><span class="language_replace">桌靴局</span></div>
                            <div class="thead__th"><span class="language_replace">幣別</span></div>
                            <div class="thead__th"><span class="language_replace">輸贏數</span></div>
                            <div class="thead__th"><span class="language_replace">結果</span></div>
                            <%--<div class="thead__th"><span class="language_replace">結算日期</span></div>
                            <div class="thead__th"><span class="language_replace">建立日期</span></div>--%>
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
