<%@ Page Language="C#" AutoEventWireup="true" CodeFile="WithdrawAgent.aspx.cs" Inherits="WithdrawAgent" %>

<%
    string ASID = Request["ASID"];
    string AgentVersion = EWinWeb.AgentVersion;
    string InOpenTime = EWinWeb.CheckInWithdrawalTime() ? "Y" : "N";
    string IsWithdrawlTemporaryMaintenance = EWinWeb.IsWithdrawlTemporaryMaintenance() ? "Y" : "N";
    EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
    EWin.BmAgent.AgentSessionResult ASR = null;
    EWin.BmAgent.AgentSessionInfo ASI = null;
    EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
    string BankCardData = "";
    string Token;
    int RValue;
    Random R = new Random();
    RValue = R.Next(100000, 9999999);
    string GUID = Guid.NewGuid().ToString();
    Token = EWinWeb.CreateToken(EWinWeb.PrivateKey, EWinWeb.APIKey, RValue.ToString());
    bool IsSetWalletPassword = false;

    ASR = api.GetAgentSessionByID(ASID);

    if (ASR.Result != EWin.BmAgent.enumResult.OK)
    {
        Response.Redirect("login.aspx");
    }
    else
    {
        ASI = ASR.AgentSessionInfo;
    }

    var Ret = lobbyAPI.GetUserAccountProperty(Token, GUID, EWin.Lobby.enumUserTypeParam.ByLoginAccount, ASI.LoginAccount, "IsSetWalletPassword");

    if (Ret.Result== EWin.Lobby.enumResult.OK)
    {
        if (Ret.PropertyValue!=null&&Ret.PropertyValue.ToString().ToUpper()=="TRUE")
        {
            IsSetWalletPassword = true;
        }
    }

    var BankCardResult = GetUserBankCard(ASID);

    if (BankCardResult.Result== EWin.BmAgent.enumResult.OK)
    {
        if (BankCardResult.BankCardList!=null&&BankCardResult.BankCardList.Count()>0)
        {
            BankCardData = Newtonsoft.Json.JsonConvert.SerializeObject(BankCardResult.BankCardList);
        }
    }

%>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="ie=edge" />
    <title>出款</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="css/basic.min.css?<%:AgentVersion%>" />
    <link rel="stylesheet" href="css/main2.css?<%:AgentVersion%>" />
