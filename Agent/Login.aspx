<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="Login" %>

<%
    //string DefaultCompany = Request["C"];
    string Lang;
    string DefaultCompany = EWinWeb.CompanyCode;
    string Version = EWinWeb.Version;
    string AgentVersion = EWinWeb.AgentVersion;
    if (string.IsNullOrEmpty(Request["Lang"])) {
        string userLang = CodingControl.GetDefaultLanguage();

        if (userLang.ToUpper() == "zh-TW".ToUpper()) { Lang = "CHT"; } else if (userLang.ToUpper() == "zh-HK".ToUpper()) { Lang = "CHT"; } else if (userLang.ToUpper() == "zh-MO".ToUpper()) { Lang = "CHT"; } else if (userLang.ToUpper() == "zh-CHT".ToUpper()) { Lang = "CHT"; } else if (userLang.ToUpper() == "zh-CHS".ToUpper()) { Lang = "CHS"; } else if (userLang.ToUpper() == "zh-SG".ToUpper()) { Lang = "CHS"; } else if (userLang.ToUpper() == "zh-CN".ToUpper()) { Lang = "CHS"; } else if (userLang.ToUpper() == "zh".ToUpper()) { Lang = "CHS"; } else if (userLang.ToUpper() == "en-US".ToUpper()) { Lang = "ENG"; } else if (userLang.ToUpper() == "en-CA".ToUpper()) { Lang = "ENG"; } else if (userLang.ToUpper() == "en-PH".ToUpper()) { Lang = "ENG"; } else if (userLang.ToUpper() == "en".ToUpper()) { Lang = "ENG"; } else if (userLang.ToUpper() == "ko-KR".ToUpper()) { Lang = "KOR"; } else if (userLang.ToUpper() == "ko-KP".ToUpper()) { Lang = "KOR"; } else if (userLang.ToUpper() == "ko".ToUpper()) { Lang = "KOR"; } else if (userLang.ToUpper() == "ja".ToUpper()) { Lang = "JPN"; } else if (userLang.ToUpper() == "th".ToUpper()) { Lang = "THAI"; } else if (userLang.ToUpper() == "ph".ToUpper()) { Lang = "PHP"; } else { Lang = "CHS"; }
    } else {
        Lang = Request["Lang"];
    }

    Lang = "ENG";

%>
<!doctype html>
<html lang="zh-Hant-TW" class="mainHtml">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Lucky Sprite</title>
    <meta id="extViewportMeta" name="viewport" content="width=device-width, height=device-height, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <link rel="stylesheet" href="css/basic.min.css?<%:AgentVersion%>">
    <link rel="stylesheet" href="css/main2.css?<%:AgentVersion%>">
    <link rel="stylesheet" href="css/login.css?<%:AgentVersion%>">
