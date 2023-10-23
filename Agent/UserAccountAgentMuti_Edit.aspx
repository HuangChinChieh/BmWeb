<%@ Page Language="C#" AutoEventWireup="true"%>

<%
    string LoginAccount = Request["LoginAccount"];
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
    var api;
    var loginAccount = "<%=LoginAccount%>";
    var mlp;
    var lang;
    var EWinInfo;
    var parentObj;
    var timerChkUserAccount;
    var uType;
    var processing = false;

    function btnSubmit() {
        checkFormData(function () {
            updateUserMutiInfo();
        });
    }


    function checkFormData(cb) {
        var retValue = true;
        var form = document.forms[0];

        if (form.Description.value.trim() == "") {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入描述"));
            retValue = false;
        }

        if (retValue)
            cb();
    }


    function updateUserMutiInfo() {
        var form = document.forms[0];
        var userList = [];
        var postObj;
        var idPointList = document.getElementById("idPointList");
        var Permission = 1;

        if (processing == false) {

            processing = true;
            window.parent.API_ShowLoading("Sending");

            api.SetMultiLogin(EWinInfo.ASID, Math.uuid(), loginAccount, form.Description.value, function (success, o) {
                if (success) {
                    if (o.ResultState == 0) {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("完成"), mlp.getLanguageKey("更新完成"), function () {
                            window.parent.API_CloseWindow(true);
                        });
                    } else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o.Message));

                        if (cb)
                            cb(false);
                    }
                } else {
                    if (o == "Timeout") {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後再嘗試"));
                    } else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o));
                    }

                    if (cb)
                        cb(false);
                }
            });

        }
        else {
            window.parent.API_ShowToastMessage(mlp.getLanguageKey("作業進行中"));
        }

    }

    function setAgentMutiInfo() {
        var hasNoData = true;

        if (EWinInfo) {
            if (EWinInfo.UserInfo.MultiLoginList) {
                if (EWinInfo.UserInfo.MultiLoginList.length > 0) {
                    for (var i = 0; i < EWinInfo.UserInfo.MultiLoginList.length; i++) {
                        if (EWinInfo.UserInfo.MultiLoginList[i].LoginAccount == loginAccount) {
                            hasNoData = false;

                            c.setElementText("idLoginAccount", null, EWinInfo.UserInfo.MultiLoginList[i].LoginAccount);
                            document.getElementById("Description").value = EWinInfo.UserInfo.MultiLoginList[i].Description;

                        }
                    }
                }
            }
        }

        if (hasNoData == true) {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("帳號錯誤"), function () {
                window.parent.API_CloseWindow(true);
            });
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

        api = window.parent.API_GetAgentAPI();
        lang = window.localStorage.getItem("agent_lang");

        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
            EWinInfo = window.parent.EWinInfo;
            setAgentMutiInfo();
            window.parent.API_CloseLoading();
        });
    }

    window.onload = init;
</script>
<body class="innerBody">
    <main>
        <div class="topList-box fixed">
            <div class="container-fluid">
                <h1 class="page__title "><span class="language_replace">編輯多重帳號</span></h1>
            </div>
        </div>
        <form method="post" onsubmit="return checkFormData(this)">
            <div class="container-fluid">
                <div class="dataList row">
                    <div class="col-12 col-lg-6">
                        <fieldset class="dataFieldset">

                            <div class="row dataFieldset-content">
                                <div class="col-12 col-sm-6 col-md-4 col-lg-6 form-group row no-gutters data-item">

                                    <div class="col-12 data-title">
                                        <label class="title"><span class="title_name"><i class="icon icon-ewin-default-account icon-s icon-before"></i><span class="language_replace">登入帳號</span></span></label>
                                    </div>

                                    <div class="col-12 data-content form-line">
                                        <div id="idLoginAccount" class="form-control-underline ">
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="col-12 col-smd-12 col-md-12 col-lg-12 form-group row no-gutters data-item">
                                    <div class="col-12 data-title">
                                        <label class="title"><span class="title_name"><i class="icon icon-ewin-default-note icon-s icon-before"></i><span class="language_replace">描述</span></span></label>
                                    </div>
                                    <div class="col-12 data-content ">
                                        <div id="idDescription" class="form-control-underline ">
                                            <input type="text" class="form-control" name="Description" id="Description" maxlength="30" language_replace="placeholder" placeholder="請輸入描述">
                                            <label for="password" class="form-label "><span class="language_replace">請輸入描述</span></label>
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
