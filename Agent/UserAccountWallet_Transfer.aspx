<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UserAccountWallet_Transfer.aspx.cs" Inherits="UserAccountWallet_Transfer" %>

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
    var ApiUrl = "UserAccountWallet_Transfer.aspx";
    var toa = "<%=toa%>";
    var mlp;
    var lang;
    var EWinInfo;

    function UserAccountTransfer() {
        var retValue = true;

        if ($("#idWalletPassword").val() == "") {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入錢包密碼"));
            retValue = false;
        }

        if ($("#idTransOutAccount").val() == "") {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入轉入帳號"));
            retValue = false;
        }

        if ($("#idTransOut").val() == "") {
            window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入轉出金額"));
            retValue = false;
        } else if (isNaN($("#idTransOut").val()) == true) {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("轉出金額輸入錯誤"));
            retValue = false;
        }
        else if (parseInt($("#idTransOut").val()) < 0) {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("轉出金額不可輸入負數"));
            retValue = false;
        }

        if (retValue) {
            postObj = {
                AID: EWinInfo.ASID,
                LoginAccount: $("#idTransOutAccount").val()
            }
            processing = true;

            window.parent.API_ShowLoading("Sending");
            $("#btnSave").hide();

            c.callService(ApiUrl + "/CheckChildAccount", postObj, function (success, o) {
                if (success) {
                    var obj = c.getJSON(o);

                    if (obj.Result == 0) {
                        postObj1 = {
                            AID: EWinInfo.ASID,
                            DstLoginAccount: $("#idTransOutAccount").val(),
                            CurrencyType: $("#idWalletList").val(),
                            TransOutValue: $("#idTransOut").val(),
                            WalletPassword: $("#idWalletPassword").val(),
                            Description: "TransOutToChildAccountFromAgent"
                        }

                        c.callService(ApiUrl + "/UserAccountTransfer", postObj1, function (success, o) {
                            if (success) {
                                var obj = c.getJSON(o);

                                if (obj.Result == 0) {
                                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("完成"), mlp.getLanguageKey("轉帳完成"), function () {
                                        window.parent.API_MainWindow("Main", "home_Casino.aspx");
                                    });

                                } else {
                                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), obj.Message);
                                    $("#btnSave").show();
                                    processing = false;
                                }
                            } else {
                                if (o == "Timeout") {
                                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後重新嘗試"));
                                    $("#btnSave").show();
                                    processing = false;
                                } else {
                                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), o);
                                    $("#btnSave").show();
                                    processing = false;
                                }
                            }

                            window.parent.API_CloseLoading();
                            $("#btnSave").show();
                        })

                    } else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), obj.Message);
                        $("#btnSave").show();
                        processing = false;
                    }
                } else {
                    if (o == "Timeout") {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後重新嘗試"));
                        $("#btnSave").show();
                        processing = false;
                    } else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), o);
                        $("#btnSave").show();
                        processing = false;
                    }
                }

                window.parent.API_CloseLoading();
                $("#btnSave").show();
            })
        }
    }
    
    function closePage() {
        window.parent.API_CloseWindow(false);
    }

    function queryCurrentUserInfo() {
        if (EWinInfo.UserInfo.WalletList != null) {
            if (EWinInfo.UserInfo.WalletList.length > 0) {
                for (var i = 0; i < EWinInfo.UserInfo.WalletList.length; i++) {
                    var temp = c.getTemplate("templateWalletInfo");
                    var w = EWinInfo.UserInfo.WalletList[i];

                    if (temp != null) {
                        temp.value = w.CurrencyType;
                        c.setClassText(temp, "currenyType", null, w.CurrencyType);
                        c.setClassText(temp, "currenyNum", null, BigNumber(w.PointValue).toFormat());

                        idWalletList.appendChild(temp);

                    }
                }
            } else {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("尚未開啟任一錢包"));
            }
        } else {
            window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("尚未開啟任一錢包"));
        }
    }
    
    function chkTextLength(el) {
        if (el.value.length > 20) {
            el.value = el.value.substring(0, 20);
        }
    }
    
    function init() {
        lang = window.localStorage.getItem("agent_lang");
        EWinInfo = window.parent.EWinInfo;
        api = window.parent.API_GetAgentAPI();

        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
            window.parent.API_CloseLoading();
            queryCurrentUserInfo();
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

                        <!-- 轉出金額 -->
                        <div class="Amount transferOut">
                            <div class="form-group">
                                <div class="form-control-underline form-input-icon">
                                    <input type="text" class="form-control" name="transferout" id="idTransOut" language_replace="placeholder" placeholder="轉出金額">
                                    <label for="transferout" class="form-label ico-before-coin"><span class="language_replace">轉出金額</span></label>
                                </div>
                            </div>

                        </div>

                        <!-- 轉入帳號 -->
                        <div class="Account transferIn">
                            <div class="form-group mb-0">
                                <div class="form-control-underline form-input-icon input-notice">
                                    <!-- 輸入驗證錯誤時，在 input 加入class => error -->
                                    <input id="idTransOutAccount" type="text" class="form-control" name="member" language_replace="placeholder" placeholder="轉入帳號">
                                    <label for="member" class="form-label ico-before-member"><span class="language_replace">轉入帳號</span></label>
                                    <!-- loading 動畫 -->
                                    <div class="icon-loading" style="display: none;">
                                        <div class="lds-dual-ring"></div>
                                    </div>
                                    <!-- 錯誤提示-->
                                    <div id="divNotice" class="notice error" style=""><i class="icon icon2020-information"></i><span class="language_replace">帳號輸入錯誤</span></div>

                                </div>
                            </div>
                        </div>

                        <!-- 轉入錢包 先不做-->
                        <div class="WalletType transferIn">
                        </div>

                        <!-- 錢包密碼 -->
                        <div class="Password">
                            <div class="form-group">
                                <div class="form-control-underline form-input-icon">
                                    <input type="password" class="form-control" name="member" id="idWalletPassword" language_replace="placeholder" placeholder="錢包密碼">
                                    <label for="password" class="form-label ico-before-lock"><span class="language_replace">錢包密碼</span></label>
                                </div>
                            </div>
                        </div>

                        <!-- 備註 -->
                        <div class="Remarks" style="display: none">
                            <div class="form-group">
                                <div class="form-control-underline input-notice form-input-icon">
                                    <textarea class="form-control control-notice" id="idDescription" rows="1" language_replace="placeholder" placeholder="備註" onkeyup="chkTextLength(this)"></textarea>
                                    <label for="" class="form-label ico-before-note"><span class="language_replace">加入備註</span></label>
                                    <div class="notice error"><i class="icon icon2020-information"></i><span class="language_replace">僅可輸入20字以內</span></div>
                                </div>
                            </div>
                        </div>

                        <div class="wrapper_center btn-group-lg">
                            <button tyep="button" class="btn btn-full-main" onclick="UserAccountTransfer()" id="btnSave"><i class="icon icon-before icon-ewin-input-transfer"></i><span class="language_replace">確認轉出</span></button>
                        </div>


                    </div>
                </section>

            </form>
        </div>
    </main>
</body>
</html>