</head>
<script src="/Scripts/Common.js"></script>
<script src="/Scripts/bignumber.min.js"></script>
<script src="/Scripts/Math.uuid.js"></script>
<script src="Scripts/MultiLanguage.js"></script>
<script type="text/javascript" src="js/AppBridge.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/google-libphonenumber/3.2.31/libphonenumber.min.js"></script>
<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
<script src="../Scripts/LobbyAPI.js"></script>
<script>
    var AppBridge = new AppBridge("JsBridge", "iosJsBridge", "");
    var c = new common();
    var lang = "<%=Lang%>";
    var mlp;
    var defaultCompany = "<%=DefaultCompany%>";
    var timer;
    var clickCount = 0;
    var companyCodeTimer;
    var companyCodeclickCount = 0;
    var v ="<%:AgentVersion%>";
    var p = new LobbyAPI("../API/LobbyAPI.asmx");
    var PhoneNumberUtil = libphonenumber.PhoneNumberUtil.getInstance();

    function setLanguage(v) {
        var form = document.forms[0];

        lang = v;
        window.localStorage.setItem("agent_lang", lang);
        form.Lang.value = lang;

        if (mlp != null) {
            mlp.loadLanguage(lang);
        }
    }

    function checkData() {
        var form = document.forms[0];

        if (form.LoginAccount.value == "") {
            showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入登入帳號"));
        } else if (form.LoginPassword.value == "") {
            showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入登入密碼"));
        } else {
            var allowCompany = true;

            if ((defaultCompany == null) || (defaultCompany == "")) {
                if (form.CompanyCode.value == "") {
                    allowCompany = false;
                    showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入公司代碼"));
                }
            }

            if (allowCompany) {
                var allowMainAccount = true;
                var rdoLoginType0 = document.getElementById("rdoLoginType0");
                var rdoLoginType1 = document.getElementById("rdoLoginType1");

                if (rdoLoginType1.checked) {
                    // Agent
                    if (form.MainAccount.value == "") {
                        allowMainAccount = false;
                        showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入主戶口帳號"));
                    }
                }

                if (allowMainAccount) {
                    c.addClassName(document.getElementById("idShowLoading"), "show");
                    form.submit();
                }
            }
        }

        window.clearTimeout(timer);
        timer = window.setTimeout(function () {
            clickCount = 0;
        }, 2000);
        clickCount++;

        if (clickCount >= 8) {
            showMessage("提醒", "是否要轉入到測試環境?", function () {
                c.addClassName(document.getElementById("idShowLoading"), "show");
                window.location.href = "http://ewin.dev.mts.idv.tw/agent/login.aspx";
            }, null);
        }

    }

    function showCompanyCode() {

        window.clearTimeout(companyCodeTimer);
        companyCodeTimer = window.setTimeout(function () {
            companyCodeclickCount = 0;
        }, 2000);
        companyCodeclickCount++;

        //if (companyCodeclickCount >= 8) {
        //    idCompanyCode.style.display = "block";
        //}
    }

    function showMessage(title, msg, cbOK, cbCancel) {
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

        var funcCancel = function () {
            c.removeClassName(idMessageBox, "show");

            if (cbCancel != null)
                cbCancel();
        }

        if (idMessageTitle != null)
            idMessageTitle.innerHTML = title;

        if (idMessageText != null)
            idMessageText.innerHTML = msg;

        if (idMessageButtonOK != null) {
            // idMessageButtonOK.style.display = "block";
            idMessageButtonOK.style.display = "";
            idMessageButtonOK.onclick = funcOK;
        }

        if (idMessageButtonCancel != null) {
            // idMessageButtonCancel.style.display = "block";
            idMessageButtonCancel.style.display = "";
            idMessageButtonCancel.onclick = funcCancel;
        }

        c.addClassName(idMessageBox, "show");
    }

    function showMessageOK(title, msg, cbOK) {
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

        if (idMessageText != null)
            idMessageText.innerHTML = msg;

        if (idMessageButtonOK != null) {
            // idMessageButtonOK.style.display = "block";
            idMessageButtonOK.style.display = "";
            idMessageButtonOK.onclick = funcOK;
        }

        if (idMessageButtonCancel != null) {
            idMessageButtonCancel.style.display = "none";
        }

        c.addClassName(idMessageBox, "show");
    }

    function onLoginType() {
        var idMainAccountField = document.getElementById("idMainAccountField");
        var rdoLoginType0 = document.getElementById("rdoLoginType0");
        var rdoLoginType1 = document.getElementById("rdoLoginType1");
        var form = document.forms[0];

        if (rdoLoginType0.checked == true) {
            idMainAccountField.style.display = "none";
        } else if (rdoLoginType1.checked == true) {
            idMainAccountField.style.display = "block";
        }
    }

    //#region 忘記密碼
    function showForgetPassWord() {
        $("#idPopUpForgetPassWord").addClass("show");
    }

    function closeForgetPassWord() {
        $("#idPopUpForgetPassWord").removeClass("show");
    }

    function sendValidateCode() {
        debugger
        var GUID = Math.uuid();
        var PhonePrefix = $("#ContactPhonePrefix").val();
        var PhoneNumber = $("#ContactPhoneNumber").val();

        if (PhoneNumber == "") {
            showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入手機號碼"));
            return;
        } else {
            var phoneValue = PhonePrefix + PhoneNumber;
            var phoneObj;

            try {
                phoneObj = PhoneNumberUtil.parse(phoneValue);

                var type = PhoneNumberUtil.getNumberType(phoneObj);

                if (type != libphonenumber.PhoneNumberType.MOBILE && type != libphonenumber.PhoneNumberType.FIXED_LINE_OR_MOBILE) {
                    showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("電話格式有誤"));
                    return;
                }
            } catch (e) {
                showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("電話格式有誤"));
                return;
            }

        }

        p.SetUserMail(GUID, 1, 1, "", PhonePrefix, PhoneNumber, "", function (success, o) {
            if (success) {
                if (o.Result == 0) {
                    showMessageOK(mlp.getLanguageKey("成功"), mlp.getLanguageKey("已寄送認證碼"));
                } else {
                    showMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey("發送失敗，請重新發送"));
                }
            } else {
                showMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey("網路錯誤") + ":" + mlp.getLanguageKey(o.Message));
            }
        });

    }

    function updatePassWord() {
        var GUID = Math.uuid();
        var PhonePrefix = $("#ContactPhonePrefix").val();
        var PhoneNumber = $("#ContactPhoneNumber").val();
        var LoginAccount = $("#LoginAccount").val();
        var LoginPassword = $("#LoginPassword").val();
        var ValidateCode = $("#ValidateCode").val();
        var ValidateType = 1;
        var EMail = "";
        var postObj;

        if (LoginAccount == "") {
            showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入帳號"));
        } else if (LoginPassword == "") {
            showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入密碼"));
        } else if (ValidateCode == "") {
            showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入驗證碼"));
        }

        postObj = {
            CompanyCode: defaultCompany,
            GUID: GUID,
            ValidateType: ValidateType,
            EMail: EMail,
            ContactPhonePrefix: PhonePrefix,
            ContactPhoneNumber: PhoneNumber,
            ValidateCode: ValidateCode,
            NewPassword: LoginPassword,
            LoginAccount: LoginAccount
        };

        c.callService("Login.aspx/SetUserPasswordByValidateCode", postObj, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);

                if (obj.Result == 0) {
                    showMessageOK(mlp.getLanguageKey("成功"), mlp.getLanguageKey("已修改密碼"), function () {
                        closeForgetPassWord();
                    });
                } else {
                    showMessageOK(mlp.getLanguageKey("錯誤"), obj.Message);
                }
            } else {
                if (o == "Timeout") {
                    showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後重新嘗試"));
                } else {
                    showMessageOK(mlp.getLanguageKey("錯誤"), o);
                }
            }
        });
    }
    //#endregion

    function init() {
        var idCompanyCode = document.getElementById("idCompanyCode");
        var langTmp;
        var langel = document.getElementsByName("lang");
        var inAPP = false;

        //存入殼內的為第一優先
        if (AppBridge) {
            if (AppBridge.config.inAPP == true) {
                inAPP = true;
                AppBridge.GetDataByKey("CompanyCode", function (retValue) {
                    if (retValue != "(null)" && retValue != "") {
                        if (typeof (retValue) != "undefined") {
                            defaultCompany = retValue;
                            document.getElementsByName("CompanyCode")[0].value = retValue;
                        }
                    }

                    //if (window.sessionStorage.getItem("hasDefaultCompany")) {
                    //    if (window.sessionStorage.getItem("hasDefaultCompany") == "false") {
                    //        idCompanyCode.style.display = "block";
                    //        document.getElementsByName("CompanyCode")[0].value = "";
                    //    }

                    //}
                    //else {
                    //    if ((defaultCompany != null) && (defaultCompany != "")) {
                    //        idCompanyCode.style.display = "none";
                    //    } else {
                    //        window.sessionStorage.setItem("hasDefaultCompany", "false");
                    //        idCompanyCode.style.display = "block";
                    //    }
                    //}
                });

            }
        }


        //設定是否已傳送資料
        window.localStorage.setItem("UpdateDeviceInfo", "false");

        if (inAPP == false) {
            //if (window.sessionStorage.getItem("hasDefaultCompany")) {
            //    if (window.sessionStorage.getItem("hasDefaultCompany") == "false") {
            //        idCompanyCode.style.display = "block";
            //        document.getElementsByName("CompanyCode")[0].value = "";
            //    }

            //}
            //else {
            //    if ((defaultCompany != null) && (defaultCompany != "")) {
            //        idCompanyCode.style.display = "none";
            //    } else {
            //        window.sessionStorage.setItem("hasDefaultCompany", "false");
            //        idCompanyCode.style.display = "block";
            //    }
            //}
        }

        for (var i = 0; i < langel.length; i++) {
            if (lang == langel[i].value) {
                langel[i].checked = true;
                break;
            }
        }

        window.localStorage.setItem("agent_lang", lang);

        onLoginType();

        mlp = new multiLanguage(v);
        mlp.loadLanguage(lang, function () {
            //if (inAPP == true) {
            //    AppBridge.getCurrentVersion(function (retInfo) {
            //        var version;
            //        var mobileType;
            //        var showAlert = false;

            //        version = retInfo.split(":")[0].toUpperCase();
            //        mobileType = retInfo.split(":")[1].toUpperCase();

            //        document.getElementById("version").innerText = "v" + version;
            //        //alert(retInfo);
            //        switch (mobileType) {
            //            case "IOS":
            //                if (parseFloat(version) < 1.1) {
            //                    showAlert = true;
            //                }
            //                break;
            //            case "AN":
            //                if (parseFloat(version) < 1.1) {
            //                    showAlert = true;
            //                }
            //                break;

            //        }

            //        if (showAlert == true) {
            //            showMessageOK(mlp.getLanguageKey("更新"), mlp.getLanguageKey("您好，目前有新版本可以更新"));
            //        }
            //    });

            //}
        });


    }

    window.onload = init;
