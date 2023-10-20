<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UserAccountWallet_Transfer2.aspx.cs" Inherits="UserAccountWallet_Transfer2" %>

<%
    string toa = Request["toa"];
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
    var ApiUrl = "UserAccountWallet_Transfer2.aspx";
    var toa = "<%=toa%>";
    var mlp;
    var lang;
    var EWinInfo;
    var timerChkUserAccount;
    var timerChkUserAccount2;
    var processing = false;

    function closePage() {
        if (window.parent.windowList.length > 1) {
            window.parent.API_CloseWindow(true);
        }
        else {
            window.parent.API_MainWindow("Main", "home_Casino.aspx");
        }
    }

    function submitForm() {
        var form = document.forms[0];
        checkFormData(function () {
            var postObj;
            var idWalletList = document.getElementById("idWalletList");
            var CurrencyType;

            if (processing == false) {


                CurrencyType = idWalletList.options[idWalletList.selectedIndex].value;

                postObj = {
                    AID: EWinInfo.ASID,
                    SrcLoginAccount: form.idTransOutAccountSrc.value,
                    DstLoginAccount: form.idTransOutAccount.value,
                    CurrencyType: CurrencyType,
                    TransOutValue: form.idTransOut.value,
                    WalletPassword: form.idWalletPassword.value,
                    Description: form.idDescription.value
                };
                processing = true;
                window.parent.API_ShowLoading("Sending");

                c.callService(ApiUrl + "/UserAccountTransfer", postObj, function (success, o) {
                    if (success) {
                        var obj = c.getJSON(o);

                        if (obj.Result == 0) {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("完成"), mlp.getLanguageKey("轉帳完成"), function () {
                                closePage();
                            });
                        } else {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(obj.Message));
                            processing = false;
                        }
                    } else {
                        if (o == "Timeout") {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後重新嘗試"));
                            processing = false;
                        } else {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o));
                            processing = false;
                        }
                    }

                    window.parent.API_CloseLoading();
                });
            }
            else {
                window.parent.API_ShowToastMessage(mlp.getLanguageKey("作業進行中"));
            }
        })
    }

    function checkFormData(cb) {
        var retValue = true;
        var form = document.forms[0];
        var idMessageConfirm;
        var idWalletList = document.getElementById("idWalletList");

        if (form.idWalletPassword.value == "") {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入錢包密碼!!"));
            retValue = false;
        }

        if (form.idTransOut.value == "") {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入轉出金額!!"));
            retValue = false;
        }
        else if (isNaN(form.idTransOut.value) == true) {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("轉出金額輸入錯誤!!"));
            retValue = false;
        }
        else if (parseInt(form.idTransOut.value) < 0) {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("轉出金額不可輸入負數!!"));
            retValue = false;
        }

        if (retValue == true) {
            checkAccountExist(form.idTransOutAccountSrc.value, function (accountExist) {
                if (accountExist == true) {
                    if (cb) {
                        idMessageConfirm = document.getElementById("idMessageConfirm");

                        checkAccountExist2(form.idTransOutAccount.value, function (accountExist) {
                            if (accountExist == true) {
                                if (cb) {
                                    idMessageConfirm = document.getElementById("idMessageConfirm");


                                    c.setClassText(idMessageConfirm, "msgLoginAccountSrc", null, form.idTransOutAccountSrc.value);
                                    c.setClassText(idMessageConfirm, "msgLoginAccount", null, form.idTransOutAccount.value);
                                    c.setClassText(idMessageConfirm, "msgCurrencyType", null, idWalletList.options[idWalletList.selectedIndex].value);
                                    c.setClassText(idMessageConfirm, "msgTransOut", null, c.toCurrency(form.idTransOut.value));
                                    window.parent.API_ShowMessage("", idMessageConfirm.innerHTML, function () {
                                        cb();
                                    }, null);

                                }
                            } else {
                                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("轉入帳號錯誤"));
                            }
                        });
                        

                    }
                } else {
                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("轉出帳號錯誤"));
                }
            });
        }
    }

    function chkUserAccount(el) {
        window.clearTimeout(timerChkUserAccount);
        el.parentNode.getElementsByClassName("icon-loading")[0].style.display = "none";
        if (el.value.trim() != "") {
            el.parentNode.getElementsByClassName("icon-loading")[0].style.display = "";
        }
        el.className = "form-control"
        timerChkUserAccount = window.setTimeout(function () {
            if (el.value.trim() != "") {
                checkAccountExist(el.value, function (retValue) {
                    el.parentNode.getElementsByClassName("icon-loading")[0].style.display = "none";
                    if (retValue == true) {

                        // document.getElementById("divNotice").style.display = "none"
                        el.className = "form-control";
                        if (el.getAttribute("iptType") == "SrcLoginAccount") {
                            queryCurrentUserInfo(1);
                        }
                        else{
                            queryCurrentUserInfo(0);
                        }
                    }
                    else {
                        // document.getElementById("divNotice").style.display = "";                      
                        el.className = "form-control error";
                    }
                })
            }

        }, 2000)
    }

    function chkUserAccount2(el) {
        window.clearTimeout(timerChkUserAccount2);
        el.parentNode.getElementsByClassName("icon-loading")[0].style.display = "none";
        if (el.value.trim() != "") {
            el.parentNode.getElementsByClassName("icon-loading")[0].style.display = "";
        }
        el.className = "form-control"
        timerChkUserAccount2 = window.setTimeout(function () {
            if (el.value.trim() != "") {
                checkAccountExist2(el.value, function (retValue) {
                    el.parentNode.getElementsByClassName("icon-loading")[0].style.display = "none";
                    if (retValue == true) {

                        // document.getElementById("divNotice").style.display = "none"
                        el.className = "form-control";
                        if (el.getAttribute("iptType") == "SrcLoginAccount") {
                            queryCurrentUserInfo(1);
                        }
                        else {
                            queryCurrentUserInfo(0);
                        }
                    }
                    else {
                        // document.getElementById("divNotice").style.display = "";                      
                        el.className = "form-control error";
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

        c.callService(ApiUrl + "/CheckChildAccount", postObj, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);

                if (obj.Result == 0) {
                    if (cb)
                        cb(true);
                } else {
                    if (cb)
                        cb(false);
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

    function checkAccountExist2(loginAccount, cb) {
        var postObj;

        postObj = {
            AID: EWinInfo.ASID,
            LoginAccount: loginAccount
        };

        c.callService(ApiUrl + "/CheckChildAccountTransfer", postObj, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);

                if (obj.Result == 0) {
                    if (cb)
                        cb(true);
                } else {
                    if (cb)
                        cb(false);
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

    function queryCurrentUserInfo(setCurrenctType) {
        var postObj;
        var form = document.forms[0];
        var idWalletList = document.getElementById("idWalletList");

        if (setCurrenctType == 1) {
            idWalletList.innerText = "";
        }
        postObj = {
            AID: EWinInfo.ASID,
            SrcLoginAccount: form.idTransOutAccountSrc.value
        };

        c.callService(ApiUrl + "/QueryCurrentUserInfo", postObj, function (success, o) {
            if (success) {
                var obj = c.getJSON(o);

                if (obj.Result == 0) {
                    parentObj = obj;
                    // build wallet list
                    if (obj.WalletList != null) {
                        if (obj.WalletList.length > 0) {
                            if (setCurrenctType == 1) {
                                for (var i = 0; i < obj.WalletList.length; i++) {
                                    var temp = c.getTemplate("templateWalletInfo");
                                    var w = obj.WalletList[i];
                                    //document.getElementsByClassName
                                    if (temp != null) {
                                        temp.value = w.CurrencyType;
                                        c.setClassText(temp, "currenyType", null, w.CurrencyType);
                                        c.setClassText(temp, "currenyNum", null, c.toCurrency(w.PointValue));

                                        idWalletList.appendChild(temp);

                                    }
                                }
                            }
                            
                        }
                        else {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("尚未開啟任一錢包"), function () {
                                closePage();
                            });
                        }
                    }
                    else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("尚未開啟任一錢包"), function () {
                            closePage();
                        });
                    }


                } else {
                    if (obj.Message == "EmptyWalletPassword") {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請先設定錢包密碼"), function () {
                            window.parent.API_MainWindow(mlp.getLanguageKey('會員中心'), 'UserAccount_Edit_MySelf.aspx?w=1&r=transfer');
                        });
                    }
                    else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(obj.Message));
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


    function chkTextLength(el) {
        if (el.value.length > 20) {
            el.value = el.value.substring(0, 20);
        }
    }


    function init() {

        lang = window.localStorage.getItem("agent_lang");
        api = window.parent.API_GetAgentAPI();

        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
            EWinInfo = window.parent.EWinInfo;
            //queryCurrentUserInfo();
            window.parent.API_CloseLoading();
        });

        if (toa != "") {
            document.getElementById("idTransOutAccount").value = toa;
        }
    }

    window.onload = init;

</script>

<body class="innerBody">
    <main>
        <div class="container-fluid">
            <h1 class="page__title "><span class="language_replace">會員轉帳</span></h1>

            <form onsubmit="return false;">
                <section class="sectionWallet wallet__currency--transfer">
                    <div class="content">

                        <!-- 可用餘額 -->
                        <%--<div class="Balance">
                            <p class="Balance_title">
                                <span class="title language_replace"></span> <span id="idCurrenyType" class="currenyType">--</span>
                            </p>
                            <p id="idPointValue" class="Balance_number">0</p>
                        </div>--%>

                        <!-- 轉出帳號 -->
                        <div class="Account transferOut">
                            <div class="form-group mb-0">
                                <div class="form-control-underline form-input-icon input-notice">
                                    <!-- 輸入驗證錯誤時，在 input 加入class => error -->
                                    <input id="idTransOutAccountSrc" type="text" class="form-control" name="member" onkeyup="chkUserAccount(this)" language_replace="placeholder" placeholder="轉出帳號" iptType="SrcLoginAccount">
                                    <label for="member" class="form-label ico-before-member"><span class="language_replace">轉出帳號</span></label>
                                    <!-- loading 動畫 -->
                                    <div class="icon-loading" style="display: none;">
                                        <div class="lds-dual-ring"></div>
                                    </div>
                                    <!-- qrCODE Scan-->
                                    <%--<div class="form-control-last">
                                        <div class="scanQrcode">
                                            <!-- <i class="icon icon2020-ico-qrcode"></i> -->
                                            <input type="file" class="custom_input_file">
                                        </div>
                                    </div>--%>
                                    <!-- 錯誤提示-->
                                    <div id="divNotice" class="notice error" style=""><i class="icon icon2020-information"></i><span class="language_replace">帳號輸入錯誤</span></div>

                                </div>


                            </div>
                        </div>
                        <!-- 轉出錢包 -->
                        <div class="WalletType transferOut">
                            <div class="form-group">
                                <label class="title">
                                    <span class="language_replace">轉出錢包</span>
                                </label>
                                <select id="idWalletList" class="custom-select custom-select-lg">
                                </select>
                            </div>
                            <div id="templateWalletInfo" style="display: none">
                                <option class="language_replace optCurrenyType" value=""><span class="currenyType">CNY</span> <span class="currenyNum">0</span></option>
                            </div>

                        </div>

                         <!-- 轉入帳號 -->
                         <div class="Account transferIn">
                            <div class="form-group mb-0">
                                <div class="form-control-underline form-input-icon input-notice">
                                    <!-- 輸入驗證錯誤時，在 input 加入class => error -->
                                    <input id="idTransOutAccount" type="text" class="form-control" name="member" onkeyup="chkUserAccount2(this)" language_replace="placeholder" placeholder="轉入帳號" iptType="DstLoginAccount">
                                    <label for="member" class="form-label ico-before-member"><span class="language_replace">轉入帳號</span></label>
                                    <!-- loading 動畫 -->
                                    <div class="icon-loading" style="display: none;">
                                        <div class="lds-dual-ring"></div>
                                    </div>
                                    <!-- qrCODE Scan-->
                                    <%--<div class="form-control-last">
                                        <div class="scanQrcode">
                                            <!-- <i class="icon icon2020-ico-qrcode"></i> -->
                                            <input type="file" class="custom_input_file">
                                        </div>
                                    </div>--%>
                                    <!-- 錯誤提示-->
                                    <div id="divNotice" class="notice error" style=""><i class="icon icon2020-information"></i><span class="language_replace">帳號輸入錯誤</span></div>

                                </div>


                            </div>
                        </div>

                        

                        <!-- 轉出金額 -->
                        <div class="Amount transferOut">
                            <div class="form-group mb-0">
                                <div class="form-control-underline form-input-icon input-notice">
                                     <!-- 輸入驗證錯誤時，在 input 加入class => error -->
                                    <input type="text" class="form-control" name="transferout" id="idTransOut" language_replace="placeholder" placeholder="轉出金額">
                                    <label for="transferout" class="form-label ico-before-coin"><span class="language_replace">轉出金額</span></label>
                                    <!-- 錯誤提示-->
                                    <div class="notice error"><i class="icon icon2020-information"></i><span class="language_replace">錯誤提示文字</span></div>
                                </div>
                            </div>

                        </div>

                        <!-- 錢包密碼不用  -->
                         <div class="Password">
                            <div class="form-group">
                                <div class="form-control-underline form-input-icon">
                                    <input type="password" class="form-control" name="member" id="idWalletPassword" language_replace="placeholder" placeholder="錢包密碼">
                                    <label for="password" class="form-label ico-before-lock"><span class="language_replace">錢包密碼</span></label>
                                </div>
                            </div>
                        </div> 

                        <!-- 備註 -->
                        <div class="Remarks">
                            <div class="form-group">
                                <div class="form-control-underline input-notice form-input-icon">
                                    <textarea class="form-control control-notice" id="idDescription" rows="1" language_replace="placeholder" placeholder="備註" onkeyup="chkTextLength(this)"></textarea>
                                    <label for="" class="form-label ico-before-note"><span class="language_replace">加入備註</span></label>
                                    <div class="notice error"><i class="icon icon2020-information"></i><span class="language_replace">僅可輸入20字以內</span></div>
                                </div>
                            </div>
                        </div>

                        <div class="wrapper_center btn-group-lg">
                            <button tyep="button" class="btn btn-full-main" onclick="submitForm()"><i class="icon icon-before icon-ewin-input-transfer"></i><span class="language_replace">確認轉出</span></button>
                        </div>

                    </div>
                </section>

            </form>
        </div>

        <div id="idMessageConfirm" style="display: none">
            <div class="dataList">
                <fieldset class="dataFieldset">
                    <div class="row dataFieldset-content">
                        <div class="col-12 col-sm-6 col-md-4 col-lg-6 form-group row no-gutters  data-item ">
                            <div class="col-12 data-title">
                                <label class="title"><span class="title_name"><i class="icon icon-ewin-default-account icon-s icon-before"></i><span class="language_replace">轉出帳號</span></span></label>
                            </div>
                            <div class="col-12 data-content form-line">
                                <span class="DateInfo msgLoginAccountSrc">--</span>
                            </div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4 col-lg-6 form-group row no-gutters  data-item ">
                            <div class="col-12 data-title">
                                <label class="title"><span class="title_name"><i class="icon icon-ewin-default-account icon-s icon-before"></i><span class="language_replace">轉入帳號</span></span></label>
                            </div>
                            <div class="col-12 data-content form-line">
                                <span class="DateInfo msgLoginAccount">--</span>
                            </div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4 col-lg-6 form-group row no-gutters  data-item ">
                            <div class="col-12 data-title">
                                <label class="title"><span class="title_name"><i class="icon icon-ewin-default-walletType icon-s icon-before"></i><span class="language_replace">轉出錢包1</span></span></label>
                            </div>
                            <div class="col-12 data-content form-line">
                                <span class="DateInfo msgCurrencyType">--</span>
                            </div>
                        </div>
                        <div class="col-12 col-sm-12 col-md-4 col-lg-6 form-group row no-gutters  data-item ">
                            <div class="col-12 data-title">
                                <label class="title"><span class="title_name"><i class="icon icon-ewin-default-amount icon-s icon-before"></i><span class="language_replace">轉出金額</span></span></label>
                            </div>
                            <div class="col-12 data-content form-line">
                                <span class="DateInfo msgTransOut">--</span>
                            </div>
                        </div>
                        <!-- 以下為沒有 Title 單行+icon樣式 -->
                        <div class="col-12 col-sm-12 col-md-4 col-lg-6 form-group row no-gutters  data-item form-line data-noTitle" style="display: none;">
                            <div class="col-auto data-title">
                                <label class="title"><span class="title_name"><i class="icon icon-ewin-default-amount icon-s icon-before"></i><span class="language_replace"></span></span></label>
                            </div>
                            <div class="col data-content">
                                <span class="DateInfo ">我是沒有Title的資料</span>
                            </div>
                        </div>
                    </div>
                </fieldset>
            </div>
        </div>
    </main>
</body>
</html>
