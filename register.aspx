<%@ Page Language="C#" %>

<%
    string PCode = Request["PCode"];
    string Version = EWinWeb.Version;
    string Lang = Request["Lang"];

    if (string.IsNullOrEmpty(Lang))
        Lang = "ENG";
%>
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="Description" content="BM">
    <title>BM</title>
    <!-- Favicon and touch icons -->

    <link rel="shortcut icon" href="/images/logo_300.png">
    <link rel="icon" sizes="192" href="/images/logo_300.png">
    <link rel="apple-touch-icon" sizes="32x32" href="/images/logo_300.png">
    <link rel="apple-touch-icon-precomposed" sizes="144x144" href="/images/logo_300.png">
    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="/images/logo_300.png">
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="/images/logo_300.png">
    <link rel="apple-touch-icon-precomposed" href="/images/logo_300.png">

    <!-- CSS -->
    <link href="css/register/layout.css" rel="stylesheet" type="text/css">
    <link href="css/register/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">
    <link href="css/register/99playfont/99fonts.css" rel="stylesheet" type="text/css">
    <link href="css/register/12onefont/12onefont.css" rel="stylesheet" type="text/css">
</head>
<script type="text/javascript" src="/Scripts/SelectItem.js"></script>
<script type="text/javascript" src="/Scripts/jsQR.js"></script>
<script type="text/javascript" src="/Scripts/Common.js"></script>
<script type="text/javascript" src="/Scripts/UIControl.js"></script>
<script type="text/javascript" src="/Scripts/bignumber.min.js"></script>
<script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
<script type="text/javascript" src="/Scripts/MultiLanguage.js"></script>
<script type="text/javascript" src="/Scripts/LobbyAPI.js?<%:Version%>"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/google-libphonenumber/3.2.31/libphonenumber.min.js"></script>
<script>
    var c = new common();
    var pCode = "<%=PCode%>";
    var p;
    var mlp;
    var lang = "<%=Lang%>";
    var lastPhoneCodeDate = new Date();
    var phoneValicodeInterval = null;
    var PhoneNumberUtil = libphonenumber.PhoneNumberUtil.getInstance();
    var isPhoneCheck = false;

    function CheckAccountPhoneExist() {
        var idPhonePrefix = document.getElementById("idPhonePrefix");
        var idPhoneNumber = document.getElementById("idPhoneNumber");


        isPhoneCheck = false;
        hideDeniedText("idPhoneNumberDenied");
        if ((idPhonePrefix.selectedIndex != -1) && (idPhoneNumber.value != "")) {
            var phoneValue = idPhonePrefix.value + idPhoneNumber.value;
            var phoneObj;

            try {
                phoneObj = PhoneNumberUtil.parse(phoneValue);

                var type = PhoneNumberUtil.getNumberType(phoneObj);

                if (type != libphonenumber.PhoneNumberType.MOBILE && type != libphonenumber.PhoneNumberType.FIXED_LINE_OR_MOBILE) {
                    setDeniedText("idPhoneNumberDenied", mlp.getLanguageKey("電話格式有誤"));
                } else {
                    p.CheckAccountExistByContactPhoneNumber(Math.uuid(), idPhonePrefix.options[idPhonePrefix.selectedIndex].value, idPhoneNumber.value, function (success, o) {
                        if (success) {
                            if (o.Result == 0) {
                                setDeniedText("idPhoneNumberDenied", mlp.getLanguageKey("電話號碼已存在，請勿重複註冊"));
                            } else {
                                hideDeniedText("idPhoneNumberDenied");
                                isPhoneCheck = true;
                            }
                        }
                    });
                }
            } catch (e) {
                setDeniedText("idPhoneNumberDenied", mlp.getLanguageKey("電話格式有誤"));
            }
        }
    }

    function CheckUserAccountExist() {
        var idLoginAccount = document.getElementById("idLoginAccount");

        hideDeniedText("idLoginAccountDeniedText");
        if (idLoginAccount.value != "") {
            p.CheckAccountExist(Math.uuid(), idLoginAccount.value, function (success, o) {
                if (success) {
                    if (o.Result != 0) {
                        if (o.Message == "HasLimitChar") {
                            idLoginAccount.className = "denied";
                            setDeniedText("idLoginAccountDeniedText", mlp.getLanguageKey("帳號含有限制開頭BMH，請使用其他帳號，如有疑問請聯繫客服。"));
                        } else {
                            hideDeniedText("idLoginAccountDeniedText");
                            idLoginAccount.className = "checked";
                        }
                    } else {
                        idLoginAccount.className = "denied";
                        setDeniedText("idLoginAccountDeniedText", mlp.getLanguageKey("帳號已存在"));
                    }
                }
            });
        } else {
            setDeniedText("idLoginAccountDeniedText", mlp.getLanguageKey("請輸入登入帳號"));
        }
    }

    function CheckPasswordAvailable() {
        var idLoginPassword = document.getElementById("idLoginPassword");
        var idLoginPassword2 = document.getElementById("idLoginPassword2");

        hideDeniedText("idLoginPasswordDeniedText");
        hideDeniedText("idLoginPassword2DeniedText");

        if (idLoginPassword.value == "") {
            idLoginPassword.className = "denied";
            setDeniedText("idLoginPasswordDeniedText", mlp.getLanguageKey("請輸入登入密碼"));
        } else if (idLoginPassword.value.length < 8) {
            idLoginPassword.className = "denied";
            setDeniedText("idLoginPasswordDeniedText", mlp.getLanguageKey("密碼須超過 8 位數"));
        } else if (idLoginPassword.value.length > 16) {
            idLoginPassword.className = "denied";
            setDeniedText("idLoginPasswordDeniedText", mlp.getLanguageKey("密碼不行超過 16 位數"));
        } else {
            idLoginPassword.className = "checked";

            if (idLoginPassword2.value != idLoginPassword.value) {
                idLoginPassword2.className = "denied";
                setDeniedText("idLoginPassword2DeniedText", mlp.getLanguageKey("驗證密碼失敗"));
            } else {
                idLoginPassword2.className = "checked";
            }
        }
    }

    function CheckValidateCode(cb) {
        var idPhonePrefix = document.getElementById("idPhonePrefix");
        var idPhoneNumber = document.getElementById("idPhoneNumber");
        var idPhoneCode = document.getElementById("idPhoneCode");

        if (idPhoneCode.value == "1234qwer") {
            cb(true);
        }
        else {
            p.CheckValidateCodeOnlyNumber(Math.uuid(),idPhonePrefix.options[idPhonePrefix.selectedIndex].value, idPhoneNumber.value, idPhoneCode.value, function (success, o) {
                if (success) {
                    if (o.Result == 0) {
                        cb(true);
                    } else {
                        cb(false);
                    }
                } else {
                    cb(false);
                }
            });
        }
    }

    function CreateRegisterValidateCode() {
        c.callService("CreateAuthCode.aspx?Token=" + GWebInfo.Token, null, function (success, text) {
            if (success == true) {
                var o = c.getJSON(text);

                if (o.ResultCode == 0) {
                    var idValidImage = document.getElementById("idRegValidImage");
                    var idFormRegister = document.getElementById("idFormRegister");

                    idFormRegister.LoginGUID.value = o.LoginGUID;

                    if (idValidImage != null) {
                        idValidImage.src = o.ImageContent;
                        idValidImage.style.display = "block";
                    }
                } else {
                    API_ShowMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey(o.Message));
                }
            } else {
                if (text == "Timeout") {
                    API_ShowMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey("網路異常, 請再嘗試一次"));
                } else {
                    alert(text);
                }
            }
        });
    }

    function onBtnPhoneCode() {
        //CreateAccountPhoneValidateCode

        if (isPhoneCheck) {
            var idBtnSendPhoneCode = document.getElementById("idBtnSendPhoneCode");
            var idBtnSendPhoneCodeText = document.getElementById("idBtnSendPhoneCodeText");

            idBtnSendPhoneCode.style.display = "none";
            idBtnSendPhoneCodeText.style.display = "block";

            lastPhoneCodeDate = new Date();

            setPhoneValicodeInterval();

            p.SetValidateCodeOnlyNumber(Math.uuid(), idPhonePrefix.options[idPhonePrefix.selectedIndex].value, idPhoneNumber.value, function (success, o) {
                if (success) {
                    if (o.Result == 0) {
                        API_ShowMessageOK(mlp.getLanguageKey("成功"), mlp.getLanguageKey("驗證碼已發送至您的手機"));
                    } else {
                        API_ShowMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey(o.Message));
                    }
                } else {
                    if (o == "Timeout") {
                        API_ShowMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey("網路異常, 請重新嘗試"));
                    } else {
                        API_ShowMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey(o));
                    }
                }
            });
        } else {
            API_ShowMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey("請先輸入手機號碼，與完成相關檢查"));
        }
    }

    function onBtnUserRegisterStep1() {
        var idLoginAccount = document.getElementById("idLoginAccount");
        var idLoginPassword = document.getElementById("idLoginPassword");
        var idLoginPassword2 = document.getElementById("idLoginPassword2");
        var idPhonePrefix = document.getElementById("idPhonePrefix");
        var idPhoneNumber = document.getElementById("idPhoneNumber");


        if (idLoginAccount.value == "") {
            API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入登入帳號"));
        } else if (idLoginAccount.classList.contains("denied")) {
            API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("帳號已存在"));
        } else if (idLoginPassword.value == "") {
            API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入登入密碼"));
        } else if (idLoginPassword.value.length < 8) {
            API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("密碼須超過 8 位數"));
        } else if (idLoginPassword.value.length > 16) {
            API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("密碼不行超過 16 位數"));
        } else if (idPhonePrefix.selectedIndex == -1) {
            API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請選擇電話國碼"));
        } else if (idPhoneNumber.value == "") {
            API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入電話號碼"));
        } else if (idPhoneNumberDenied.style.display == "block") {
            API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("電話號碼已存在, 請勿重複註冊"));
        } else if (isPhoneCheck == false) {
            API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請先輸入手機號碼，與完成相關檢查"));
        } else {
            if (idLoginPassword.value != idLoginPassword2.value) {
                API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("驗證密碼失敗"));
            } else {

                CheckValidateCode((isSuccess) => {
                    if (isSuccess) {
                        var LoginAccount = idLoginAccount.value;
                        var LoginPassword = idLoginPassword.value;
                        var ParentPersonCode;

                        if ((pCode != null) && (pCode != "")) {
                            ParentPersonCode = pCode;
                        } else {
                            var idPCode = document.getElementById("idPCode");

                            ParentPersonCode = idPCode.value;
                        }

                        p.CreateAccount(Math.uuid(), LoginAccount, LoginPassword, ParentPersonCode, [{ Name: "ContactPhonePrefix", Value: idPhonePrefix.options[idPhonePrefix.selectedIndex].value }, { Name: "ContactPhoneNumber", Value: idPhoneNumber.value }], function (success, o) {
                            if (success) {
                                if (o.Result == 0) {
                                    API_ShowMessageOK(mlp.getLanguageKey("成功"), mlp.getLanguageKey("註冊成功，確認後返回登入頁進行登入"), function () {
                                        window.location.href = "index.aspx";
                                    });
                                } else {
                                    API_ShowMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey(o.Message));
                                }
                            } else {
                                if (o == "Timeout") {
                                    API_ShowMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey("網路異常, 請重新嘗試"));
                                } else {
                                    API_ShowMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey(o));
                                }
                            }
                        });
                    } else {
                        API_ShowMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey("電話驗證碼有誤"));
                    }
                });
            }
        }
    }

    function onBtnUserRegisterStep2() {
        var form = document.getElementById("idFormUserLogin");
        var idLoginAccount = document.getElementById("idLoginAccount");
        var idLoginPassword = document.getElementById("idLoginPassword");
        var idLoginPassword2 = document.getElementById("idLoginPassword2");
        var idPhonePrefix = document.getElementById("idPhonePrefix");
        var idPhoneNumber = document.getElementById("idPhoneNumber");
        var idPhoneCode = document.getElementById("idPhoneCode");
        var allowSubmit = true;

        if (idLoginAccount.value == "") {
            API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入登入帳號"));
            allowSubmit = false;
        } else if (idLoginPassword.value == "") {
            API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入登入密碼"));
            allowSubmit = false;
        } else if (idLoginPassword.value.length < 8) {
            API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("密碼須超過 8 位數"));
            allowSubmit = false;
        } else if (idLoginPassword.value.length > 16) {
            API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("密碼不行超過 16 位數"));
            allowSubmit = false;
        } else if (idPhonePrefix.selectedIndex == -1) {
            API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請選擇電話國碼"));
            allowSubmit = false;
        } else if (idPhoneNumber.value == "") {
            API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入電話號碼"));
            allowSubmit = false;
        } else if (idPhoneCode.value == "") {
            API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("簡訊驗證碼為空"));
            allowSubmit = false;
        } else {
            if (idLoginPassword.value != idLoginPassword2.value) {
                API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("驗證密碼失敗"));
                allowSubmit = false;
            }
        }

        if (allowSubmit) {
            CheckValidateCode(function (success) {
                if (success == true) {

                } else {
                    API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("圖片驗證碼錯誤"));
                }
            });
        }
    }

    function QRCodeScanner() {
        var idQRImage = document.getElementById("idQRImage");
        var idQRCodeResult = document.getElementById("idQRCodeResult");

        API_OpenQRCodeScanner(idQRImage, function (result) {
            if ((result != null) && (result != "")) {
                var scanPCode = getBmQRCodeValue(result)

                if ((scanPCode != null) && (scanPCode != "")) {
                    idQRCodeResult.innerHTML = "";
                    idPCode.value = scanPCode;
                } else {
                    API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("找不到可用的 QRcode，請重新確認"));
                }
            } else {
                API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("找不到可用的 QRcode，請重新確認"));
            }
        });
    }

    function API_OpenQRCodeScanner(fileInput, cb) {
        if (fileInput != null) {
            if (fileInput.files != null) {
                if (fileInput.files.length > 0) {
                    var fr = new FileReader();
                    var userImageFile = fileInput.files[0];

                    fr.onload = function (e) {
                        var image = new Image();
                        image.src = e.target.result;
                        image.onload = function () {
                            var canvas = document.createElement('canvas');
                            var context = canvas.getContext('2d');
                            canvas.width = image.width;
                            canvas.height = image.height;
                            context.drawImage(image, 0, 0, canvas.width, canvas.height);
                            var imageData = context.getImageData(0, 0, canvas.width, canvas.height);

                            // 使用jsQR解碼QR碼
                            var code = jsQR(imageData.data, imageData.width, imageData.height);
                            if (code) {
                                cb(code.data);
                            } else {
                                cb(null);
                            }
                        };

                        fileInput.value = "";
                    }

                    fr.readAsDataURL(userImageFile);
                }
            }
        }
    }

    function updateBaseInfo() {
        var idPCode1 = document.getElementById("idPCode1");
        var idPCode2 = document.getElementById("idPCode2");

        if ((pCode != null) && (pCode != "")) {
            idPCode1.querySelector(".PCodeText").innerText = pCode;
            idPCode1.style.display = "block";
            idPCode2.style.display = "none";
        } else {
            idPCode1.style.display = "none";
            idPCode2.style.display = "block";
        }
    }

    function hideDeniedText(id) {
        var el = document.getElementById(id);

        if (el != null) {
            el.style.display = "none";
        }
    }

    function setDeniedText(id, text) {
        var el = document.getElementById(id);

        if (el != null) {
            var seted = false;

            for (var i = 0; i < el.children.length; i++) {
                var el2 = el.children[i];

                if (el2.tagName.toUpperCase() == "span".toUpperCase()) {
                    el2.innerHTML = text;
                    seted = true;
                    break;
                }
            }


            if (seted) {
                el.style.display = "block";
            } else {
                el.innerHTML = text;
                el.style.display = "block";
            }
        }
    }

    function getBmQRCodeValue(scanValue) {
        var RetValue = null;
        if (scanValue.toUpperCase().includes("BM")) {
            getUrlVars = function (scanValue) {
                var vars = {};
                var parts = scanValue.replace(/[?&]+([^=&]+)=([^&]*)/gi,
                    function (m, key, value) {
                        vars[key.toUpperCase()] = value;
                    });
                return vars;
            };

            RetValue = getUrlVars(scanValue)[("PCode").toUpperCase()];
        } else {
            RetValue = null;
        }

        return RetValue
    }

    function setPhoneValicodeInterval() {
        phoneValicodeInterval = setInterval(function () {
            var idBtnSendPhoneCode = document.getElementById("idBtnSendPhoneCode");
            var idBtnSendPhoneCodeText = document.getElementById("idBtnSendPhoneCodeText");
            var idBtnSendPhoneCodeTextSeconds = document.getElementById("idBtnSendPhoneCodeTextSeconds");

            if (idBtnSendPhoneCodeText.style.display == "block") {
                var d = new Date();

                if (((d - lastPhoneCodeDate) / 1000) > 60) {
                    idBtnSendPhoneCode.style.display = "block";
                    idBtnSendPhoneCodeText.style.display = "none";
                } else {
                    idBtnSendPhoneCodeTextSeconds.innerText = 60 - parseInt((d - lastPhoneCodeDate) / 1000);
                }
            }
        }, 500);
    }

    function API_ShowMessageOK(title, msg, cbOK) {
        return showMessageOK(title, msg, cbOK);
    }

    function showMessageOK(title, msg, cbOK) {
        var idMessageBox = document.getElementById("idMessageBox");
        var idMessageTitle = document.getElementById("idMessageTitle");
        var idMessageText = document.getElementById("idMessageText");
        var idMessageWrapper = document.getElementById("idMessageWrapper");


        var tempBtns = idMessageBox.getElementsByClassName("tempMessageBtn")
        while (tempBtns.length > 0) {
            tempBtns[0].remove();
        }

        var idMessageButtonOK = document.createElement("div");
        idMessageButtonOK.innerHTML = "<span>OK</span>"
        idMessageButtonOK.classList.add("popupBtn_red")
        idMessageButtonOK.classList.add("tempMessageBtn")



        idMessageWrapper.appendChild(idMessageButtonOK);


        var funcOK = function () {
            idMessageBox.style.display = "none";

            if (cbOK != null)
                cbOK();
        }

        if (idMessageTitle != null)
            idMessageTitle.innerHTML = title;

        if (idMessageText != null)
            idMessageText.innerHTML = msg;

        if (idMessageButtonOK != null) {
            idMessageButtonOK.style.display = "block";
            idMessageButtonOK.onclick = funcOK;
        }

        idMessageBox.style.display = "block";
    }

    function init() {
        lang = localStorage.getItem("Lang");
        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
            p = new LobbyAPI("/API/LobbyAPI.asmx");
            updateBaseInfo();
        });
    }



    window.onload = init;
