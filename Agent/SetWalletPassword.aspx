<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SetWalletPassword.aspx.cs" Inherits="SetWalletPassword" %>

<%
    string ASID = Request["ASID"];
    string AgentVersion = EWinWeb.AgentVersion;
    EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
    EWin.BmAgent.AgentSessionResult ASR = null;
    EWin.BmAgent.AgentSessionInfo ASI = null;

    ASR = api.GetAgentSessionByID(ASID);

    if (ASR.Result != EWin.BmAgent.enumResult.OK)
    {
        Response.Redirect("login.aspx");
    }
    else
    {
        ASI = ASR.AgentSessionInfo;
    }

%>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="ie=edge" />
    <title>設定錢包密碼</title>
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
    var ApiUrl = "SetWalletPassword.aspx";
    var c = new common();
    var ac = new AgentCommon();
    var mlp;
    var EWinInfo;
    var api;
    var p;
    var lang;
    var isSent = false;
    var PhoneNumberUtil = libphonenumber.PhoneNumberUtil.getInstance();

    function init() {
        EWinInfo = window.parent.EWinInfo;
        api = window.parent.API_GetAgentAPI();

        p = new LobbyAPI("/API/LobbyAPI.asmx");;
        lang = window.localStorage.getItem("agent_lang");
        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
            getPhoneNumber();
            //window.parent.API_CloseLoading();
        });
    }

    function getPhoneNumber() {
        var postData = {
            AID: EWinInfo.ASID
        };

        window.parent.API_ShowLoading();
        c.callService(ApiUrl + "/GetUserSMSNumber", postData, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);

                if (obj.Result == 0) {
                    if (obj.ContactPhonePrefix[0] != "+") {
                        $("#idPhonePrefix").val("+" + obj.ContactPhonePrefix);
                    } else {
                        $("#idPhonePrefix").val(obj.ContactPhonePrefix);
                    }

                    $("#idPhoneNumber").val(obj.ContactPhoneNumber);

                    $("#idPhonePrefix").attr("disabled", "true");
                    $("#idPhoneNumber").attr("disabled", "true");
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

    function SendPhone() {

        if (isSent) {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("已發送驗證碼，短時間內請勿重複發送"));
            return;
        }

        var GUID = Math.uuid();
        var idPhonePrefix = document.getElementById("idPhonePrefix");
        var idPhoneNumber = document.getElementById("idPhoneNumber");


        if (idPhonePrefix.value == "") {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入國碼"));
            return;
        } else if (idPhoneNumber.value == "") {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入電話"));
            return;
        } else {
            var phoneValue = idPhonePrefix.value + idPhoneNumber.value;
            var phoneObj;

            try {
                phoneObj = PhoneNumberUtil.parse(phoneValue);

                var type = PhoneNumberUtil.getNumberType(phoneObj);

                if (type != libphonenumber.PhoneNumberType.MOBILE && type != libphonenumber.PhoneNumberType.FIXED_LINE_OR_MOBILE) {
                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("電話格式有誤"));
                    return;
                }
            } catch (e) {
                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("電話格式有誤"));
                return;
            }
        }


        var postData = {
            PhonePrefix: idPhonePrefix.value,
            PhoneNumber: idPhoneNumber.value
        };

        window.parent.API_ShowLoading();
        c.callService(ApiUrl + "/GetLoginAccount", postData, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);

                if (obj.Result == 0) {
                   
                    p.SetUserMail(GUID, 1, 1, "", idPhonePrefix.value, idPhoneNumber.value, "", function (success, o) {
                        if (success) {
                            if (o.Result == 0) {
                                isSent = true;
                                startCountDown(120);
                                window.parent.showMessageOK(mlp.getLanguageKey("成功"), mlp.getLanguageKey("已寄送認證碼"));
                            } else {
                                window.parent.showMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey("發送失敗，請重新發送"));
                            }
                        } else {
                            window.parent.showMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey("網路錯誤") + ":" + mlp.getLanguageKey(o.Message));
                        }
                    });
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

    function startCountDown(duration) {

        let secondsRemaining = duration;
        let min = 0;
        let sec = 0;

        let countInterval = setInterval(function () {
            let BtnSend = document.getElementById("btnSend");

            //min = parseInt(secondsRemaining / 60);
            //sec = parseInt(secondsRemaining % 60);
            BtnSend.querySelector("span").innerText = secondsRemaining + "s"

            secondsRemaining = secondsRemaining - 1;
            if (secondsRemaining < 0) {
                clearInterval(countInterval);
                SetBtnSend();
            };

        }, 1000);
    }

    function showNote() {
        window.event.stopPropagation();
        window.parent.API_ShowMessageOK(mlp.getLanguageKey("提醒"),mlp.getLanguageKey("注意事項")
        );
    }

    function SetBtnSend() {
        let BtnSend = document.getElementById("btnSend");
        BtnSend.querySelector("span").innerText = mlp.getLanguageKey("取得驗證碼");
        isSent = false;
    }

    function formSubmitCheck() {
        if (isSent) {

            let ValidCode = document.getElementById("idValidCode");
            let Password = document.getElementById("idNewPassword");
            var rules = new RegExp('^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,12}$');

            if (ValidCode.value == "") {
                window.parent.showMessageOK("", mlp.getLanguageKey("錯誤, 請輸入認證碼"));
                return;
            } else if (Password.value == "") {
                window.parent.showMessageOK("", mlp.getLanguageKey("錯誤, 請輸入新密碼"));
                return
            }

            SetNewPassword(ValidCode.value, Password.value);
        } else {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請先取得驗證碼"));
        }

    }

    function SetNewPassword(validCode, newPassword) {


        var idPhonePrefix = document.getElementById("idPhonePrefix");
        var idPhoneNumber = document.getElementById("idPhoneNumber");
        var GUID = Math.uuid();
        var ValidateType = 1;
        var EMail = '';
        var ValidateCode = validCode;
        var NewPassword = newPassword;
 
        var postData = {
            LoginAccount: EWinInfo.LoginAccount,
            ValidateType: 1,
            EMail: '',
            ContactPhonePrefix: idPhonePrefix.value,
            ContactPhoneNumber: idPhoneNumber.value,
            ValidateCode, ValidateCode,
            NewPassword: NewPassword
        }
     
        c.callService(ApiUrl + "/SetUserWalletPasswordByValidateCode", postData, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);

                if (obj.Result == 0) {
                    window.parent.showMessageOK(mlp.getLanguageKey("成功"), mlp.getLanguageKey("已成功修改密碼！"), function () {
                        window.parent.API_MainWindow('Main', 'home_Casino.aspx');
                    });
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

    window.onload = init;
</script>
<body class="innerBody ">
    <main class="innerMain">
        <div class="container-fluid">
            <div class="collapse-box">
                <h2 class="collapse-header has-arrow zIndex_overMask_SafariFix">
                    <span class="language_replace">設定錢包密碼</span>
                    <btn style="font-size: 12px; right: 5px; position: absolute; border: 2px solid; width: 22px; text-align: center; border-radius: 11px; color: #bba480; cursor: pointer;" onclick="showNote()">!</btn>
                </h2>
            </div>

            <form onsubmit="return false;">
                <section class="sectionWallet wallet__currency--transfer">
                    <div class="content">

                        <!-- 轉出金額 -->

                        <div class="form-group">
                            <div class="form-control-underline">
                                <input type="text" class="form-control" name="transferout" id="idPhonePrefix" language_replace="placeholder" placeholder="國碼" disabled="disabled" />
                                <label for="idTransOut" class="form-label"><span class="language_replace">國碼</span></label>
                            </div>
                        </div>


                        <!-- 錢包密碼 -->

                        <div class="form-group">
                            <div class="form-control-underline">
                                <input type="text" class="form-control" name="member" id="idPhoneNumber" language_replace="placeholder" placeholder="手機電話號碼" disabled="disabled" />
                                <label for="idPhoneNumber" class="form-label"><span class="language_replace">手機電話號碼</span></label>
                            </div>
                        </div>


                        <div class="wrapper_center btn-group-lg" style="padding-bottom: 10px;">
                            <button type="button" class="btn btn-full-main" id="btnSend" onclick="SendPhone()"><span class="language_replace">取得驗證碼</span></button>
                        </div>

                        <div class="form-group">
                            <div class="form-control-underline">
                                <input type="text" class="form-control" name="member" id="idValidCode" language_replace="placeholder" placeholder="請輸入驗證碼" />
                                <label for="idValidCode" class="form-label"><span class="language_replace">驗證碼</span></label>
                            </div>
                        </div>


                        <div class="form-group">
                            <div class="form-control-underline">
                                <input type="password" class="form-control" name="member" id="idNewPassword" language_replace="placeholder" placeholder="請輸入新密碼" />
                                <label for="idNewPassword" class="form-label"><span class="language_replace">新密碼</span></label>
                            </div>
                        </div>

                        <div class="wrapper_center btn-group-lg" style="padding-bottom: 10px;">
                            <button type="button" class="btn btn-full-main" onclick="formSubmitCheck()"><span class="language_replace">重設密碼</span></button>
                        </div>
                    </div>

                </section>

            </form>
        </div>
    </main>
</body>
</html>
