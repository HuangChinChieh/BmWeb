<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UserAccount_Add_Casino.aspx.cs" Inherits="UserAccount_Add_Casino" %>

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
<script type="text/javascript">
    var c = new common();
    var ac = new AgentCommon();
    var ApiUrl = "UserAccount_Add_Casino.aspx";
    var mlp;
    var lang;
    var EWinInfo;
    var parentObj;
    var timerChkUserAccount;
    var uType;
    var processing = false;
    var GetCompanyPermissionGroup;
    var p;
    var PhoneNumberUtil = libphonenumber.PhoneNumberUtil.getInstance();

    function checkFormData() {
        var retValue = true;
        var chkMessage = "";
        var form = document.forms[0];

        if (form.LoginAccount.value == "") {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入帳號"));
            retValue = false;
        }

        if (form.LoginPassword.value == "") {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入登入密碼"));
            retValue = false;
        } else {
            if (form.LoginPassword.value != form.LoginPassword2.value) {
                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("登入密碼二次驗證失敗"));
                retValue = false;
            }
        }

        CheckAccountPhoneExist(function (check) {
            if (check) {
                // 檢查所有錢包數值
                for (var i = 0; i < idPointList.children.length; i++) {
                    var el = idPointList.children[i];

                    if (el.hasAttribute("currencyType")) {
                        var btnPointNew = c.getFirstClassElement(el, "btnPointNew");
                        //其它遊戲
                        var currencyType = el.getAttribute("currencyType");
                        var pointUserRate = c.getFirstClassElement(el, "PointUserRate");
                        var pointBuyChipRate = c.getFirstClassElement(el, "PointBuyChipRate");
                        var agentGameUserRate = 0;
                        var agentGameBuyChipRate = 0;

                        if (isNaN(pointUserRate.value) == true || isNaN(pointBuyChipRate.value) == true) {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), btnPointNew.getAttribute("btnGameCode") + "-" + currencyType + " " + mlp.getLanguageKey("佔成/轉碼請輸入正確數字"));
                            retValue = false;
                            break;
                        }

                        for (var j = 0; j < EWinInfo.UserInfo.GameCodeList.length; j++) {
                            if (EWinInfo.UserInfo.GameCodeList[j].CurrencyType == currencyType) {
                                if (EWinInfo.UserInfo.GameCodeList[j].GameAccountingCode == btnPointNew.getAttribute("btnGameCode")) {
                                    agentGameUserRate = EWinInfo.UserInfo.GameCodeList[j].UserRate;
                                    agentGameBuyChipRate = EWinInfo.UserInfo.GameCodeList[j].BuyChipRate;
                                }
                            }
                        }

                        if ((pointUserRate.value != "") && (pointUserRate.value != null)) {
                            if ((Number(pointUserRate.value) > agentGameUserRate) || Number(pointUserRate.value) < 0) {
                                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), btnPointNew.getAttribute("btnGameCode") + "-" + currencyType + " " + mlp.getLanguageKey("佔成可接受範圍為") + " 0 - " + agentGameUserRate);
                                retValue = false;
                                break;
                            }
                        } else {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), btnPointNew.getAttribute("btnGameCode") + "-" + currencyType + " " + mlp.getLanguageKey("佔成率不可空白"));
                            retValue = false;
                            break;
                        }

                        if ((pointBuyChipRate.value != "") || (pointBuyChipRate.value != null)) {
                            if (Number(pointBuyChipRate.value) < 0) {
                                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), btnPointNew.getAttribute("btnGameCode") + "-" + currencyType + " " + mlp.getLanguageKey("轉碼不可負數"));
                                retValue = false;
                                break;
                            }
                            else {
                                switch (EWinInfo.CompanyInfo.DownlineBuyChipRateType) {
                                    case 0:
                                        //不允許下線轉碼率設定高於上線
                                        if (Number(agentGameBuyChipRate) < Number(pointBuyChipRate.value)) {
                                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), btnPointNew.getAttribute("btnGameCode") + "-" + currencyType + " " + mlp.getLanguageKey("下線轉碼率不可高於上線"));
                                            retValue = false;
                                            break;
                                        }
                                        break;
                                    case 1:
                                        //允許設定高於上線
                                        if (Number(agentGameBuyChipRate) < Number(pointBuyChipRate.value)) {
                                            if (chkMessage == "") {
                                                chkMessage = btnPointNew.getAttribute("btnGameCode") + "-" + currencyType + " " + mlp.getLanguageKey("轉碼數超過上線,用戶須自行承擔差額,確定要繼續嗎?");
                                            }
                                            else {
                                                chkMessage = chkMessage + "<br/>" + btnPointNew.getAttribute("btnGameCode") + "-" + currencyType + " " + mlp.getLanguageKey("轉碼數超過上線,用戶須自行承擔差額,確定要繼續嗎?");
                                            }
                                            break;
                                        }
                                        break;
                                    case 2:
                                        //代理佔成時才允許下線碼佣高於代理
                                        if (Number(agentGameUserRate) > 0) {
                                            if (Number(agentGameBuyChipRate) < Number(pointBuyChipRate.value)) {
                                                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), btnPointNew.getAttribute("btnGameCode") + "-" + currencyType + " " + mlp.getLanguageKey("下線轉碼率不可高於上線"));
                                                retValue = false;
                                                break;
                                            }
                                        }
                                        break;
                                }
                            }

                        } else {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), btnPointNew.getAttribute("btnGameCode") + "-" + currencyType + " " + mlp.getLanguageKey("轉碼率不可空白"));
                            retValue = false;
                            break;
                        }
                    } else if (el.hasAttribute("default")) {
                        //其它遊戲
                        var currencyType = el.getAttribute("default");
                        var pointUserRate = c.getFirstClassElement(el, "PointUserRate");
                        var pointBuyChipRate = c.getFirstClassElement(el, "PointBuyChipRate");
                        var agentGameUserRate = 0;
                        var agentGameBuyChipRate = 0;

                        if (isNaN(pointUserRate.value) == true || isNaN(pointBuyChipRate.value) == true) {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), currencyType + " " + mlp.getLanguageKey("佔成/轉碼請輸入正確數字"));
                            retValue = false;
                            break;
                        }

                        for (var j = 0; j < EWinInfo.UserInfo.WalletList.length; j++) {
                            if (EWinInfo.UserInfo.WalletList[j].CurrencyType == EWinInfo.MainCurrencyType) {
                                agentGameUserRate = EWinInfo.UserInfo.WalletList[j].UserRate;
                                agentGameBuyChipRate = EWinInfo.UserInfo.WalletList[j].BuyChipRate;
                            }
                        }

                        if ((pointUserRate.value != "") && (pointUserRate.value != null)) {
                            if ((Number(pointUserRate.value) > agentGameUserRate) || Number(pointUserRate.value) < 0) {
                                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), currencyType + " " + mlp.getLanguageKey("佔成可接受範圍為") + " 0 - " + agentGameUserRate);
                                retValue = false;
                                break;
                            }
                        } else {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), currencyType + " " + mlp.getLanguageKey("佔成率不可空白"));
                            retValue = false;
                            break;
                        }

                        if ((pointBuyChipRate.value != "") || (pointBuyChipRate.value != null)) {
                            if (Number(pointBuyChipRate.value) < 0) {
                                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), currencyType + " " + mlp.getLanguageKey("轉碼不可負數"));
                                retValue = false;
                                break;
                            } else {
                                if (Number(agentGameBuyChipRate) < Number(pointBuyChipRate.value)) {
                                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), currencyType + " " + mlp.getLanguageKey("下線轉碼率不可高於上線"));
                                    retValue = false;
                                    break;
                                }
                            }

                        } else {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), currencyType + " " + mlp.getLanguageKey("轉碼率不可空白"));
                            retValue = false;
                            break;
                        }

                    }
                }

                if (retValue == true) {
                    checkAccountExist(form.LoginAccount.value, function (accountExist) {
                        if (accountExist == true) {
                            if (chkMessage != "") {
                                window.parent.API_ShowMessage(mlp.getLanguageKey("警告"), chkMessage, function () {
                                    updateUserInfo();
                                }, null);
                            }
                            else {
                                updateUserInfo();
                            }

                        } else {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("登入帳號已存在"));
                        }
                    });
                }
            } else {

            }
        });
    }

    function chkUserAccount(el) {
        window.clearTimeout(timerChkUserAccount);
        document.getElementById("idLoginAccount").classList.remove("iconError");
        document.getElementById("idLoginAccount").classList.remove("iconErrorAnim");
        document.getElementById("idLoginAccount").classList.remove("iconCheck");
        document.getElementById("idLoginAccount").classList.remove("iconCheckAnim");
        document.getElementsByClassName("icon-loading")[0].style.display = "none";
        if (el.value.trim() != "") {
            document.getElementsByClassName("icon-loading")[0].style.display = "";
        }

        $("#LoginAccount").val(el.value.replace(/ /g, ''));

        timerChkUserAccount = window.setTimeout(function () {
            if (el.value.trim() != "") {

                checkAccountExist(el.value, function (retValue) {
                    document.getElementsByClassName("icon-loading")[0].style.display = "none";
                    if (retValue == true) {
                        document.getElementById("idLoginAccount").classList.remove("iconError");
                        document.getElementById("idLoginAccount").classList.remove("iconErrorAnim");

                        document.getElementById("idLoginAccount").classList.add("iconCheck");
                        document.getElementById("idLoginAccount").classList.add("iconCheckAnim");
                    }
                    else {
                        document.getElementById("idLoginAccount").classList.remove("iconCheck");
                        document.getElementById("idLoginAccount").classList.remove("iconCheckAnim");

                        document.getElementById("idLoginAccount").classList.add("iconError");
                        document.getElementById("idLoginAccount").classList.add("iconErrorAnim");
                    }
                })
            }

        }, 2000)
    }

    function checkAccountExist(loginAccount, cb) {
        var postObj;

        postObj = {
            AID: EWinInfo.ASID,
            LoginAccount: loginAccount
        };

        c.callService(ApiUrl + "/CheckAccountExist", postObj, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);

                if (obj.Result == 0) {
                    if (cb)
                        cb(true);
                } else {
                    if (obj.Message == "AccountExist") {
                        if (cb)
                            cb(false);
                    } else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), obj.Message);
                    }
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

    function queryCurrentUserInfo() {
        var postObj;

        postObj = {
            AID: EWinInfo.ASID
        };

        c.callService(ApiUrl + "/QueryCurrentUserInfo", postObj, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);

                if (obj.Result == 0) {
                    parentObj = obj;
                    updateBaseInfo(obj);

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

    function updateUserInfo() {
        var form = document.forms[0];
        var userList = [];
        var postObj;
        var idPointList = document.getElementById("idPointList");
        var AllowPayment = 0;
        var AllowServiceChat = 0;
        var retValue = true;

        if (processing == false) {

            // 建立用戶更新物件
            if ((form.LoginPassword.value != "") && (form.LoginPassword.value != null)) {
                userList[userList.length] = { Name: "LoginPassword", Value: form.LoginPassword.value };
            }
            userList[userList.length] = { Name: "UserAccountType", Value: uType };
            userList[userList.length] = { Name: "UserAccountState", Value: 0 };
            userList[userList.length] = { Name: "RealName", Value: form.RealName.value };
            userList[userList.length] = { Name: "ContactPhonePrefix", Value: form.ContactPhonePrefix.options[form.ContactPhonePrefix.selectedIndex].value };
            userList[userList.length] = { Name: "ContactPhoneNumber", Value: form.ContactPhoneNumber.value };

            if (EWinInfo) {
                //確定公司是否允許
                if (EWinInfo.CompanyInfo) {
                    if (EWinInfo.CompanyInfo.PaymentGPay != 0) {
                        if (parentObj) {
                            //確定上線是否可用金流
                            if (parentObj.AllowPayment == 1) {
                                AllowPayment = 1;
                            }
                        }
                    }
                    if (EWinInfo.CompanyInfo.ServiceChatType == 1) {
                        if (parentObj) {
                            //確定上線是否可用客服
                            if (parentObj.AllowServiceChat == 1) {
                                AllowServiceChat = 1;
                            }
                        }
                    }
                }
            }

            userList[userList.length] = { Name: "AllowPayment", Value: AllowPayment };
            userList[userList.length] = { Name: "AllowServiceChat", Value: AllowServiceChat };

            userList[userList.length] = { Name: "AllowBet", Value: 3 };



            // 建立錢包更新物件
            for (var i = 0; i < idPointList.children.length; i++) {
                var el = idPointList.children[i];

                if (el.hasAttribute("currencyType")) {
                    var btnPointNew = c.getFirstClassElement(el, "btnPointNew");
                    var currencyType = el.getAttribute("currencyType");
                    var PointStateSelect = 0;
                    var pointUserRate = c.getFirstClassElement(el, "PointUserRate");
                    var pointBuyChipRate = c.getFirstClassElement(el, "PointBuyChipRate");
                    var g;


                    if (pointUserRate.value == "") {

                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), btnPointNew.getAttribute("btnGameCode") + "-" + mlp.getLanguageKey("佔成率(%)") + " " + mlp.getLanguageKey("不可為空值"));
                        retValue = false;
                        break;
                    }

                    if (pointBuyChipRate.value == "") {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), btnPointNew.getAttribute("btnGameCode") + "-" + mlp.getLanguageKey("轉碼率(%)") + " " + mlp.getLanguageKey("不可為空值"));
                        retValue = false;
                        break;
                    }

                    g = {
                        CurrencyType: currencyType,
                        PointState: PointStateSelect,
                        UserRate: pointUserRate.value,
                        BuyChipRate: pointBuyChipRate.value,
                        GameAccountingCode: btnPointNew.getAttribute("btnGameCode")
                    }

                    userList[userList.length] = {
                        Name: "GameCodeList",
                        Value: JSON.stringify(g)
                    };

                } else if (el.hasAttribute("default")) {
                    var currencyType = el.getAttribute("default");
                    var PointStateSelect = 0;
                    var pointUserRate = c.getFirstClassElement(el, "PointUserRate");
                    var pointBuyChipRate = c.getFirstClassElement(el, "PointBuyChipRate");

                    if (pointUserRate.value == "") {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), currencyType + "-" + mlp.getLanguageKey("佔成率(%)") + " " + mlp.getLanguageKey("不可為空值"));
                        retValue = false;
                        break;
                    }

                    if (pointBuyChipRate.value == "") {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), currencyType + "-" + mlp.getLanguageKey("轉碼率(%)") + " " + mlp.getLanguageKey("不可為空值"));
                        retValue = false;
                        break;
                    }

                    let k = {
                        CurrencyType: EWinInfo.MainCurrencyType,
                        PointState: PointStateSelect,
                        UserRate: pointUserRate.value,
                        BuyChipRate: pointBuyChipRate.value,
                    };

                    userList[userList.length] = {
                        Name: "Wallet",
                        Value: JSON.stringify(k)
                    };

                }
            }

            if (retValue) {

                postObj = {
                    AID: EWinInfo.ASID,
                    LoginAccount: form.LoginAccount.value,
                    UserField: userList
                }
                processing = true;
                window.parent.API_ShowLoading("Sending");

                c.callService(ApiUrl + "/CreateUserInfo", postObj, function (success, o) {
                    if (success) {
                        var obj = c.getJSON(o);

                        if (obj.Result == 0) {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("更新完成"), mlp.getLanguageKey("更新完成"), function () {
                                window.parent.API_CloseWindow(true);
                            });
                        } else {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), obj.Message);
                            processing = false;
                        }
                    } else {
                        if (o == "Timeout") {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後重新嘗試"));
                            processing = false;
                        } else {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), o);
                            processing = false;
                        }
                    }

                    window.parent.API_CloseLoading();
                })
            }

        }
        else {
            window.parent.API_ShowToastMessage(mlp.getLanguageKey("作業進行中"));
        }
    }

    function updateBaseInfo(o) {
        var t;
        var btnPointNew;


        if (o != null) {
            c.setElementText("idCompanyCode", null, o.CompanyCode);
            c.setElementText("ParentLoginAccount", null, o.LoginAccount);

            if (o.IsLendChipAccount) {
                c.setElementText("IsLendChipAccount", null, mlp.getLanguageKey("此帳戶為配碼帳戶"));
                idLendChipAccount.style.display = "block";
            } else {
                idLendChipAccount.style.display = "none";
            }

            if (o.WalletList != null) {
                var idPointList = document.getElementById("idPointList");

                c.clearChildren(idPointList);

                for (var i = 0; i < o.WalletList.length; i++) {
                    if (o.WalletList[i].CurrencyType != EWinInfo.CompanyInfo.DefaultCurrencyType) {
                        continue;
                    }
                    var w = o.WalletList[i];

                    t = c.getTemplate("templateWalletItem");
                    // t.style.display = "none";
                    btnPointNew = c.getFirstClassElement(t, "btnPointNew");
                    pointUserRate = c.getFirstClassElement(t, "PointUserRate");
                    pointBuyChipRate = c.getFirstClassElement(t, "PointBuyChipRate");

                    t.setAttribute("default", w.CurrencyType);
                    t.classList.add(w.CurrencyType);
                    t.classList.add("div_GameCode");
                    c.setClassText(t, "PointCurrencyType", null, w.CurrencyType);
                    c.setClassText(t, "GameAccountingCode", null, "Default");

                    c.setClassText(t, "parentBuyChipRate", null, w.BuyChipRate);
                    c.setClassText(t, "parentUserRate", null, w.UserRate);

                    btnPointNew.setAttribute("btnGameCode", w.CurrencyType);
                    btnPointNew.setAttribute("btnUserRate", w.UserRate);
                    btnPointNew.setAttribute("btnBuyChipRate", w.BuyChipRate);

                    idPointList.appendChild(t);

                    //多遊戲設定
                    if (EWinInfo.UserInfo.GameCodeList.length > 0) {
                        for (var j = 0; j < EWinInfo.UserInfo.GameCodeList.length; j++) {
                            if (EWinInfo.UserInfo.GameCodeList[j].CurrencyType == w.CurrencyType) {
                                t = c.getTemplate("templateWalletItem");
                                // t.style.display = "none";
                                btnPointNew = c.getFirstClassElement(t, "btnPointNew");
                                pointUserRate = c.getFirstClassElement(t, "PointUserRate");
                                pointBuyChipRate = c.getFirstClassElement(t, "PointBuyChipRate");

                                t.setAttribute("currencyType", w.CurrencyType);
                                t.classList.add(EWinInfo.UserInfo.GameCodeList[j].GameAccountingCode);
                                t.classList.add("div_GameCode");
                                c.setClassText(t, "PointCurrencyType", null, w.CurrencyType);
                                c.setClassText(t, "GameAccountingCode", null, mlp.getLanguageKey(EWinInfo.UserInfo.GameCodeList[j].GameAccountingCode));

                                c.setClassText(t, "parentBuyChipRate", null, EWinInfo.UserInfo.GameCodeList[j].BuyChipRate);
                                c.setClassText(t, "parentUserRate", null, EWinInfo.UserInfo.GameCodeList[j].UserRate);

                                btnPointNew.setAttribute("btnGameCode", EWinInfo.UserInfo.GameCodeList[j].GameAccountingCode);
                                btnPointNew.setAttribute("btnUserRate", EWinInfo.UserInfo.GameCodeList[j].UserRate);
                                btnPointNew.setAttribute("btnBuyChipRate", EWinInfo.UserInfo.GameCodeList[j].BuyChipRate);

                                idPointList.appendChild(t);
                            }
                        }
                    }


                }
            }
        }

    }

    function setUserAccountType() {
        var idMessageText = document.getElementById("idMessageText");
        var divUserAccountType = document.getElementById("divUserAccountType");
        var bitLimitDIV = document.getElementsByClassName("bitLimitDIV");

        idMessageText.appendChild(divUserAccountType);
        divUserAccountType.style.display = "";
        bitLimitDIV[0].style.display = "none";

        showBox(mlp.getLanguageKey("帳戶類型"), "", false, function () {

        })

    }

    function setUType(iUType) {
        uType = iUType;

        switch (iUType) {
            case "Agent":
                document.getElementById("idUserAccountType").innerText = mlp.getLanguageKey("代理");
                uType = 1;
                break;
            case "UserAccount":
                document.getElementById("idUserAccountType").innerText = mlp.getLanguageKey("一般帳戶");
                uType = 0;
                break
        }

        c.removeClassName(idMessageBox, "show");

    }

    function CheckAccountPhoneExist(cb) {

        var idPhonePrefix = document.getElementById("ContactPhonePrefix");
        var idPhoneNumber = document.getElementById("ContactPhoneNumber");

        if (idPhonePrefix.value == "") {
            window.parent.showMessageOK("", mlp.getLanguageKey("請輸入國碼"));
            cb(false);
            return;
        } else if (idPhoneNumber.value == "") {
            window.parent.showMessageOK("", mlp.getLanguageKey("請輸入電話"));
            cb(false);
            return;
        } else {
            var phoneValue = idPhonePrefix.value + idPhoneNumber.value;
            var phoneObj;

            try {
                phoneObj = PhoneNumberUtil.parse(phoneValue);

                var type = PhoneNumberUtil.getNumberType(phoneObj);

                if (type != libphonenumber.PhoneNumberType.MOBILE && type != libphonenumber.PhoneNumberType.FIXED_LINE_OR_MOBILE) {
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("電話格式有誤"));
                    cb(false);
                    return;
                }
            } catch (e) {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("電話格式有誤"));
                cb(false);
                return;
            }
        }

        p.CheckAccountExistEx(Math.uuid(), "", idPhonePrefix.value, idPhoneNumber.value, "", function (success, o) {
            if (success) {
                if (o.Result != 0) {
                    cb(true);
                } else {
                    cb(false);
                    window.parent.API_ShowMessageOK("", mlp.getLanguageKey("電話已存在"));
                }
            }

        });
    }

    function applyGameInfo() {
        let tmpPointUserRate = $(".tmpPointUserRate").val();
        let tmpPointBuyChipRate = $(".tmpPointBuyChipRate").val();

        $(".PointUserRate").val(tmpPointUserRate);
        $(".PointBuyChipRate").val(tmpPointBuyChipRate);
    }

    function init() {
        lang = window.localStorage.getItem("agent_lang");
        p = window.parent.API_GetLobbyAPI();

        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
            EWinInfo = window.parent.EWinInfo;
            queryCurrentUserInfo();
            //setUserAccountType();
            uType = 1;
            document.getElementById("idUserAccountType").innerText = mlp.getLanguageKey("代理");

            var select = document.getElementById("ContactPhonePrefix");
            select.innerHTML = "";

            var option = document.createElement("option");
            option.text = mlp.getLanguageKey("+63 菲律賓");
            option.value = "+63";
            select.appendChild(option);

        });
    }

    window.onload = init;