</head>
<script type="text/javascript" src="js/AgentCommon.js"></script>
<script type="text/javascript" src="/Scripts/Common.js"></script>
<script type="text/javascript" src="/Scripts/bignumber.min.js"></script>
<script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
<script type="text/javascript" src="Scripts/MultiLanguage.js"></script>
<script type="text/javascript" src="js/date.js"></script>
<script type="text/javascript" src="/Scripts/LobbyAPI.js?<%:AgentVersion%>"></script>
<script src="js/jquery-3.3.1.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/google-libphonenumber/3.2.31/libphonenumber.min.js"></script>
<script>
    var ApiUrl = "WithdrawAgent.aspx";
    var c = new common();
    var ac = new AgentCommon();
    var mlp;
    var EWinInfo;
    var api;
    var p;
    var lang;
    var isSent = false;
    var PhoneNumberUtil = libphonenumber.PhoneNumberUtil.getInstance();
    var IsOpenTime = "<%=InOpenTime%>";
    var IsWithdrawlTemporaryMaintenance = "<%=IsWithdrawlTemporaryMaintenance%>";
    var IsSetWalletPassword = "<%=IsSetWalletPassword%>";
    var bankData = '<%=BankCardData%>';
    var TimeZone = 8;
    var checkGcashbool = false;
    var checkBankbool = false;
    function init() {
        EWinInfo = window.parent.EWinInfo;
        api = window.parent.API_GetAgentAPI();

        p = new LobbyAPI("/API/LobbyAPI.asmx");
        lang = window.localStorage.getItem("agent_lang");
        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
            if (IsOpenTime == "N") {
                window.parent.API_NonCloseShowMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("NotInOpenTime"), function () {
                    window.parent.API_MainWindow('Main', 'home_Casino.aspx');
                });
            } else {
                if (IsWithdrawlTemporaryMaintenance == "Y") {
                    window.parent.API_NonCloseShowMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("WithdrawlTemporaryMaintenance"), function () {
                        window.parent.API_MainWindow('Main', 'home_Casino.aspx');
                    });
                } else {
                    if (IsSetWalletPassword.toUpperCase() != "TRUE") {
                        window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("尚未設定錢包密碼"), function () {
                            window.parent.API_MainWindow(mlp.getLanguageKey("設定錢包密碼"), "SetWalletPassword.aspx");
                        });
                    } else {
                        if (bankData == '') {
                            window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("尚未設定出款卡"), function () {
                                window.parent.API_MainWindow(mlp.getLanguageKey("設定出款卡"), "BankCard_Maint.aspx");
                            });
                        } else {
                            bankData = JSON.parse(bankData);
                            for (var i = 0; i < bankData.length; i++) {
                                var data = bankData[i];
                                if (data.BankCardState == 0) {
                                    if (data.PaymentMethod == 4) {
                                        $('#idSelectGCashAccount').append(`<option class="language_replace" value="${data.BankCardGUID}">${data.BankNumber}</option>`);
                                        checkGcashbool = true;
                                    } else if (data.PaymentMethod == 0) {
                                        $('#idSelectBankCard').append(`<option class="language_replace" value="${data.BankCardGUID}">${data.BankNumber}</option>`);
                                        checkBankbool = true;
                                    }
                                }
                            }
                            GetListPaymentChannel();
                        }
                        
                    }
                }
            }
        });
    }

    function compareDate(time1, time2) {
        var date = new Date();
        var nowdate = new Date();
        var a = time1.split(":");
        var b = time2.split(":");
        return date.setHours(a[0], a[1], a[2]) <= nowdate && nowdate <= date.setHours(b[0], b[1], b[2]);
    }

    function GetListPaymentChannel() {

        var boolGcashExist = false;
        var GcashMaxAmount = "unlimited";
        var GcashMinAmount = "unlimited";
        var boolBankExist = false;
        var BankMaxAmount = "unlimited";
        var BankMinAmount = "unlimited";
 
        var postData = {
            AID: EWinInfo.ASID,
            DirectionType:1
        }

        c.callService(ApiUrl + "/ListPaymentChannel", postData, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);

                if (obj.Result == 0) {
                    if (obj.ChannelList && obj.ChannelList.length > 0) {
                        obj.ChannelList = obj.ChannelList.filter(f => f.UserLevelIndex <= EWinInfo.UserLevel)
                        for (var i = 0; i < obj.ChannelList.length; i++) {
                            var channel = obj.ChannelList[i];
                            //UserLevelIndex
                            if (channel.CurrencyType == EWinInfo.MainCurrencyType) {
                                if (true) {
                                    var startTime = Date.parse("2022/12/19 " + channel.AvailableTime.StartTime).getTime();
                                    var endTime = Date.parse("2022/12/19 " + channel.AvailableTime.EndTime).getTime();
                                    startTime = startTime + (TimeZone * 60 * 60 * 1000);
                                    endTime = endTime + (TimeZone * 60 * 60 * 1000);

                                    startTimetext = new Date(startTime).toTimeString();
                                    startTimetext = startTimetext.split(' ')[0];
                                    endTimetext = new Date(endTime).toTimeString();
                                    endTimetext = endTimetext.split(' ')[0];
                                    if (compareDate(startTimetext, endTimetext)) {
                                        var ChannelCode = channel.PaymentChannelCode.split('.')[1];
                                        if (channel.GroupIndex == 2) {
                                            //Gcash
                                            boolGcashExist = true;
                                            if (channel.AmountMin != 0) {
                                                GcashMinAmount = toCurrency(new BigNumber(Math.abs(channel.AmountMin)));
                                            }

                                            if (channel.AmountMax != 0) {
                                                GcashMaxAmount = toCurrency(new BigNumber(Math.abs(channel.AmountMax)));
                                            }
                                        }
                                        else if (channel.GroupIndex == 1) {
                                            //Bank
                                            boolBankExist = true;
                                            if (channel.AmountMin != 0) {
                                                BankMinAmount = toCurrency(new BigNumber(Math.abs(channel.AmountMin)));
                                            }

                                            if (channel.AmountMax != 0) {
                                                BankMaxAmount = toCurrency(new BigNumber(Math.abs(channel.AmountMax)));
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        if (boolGcashExist) {
                            $('#idSelectPaymentMethod').append(`<option class="language_replace" value="GCash" langkey="GCash" id="optGCash">GCash ${GcashMinAmount}~${GcashMaxAmount}</option>`);
                        }

                        if (boolBankExist) {
                            $('#idSelectPaymentMethod').append(`<option class="language_replace" value="BANK" langkey="BANK" id="optBANK">BANK ${BankMinAmount}~${BankMaxAmount}</option>`);
                        }

                        if (boolBankExist == false && boolGcashExist==false) {
                            window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("WithdrawlTemporaryMaintenance"), function () {
                                window.parent.API_MainWindow('Main', 'home_Casino.aspx');
                            });
                        }
                    }
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

    function toCurrency(num) {

        num = parseFloat(Number(num).toFixed(2));
        var parts = num.toString().split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        return parts.join('.');
    }

    function setAmount() {
        var amount = $("#amount").val().replace(/\D/g, '');
        $("#amount").val(amount);

    }

    function SelectPaymentMethod() {
        if ($('#idSelectPaymentMethod').val() == 'BANK') {
            if (checkBankbool) {
                $('#BankCardGroup').show();
                $('#GCashGroup').hide();
            } else {
                window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("尚未設定出款卡"), function () {
                    window.parent.API_MainWindow(mlp.getLanguageKey("設定出款卡"), "BankCard_Maint.aspx");
                });
            }

        } else if ($('#idSelectPaymentMethod').val() == 'GCash') {
            if (checkGcashbool) {
                $('#GCashGroup').show();
                $('#BankCardGroup').hide();
            } else {
                window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("尚未設定出款卡"), function () {
                    window.parent.API_MainWindow(mlp.getLanguageKey("設定出款卡"), "BankCard_Maint.aspx");
                });
            }
        } else {
            $('#GCashGroup').hide();
            $('#BankCardGroup').hide();
        }
    }

    function createWithdraw() {
        var amount = $('#amount').val().trim();
        var paymentMethod = $('#idSelectPaymentMethod').val();
        var walletPassword = $('#idWalletPassword').val().trim();
        var paymentCode = "";
        var bankcarddata;
        var pointValue = 0;

        window.parent.API_QueryUserInfo(function(){
            if (EWinInfo.UserInfo.WalletList) {
                var removeArray = [];

                for (var i = 0; i < EWinInfo.UserInfo.WalletList.length; i++) {
                    //if (EWinInfo.UserInfo.WalletList[i].PointState == 1 ) {
                    //    removeArray.push(i);
                    //}
                    if (EWinInfo.MainCurrencyType == EWinInfo.UserInfo.WalletList[i].CurrencyType) {
                        if (EWinInfo.UserInfo.WalletList[i].PointState == 1) {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("錢包狀態為停用"));
                            return;
                        }
                        pointValue = EWinInfo.UserInfo.WalletList[i].PointValue;
                        break;
                    }
                }
            }

            if (paymentMethod == "-1") {
                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("尚未選擇出款方式"));
                return;
            }

            if (amount == '') {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("尚未輸入金額"));
                return;
            }

            if (!Number.isInteger(parseFloat(amount))) {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("金額只能輸入整數"));
                return;
            }

            if (amount > pointValue) {
                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("錢包餘額不足"));
                return;
            }

            if (walletPassword == '') {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("尚未輸入錢包密碼"));
                return;
            }

            if (paymentMethod == 'GCash') {
                paymentCode = ".Withdrawal.Gcash";
                if ($('#idSelectGCashAccount').val() == "-1") {
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("尚未選擇出款卡"), function () { });
                    return;
                }

                bankcarddata = bankData.find(w => w.BankCardGUID == $("#idSelectGCashAccount").val());
            } else if (paymentMethod == 'BANK') {
                paymentCode = ".Withdrawal.BANK";
                if ($('#idSelectBankCard').val() == "-1") {
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("尚未選擇出款卡"), function () { });
                    return;
                }

                bankcarddata = bankData.find(w => w.BankCardGUID == $("#idSelectBankCard").val());
            } else {
                paymentCode = "";
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("尚未選擇出款卡"), function () { });
                return;
            }



            var bankCard = bankcarddata.BankNumber;
            var bankCardNameFirst = bankcarddata.AccountName;
            var bankName = bankcarddata.BankName;


            window.parent.API_ShowLoading();
            GetPaymentMethod(paymentCode, function (s, paymentMethodID) {
                if (s) {
                    checkWalletPassword(walletPassword, function (s1) {
                        if (s1) {
                            GetPaymentChannelByGroupIndex(paymentMethod, amount, function (s2, paymentChannelCode) {
                                if (s2) {
                                    GetInProgressPaymentByLoginAccount(function (s3) {
                                        if (s3) {

                                            CreateEPayWithdrawalAgent(amount, paymentMethodID, paymentChannelCode, function (s4, orderNumber) {
                                                if (s4) {
                                                    ConfirmEPayWithdrawal(paymentMethod, orderNumber, function (s5, paymentSerial) {
                                                        if (s5) {
                                                            $('#step1').hide();
                                                            $('#step2').show();
                                                            $('#idOrderNumber').val(paymentSerial);
                                                            $('#idPaymentMethod').val(paymentMethod);
                                                            $('#idUserAccount').val(bankCard);
                                                            $('#idAmount').val(amount);
                                                        }
                                                    });
                                                }
                                            });
                                        }
                                    });
                                }
                            });
                        }
                    });
                }
            });
        });
    
    }

    function CreateEPayWithdrawalAgent(amount, paymentMethodID, paymentChannelCode,cb) {

        var postData = {
            AID: EWinInfo.ASID,
            Amount: amount,
            PaymentMethodID: paymentMethodID,
            PaymentChannelCode: paymentChannelCode
        }

        c.callService(ApiUrl + "/CreateEPayWithdrawalAgent", postData, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);
                if (obj.Result == 0) {
                    $('#idResiveAmount').val(obj.Data.PaymentCryptoDetailList[0]["ReceiveAmount"]);
                    cb(true, obj.Data.OrderNumber);
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

    function ConfirmEPayWithdrawal(paymentMethod, orderNumber, cb) {
        var postData;
        var bankcarddata;
        if (paymentMethod == 'GCash') {
            bankcarddata = bankData.find(w => w.BankCardGUID == $("#idSelectGCashAccount").val());
            var phoneNumber = bankcarddata.BankNumber.trim();
            var bankCardNameFirst = bankcarddata.AccountName;
            var bankName = bankcarddata.BankName;

            var postData = {
                AID: EWinInfo.ASID,
                OrderNumber: orderNumber,
                BankCard: '',
                BankCardName: '',
                BankName: 'Gcash',
                BankBranchCode: '',
                PhoneNumber: phoneNumber
            }
        } else if (paymentMethod == 'BANK') {
            bankcarddata = bankData.find(w => w.BankCardGUID == $("#idSelectBankCard").val());
            var bankCard = bankcarddata.BankNumber;
            var bankCardNameFirst = bankcarddata.AccountName;
            var bankName = bankcarddata.BankName;

            var postData = {
                AID: EWinInfo.ASID,
                OrderNumber: orderNumber,
                BankCard: bankCard,
                BankCardName: bankCardNameFirst,
                BankName: bankName,
                BankBranchCode: '',
                PhoneNumber: ''
            }
        }

        c.callService(ApiUrl + "/ConfirmEPayWithdrawal", postData, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);
                if (obj.Result == 0) {
                    cb(true, obj.Message);
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

    function GetInProgressPaymentByLoginAccount(cb) {

        var postData = {
            AID: EWinInfo.ASID,
            LoginAccount: EWinInfo.LoginAccount,
            PaymentType: 1
        }

        c.callService(ApiUrl + "/GetInProgressPaymentByLoginAccount", postData, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);
                if (obj.Result == 0) {
                    if (obj.UserAccountPayments.length > 0) {
                        window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("只能有一筆進行中之訂單"), function () {

                        });
                    } else {
                        cb(true);
                    }

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

    function GetPaymentChannelByGroupIndex(paymentMethod, amount, cb) {
        var GroupIndex = -1;
        if (paymentMethod == 'GCash') {
            GroupIndex = 2;
        } else if (paymentMethod =='BANK') {
            GroupIndex = 1;
        }

        if (GroupIndex != -1) {
            var postData = {
                AID: EWinInfo.ASID,
                DirectionType: 1,
                GroupIndex: GroupIndex,
                Amount: amount
            }

            c.callService(ApiUrl + "/GetPaymentChannelByGroupIndex", postData, function (success, o) {
                if (success) {
                    var obj = c.getJSON(o);
                    if (obj.Result == 0) {
                        cb(true, obj.ChannelList[0].PaymentChannelCode);
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
        } else {

            window.parent.API_CloseLoading();
            window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("貨幣未設定匯率"), function () {

            });
        }
      
    }

    function checkWalletPassword(walletPassword,cb) {
        var postData = {
            AID: EWinInfo.ASID,
            Password: walletPassword
        }

        c.callService(ApiUrl + "/CheckPassword", postData, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);
                if (obj.Result == 0) {
                    cb(true);
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

    function GetPaymentMethod(PaymentCode,cb) {
        
        var postData = {
            AID: EWinInfo.ASID,
            PaymentCategoryCode: "EPAY",
            PaymentType: 1,
            PaymentCode: PaymentCode,
            UserLevel: EWinInfo.UserLevel,
            DirectionType: 1
        }

        c.callService(ApiUrl + "/GetPaymentMethodByPaymentCodeFilterPaymentChannel", postData, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);
                if (obj.Result == 0) {
                    if (obj.PaymentMethodResults.length > 0) {
                        PaymentMethodID = obj.PaymentMethodResults[0].PaymentMethodID;
                        cb(true, PaymentMethodID);
                    } else {
                        window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("貨幣未設定匯率"), function () {
                           
                        });
                    }
                   
                } else {
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("貨幣未設定匯率"), function () {

                    });
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

    window.onload = init;
</script>
<body class="innerBody bg_transfer">
    <main>
        <div class="container-fluid">
            <h1 class="page__title "><span class="language_replace">設定錢包密碼</span></h1>

            <form onsubmit="return false;">
                <section class="sectionWallet wallet__currency--transfer">
                    <div class="content" id="step1">

                        <!-- 轉出金額 -->

                        <div class="form-group">
                              <select name="idSelectPaymentMethod" id="idSelectPaymentMethod" class="custom-select" onchange="SelectPaymentMethod()">
                                                <option class="language_replace" value="-1" langkey="請選擇出款方式">請選擇出款方式</option>
                                            </select>
                        </div>


                        <!-- 錢包密碼 -->

                        <div class="form-group">
                            <div class="form-control-underline">
                                 <input type="text" class="form-control" id="amount" language_replace="placeholder" placeholder="請輸入金額" onkeyup="setAmount()" />
                                <label for="idPhoneNumber" class="form-label"><span class="language_replace">輸入金額</span></label>
                            </div>
                        </div>


                        <div class="form-group">
                            <div class="form-control-underline">
                                <input type="password" class="form-control" name="member" id="idWalletPassword" language_replace="placeholder" placeholder="請輸入錢包密碼" />
                                <label for="idWalletPassword" class="form-label"><span class="language_replace">錢包密碼</span></label>
                            </div>
                        </div>

                        <div class="form-group" id="BankCardGroup"  style="display:none;">
                              <select name="idSelectBankCard" id="idSelectBankCard" class="custom-select">
                                                <option class="language_replace" value="-1" langkey="請選擇出款卡">請選擇出款卡</option>
                                            </select>
                        </div>

                        <div class="form-group" id="GCashGroup" style="display:none;">
                              <select name="idSelectGCashAccount" id="idSelectGCashAccount" class="custom-select" >
                                                <option class="language_replace" value="-1" langkey="選擇 GCash 帳號">選擇 GCash 帳號</option>
                                            </select>
                        </div>

                        <div class="wrapper_center btn-group-lg" style="padding-bottom: 10px;">
                            <button type="button" class="btn btn-full-main" onclick="createWithdraw()"><span class="language_replace">送出</span></button>
                        </div>
                    </div>

                        <div class="content" id="step2" style="display:none;">

                        <!-- 轉出金額 -->

                        <div class="form-group">
                            <div class="form-control-underline">
                                 <input type="text" class="form-control" id="idOrderNumber" language_replace="placeholder" placeholder="訂單編號" disabled="disabled" />
                                <label for="idOrderNumber" class="form-label"><span class="language_replace">訂單編號</span></label>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="form-control-underline">
                                 <input type="text" class="form-control" id="idPaymentMethod" language_replace="placeholder" placeholder="出款類型" disabled="disabled" />
                                <label for="idPaymentMethod" class="form-label"><span class="language_replace">出款類型</span></label>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="form-control-underline">
                                 <input type="text" class="form-control" id="idUserAccount" language_replace="placeholder" placeholder="帳號/卡號" disabled="disabled" />
                                <label for="idUserAccount" class="form-label"><span class="language_replace">帳號/卡號</span></label>
                            </div>
                        </div>

                            
                        <div class="form-group">
                            <div class="form-control-underline">
                                 <input type="text" class="form-control" id="idAmount" language_replace="placeholder" placeholder="出款金額" disabled="disabled" />
                                <label for="idAmount" class="form-label"><span class="language_replace">出款金額</span></label>
                            </div>
                        </div>

                         <div class="form-group">
                            <div class="form-control-underline">
                                 <input type="text" class="form-control" id="idResiveAmount" language_replace="placeholder" placeholder="出款金額" disabled="disabled" />
                                <label for="idResiveAmount" class="form-label"><span class="language_replace">實際取得金額</span></label>
                            </div>
                        </div>
                    </div>
                </section>

            </form>
        </div>
    </main>
</body>
</html>
