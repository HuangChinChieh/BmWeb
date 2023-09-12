<%@ Page Language="C#" AutoEventWireup="true" CodeFile="home_CasinoExcludeLogin.aspx.cs" Inherits="home_CasinoExcludeLogin" %>

<%
    string DefaultCompany = "";
    string DefaultCurrencyType = "";
    string AgentVersion = EWinWeb.AgentVersion;

    DefaultCompany = EWinWeb.CompanyCode;
    DefaultCurrencyType = EWinWeb.MainCurrencyType;
%>
<!doctype html>
<html lang="zh-Hant-TW" class="innerHtml">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Home 測試頁</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/basic.min.css?<%=AgentVersion %>">
    <link rel="stylesheet" href="css/main2.css?<%=AgentVersion %>">
    <link rel="stylesheet" href="css/index.css?<%=AgentVersion %>">
    <style>
        .data {
            color: rgba(255, 238, 210, 0.8);
        }

        .homeitemborder {
            border: solid 3px rgba(255, 255, 255, 0.15);
            margin-bottom: 20px;
        }

        .homeitemtitle {
            font-size: 1.15rem;
            font-weight: bold;
            color: rgba(227, 195, 141, 0.85);
        }

        .homeitemvalue {
            color: rgba(255, 238, 210, 0.8);
            font-size: 2rem;
        }

        .homeitembackground {
            background-repeat: no-repeat;
            background-position: left 10px center;
            background-size: auto 54px
        }

        .homeitemchildimg {
            background-repeat: no-repeat;
            background-size: contain;
            background-position: 50%;
            width: 44px;
            height: 44px;
            margin: auto;
            filter: brightness(0.1);
        }

        .ant-btn {
            line-height: 1.499;
            position: relative;
            display: inline-block;
            font-weight: 400;
            white-space: nowrap;
            text-align: center;
            background-image: none;
            box-shadow: 0 2px 0 rgba(0,0,0,.015);
            cursor: pointer;
            transition: all .3s cubic-bezier(.645,.045,.355,1);
            -webkit-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
            user-select: none;
            touch-action: manipulation;
            height: 32px;
            padding: 0 15px;
            font-size: 14px;
            border-radius: 4px;
            color: rgba(0,0,0,.65);
            background-color: #fff;
            border: 1px solid #d9d9d9
        }
    </style>
    <script type="text/javascript" src="/Scripts/Common.js"></script>
    <script type="text/javascript" src="/Scripts/bignumber.min.js"></script>
    <script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
    <script type="text/javascript" src="Scripts/MultiLanguage.js"></script>
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript" src="js/AgentAPI.js"></script>
    <script type="text/javascript" src="js/AgentCommon.js"></script>
    <script type="text/javascript" src="js/date.js"></script>
    <script type="text/javascript">
        var ApiUrl = "home_CasinoExcludeLogin.aspx";
        var c = new common();
        var ac = new AgentCommon();
        var mlp;
        var EWinInfo = null;
        var api;
        var lang;
        var parentLoginAccount = "";
        var startDate = Date.today().toString("yyyy-MM-dd");
        var endDate = Date.today().toString("yyyy-MM-dd");
        var DefaultCurrencyType = "<%=DefaultCurrencyType%>";
        var MsgText = " Group Profit - DownLine Total Profit = Pesonal Profit,<br/>"
            + " NGR * Share (at that time) = Group Profit,<br/>"
            + " Valid Bet * Rebate (at that time) = Group Profit,<br/>"
            + "<br/>"
            + "「Win/Loss」, 「NGR」, 「Valid Bet」 are group statistics.<br/>"
            + "<br/>"
            + "Numbers are trial calculations.<br/>"
            + "Don't represent final results.<br/>"
            + "They are for reference only.";

        function queryUserInfo(cb) {
            var LoginAccount = $('#loginAccount').val();
            var postData = {
                "LoginAccount": LoginAccount
            }

            c.callService(ApiUrl + "/QueryUserInfo", postData, function (success, obj) {
                if (success) {
                    var o = c.getJSON(obj);
                    if (o.Result == 0) {
                        $("#idLoginAccount").text(LoginAccount);
                        //$("#idPromotionCode").text(EWinInfo.UserInfo.PersonCode);
                        //$('#QRCodeimg').attr("src", `/GetQRCode.aspx?QRCode=${EWinInfo.CompanyInfo.QRCodeURL}?PCode=${EWinInfo.UserInfo.PersonCode}&Download=2`);
                        //$(".spanUrlLink1").text(EWinInfo.CompanyInfo.QRCodeURL + "?PCode=" + EWinInfo.UserInfo.PersonCode);

                        // build wallet list
                        if (o.WalletList != null) {
                            for (var i = 0; i < o.WalletList.length; i++) {
                                var w = o.WalletList[i];
                                if (w.CurrencyType != DefaultCurrencyType) {
                                    continue;
                                }

                                if (w.PointValue.toString().includes("e")) {
                                    $("#idWalletBalance").text(BigNumber(roundDown(w.PointValue, 2)).toFormat());
                                } else {
                                    $("#idWalletBalance").text(Number(BigNumber(roundDown(w.PointValue, 2))));
                                }
                            }

                        }

                        if (o.GameCodeList != null) {
                            for (var l = 0; l < o.GameCodeList.length; l++) {
                                let kk = o.GameCodeList[l];
                                if (kk.CurrencyType == DefaultCurrencyType) {
                                    let t = c.getTemplate("tempGameAccountingCode");

                                    c.setClassText(t, "GameAccountingCode", null, mlp.getLanguageKey(kk.GameAccountingCode));
                                    c.setClassText(t, "UserRate", null, c.toCurrency(kk.UserRate) + "%");
                                    c.setClassText(t, "BuyChipRate", null, c.toCurrency(kk.BuyChipRate) + "%");

                                    $("#tb_GameAccountingCode").append(t);
                                }
                            }
                        }

                        if ($("#idUserWalletInfo .GameAccountingCodeList").children().length == 0) {
                            $('.btnOpen').hide();
                            $('.btnClose').hide();
                        }

                        queryAccountingData();

                        if (cb)
                            cb(true);
                    CloseLoading();
                    } else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o.Message));

                        if (cb)
                            cb(false);
                    CloseLoading();
                    }
                } else {
                    if (o == "Timeout") {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後重新嘗試"));
                    } else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), o);
                    }
                }

            });
        }
        //小數點後兩位無條件捨去
        function roundDown(num, decimal) {
            return Math.floor((num + Number.EPSILON) * Math.pow(10, decimal)) / Math.pow(10, decimal);
        }

        function callService(URL, postObject, cb) {
            var xmlHttp = new XMLHttpRequest;
            var postData;

            if (postObject)
                postData = JSON.stringify(postObject);

            xmlHttp.open("POST", URL, true);
            xmlHttp.onreadystatechange = function () {
                if (this.readyState == 4) {
                    var contentText = this.responseText;

                    if (this.status == "200") {
                        if (cb) {
                            cb(true, contentText);
                        }
                    } else {
                        cb(false, contentText);
                    }
                }
            };

            xmlHttp.timeout = 110000;  // 30s
            xmlHttp.ontimeout = function () {
                if (cb)
                    cb(false, "Timeout");
            };

            xmlHttp.setRequestHeader("Content-Type", "application/json; charset=utf-8");
            xmlHttp.send(postData);
        };

        function queryAccountingData() {
            var postData;
            $(".TotalValidBetValue").text(0);
            $(".TotalRewardValue").text(0);
            $(".UserRebate").text(0);
            $(".PaidOPValue").text(0);
            $(".TotalNGR").text(0);
            $(".ComissionValue").text(0);
            $(".TotalLineRebate").text(0);
            $(".TotalChildLineRebate").text(0);
            $(".TotalOrderCount").text(0);
            $(".NewUserCount").text(0);
            $(".WithdrawalValue").text(0);
            $(".WithdrawalCount").text(0);
            $(".DepositValue").text(0);
            $(".DepositCount").text(0);
            $(".FirstDepositValue").text(0);
            $(".FirstDepositCount").text(0);
            $(".RewardValue").text(0);
            $(".NotFirstDepositCount").text(0);
            $(".PreferentialCost").text(0);
            $(".FailureCondition").text("");
            $(".UserRebateUserRate").text(0);
            $(".UserRebateCommission").text(0);
            $(".TotalLineRebateUserRate").text(0);
            $(".TotalChildLineRebateUserRate").text(0);
            $(".TotalLineRebateCommission").text(0);
            $(".TotalChildLineRebateCommission").text(0);
            $(".ActiveUser").text(0);
            $("#tb_TopTenOrderUser").empty();
            MsgText = " Group Profit - DownLine Total Profit = Pesonal Profit,<br/>"
                + " NGR * Share (at that time) = Group Profit,<br/>"
                + " Valid Bet * Rebate (at that time) = Group Profit,<br/>"
                + "<br/>"
                + "「Win/Loss」, 「NGR」, 「Valid Bet」 are group statistics.<br/>"
                + "<br/>"
                + "Numbers are trial calculations.<br/>"
                + "Don't represent final results.<br/>"
                + "They are for reference only.<br/>";

            var LoginAccount = $('#loginAccount').val();

            if (LoginAccount=='') {
                alert('尚未輸入帳號');
                return;
            }
            
            postData = {
                QueryBeginDate: startDate,
                QueryEndDate: endDate,
                CurrencyType: DefaultCurrencyType,
                LoginAccount: LoginAccount
            };
            
            ShowLoading();

            c.callService(ApiUrl + "/GetOrderSummary", postData, function (success, obj) {
                if (success) {
                    CloseLoading();
                    var o = c.getJSON(obj);

                    let TotalValidBetValue = 0;
                    let UserRebateUserRate = 0;
                    let TotalLineRebate = 0;
                    let TotalNGR = 0;
                    let PaidOPValue = 0;
                    let RewardValue = 0;
                    let PreferentialCost = 0;
                    let TotalOrderCount = 0;
                    let NewUserCount = 0;
                    let WithdrawalValue = 0;
                    let WithdrawalCount = 0;
                    let DepositValue = 0;
                    let DepositCount = 0;
                    let FirstDepositValue = 0;
                    let UserRebateCommission = 0;
                    let ActiveUser = 0;
                    let TotalLineRebateUserRate = 0;
                    let TotalLineRebateCommission = 0;

                    if (o.Result == 0) {
                        $(".FirstDepositCount").text(toCurrency(o.FirstDepositCount));
                        $(".NotFirstDepositCount").text(toCurrency(o.NextDepositCount));
                        $(".TotalWithdrawUsers").text(toCurrency(o.TotalWithdrawUsers));
                        $(".TotalOrderUsers").text(toCurrency(o.TotalOrderUsers));
                        $(".ActivateUserCount").text(toCurrency(o.ActivateUserCount));

                        if (o.UserOrderList != null) {
                            for (var i = 0; i < o.UserOrderList.length; i++) {
                                let kk = o.UserOrderList[i];
                                let t = c.getTemplate("tempTopTenOrderUser");

                                c.setClassText(t, "LoginAccount", null, kk.LoginAccount);
                                c.setClassText(t, "OrderValue", null, c.toCurrency(kk.SelfOrderValue));
                                c.setClassText(t, "RewardValue", null, c.toCurrency(kk.SelfRewardValue));

                                $("#tb_TopTenOrderUser").append(t);
                            }
                        }
        
                        //if (o.CanReceiveUserRebateUserRate == 0) {
                        //    let strFailureCondition = "";

                        //    if (o.FailureCondition != null) {
                        //        if (o.FailureCondition.indexOf(";") > 0) {
                        //            let FailureConditions = o.FailureCondition.split(";");

                        //            for (var i = 0; i < FailureConditions.length; i++) {
                        //                switch (FailureConditions[i]) {
                        //                    case "AgentMinActiveUserCount":
                        //                        strFailureCondition += " Valid members is less than " + o.AgentMinActiveUserCount + "; ";
                        //                        break;
                        //                    case "RebateAmountMin":
                        //                        strFailureCondition += " Personal Profit is less than " + toCurrency(o.RebateAmountMin) + "; ";
                        //                        break;
                        //                }
                        //            }
                        //        }
                        //    }

                        //    $(".FailureCondition").text(strFailureCondition);

                        //}

                        //MsgText += ` Minimum Available Personal Profit = ${toCurrency(o.RebateAmountMin)} <br/>`;
                        //MsgText += ` Valid Member Count = ${o.AgentMinActiveUserCount} <br/>`;

                        if (o.AgentItemList.length > 0) {
                            for (var i = 0; i < o.AgentItemList.length; i++) {
                                let data = o.AgentItemList[i];
                                TotalValidBetValue = TotalValidBetValue + data.TotalValidBetValue;
                                UserRebateUserRate = UserRebateUserRate + data.UserRebateUserRate;
                                PaidOPValue = PaidOPValue + data.PaidOPValue;
                                TotalNGR = TotalNGR + data.TotalNGR;
                                UserRebateCommission = UserRebateCommission + data.UserRebateCommission;
                                RewardValue = RewardValue + data.TotalRewardValue;
                                PreferentialCost = PreferentialCost + data.BonusPointValue;
                                TotalOrderCount = TotalOrderCount + data.TotalOrderCount;
                                ActiveUser = ActiveUser + data.ActiveUser;
                                NewUserCount = NewUserCount + data.NewUserCount + data.NewAgentCount;
                                WithdrawalValue = WithdrawalValue + data.WithdrawalValue;
                                WithdrawalCount = WithdrawalCount + data.WithdrawalCount;
                                DepositValue = DepositValue + data.DepositValue;
                                DepositCount = DepositCount + data.DepositCount;
                                FirstDepositValue = FirstDepositValue + data.FirstDepositValue;
                                TotalLineRebateUserRate = TotalLineRebateUserRate + data.TotalLineRebateUserRate;
                                TotalLineRebateCommission = TotalLineRebateCommission + data.TotalLineRebateCommission;
                            }

                            $(".TotalValidBetValue").text(toCurrency(TotalValidBetValue));
                            $(".UserRebateUserRate").text(toCurrency(UserRebateUserRate));
                            //$(".PaidOPValue").text(toCurrency(PaidOPValue));
                            //$(".TotalNGR").text(toCurrency(TotalNGR));
                            $(".UserRebateCommission").text(toCurrency(UserRebateCommission));
                            $(".TotalLineRebateUserRate").text(toCurrency(TotalLineRebateUserRate));
                            //$(".TotalChildLineRebateUserRate").text(toCurrency(TotalLineRebateUserRate - UserRebateUserRate));
                            //$(".TotalLineRebateCommission").text(toCurrency(TotalLineRebateCommission));
                            //$(".TotalChildLineRebateCommission").text(toCurrency(TotalLineRebateCommission - UserRebateCommission));
                            $(".TotalRewardValue").text(toCurrency(RewardValue));
                            $(".PreferentialCost").text(toCurrency(PreferentialCost));
                            //$(".TotalOrderCount").text(toCurrency(TotalOrderCount));
                            //$(".ActiveUser").text(toCurrency(ActiveUser));
                            $(".NewUserCount").text(toCurrency(NewUserCount));
                            $(".WithdrawalValue").text(toCurrency(WithdrawalValue));
                            $(".WithdrawalCount").text(toCurrency(WithdrawalCount));
                            $(".DepositValue").text(toCurrency(DepositValue));
                            $(".DepositCount").text(toCurrency(DepositCount));
                            $(".FirstDepositValue").text(toCurrency(FirstDepositValue));
                        }
                    } else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(obj.Message));
                    }
                } else {
                    CloseLoading();
                    if (o == "Timeout") {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後重新嘗試"));
                    } else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), o);
                    }
                }

            });

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

        function getChildUserData() {
            var postData;
            var LoginAccount = $('#loginAccount').val();

            postData = {
                LoginAccount: LoginAccount
            };

            c.callService(ApiUrl + "/GetChildUserData", postData, function (success, obj) {
                if (success) {
                    var o = c.getJSON(obj);
                    if (o.Result == 0) {
                        $(".AgentCount").text(toCurrency(o.AgentCount));
                        $(".AgentCount_Under").text(toCurrency(o.AgentCount_Under));
                        $(".AgentCount_Other").text(toCurrency(o.AgentCount - o.AgentCount_Under));
                        $(".UserCount").text(toCurrency(o.UserCount));
                        $(".UserCount_Under").text(toCurrency(o.UserCount_Under));
                        $(".UserCount_Other").text(toCurrency(o.UserCount - o.UserCount_Under));
                    }
                } else {
                    if (o == "Timeout") {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後重新嘗試"));
                    } else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), o);
                    }
                }

            });

        CloseLoading();
        }

        function changeDateTab(e, type) {
            window.event.stopPropagation();
            window.event.preventDefault();

            var tabMainContent = document.getElementById("idTabMainContent");
            var tabItem = tabMainContent.getElementsByClassName("nav-link");
            for (var i = 0; i < tabItem.length; i++) {
                tabItem[i].classList.remove('active');
                tabItem[i].parentNode.classList.remove('active');

                tabItem[i].setAttribute("aria-selected", "false");

            }

            e.parentNode.classList.add('active');
            e.classList.add('active');
            e.setAttribute("aria-selected", "true");
            switch (type) {
                case 0:
                    startDate = Date.today().toString("yyyy-MM-dd");
                    endDate = Date.today().toString("yyyy-MM-dd");
                    queryAccountingData();
                    break;
                case 1:
                    startDate = Date.today().addDays(-1).toString("yyyy-MM-dd");
                    endDate = Date.today().addDays(-1).toString("yyyy-MM-dd");
                    queryAccountingData();
                    break;
                case 2:
                    startDate = getFirstDayOfWeek(Date.today()).toString("yyyy-MM-dd");
                    endDate = getLastDayOfWeek(Date.today()).toString("yyyy-MM-dd");
                    queryAccountingData();
                    break;
                case 3:
                    startDate = getFirstDayOfWeek(Date.today().addDays(-7)).toString("yyyy-MM-dd");
                    endDate = getLastDayOfWeek(Date.today().addDays(-7)).toString("yyyy-MM-dd");
                    queryAccountingData();
                    break;
                case 4:
                    startDate = Date.today().moveToFirstDayOfMonth().toString("yyyy-MM-dd");
                    endDate = Date.today().moveToLastDayOfMonth().toString("yyyy-MM-dd");
                    queryAccountingData();
                    break;
                case 5:
                    startDate = Date.today().addMonths(-1).moveToFirstDayOfMonth().toString("yyyy-MM-dd");
                    endDate = Date.today().addMonths(-1).moveToLastDayOfMonth().toString("yyyy-MM-dd");
                    queryAccountingData();
                    break;
            }
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

        function toCurrency(num) {

            num = parseFloat(Number(num).toFixed(2));
            var parts = num.toString().split('.');
            parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
            return parts.join('.');
        }

        function searchBtn() {
            var LoginAccount = $('#loginAccount').val();

            if (LoginAccount.trim() == '') {
                alert("尚未輸入帳號");
                return;
            }

            queryUserInfo();
            getChildUserData();
        }

        function init() {
            lang = window.localStorage.getItem("agent_lang");
            mlp = new multiLanguage();
            mlp.loadLanguage(lang, function () {
        
            });
        }

        function API_ShowMessageOK(title,message) {
            alert(title + "," + message);
        }

        window.onload = init;
    </script>
</head>
<body class="innerBody" style="background-color:darkslategrey;">
    <main>
        <div id="WrapperFilterGame_Home" class="fixed Filter__Wrapper">
            <div class="container-fluid ">
                  <div id="idSearchButton" class="col-12 col-md-6 col-lg-4 col-xl-auto">
                        <div class="form-group form-group-s2 ">
                            <div class="title hidden shown-md"><span class="language_replace">帳號</span></div>
                            <div class="input-group form-control-underline iconCheckAnim placeholder-move-right zIndex_overMask_SafariFix">
                                <input type="text" class="form-control" id="loginAccount" value="">
                                <div class="input-group-append">
                                    <span onclick="searchBtn()" class="input-group-text language_replace" style="cursor: pointer; color: #C9AE7F; background-color: #2d3244; border: none">搜尋</span>
                                </div>
                            </div>

                        </div>
                    </div>
                <div class="row" style="width: 99%; margin: auto; margin-top: 20px">
            <div class="col-12 col-md-12 col-lg-12 col-gx-3 col-xl-3">

                <div class="currencyWalletList" style="margin-top: 20px">
                    <div class="container-fluid">
                        <div class="row">
                            <div class="col-12 col-md-12 col-lg-12 col-gx-12 col-xl-12">
                                <div id="idUserWalletInfo">
                                </div>
                                <div class="row">
                                    <div class="col-12 col-md-12 col-lg-12 col-gx-12 col-xl-12">
                                        <div class="row item" style="border: hidden">
                                            <div class="col-3 col-md-3 col-lg-3 col-gx-3 col-xl-3">
                                                <div class="item homeitembackground" style="background-image: url(./Images/home/LoginAccount.png); width: 100%; height: 100%; border: hidden">
                                                </div>
                                            </div>
                                            <div class="col-9 col-md-9 col-lg-9 col-gx-9 col-xl-9">
                                                <div>
                                                    <span class="currency language_replace homeitemtitle">帳號</span>
                                                </div>
                                                <div>
                                                    <span class="language_replace homeitemvalue" id="idLoginAccount">0</span>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row item">
                                            <div class="col-3 col-md-3 col-lg-3 col-gx-3 col-xl-3">
                                                <div class="item homeitembackground" style="background-image: url(./Images/home/Balance.png); width: 100%; height: 100%; border: hidden">
                                                </div>
                                            </div>
                                            <div class="col-9 col-md-9 col-lg-9 col-gx-9 col-xl-9">
                                                <div>
                                                    <span class="currency language_replace homeitemtitle">可用餘額</span>
                                                </div>
                                                <div>
                                                    <span class="language_replace homeitemvalue" id="idWalletBalance">0</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-12 col-md-12 col-lg-12 col-gx-12 col-xl-12">
                                        <div class="item row">
                                            <div class="col-8 col-md-8 col-lg-8 col-gx-8 col-xl-8">
                                                <div>
                                                    <span class="currency language_replace homeitemtitle">推薦碼</span>
                                                </div>
                                                <div>
                                                    <span class="language_replace homeitemvalue" id="idPromotionCode">0</span>
                                                </div>
                                                <div>
                                                    <span class="spanUrlLink1" id="spanUrlLink1" style="position: absolute; top: -100px; width: 100px; height: 0px; text-indent: -9999999999px;"></span>
                                                    <button style="border-color: #492a84; color: #492a84" class="ant-btn" onclick="copyPromotionUrl()">
                                                        <i aria-label="icon: copy" class="anticon anticon-copy">
                                                            <svg viewBox="64 64 896 896" data-icon="copy" width="1em" height="1em" fill="currentColor" aria-hidden="true" focusable="false" class="">
                                                                <path d="M832 64H296c-4.4 0-8 3.6-8 8v56c0 4.4 3.6 8 8 8h496v688c0 4.4 3.6 8 8 8h56c4.4 0 8-3.6 8-8V96c0-17.7-14.3-32-32-32zM704 192H192c-17.7 0-32 14.3-32 32v530.7c0 8.5 3.4 16.6 9.4 22.6l173.3 173.3c2.2 2.2 4.7 4 7.4 5.5v1.9h4.2c3.5 1.3 7.2 2 11 2H704c17.7 0 32-14.3 32-32V224c0-17.7-14.3-32-32-32zM350 856.2L263.9 770H350v86.2zM664 888H414V746c0-22.1-17.9-40-40-40H232V264h432v624z"></path></svg></i>
                                                        <span>複製</span>
                                                    </button>
                                                    <div id="toastCopied" class="toastCopied">
                                                        <span class="language_replace">已複製</span>
                                                    </div>
                                                    <button style="border-color: #492a84; color: #492a84" class="ant-btn" onclick="downPromotionUrlImage()">
                                                        <i aria-label="icon: download" class="anticon anticon-download">
                                                            <svg viewBox="64 64 896 896" data-icon="download" width="1em" height="1em" fill="currentColor" aria-hidden="true" focusable="false" class="">
                                                                <path d="M505.7 661a8 8 0 0 0 12.6 0l112-141.7c4.1-5.2.4-12.9-6.3-12.9h-74.1V168c0-4.4-3.6-8-8-8h-60c-4.4 0-8 3.6-8 8v338.3H400c-6.7 0-10.4 7.7-6.3 12.9l112 141.8zM878 626h-60c-4.4 0-8 3.6-8 8v154H214V634c0-4.4-3.6-8-8-8h-60c-4.4 0-8 3.6-8 8v198c0 17.7 14.3 32 32 32h684c17.7 0 32-14.3 32-32V634c0-4.4-3.6-8-8-8z"></path></svg></i>
                                                        <span>下載</span>
                                                    </button>
                                                </div>
                                            </div>
                                            <div class="col-4 col-md-4 col-lg-4 col-gx-4 col-xl-4">
                                                <img id="QRCodeimg" alt="" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-12 col-md-12 col-lg-12 col-gx-12 col-xl-12">
                                        <div>
                                            <div class="item row" style="text-align: center; align-items: center;">
                                                <div class="col-2 col-md-2 col-lg-2 col-gx-2 col-xl-2">
                                                    <div class="homeitemchildimg" style="background-image: url(./Images/home/team_agent.svg);"></div>
                                                    <div>
                                                        <span class="homeitemtitle language_replace">代理</span>
                                                    </div>
                                                </div>
                                                <div class="col-4 col-md-4 col-lg-4 col-gx-4 col-xl-4">
                                                    <div>
                                                        <span class="data AgentCount homeitemvalue">0</span>
                                                    </div>
                                                    <div>
                                                        <span class="language_replace homeitemtitle">總數</span>
                                                    </div>
                                                </div>
                                                <div class="col-6 col-md-6 col-lg-6 col-gx-6 col-xl-6">
                                                    <div class="row">
                                                        <div class="col-6 col-md-6 col-lg-6 col-gx-6 col-xl-6 homeitemborder" style="margin: 0">
                                                            <div>
                                                                <span class="data AgentCount_Under homeitemvalue">0</span>
                                                            </div>
                                                            <div>
                                                                <span class="language_replace homeitemtitle">直屬</span>
                                                            </div>
                                                        </div>
                                                        <div class="col-6 col-md-6 col-lg-6 col-gx-6 col-xl-6 homeitemborder" style="margin: 0">
                                                            <div>
                                                                <span class="data AgentCount_Other homeitemvalue">0</span>
                                                            </div>
                                                            <div>
                                                                <span class="language_replace homeitemtitle">下線</span>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-12 col-md-12 col-lg-12 col-gx-12 col-xl-12">
                                        <div>
                                            <div class="item row" style="text-align: center; align-items: center;">
                                                <div class="col-2 col-md-2 col-lg-2 col-gx-2 col-xl-2">
                                                    <div class="homeitemchildimg" style="background-image: url(./Images/home/team_user.svg);"></div>
                                                    <div>
                                                        <span class="homeitemtitle language_replace">會員</span>
                                                    </div>
                                                </div>
                                                <div class="col-4 col-md-4 col-lg-4 col-gx-4 col-xl-4">
                                                    <div>
                                                        <span class="data UserCount homeitemvalue">0</span>
                                                    </div>
                                                    <div>
                                                        <span class="language_replace homeitemtitle">總數</span>
                                                    </div>
                                                </div>
                                                <div class="col-6 col-md-6 col-lg-6 col-gx-6 col-xl-6">
                                                    <div class="row">
                                                        <div class="col-6 col-md-6 col-lg-6 col-gx-6 col-xl-6 homeitemborder" style="margin: 0">
                                                            <div>
                                                                <span class="data UserCount_Under homeitemvalue">0</span>
                                                            </div>
                                                            <div>
                                                                <span class="language_replace homeitemtitle">直屬</span>
                                                            </div>
                                                        </div>
                                                        <div class="col-6 col-md-6 col-lg-6 col-gx-6 col-xl-6 homeitemborder" style="margin: 0">
                                                            <div>
                                                                <span class="data UserCount_Other homeitemvalue">0</span>
                                                            </div>
                                                            <div>
                                                                <span class="language_replace homeitemtitle">下線</span>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                        </div>
                    </div>
                </div>

            </div>

            <div class="col-12 col-md-12 col-lg-12 col-gx-9 col-xl-9">

                <div id="WrapperFilterGame_Home" class="fixed Filter__Wrapper">
                    <div class="container-fluid ">
                        <div class="row">
                            <div id="idTabMainContent" class="tab__Wrapper col-12 col-md">
                                <ul class="nav-tabs-block nav nav-tabs tab-items-6" role="tablist">
                                    <li class="nav-item ">
                                        <a onclick="changeDateTab(this,0)" class="nav-link active language_replace" data-toggle="tab" href="" role="tab" aria-selected="true">本日</a>
                                    </li>
                                    <li class="nav-item active">
                                        <a onclick="changeDateTab(this,1)" class="nav-link language_replace" data-toggle="tab" href="" role="tab" aria-selected="true">昨天</a>
                                    </li>
                                    <li class="nav-item">
                                        <a onclick="changeDateTab(this,2)" class="nav-link language_replace" data-toggle="tab" href="" role="tab" aria-selected="true">本週</a>
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
                                    <li class="tab-slide"></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="currencyWalletList" style="margin-top: 5px">
                    <div class="container-fluid">
                        <div id="idUserInfo" class="row">

                            <div class="col-12 col-md-12 col-lg-6 col-gx-6 col-xl-6">
                                <div class="item homeitemborder homeitembackground" style="background-image: url(./Images/home/UserRebateCommission.png); text-align: right">
                                    <div>
                                        <span class="currency language_replace homeitemtitle">總返水</span>
                                    </div>
                                    <div>
                                        <span class="language_replace UserRebateCommission homeitemvalue">0</span>
                                    </div>

                                    <div class="wrapper_revenueAmount">
                                        <div class="detailItem">
                                            <span class="title-s"><span class="language_replace"></span></span>
                                            <span class="data"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-md-12 col-lg-6 col-gx-6 col-xl-6">
                                <div class="item homeitemborder homeitembackground" style="background-image: url(./Images/home/UserRebateUserRate.png); text-align: right">
                                    <div>
                                        <span class="currency language_replace homeitemtitle">總收益</span>
                                    </div>
                                    <div>
                                        <span class="language_replace UserRebateUserRate homeitemvalue">0</span>
                                    </div>

                                    <div class="wrapper_revenueAmount">
                                        <div class="detailItem">
                                            <span class="title-s"><span class="language_replace"></span></span>
                                            <span class="data FailureCondition" style="color: #FF4D00; display: none"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3">
                                <div class="item homeitemborder homeitembackground" style="background-image: url(./Images/home/TotalValidBetValue.png); text-align: right">
                                    <div>
                                        <span class="currency language_replace homeitemtitle">有效投注</span>
                                    </div>
                                    <div>
                                        <span class="language_replace TotalValidBetValue homeitemvalue">0</span>
                                    </div>

                                    <div class="wrapper_revenueAmount">
                                        <div class="detailItem">
                                            <span class="title-s"><span class="language_replace"></span></span>
                                            <span class="data"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3">
                                <div class="item homeitemborder homeitembackground" style="background-image: url(./Images/home/TotalRewardValue.png); text-align: right">
                                    <div>
                                        <span class="currency language_replace homeitemtitle">會員輸贏</span>
                                    </div>
                                    <div>
                                        <span class="language_replace TotalRewardValue homeitemvalue">0</span>
                                    </div>

                                    <div class="wrapper_revenueAmount">
                                        <div class="detailItem">
                                            <span class="title-s"><span class="language_replace"></span></span>
                                            <span class="data"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3">
                                <div class="item homeitemborder homeitembackground" style="background-image: url(./Images/home/TotalLineRebateUserRate.png); text-align: right">
                                    <div>
                                        <span class="currency language_replace homeitemtitle">總佔成</span>
                                    </div>
                                    <div>
                                        <span class="language_replace TotalLineRebateUserRate  homeitemvalue">0</span>
                                    </div>

                                    <div class="wrapper_revenueAmount">
                                        <div class="detailItem">
                                            <span class="title-s"><span class="language_replace"></span></span>
                                            <span class="data"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3">
                                <div class="item homeitemborder homeitembackground" style="background-image: url(./Images/home/PreferentialCost.png); text-align: right">
                                    <div>
                                        <span class="currency language_replace homeitemtitle">優惠成本</span>
                                    </div>
                                    <div>
                                        <span class="language_replace PreferentialCost homeitemvalue">0</span>
                                    </div>

                                    <div class="wrapper_revenueAmount">
                                        <div class="detailItem">
                                            <span class="title-s"><span class="language_replace"></span></span>
                                            <span class="data"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3">
                                <div class="item homeitemborder homeitembackground" style="background-image: url(./Images/home/TotalOrderUsers.png); text-align: right">
                                    <div>
                                        <span class="currency language_replace homeitemtitle">投注人數</span>
                                    </div>
                                    <div>
                                        <span class="language_replace TotalOrderUsers  homeitemvalue">0</span>
                                    </div>

                                    <div class="wrapper_revenueAmount">
                                        <div class="detailItem">
                                            <span class="title-s"><span class="language_replace"></span></span>
                                            <span class="data"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3">
                                <div class="item homeitemborder homeitembackground" style="background-image: url(./Images/home/NewUserCount.png); text-align: right">
                                    <div>
                                        <span class="currency language_replace homeitemtitle">新用戶數</span>
                                    </div>
                                    <div>
                                        <span class="language_replace NewUserCount homeitemvalue">0</span>
                                    </div>

                                    <div class="wrapper_revenueAmount">
                                        <div class="detailItem">
                                            <span class="title-s"><span class="language_replace"></span></span>
                                            <span class="data"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3">
                                <div class="item homeitemborder homeitembackground" style="background-image: url(./Images/home/ActivateUserCount.png); text-align: right">
                                    <div>
                                        <span class="currency language_replace homeitemtitle">活躍用戶</span>
                                    </div>
                                    <div>
                                        <span class="language_replace ActivateUserCount  homeitemvalue">0</span>
                                    </div>

                                    <div class="wrapper_revenueAmount">
                                        <div class="detailItem">
                                            <span class="title-s"><span class="language_replace"></span></span>
                                            <span class="data"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3">
                                <div class="item homeitemborder homeitembackground" style="background-image: url(./Images/home/WithdrawalValue.png); text-align: right">
                                    <div>
                                        <span class="currency language_replace homeitemtitle">提現金額</span>
                                    </div>
                                    <div>
                                        <span class="language_replace WithdrawalValue homeitemvalue">0</span>
                                    </div>

                                    <div class="wrapper_revenueAmount">
                                        <div class="detailItem">
                                            <span class="data TotalWithdrawUsers ">0</span>
                                            <span class="title-s"><span class="language_replace">人</span></span>
                                            <span class="data ">| </span>
                                            <span class="data WithdrawalCount">0</span>
                                            <span class="title-s"><span class="language_replace">筆</span></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3">
                                <div class="item homeitemborder homeitembackground" style="background-image: url(./Images/home/DepositValue.png); text-align: right">
                                    <div>
                                        <span class="currency language_replace homeitemtitle">充值金額</span>
                                    </div>
                                    <div>
                                        <span class="language_replace DepositValue homeitemvalue">0</span>
                                    </div>

                                    <div class="wrapper_revenueAmount">
                                        <div class="detailItem">
                                            <span class="data DepositCount">0</span>
                                            <span class="title-s"><span class="language_replace">筆</span></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3">
                                <div class="item homeitemborder homeitembackground" style="background-image: url(./Images/home/FirstDepositValue.png); text-align: right">
                                    <div>
                                        <span class="currency language_replace homeitemtitle">首存金額</span>
                                    </div>
                                    <div>
                                        <span class="language_replace FirstDepositValue homeitemvalue">0</span>
                                    </div>

                                    <div class="wrapper_revenueAmount">
                                        <div class="detailItem">
                                            <span class="data FirstDepositCount">0</span>
                                            <span class="title-s"><span class="language_replace">筆</span></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3">
                                <div class="item homeitemborder homeitembackground" style="background-image: url(./Images/home/FirstDepositCount.png); text-align: right">
                                    <div>
                                        <span class="currency language_replace homeitemtitle">首存人數</span>
                                    </div>
                                    <div>
                                        <span class="language_replace FirstDepositCount homeitemvalue">0</span>
                                    </div>

                                    <div class="wrapper_revenueAmount">
                                        <div class="detailItem">
                                            <span class="title-s"><span class="language_replace"></span></span>
                                            <span class="data"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3">
                                <div class="item homeitemborder homeitembackground" style="background-image: url(./Images/home/NotFirstDepositCount.png); text-align: right">
                                    <div>
                                        <span class="currency language_replace homeitemtitle">複存人數</span>
                                    </div>
                                    <div>
                                        <span class="language_replace NotFirstDepositCount homeitemvalue">0</span>
                                    </div>

                                    <div class="wrapper_revenueAmount">
                                        <div class="detailItem">
                                            <span class="title-s"><span class="language_replace"></span></span>
                                            <span class="data"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <%--<div style="display: none">
                                <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3">
                                    <div class="item homeitem">
                                        <div class="currencyWallet__type">
                                            <div class="wallet__type">
                                                <span class="currency language_replace">總線返水佣金</span>
                                            </div>
                                            <div class="settleAccount__type" style="">
                                                <span class="language_replace TotalLineRebateCommission homeitemvalue">0</span>
                                            </div>
                                        </div>
                                        <div class="wrapper_revenueAmount">
                                            <div class="detailItem">
                                                <span class="title-s"><span class="language_replace"></span></span>
                                                <span class="data"></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3">
                                    <div class="item homeitem">
                                        <div class="currencyWallet__type">
                                            <div class="wallet__type">
                                                <span class="currency language_replace">下線總線返水佣金總計</span>
                                            </div>
                                            <div class="settleAccount__type" style="">
                                                <span class="language_replace TotalChildLineRebateCommission homeitemvalue">0</span>
                                            </div>
                                        </div>
                                        <div class="wrapper_revenueAmount">
                                            <div class="detailItem">
                                                <span class="title-s"><span class="language_replace"></span></span>
                                                <span class="data"></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3">
                                    <div class="item homeitem">
                                        <div class="currencyWallet__type">
                                            <div class="wallet__type">
                                                <span class="currency language_replace">淨收益 NGR</span>
                                            </div>
                                            <div class="settleAccount__type" style="">
                                                <span class="language_replace TotalNGR homeitemvalue">0</span>
                                            </div>
                                        </div>
                                        <div class="wrapper_revenueAmount">
                                            <div class="detailItem">
                                                <span class="title-s"><span class="language_replace"></span></span>
                                                <span class="data"></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3">
                                    <div class="item homeitem">
                                        <div class="currencyWallet__type">
                                            <div class="wallet__type">
                                                <span class="currency language_replace">投注筆數</span>
                                            </div>
                                            <div class="settleAccount__type" style="">
                                                <span class="language_replace TotalOrderCount homeitemvalue">0</span>
                                            </div>
                                        </div>
                                        <div class="wrapper_revenueAmount">
                                            <div class="detailItem">
                                                <span class="title-s"><span class="language_replace"></span></span>
                                                <span class="data"></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3">
                                    <div class="item homeitem">
                                        <div class="currencyWallet__type">
                                            <div class="wallet__type">
                                                <span class="currency language_replace">有效會員數</span>
                                            </div>
                                            <div class="settleAccount__type" style="">
                                                <span class="language_replace ActiveUser homeitemvalue">0</span>
                                            </div>
                                        </div>
                                        <div class="wrapper_revenueAmount">
                                            <div class="detailItem">
                                                <span class="title-s"><span class="language_replace"></span></span>
                                                <span class="data"></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3" style="display: none">
                                    <div class="item homeitem">
                                        <div class="currencyWallet__type">
                                            <div class="wallet__type">
                                                <span class="currency language_replace">已付佣金</span>
                                            </div>
                                            <div class="settleAccount__type" style="">
                                                <span class="language_replace PaidOPValue homeitemvalue">0</span>
                                            </div>
                                        </div>
                                        <div class="wrapper_revenueAmount">
                                            <div class="detailItem">
                                                <span class="title-s"><span class="language_replace"></span></span>
                                                <span class="data"></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3" style="display: none">
                                    <div class="item homeitem">
                                        <div class="currencyWallet__type">
                                            <div class="wallet__type">
                                                <span class="currency language_replace">最低派發佣金</span>
                                            </div>
                                            <div class="settleAccount__type" style="">
                                                <span class="language_replace RebateAmountMin homeitemvalue">0</span>
                                            </div>
                                        </div>
                                        <div class="wrapper_revenueAmount">
                                            <div class="detailItem">
                                                <span class="title-s"><span class="language_replace"></span></span>
                                                <span class="data "></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-6 col-md-6 col-lg-6 col-gx-6 col-xl-6" style="display: none">
                                    <div class="item homeitem">
                                        <div class="currencyWallet__type">
                                            <div class="wallet__type">
                                                <span class="currency language_replace">總返水</span>
                                            </div>
                                            <div class="settleAccount__type" style="">
                                                <span class="language_replace homeitemvalue">0</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-12 col-md-6 col-lg-4 col-gx-3 col-xl-3" style="display: none">
                                    <div class="item homeitem">
                                        <div class="currencyWallet__type">
                                            <div class="wallet__type">
                                                <span class="currency language_replace">總佔成</span>
                                            </div>
                                            <div class="settleAccount__type" style="">
                                                <span class="language_replace homeitemvalue ">0</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>--%>

                        </div>
                    </div>
                </div>

                <div class="currencyWalletList" style="margin-top: 20px">
                    <div class="container-fluid">
                        <div class="row">
                            <div class="col-12 col-md-12 col-lg-6 col-gx-6 col-xl-6">
                                <div class="homeitemborder" style="padding: 10px">
                                    <div style="text-align: center; padding-bottom: 5px;">
                                        <span class="currency language_replace homeitemtitle">各遊戲的佔成返水</span>
                                    </div>
                                    <table class="table table-striped">
                                        <thead>
                                            <tr>
                                                <th scope="col">遊戲種類</th>
                                                <th scope="col">返水率</th>
                                                <th scope="col">佔成率</th>
                                            </tr>
                                        </thead>
                                        <tbody id="tb_GameAccountingCode">
                                        </tbody>
                                    </table>
                                </div>

                            </div>
                            <div class="col-12 col-md-12 col-lg-6 col-gx-6 col-xl-6">
                                <div class="homeitemborder" style="padding: 10px">
                                    <div style="text-align: center; padding-bottom: 5px;">
                                        <span class="currency language_replace homeitemtitle">活躍會員 (前10)</span>
                                    </div>
                                    <table class="table table-striped">
                                        <thead>
                                            <tr>
                                                <th scope="col">帳號</th>
                                                <th scope="col">轉碼</th>
                                                <th scope="col">輸贏</th>
                                            </tr>
                                        </thead>
                                        <tbody id="tb_TopTenOrderUser">
                                        </tbody>
                                    </table>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
            </div>
        </div>
        
        <div style="display: none">
            <table>
                <tbody id="tempGameAccountingCode">
                    <tr>
                        <td class="GameAccountingCode language_replace"></td>
                        <td class="BuyChipRate">0</td>
                        <td class="UserRate">0</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div style="display: none">
            <table>
                <tbody id="tempTopTenOrderUser">
                    <tr>
                        <td class="LoginAccount"></td>
                        <td class="OrderValue">0</td>
                        <td class="RewardValue">0</td>
                    </tr>
                </tbody>
            </table>
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
</html>