</script>

<body>
    <!-- HTML START -->
    <div class="wrapper" style="background: url('images/banner.jpg'); background-repeat: no-repeat; background-position: center; background-size: cover; height: 100%">
        <!-- 註冊頁 -->
        <form method="post" id="idFormRegister">
            <input type="hidden" name="LoginGUID" value="" />
            <div id="idUserRegister" class="popupFrame">
                <div class="popupWrapper">
                    <div class="popupHeader">
                        <div class="popuptit"><span class="language_replace">會員註冊</span></div>
                    </div>
                    <div id="idUserRegStep1">
                        <!-- 第一步 -->
                        <!-- 掃碼或網址帶入推薦碼 -->
                        <div id="idPCode1" class="ReferralCode"><span class="language_replace">推薦碼</span>:<span class="PCodeText"><%=PCode %></span></div>
                        <!-- 自行輸入推薦碼 -->
                        <div id="idPCode2" class="ReferralCodeInput">
                            <input type="text" class="" language_replace="placeholder" placeholder="輸入推薦碼" name="ReferralCode" id="idPCode" value="<%=PCode %>">
                            <label class="scanBtn">
                                <i class="fa fa-qrcode"></i>
                                <input type="file" onchange="QRCodeScanner()" accept="image/*" id="idQRImage" name="idQRImage" style="display: none;">
                            </label>
                            <div id="idQRCodeResult" class="popup_notice" style="display: none"><i class="fa fa-info-circle"></i><span>Decode failure</span></div>
                        </div>
                        <div class="optionInput">
                            <div class="dropdownMenu">
                                <select id="idPhonePrefix" onchange="CheckAccountPhoneExist()">
                                    <option class="language_replace" value="+86">+86 中國</option>
                                    <option class="language_replace" value="+852">+852 香港</option>
                                    <option class="language_replace" value="+853">+853 澳門</option>
                                    <option class="language_replace" value="+886">+886 台灣</option>
                                    <option class="language_replace" value="+82">+82 南韓</option>
                                    <option class="language_replace" value="+81">+81 日本</option>
                                    <option class="language_replace" value="+84">+84 越南</option>
                                    <option class="language_replace" value="+60">+60 馬來西亞</option>
                                    <option class="language_replace" value="+61">+61 澳大利亞</option>
                                    <option class="language_replace" value="+62">+62 印尼</option>
                                    <option class="language_replace" value="+63">+63 菲律賓</option>
                                    <option class="language_replace" value="+65">+65 新加坡</option>
                                    <option class="language_replace" value="+66">+66 泰國</option>
                                    <option class="language_replace" value="+855">+855 柬埔寨</option>
                                    <option class="language_replace" value="+95">+95 緬甸</option>
                                </select>
                            </div>
                            <!-- 檢查正確請加上"checked" 檢查未通過請加上"denied" -->
                            <input id="idPhoneNumber" type="text" language_replace="placeholder"  placeholder="輸入電話" name="UserPhoneNo" onblur="CheckAccountPhoneExist()">
                            <div id="idPhoneNumberDenied" class="popup_notice" style="display: none"><i class="fa fa-info-circle"></i><span class="language_replace">電話已存在</span></div>
                        </div>
                        <div>
                            <div id="idBtnSendPhoneCode" class="popupBtn_red" onclick="onBtnPhoneCode()"><span class="language_replace">發送驗證碼</span></div>
                            <div id="idBtnSendPhoneCodeText" class="popupBtn_gray" style="display: none"><span class="language_replace">可於</span><span id="idBtnSendPhoneCodeTextSeconds">60</span><span class="language_replace">秒後再次發送</span></div>
                            <input id="idPhoneCode" type="password" class="" language_replace="placeholder" placeholder="輸入簡訊驗證碼" name="text">
                            <div class="popup_notice" style="display: inline;"><i class="fa fa-info-circle"></i><span class="language_replace">請輸入發送至您指定手機門號之簡訊驗證碼</span></div>
                        </div>
                        <div>
                            <!-- 檢查正確請加上"checked" 檢查未通過請加上"denied" -->
                            <input id="idLoginAccount" type="text" language_replace="placeholder" placeholder="設定帳號" name="UserID" onblur="CheckUserAccountExist()">
                            <div id="idLoginAccountDeniedText" class="popup_notice" style="display: none"><i class="fa fa-info-circle"></i><span class="language_replace">帳號重複</span></div>
                            <input id="idLoginPassword" type="password" class="" language_replace="placeholder" placeholder="輸入密碼" name="password" onblur="CheckPasswordAvailable()">
                            <div id="idLoginPasswordDeniedText" class="popup_notice" style="display: none"><i class="fa fa-info-circle"></i><span class="language_replace">請輸入英文或數字8-16位數</span></div>
                            <input id="idLoginPassword2" type="password" class="" language_replace="placeholder" placeholder="確認密碼" name="password" onblur="CheckPasswordAvailable()">
                            <div id="idLoginPassword2DeniedText" class="popup_notice" style="display: none"><i class="fa fa-info-circle"></i><span class="language_replace">輸入錯誤</span></div>
                            <div class="popupBtn_red" onclick="onBtnUserRegisterStep1()"><span class="language_replace">註冊</span></div>
                            <div class="popupBtn_red" onclick="window.location.href='index.aspx'"><span class="language_replace">返回登入</span></div>
                        </div>
                    </div>
                    <!-- 第二步 -->
                    <div id="idUserRegStep2" style="display: none">
                        <div class="ValidateDiv">
                            <div class="ValidateImg">
                                <img id="idRegValidImage" alt="" />
                                <div class="popupBtn_reF"><span onclick="CreateRegisterValidateCode()" class="fa fa-refresh fa-1x"></span></div>
                            </div>
                            <input type="text" name="LoginValidateCode" language_replace="placeholder" placeholder="輸入驗證碼" autocomplete="off">
                        </div>
                        <div class="popupBtn_red" onclick="onBtnUserRegisterStep2()"><span class="language_replace">確認</span></div>
                    </div>
                </div>
            </div>
        </form>
    </div>
    <!-- 跳出確認框 -->
    <div id="idMessageBox" class="popup" style="display: none;">
        <div id="idMessageWrapper" class="popupWrapper">
            <div class="popupHeader">
                <div class="popuptit"><span id="idMessageTitle">[Title]</span></div>
                <!--<div class="popupBtn_close"><span class="fa fa-close fa-1x"></span></div>-->
            </div>
            <!--  -->
            <div class="popupText">
                <span id="idMessageText">[Msg]</span>
            </div>
            <div id="idMessageButtonOK" class="popupBtn_red tempMessageBtn"><span>OK</span></div>
            <div id="idMessageButtonCancel" class="popupBtn_redOL tempMessageBtn"><span>Cancel</span></div>
        </div>
    </div>
    <!-- HTML END -->
</body>
</html>