</script>
<body class="innerBody">
    <main>
        <%--        <div class="loginUserInfo">
            <div class="loginUserInfo__account heading-1" id="idLoginAccount">
            </div>
        </div>--%>
        <div class="topList-box box-shadow fixed">
            <div class="container-fluid">
                <h1 class="page__title "><span class="language_replace">新增下線</span></h1>

                <div class="step__header">

                    <div id="stepFlows" class="step__flows step-total-2">
                        <!-- flow 狀態 
                                1.目前所在step => 加入class="active"
                            -->
                        <div class="step__flow flow-1 active" onclick="previousStep(this)" data-step="1" aria-checked="checking">
                            <div class="step__status">
                                <span class="number">1</span>
                                <span class="icon icon2020-ico-account"></span>
                                <span class="chedcked"></span>
                            </div>
                            <div class="step__title"><span class="language_replace">基本資料</span></div>
                        </div>
                        <div class="step__flow flow-2" onclick="nextStep(this)" data-step="1" aria-checked="checking">
                            <div class="step__status">
                                <span class="number">2</span>
                                <span class="icon icon-ico-wallet"></span>
                                <span class="chedcked"></span>
                            </div>
                            <div class="step__title"><span class="language_replace">錢包設定</span></div>
                        </div>
                        <div class="progress_inner__bar"></div>
                        <div class="progress_inner__bar--base"></div>

                    </div>
                </div>
            </div>
        </div>
        <form method="post" onsubmit="return false">


            <div class="step__content">

                <div id="idStepContent" class="dataList step__list step-1">

                    <div class="step__listItem step-1">
                        <fieldset class="dataFieldset">
                            <legend class="dataFieldset-title language_replace hidden shown-lg">基本資料</legend>
                            <div class="row">

                                <div class="col-12 col-smd-12 col-md-6 col-lg-12 form-group row no-gutters">
                                    <div class="col-12">
                                        <label class="title"><span class="title_name"><i class="icon icon-ewin-default-accountType icon-s icon-before"></i><span class="language_replace">帳戶類型</span></span></label>
                                    </div>
                                    <div class="col-12 form-line d-flex justify-content-between align-items-center">
                                        <span class="language_replace" id="idUserAccountType"></span>
                                        <button type="button" style="display: none" class="btn btn-icon btn-s btn-outline-main btn-roundcorner" onclick="setUserAccountType()"><i class="icon icon-ewin-input-setUserAccountType icon-before icon-line-vertical"></i><span class="language_replace">狀態變更</span></button>
                                    </div>
                                </div>
                                <div class="col-12 col-smd-12 col-md-6 col-lg-12 form-group row no-gutters">
                                    <div class="col-12">
                                        <label class="title"><span class="title_name"><i class="icon icon-ewin-default-account icon-s icon-before"></i><span class="language_replace">登入帳號</span></span> </label>
                                    </div>
                                    <div class="col-12">
                                        <!-- 
                                                1.若資料正確 <div class="form-control-underline...=>加入class "iconCheck iconCheckAnim"
                                                2.若資料錯誤 <div class="form-control-underline...=>加入class "iconError iconErrorAnim" 

                                                 3.若 資料驗證中，則 icon-loading => display:block
                                                -->
                                        <div id="idLoginAccount" class="form-control-underline ">
                                            <input type="text" class="form-control" name="LoginAccount" id="LoginAccount" language_replace="placeholder" placeholder="請輸入帳號" onkeyup="chkUserAccount(this)">
                                            <label for="password" class="form-label "><span class="language_replace">請輸入帳號</span></label>
                                            <!-- loading 動畫 -->
                                            <div class="icon-loading" style="display: none;">
                                                <div class="lds-dual-ring"></div>
                                            </div>

                                        </div>
                                    </div>
                                </div>

                                <div class="col-12 col-md-6 form-group" id="idLendChipAccount">
                                    <label class="title"><span class="title_name"><i class="icon icon-ewin-default-accountType icon-s icon-before"></i><span class="language_replace">配碼帳戶</span></span></label>
                                    <span class="language_replace" id="IsLendChipAccount"></span>
                                </div>

                                <div class="col-12 col-smd-12 col-md-12 form-group row no-gutters">
                                    <div class="col-12">
                                        <label class="title"><span class="title_name"><i class="icon icon-ewin-default-accountNickname icon-s icon-before"></i><span class="language_replace">姓名</span></span></label>
                                    </div>
                                    <div class="col-12">
                                        <div class="form-control-underline">
                                            <input type="text" class="form-control" name="RealName" id="RealName" language_replace="placeholder" placeholder="請輸入姓名">
                                            <label for="password" class="form-label "><span class="language_replace">請輸入姓名</span></label>
                                        </div>
                                    </div>
                                </div>
                                <!-- password input =============== -->
                                <div class="col-12 form-group row no-gutters">
                                    <div class="col-12">
                                        <label class="title"><span class="title_name"><i class="icon icon-ewin-default-accountPassword icon-s icon-before"></i><span class="language_replace">登入密碼</span></span>                        </label>
                                    </div>
                                    <div class="col-12 col-smd-6 pr-smd-1">
                                        <div class="form-control-underline">
                                            <input type="password" class="form-control" name="LoginPassword" id="LoginPassword" language_replace="placeholder" placeholder="請輸入登入密碼">
                                            <label for="password" class="form-label "><span class="language_replace">請輸入登入密碼</span></label>
                                        </div>
                                    </div>
                                    <div class="col-12 col-smd-6 mt-3 mt-smd-0 pl-smd-1">
                                        <div class="form-control-underline">
                                            <input type="password" class="form-control" name="LoginPassword2" id="LoginPassword2" language_replace="placeholder" placeholder="確認密碼">
                                            <label for="password" class="form-label "><span class="language_replace">確認密碼</span></label>
                                        </div>
                                    </div>
                                </div>
                                <!-- <div class="col-12 form-group row no-gutters">                              
                                <div class="col-12">
                                    <div class="form-control-underline">
                                        <input type="password" class="form-control" name="LoginPassword2" id="LoginPassword2" placeholder="確認密碼">
                                        <label for="password" class="form-label "><span class="language_replace">確認密碼</span></label>
                                    </div>
                                </div>
                               </div> -->
                                <!-- select =============== -->
                                <div class="col-12 form-group row no-gutters">
                                    <div class="col-12">
                                        <label class="title"><span class="title_name"><i class="icon icon-ewin-default-accounCellphone icon-s icon-before"></i><span class="language_replace">電話</span></span></label>
                                    </div>
                                    <div class="col-12 col-md">
                                        <div class="row no-gutters">
                                            <div class="col-auto col-md-6">
                                                <div class="form-control-underline">
                                                    <select name="ContactPhonePrefix" id="ContactPhonePrefix" class="custom-select">
                                                        <option class="language_replace" value="">(其他)</option>
                                                        <option class="language_replace" value="+86">+86 中國</option>
                                                        <option class="language_replace" value="+853">+853 澳門</option>
                                                        <option class="language_replace" value="+852">+852 香港</option>
                                                        <option class="language_replace" value="+886">+886 台灣</option>
                                                        <option class="language_replace" value="+81">+81 日本</option>
                                                        <option class="language_replace" value="+82">+82 南韓</option>
                                                        <option class="language_replace" value="+84">+84 越南</option>
                                                        <option class="language_replace" value="+66">+66 泰國</option>
                                                        <option class="language_replace" value="+855">+855 柬埔寨</option>
                                                        <option class="language_replace" value="+63">+63 菲律賓</option>
                                                        <option class="language_replace" value="+65">+65 新加坡</option>
                                                        <option class="language_replace" value="+60">+60 馬來西亞</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col col-md-6 pl-2">
                                                <div class="form-control-underline">
                                                    <input type="text" class="form-control" name="ContactPhoneNumber" id="ContactPhoneNumber" language_replace="placeholder" placeholder="請輸入手機號碼">
                                                    <label for="password" class="form-label "><span class="language_replace">請輸入手機號碼</span></label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </fieldset>

                        <div class="wrapper_center fixed-Bottom hidden-lg btn-group-lg ">
                            <button type="button" class="btn btn-outline-main" onclick="closePage(this)"><i class="icon icon-before icon-ewin-input-cancel"></i><span class="language_replace">取消</span></button>
                            <button type="button" class="btn btn-full-main " onclick="nextStep(this)" data-step="1"><span class="language_replace">下一步</span><i class="icon icon-after icon-ewin-input-arrow-right"></i></button>
                        </div>
                    </div>
                    <div class="step__listItem step-2">
                        <!-- 錢包管理 -->

                        <fieldset class="dataFieldset">
                            <legend class="dataFieldset-title language_replace hidden shown-lg">錢包管理</legend>
                            <div class="row" style="padding-bottom:5px">
                                <div class="col-12 col-smd-4 pr-smd-1">
                                    <div>
                                        <label for="password" class="form-label "><span class="language_replace">佔成率(%)</span></label>
                                        <input type="text" class="form-control tmpPointUserRate" value="0">
                                    </div>
                                </div>
                                <div class="col-12 col-smd-4 mt-3 mt-smd-0 pl-smd-1">
                                    <div>
                                        <label for="password" class="form-label "><span class="language_replace">轉碼率(%)</span></label>
                                        <input type="text" class="form-control tmpPointBuyChipRate" value="0">
                                    </div>
                                </div>
                                <div class="col-12 col-smd-4 mt-3 mt-smd-0 pl-smd-1">
                                    <div>
                                        <label for="password" class="form-label "><span class="language_replace"> </span></label>
                                       <button type="button" class="btn btn-full-main form-control" onclick="applyGameInfo()">
                                           <span class="language_replace">套用</span>
                                       </button>
                                    </div>
                                </div>
                            </div>
                            <div class="MT__tableDiv">
                                <!-- 自訂表格 -->
                                <div class="MT__table MT__table--Sub table-col-7">
                                    <!-- 標題項目  -->
                                    <div class="thead">
                                        <!--標題項目單行 -->
                                        <div class="thead__tr">
                                            <div class="thead__th">
                                                <span class="language_replace">貨幣</span>
                                            </div>
                                            <div class="thead__th">
                                                <span class="language_replace">遊戲類型</span>
                                            </div>
                                            <div class="thead__th">
                                                <span class="language_replace">佔成率(%)</span>
                                            </div>
                                            <div class="thead__th">
                                                <span class="language_replace">轉碼率(%)</span>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- 表格上下滑動框 -->
                                    <div id="templateWalletItem" style="display: none">
                                        <!--表格內容單行 -->
                                        <div class="tbody__tr">
                                            <div class="tbody__td td-100 currencyType">
                                                <span class="td__title">
                                                    <i class="icon icon-ewin-default-coin-o"></i>
                                                    <span class="language_replace"></span>
                                                </span>
                                                <span class="td__content">
                                                    <span class="language_replace PointCurrencyType"></span>
                                                    <span class="btnPointNew" btntype="create" style="display: none">
                                                        <button type="button" class="btn btn-s btn-outline-main "><i class="icon"></i><span class="language_replace btnText">新增</span></button>
                                                    </span>
                                                </span>
                                            </div>
                                            <div class="tbody__td td-3 td-vertical">
                                                <span class="td__title">
                                                    <span class="language_replace">遊戲代碼</span>
                                                </span>
                                                <span class="td__content">
                                                    <span class="language_replace GameAccountingCode"></span>
                                                </span>
                                            </div>
                                            <div class="tbody__td td-3 td-vertical">
                                                <span class="td__title">
                                                    <span class="language_replace">佔成率(%)</span>
                                                </span>
                                                <span class="td__content">
                                                    <div class="form-control-hidden ADJ_userRate">
                                                        <input type="text" class="form-control PointUserRate" language_replace="placeholder" placeholder="佔成率上限" value="0">
                                                        <!-- placholder label -->
                                                        <label class="form-label span_parentUserRate">
                                                            <span class="language_replace">上線</span><span class="number"><span class="parentUserRate"></span>%</span>
                                                        </label>
                                                    </div>
                                                </span>
                                            </div>
                                            <div class="tbody__td td-3 td-vertical">
                                                <span class="td__title">
                                                    <span class="language_replace">轉碼率(%)</span>
                                                </span>
                                                <span class="td__content">
                                                    <div class="form-control-hidden ADJ_userRate">
                                                        <input type="text" class="form-control PointBuyChipRate" language_replace="placeholder" placeholder="轉碼率上限" value="0">
                                                        <!-- placholder label -->
                                                        <label class="form-label span_parentBuyChipRate">
                                                            <span class="language_replace">上線</span><span class="number"><span class="parentBuyChipRate"></span>%</span>
                                                        </label>
                                                    </div>
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- END OF templateWalletItem  -->

                                    <!-- 原本的寫法 寫在 tbody裡-->
                                    <!-- <div id="idPointList" class="wallet_PointList">
                                    </div> -->
                                    <div id="idPointList" class="tbody wallet_PointList userAccount_Edit">
                                    </div>

                                </div>

                            </div>
                        </fieldset>
                        <div class="wrapper_center fixed-Bottom last-step-execute btn-group-lg">
                            <button type="button" class="btn btn-outline-main " onclick="closePage(this)"><i class="icon icon-before icon-ewin-input-cancel"></i><span class="language_replace">取消</span></button>
                            <button type="button" class="btn btn-full-main hidden-lg" onclick="previousStep(this)" data-step="1"><i class="icon icon-before icon-ewin-input-arrow-left"></i><span class="language_replace">上一步</span></button>
                            <button type="button" class="btn btn-full-main" onclick="checkFormData()"><i class="icon icon-before icon-ewin-input-submit"></i><span class="language_replace">送出</span></button>
                        </div>
                    </div>

                    <div id="BetLimitTab" class="BetLimitTab bitLimitDIV" style="display: none">
                        <ul class="nav-tabs-block nav nav-tabs tab-items-2" role="tablist">
                            <li class="nav-item">
                                <a onclick="tabSwitch(this)" class="BetLimitTabNavTabs nav-link active language_replace" data-toggle="tab" href="#tab-1" role="tab" aria-controls="tab-1" aria-selected="true">快速電投</a>
                            </li>
                            <li class="nav-item">
                                <a onclick="tabSwitch(this)" class="BetLimitTabNavTabs nav-link language_replace" data-toggle="tab" href="#tab-2" role="tab" aria-controls="tab-2" aria-selected="false">網投</a>
                            </li>
                            <li class="tab-slide"></li>
                        </ul>

                    </div>

                </div>
            </div>

            <div id="divUserAccountType" class="popUp__UserAccountType" style="display: none">
                <div class="user-item UserAccountType__agent" onclick="setUType('Agent')">
                    <div class="content">
                        <span class="icon"></span>
                        <span class="text"><span class="language_replace">代理</span></span>
                    </div>
                </div>
            </div>
        </form>

    </main>

    <!-- 
        popUp MessageBOX=================================
        popUp 出現 => class 加入show
        mask_overlay_popup 遮罩按下時 popup會消失
     -->
    <div class="popUp " id="idMessageBox">
        <div class="popUpWrapper">
            <div class="popUp__title" id="idMessageTitle">[Title]</div>
            <div class="popUp__content" id="idMessageText">
            </div>
            <div class="popUp__footer">
                <div class="form-group-popupBtn">
                    <div class="btn btn-outline-main btn-popup-cancel" id="idMessageButtonCancel">Cancel</div>
                    <div class="btn btn-full-main btn-popup-confirm" id="idMessageButtonOK">OK</div>
                </div>
            </div>
        </div>
        <!-- mask_overlay 半透明遮罩-->
        <!-- <div id="mask_overlay_popup" class="mask_overlay_popup" onclick="MaskPopUp(this)"></div> -->
        <div id="mask_overlay_popup" class="mask_overlay_popup"></div>
    </div>

    <script>
        //TAB FLOW
        //上一步
        function previousStep(e) {
            var idStepContent = document.getElementById("idStepContent");
            var idstepFlows = document.getElementById("stepFlows");
            var step__listItem = document.getElementsByClassName("step__listItem");
            var data_step = e.dataset.step; //get TAB data-step 
            var myIndex = 0;

            // GET EACH TAB item
            var stepFlowItems = idstepFlows.querySelectorAll('.step__flow');

            for (var i = 0; i < stepFlowItems.length; i++) {
                stepFlowItems[i].classList.remove('active');
                stepFlowItems[i].setAttribute("aria-checked", "checking");
            }

            myIndex = parseInt(data_step) - 1;
            stepFlowItems[myIndex].classList.add('active');
            idStepContent.className = "dataList step__list step-" + parseInt(data_step);

            window.setTimeout(function () {
                setScreenToTop();
            }, 100)

        }

        //下一步
        function nextStep(e) {
            var idStepContent = document.getElementById("idStepContent");
            var idstepFlows = document.getElementById("stepFlows");
            var step__listItem = document.getElementsByClassName("step__listItem");

            // var data_step = e.dataset.stepfinish; //get TAB data-step 
            var data_step = e.dataset.step; //get top TAB data-step 

            // GET EACH TAB item
            var stepFlowItems = idstepFlows.querySelectorAll('.step__flow');
            var myIndex = 0;

            for (var i = 0; i < stepFlowItems.length; i++) {
                stepFlowItems[i].classList.remove('active');
                stepFlowItems[i].setAttribute("aria-checked", "checking");
            }

            myIndex = parseInt(data_step);
            stepFlowItems[myIndex].classList.add('active');
            // stepFlowItems[myIndex].setAttribute("aria-checked", "checking");
            stepFlowItems[myIndex - 1].setAttribute("aria-checked", "checked");

            idStepContent.className = "dataList step__list step-" + (myIndex + 1);

            window.setTimeout(function () {
                setScreenToTop();
            }, 100)
        }

        function setScreenToTop() {
            var stepContent;
            var scrollTop = 0;

            stepContent = document.getElementsByClassName("step__content")[0];
            stepContent.scrollTo(0, 0);
        }

        function closePage() {
            window.parent.API_CloseWindow(false);
        }

        // tab 切換 ===================================
        function tabSwitch(e) {
            var idBetLimitTab = document.getElementById("BetLimitTab");

            var tabNavItems = idBetLimitTab.getElementsByClassName('nav-item');
            var tabNavItemsALink = idBetLimitTab.getElementsByClassName("BetLimitTabNavTabs");

            var tabContentItems = idBetLimitTab.getElementsByClassName("BetLimitTabContent");


            var data_toggle = e.dataset.toggle;
            var data_target = e.getAttribute("aria-controls");


            window.event.stopPropagation();
            window.event.preventDefault();

            for (var i = 0; i < tabNavItemsALink.length; i++) {

                tabNavItems[i].classList.remove('active');
                tabNavItemsALink[i].classList.remove('active');
                tabNavItemsALink[i].setAttribute("aria-selected", "false");

            }

            e.parentNode.classList.add('active');
            e.classList.add('active');
            e.setAttribute("aria-selected", "true");

            //TAB 內容==========================================

            for (var i = 0; i < tabContentItems.length; i++) {
                tabContentItems[i].classList.remove('show', 'active');
            }

            document.getElementById(data_target).classList.add('show', 'active');


            return false;
        }

        function showBox(title, msg, showOK, cbOK) {
            var idMessageBox = document.getElementById("idMessageBox");
            var idMessageTitle = document.getElementById("idMessageTitle");
            var idMessageText = document.getElementById("idMessageText");
            var idMessageButtonOK = document.getElementById("idMessageButtonOK");
            var idMessageButtonCancel = document.getElementById("idMessageButtonCancel");

            var funcOK = function () {
                c.removeClassName(idMessageBox, "show");

                if (cbOK != null)
                    cbOK();
            }

            if (idMessageTitle != null)
                idMessageTitle.innerHTML = title;

            //if (idMessageText != null)
            //    idMessageText.innerHTML = msg;

            if (idMessageButtonOK != null) {
                if (showOK == true) {
                    idMessageButtonOK.style.display = "";
                    idMessageButtonOK.onclick = funcOK;
                }
                else {
                    idMessageButtonOK.style.display = "none";
                }
            }

            if (idMessageButtonCancel != null) {
                idMessageButtonCancel.style.display = "none";
            }

            c.addClassName(idMessageBox, "show");
        }

        //PopUP半透明遮罩
        function MaskPopUp(obj) {
            idMessageBox.classList.remove("show");
        }

    </script>
</body>
</html>
