<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UserAccountAgent_Add.aspx.cs" Inherits="UserAccountAgent_Add" %>

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
    var ApiUrl = "UserAccountAgent_Add.aspx";
    var mlp;
    var lang;
    var EWinInfo;
    var parentObj;
    var timerChkUserAccount;
    var uType;
    var processing = false;


    function btnSubmit() {
        checkFormData(function () {
            updateUserInfo();
        });
    }


    function checkFormData(cb) {
        var retValue = true;
        var form = document.forms[0];

        if (form.LoginAccount.value.trim() == "") {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入帳號"));
            retValue = false;
        } else if (form.LoginAccount.value.trim().toUpperCase() == EWinInfo.LoginAccount.toUpperCase()) {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入非本人帳號"));
            retValue = false;
        } else if (form.LoginAccount.value.trim().toUpperCase().startsWith('BMH')) {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("帳號含有限制開頭BMH，請使用其他帳號，如有疑問請聯繫客服。"));
            retValue = false;
        }

        if (form.LoginPassword.value.trim() == "") {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入密碼"));
            retValue = false;
        }
        else {
            if (form.LoginPassword.value != form.LoginPassword2.value) {
                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("登入密碼二次驗證失敗"));
                retValue = false;
            }
        }

        if (retValue == true) {
            checkAccountExist(form.LoginAccount.value, function (accountExist) {
                if (accountExist == true) {
                    if (cb)
                        cb();
                } else {
                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("登入帳號已存在"));
                }
            });
        }
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
                    } else if (obj.Message == "HasLimitChar") {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("帳號含有限制開頭BMH，請使用其他帳號，如有疑問請聯繫客服。"));
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


    function updateUserInfo() {
        var form = document.forms[0];
        var userList = [];
        var postObj;
        var idPointList = document.getElementById("idPointList");
        var Permission = 1;

        if (processing == false) {

            // 建立用戶更新物件
            if ((form.LoginPassword.value != "") && (form.LoginPassword.value != null))
                userList[userList.length] = { Name: "LoginPassword", Value: form.LoginPassword.value };

            userList[userList.length] = { Name: "Permission", Value: form.idPermission.value };
            userList[userList.length] = { Name: "Description", Value: form.idDescription.value };

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
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("完成"), mlp.getLanguageKey("新增完成"), function () {
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
        else {
            window.parent.API_ShowToastMessage(mlp.getLanguageKey("作業進行中"));
        }

    }

    function chkTextLength(el) {
        if (el.value.length > 100) {
            el.value = el.value.substring(0, 100);
        }
    }

    function closePage() {
        window.parent.API_CloseWindow(false);
    }

    function init() {

        lang = window.localStorage.getItem("agent_lang");

        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
            EWinInfo = window.parent.EWinInfo;
            window.parent.API_CloseLoading();
        });
    }

    window.onload = init;
</script>
<body class="innerBody">
    <main>
        <div class="topList-box fixed">
            <div class="container-fluid">
                <h1 class="page__title "><span class="language_replace">新增助手</span></h1>
            </div>
        </div>
        <form method="post" onsubmit="return checkFormData(this)">
            <div class="container-fluid">
                <div class="dataList row">
                    <div class="col-12 col-lg-6">
                        <fieldset class="dataFieldset">
                            <div class="row dataFieldset-content">

                                <div class="col-12 col-smd-12 col-md-12 col-lg-12 form-group row no-gutters data-item">

                                    <div class="col-12 data-title">
                                                <label class="title"><span class="title_name"><i class="icon icon-ewin-default-account icon-s icon-before"></i><span class="language_replace">登入帳號</span></span></label>
                                            </div>
                                            <div class="col-12 data-content ">
                                        <!-- 
                                                1.若資料正確 <div class="form-control-underline...=>加入class "iconCheck iconCheckAnim"
                                                2.若資料錯誤 <div class="form-control-underline...=>加入class "iconError iconErrorAnim"   
                                             -->
                                        <div id="idLoginAccount" class="form-control-underline ">
                                            <input type="text" class="form-control" name="LoginAccount" id="LoginAccount" language_replace="placeholder" placeholder="請輸入帳號" >
                                            <label for="password" class="form-label "><span class="language_replace">請輸入帳號</span></label>
                                            <!-- loading 動畫 -->
                                            <div class="icon-loading" style="display: none;">
                                                <div class="lds-dual-ring"></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <!-- password input =============== -->
                                <div class="col-12 form-group row no-gutters data-item ">
                                    <div class="col-12 data-title">           <label class="title">                <span class="title_name"><i class="icon icon-ewin-default-accountPassword icon-s icon-before"></i><span class="language_replace">登入密碼</span></span></label></div>

                                    <div class="col-12 data-content row no-gutters">
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

                                </div>
                                <div class="col-12 col-md-12 form-group row no-gutters data-item ">
                                    <div class="col-12 data-title">
                                        <label class="title"><span class="title_name"><i class="icon icon-ewin-default-accountType icon-s icon-before"></i><span class="language_replace">權限設定</span></span></label> 
                                    </div>

                                    <div class="col-12 data-content">
                                        <div class="form-control-underline">
                                            <select name="Permission" id="idPermission" class="custom-select">
                                                <option class="language_replace" value="0">管理者</option>
                                                <option class="language_replace" value="1">允許檢視</option>
                                                <option class="language_replace" value="2">允許檢視 + 轉帳</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>

                                <!-- 備註 -->                                
                                <div class="col-12 col-md-12 form-group row no-gutters data-item ">
                                    <div class="col-12 data-title">
                                        <label class="title"><span class="title_name"><i class="icon icon-ewin-default-note icon-s icon-before"></i><span class="language_replace">備註</span></span></label> 
                                    </div>
                                    <div class="col-12 data-content">
                                        <div class="form-control-underline  input-notice">
                                            <!-- 當input下方有提示且非錯誤提示時，加 class => control-notice -->
                                            <textarea class="form-control control-notice" id="idDescription" rows="5" language_replace="placeholder" placeholder="備註" onkeyup="chkTextLength(this)"></textarea>
                                            <!-- <label for="" class="form-label"><span class="language_replace">加入備註</span></label> -->
                                            <div class="notice error"><i class="icon icon2020-information"></i><span class="language_replace">僅可輸入100字以內</span></div>
                                        </div>

                                    </div>

                                </div>
                            </div>
                            <div class="wrapper_center btn-group-lg">
                                <button type="button" class="btn btn-outline-main" onclick="closePage(this)"><i class="icon icon-before icon-ewin-input-cancel"></i><span class="language_replace">取消</span></button>
                                <button type="button" class="btn btn-full-main" onclick="btnSubmit()"><i class="icon icon-before icon-ewin-input-submit"></i><span class="language_replace">送出</span></button>
                            </div>
                        </fieldset>

                       

                    </div>
                </div>

            </div>
          

        </form>
    </main>
</body>
</html>
