<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UserAccountWallet_Transfer.aspx.cs" Inherits="UserAccountWallet_Transfer" %>

<%
    string ASID = Request["ASID"];
    string AgentVersion = EWinWeb.AgentVersion;
    EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
    EWin.BmAgent.AgentSessionResult ASR = null;
    EWin.BmAgent.AgentSessionInfo ASI = null;

    ASR = api.GetAgentSessionByID(ASID);

    if (ASR.Result != EWin.BmAgent.enumResult.OK) {
        Response.Redirect("login.aspx");
    } else {
        ASI = ASR.AgentSessionInfo;
    }

%>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="ie=edge" />
    <title>傭金結算查詢</title>
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
<script src="js/jquery-3.3.1.min.js"></script>
<script>
    var ApiUrl = "UserAccountWallet_Transfer.aspx";
    var c = new common();
    var ac = new AgentCommon();
    var mlp;
    var EWinInfo;
    var api;
    var lang;

    function transfer() {
        let transOutVal = $("#idTransOut").val();
        let retValue = true;
        let wallet;
        let walletPoint = 0;
        wallet = EWinInfo.UserInfo.WalletList.find(x => x.CurrencyType.toLocaleUpperCase() == "PHP");

        if (wallet) {
            if (wallet.PointValue > 0) {
                walletPoint = wallet.PointValue;
            } else {
                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("轉帳金額不足!!"));
                retValue = false;
            }
        } else {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("無可用錢包!!"));
            retValue = false;
        }

        if (transOutVal == "") {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入轉出金額!!"));
            retValue = false;
        } else if (isNaN(transOutVal) == true) {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("轉出金額輸入錯誤!!"));
            retValue = false;
        } else if (parseInt(transOutVal) < 0) {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("轉出金額不可輸入負數!!"));
            retValue = false;
        } else if (parseInt(transOutVal) < 0) {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("轉出金額不可輸入負數!!"));
            retValue = false;
        } else if (parseInt(transOutVal) > walletPoint) {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("轉出金額超過可轉金額!!"));
            retValue = false;
        }

        if (retValue) {
            var postData = {
                AID: EWinInfo.ASID,
                CurrencyType: "PHP",
                TransOutValue: transOutVal
            };

            window.parent.API_ShowLoading();
            c.callService(ApiUrl + "/TransToGameAccount", postData, function (success, o) {
                if (success) {
                    var obj = c.getJSON(o);

                    if (obj.Result == 0) {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("轉帳完成"), mlp.getLanguageKey("轉帳完成"), function () {
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
    }

    function init() {
        EWinInfo = window.parent.EWinInfo;
        api = window.parent.API_GetAgentAPI();

        lang = window.localStorage.getItem("agent_lang");
        mlp = new multiLanguage();
        mlp.loadLanguage(lang, function () {
            window.parent.API_CloseLoading();
        });
    }

    window.onload = init;
</script>
<body class="innerBody bg_transfer">
    <main>
        <div class="container-fluid">
            <h1 class="page__title "><span class="language_replace">會員轉帳</span></h1>

            <form onsubmit="return false;">
                <section class="sectionWallet wallet__currency--transfer">
                    <div class="content">

                        <!-- 轉出金額 -->
                        <div class="Amount transferOut">
                            <div class="form-group">
                                <div class="form-control-underline form-input-icon">
                                    <input type="number" class="form-control" name="transferout" id="idTransOut" language_replace="placeholder" placeholder="轉出金額">
                                    <label for="transferout" class="form-label ico-before-coin"><span class="language_replace">轉出金額</span></label>
                                </div>
                            </div>
                        </div>

                        <!-- 錢包密碼 -->
                        <div class="Password" style="display: none">
                            <div class="form-group">
                                <div class="form-control-underline form-input-icon">
                                    <input type="password" class="form-control" name="member" id="idWalletPassword" language_replace="placeholder" placeholder="錢包密碼">
                                    <label for="password" class="form-label ico-before-lock"><span class="language_replace">錢包密碼</span></label>
                                </div>
                            </div>
                        </div>

                        <div class="wrapper_center btn-group-lg">
                            <button type="button" class="btn btn-full-main" onclick="transfer()"><i class="icon icon-before icon-ewin-input-transfer"></i><span class="language_replace">確認轉出</span></button>
                        </div>
                    </div>
                </section>

            </form>
        </div>
    </main>
</body>
</html>