</script>
<body class="bg_mainBody LoginBody">
    <main class="main_area main__login">
        <div class="container loginWrapper">
            <section class="login__brand">
                <div class="heading-login text-center">
                    <span class="language_replace" onclick="showCompanyCode()">Lucky Sprite</span>
                </div>
                <!-- <div class="login__qrcode"><span class="qrcode"></span></div> -->
                <%if (EWinWeb.IsTestSite == true) { %>
                <div>
                    <p style="text-align: center; font-size: 14px; margin-bottom: 0; line-height: 1;"><span class="language_replace num-negative">此為測試環境</span></p>
                </div>
                <%} %>
            </section>
            <form class="loginForm" method="post" action="AgentLogin.aspx">
                <input type="hidden" name="Lang" value="<%=Lang %>" />

                <div class="loginForm__left">
                    <div class="form-group form-group-loginUser" style="display: none;">

                        <div class="custom-control custom-radio custom-control-inline">
                            <input onclick="onLoginType()" type="radio" name="LoginType" id="rdoLoginType0" value="0" class="custom-control-input-hidden" checked>
                            <label class="custom-control-label" for="rdoLoginType0"><span class="language_replace">主帳戶登入</span></label>
                        </div>
                        <div class="custom-control custom-radio custom-control-inline" style="display: none;">
                            <input onclick="onLoginType()" type="radio" name="LoginType" id="rdoLoginType1" value="1" class="custom-control-input-hidden">
                            <label class="custom-control-label" for="rdoLoginType1"><span class="language_replace">助手登入</span></label>
                        </div>
                    </div>
                    <div class="form-group form-group-lang">
                        <p><span class="language_replace">語系</span></p>
                        <div class="custom-control custom-radio-lang custom-control-inline" onclick="setLanguage('CHS')" style="display: none">
                            <input type="radio" id="lang1" name="lang" class="custom-control-input-hidden" value="CHS">
                            <label class="custom-control-label-lang ico-before-cn" for="lang1">
                                <span
                                    class="language_replace">简体中文</span></label>
                        </div>
                        <div class="custom-control  custom-control-inline custom-radio-lang" style="width: 25% !important" onclick="setLanguage('CHT')">
                            <input type="radio" id="lang2" name="lang" class="custom-control-input-hidden" value="CHT">
                            <label class="custom-control-label-lang ico-before-hk" for="lang2">
                                <span
                                    class="language_replace">繁體中文</span></label>
                        </div>
                        <div class="custom-control custom-radio-lang custom-control-inline" style="width: 25% !important" onclick="setLanguage('ENG')">
                            <input type="radio" id="lang3" name="lang" class="custom-control-input-hidden" value="ENG" checked>
                            <label class="custom-control-label-lang ico-before-en" for="lang3">
                                <span
                                    class="language_replace">english</span></label>
                        </div>
                    </div>
                </div>
                <div class="loginForm__right">
                    <div class="form-group">
                        <div class="form-control-underline form-input-icon">
                            <input type="text" class="form-control" name="LoginAccount" required>
                            <label for="member" class="form-label ico-before-member"><span class="language_replace">登入帳號</span></label>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="form-control-underline form-input-icon">
                            <input type="password" class="form-control" name="LoginPassword" id="" required>
                            <label for="password" class="form-label ico-before-lock"><span class="language_replace">登入密碼</span></label>
                        </div>
                    </div>
                    <div id="idMainAccountField" class="form-group" style="display: none">
                        <div class="form-control-underline form-input-icon">
                            <input type="text" class="form-control" name="MainAccount" required>
                            <label for="member" class="form-label ico-before-member"><span class="language_replace">主戶口帳號</span></label>
                        </div>
                    </div>
                    <div id="idCompanyCode" class="form-group" style="display: none">
                        <div class="form-control-underline form-input-icon">
                            <input type="text" class="form-control" name="CompanyCode" value="<%=DefaultCompany %>" required>
                            <label for="demo" class="form-label ico-before-location"><span class="language_replace">公司代碼</span></label>
                        </div>
                    </div>
                    <div class="form-group form-group-btnLogin btn-group-lg">
                        <div class="btn btn-full-main" onclick="checkData()"><span class="language_replace">登入</span></div>
                    </div>
                    <div class="form-group form-group-btnLogin btn-group-lg">
                        <div class="btn btn-full-main" onclick="showForgetPassWord()"><span class="language_replace">忘記密碼</span></div>
                    </div>
                </div>
            </form>
            <div class="copyright">

                <p><span class="language_replace">Copyright © 2020 eWin版權所有</span></p>
                <p><span id="version" class="language_replace">v1.0</span></p>
            </div>
        </div>
    </main>

    <div class="popUp" id="idMessageBox" style="z-index:999">
        <div class="popUpWrapper">
            <div class="popUp__title" id="idMessageTitle">[Title]</div>
            <div class="popUp__content" id="idMessageText">
                [Msg]
            </div>
            <div class="form-group-popupBtn">
                <div class="btn btn-popup-cancel" id="idMessageButtonCancel">Cancel</div>
                <div class="btn btn-popup-confirm" id="idMessageButtonOK">OK</div>
            </div>
        </div>

        <!-- mask_overlay 半透明遮罩-->
        <div class="mask_overlay_popup mask_overlay_loading"></div>
    </div>

    <div class="popUp" id="idShowLoading">
        <!-- <div class="popUpWrapper">
            <div class="popUp__title" id="idMessageTitle">[Title]</div>
            <div class="popUp__content" id="idMessageText">
                [Msg]
            </div>
        </div> -->
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
            <div class="loading_text">Login</div>
        </div>

        <!-- mask_overlay 半透明遮罩-->
        <div class="mask_overlay_popup mask_overlay_loading"></div>
    </div>

    <div class="popUp " id="idPopUpForgetPassWord">
        <div class="popUpWrapper">
            <div class="popUp__close btn btn-close" onclick="closeForgetPassWord()"></div>
            <div class="popUp__title"><span class="language_replace">忘記密碼</span></div>
            <div class="popUp__content">
                <div>
                    <div class="col-12 form-group row no-gutters data-item">
                        <div class="col-12 data-title">
                            <label class="title"><span class="title_name"><span class="language_replace" langkey="電話">電話</span></span></label>
                        </div>
                        <div class="col-12 data-content">
                            <div class="row no-gutters">
                                <div class="col-auto col-md-4 ">
                                    <div class="form-control-underline">
                                        <select name="ContactPhonePrefix" id="ContactPhonePrefix" class="custom-select">
                                            <option class="language_replace" value="+63" langkey="+63 菲律賓">+63 菲律賓</option>
                                            <option class="language_replace" value="+886" langkey="+886 台灣">+886 台灣</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col col-md-6 pl-2">
                                    <div class="form-control-underline">
                                        <input type="text" class="form-control" name="ContactPhoneNumber" id="ContactPhoneNumber" language_replace="placeholder" placeholder="請輸入手機號碼" langkey="請輸入手機號碼">
                                        <label for="password" class="form-label "><span class="language_replace" langkey="請輸入手機號碼">請輸入手機號碼</span></label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-12 col-md-6  col-lg-12  form-group row no-gutters data-item">
                        <div class="col-12 data-title">
                            <div class="form-group form-group-btnLogin btn-group-lg" style="padding-top:0px !important">
                               <div class="btn btn-full-main" onclick="sendValidateCode()"><span class="language_replace">傳送驗證碼</span></div>
                            </div>
                        </div>
                    </div>

                    <div class="col-12 col-md-6  col-lg-12  form-group row no-gutters data-item">
                        <div class="col-12 data-title">
                            <label class="title"><span class="title_name"><span class="language_replace" langkey="帳號">帳號</span></span></label>
                        </div>
                        <div class="col-12 data-content">
                            <div class="form-control-underline">
                                <input type="text" class="form-control" name="LoginAccount" id="LoginAccount" language_replace="placeholder" placeholder="請輸入帳號" langkey="請輸入帳號">
                                <label for="password" class="form-label "><span class="language_replace" langkey="請輸入帳號">請輸入帳號</span></label>
                            </div>
                        </div>
                    </div>

                    <div class="col-12 form-group row no-gutters data-item ">
                        <div class="col-12 data-title">
                            <label class="title"><span class="title_name"><span class="language_replace" langkey="登入密碼">登入密碼</span></span></label>
                        </div>
                        <div class="col-12 data-content">
                            <div class="form-control-underline">
                                <input type="password" class="form-control" name="LoginPassword" id="LoginPassword" language_replace="placeholder" placeholder="請輸入密碼" langkey="請輸入密碼">
                                    <label for="password" class="form-label "><span class="language_replace" langkey="請輸入密碼">請輸入密碼</span></label>
                            </div>
                        </div>
                    </div>

                    <div class="col-12 col-md-6  col-lg-12  form-group row no-gutters data-item">
                        <div class="col-12 data-title">
                            <label class="title"><span class="title_name"><span class="language_replace" langkey="驗證碼">驗證碼</span></span></label>
                        </div>
                        <div class="col-12 data-content">
                            <div class="form-control-underline">
                                <input type="text" class="form-control" name="ValidateCode" id="ValidateCode" language_replace="placeholder" placeholder="請輸入驗證碼" langkey="請輸入驗證碼">
                                <label for="password" class="form-label "><span class="language_replace" langkey="請輸入驗證碼">請輸入驗證碼</span></label>
                            </div>
                        </div>
                    </div>

                    <div class="col-12 col-md-6  col-lg-12  form-group row no-gutters data-item">
                        <div class="col-12 data-title">
                            <div class="form-group form-group-btnLogin btn-group-lg" style="padding-top:0px !important">
                                <div class="btn btn-full-main" onclick="updatePassWord()"><span class="language_replace">修改密碼</span></div>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>
        <!-- mask_overlay 半透明遮罩-->
        <div class="mask_overlay_popup mask_overlay_loading"></div>
    </div>

</body>
</html>
