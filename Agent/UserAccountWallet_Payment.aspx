<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UserAccountWallet_Payment.aspx.cs" Inherits="UserAccountWallet_Payment" %>
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
    var ApiUrl = "UserAccountWallet_Payment.aspx";
    var toa = "<%=toa%>";
    var mlp;
    var lang;
    var EWinInfo;
    var processing = false;

    function closePage() {
        if (window.parent.windowList.length > 1) {
            window.parent.API_CloseWindow(true);
        }
        else {
            window.parent.API_MainWindow("Main", "home_Casino.aspx");
        }
    }

    function submitCheck() {
        var CurrencyType = idWalletList.options[idWalletList.selectedIndex].value;
        var TransOutValue = document.forms[0].idTransOut.value;
        window.parent.API_ShowMessageOK(mlp.getLanguageKey("確定要求提款"), mlp.getLanguageKey("將會預先從您的錢包保管額度並通知您的上線處理提款要求") + "<br>" + CurrencyType + " " + TransOutValue + "<br><br>" + mlp.getLanguageKey("是否確定進行?"), function () {
            submitForm();
        });
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
                    CurrencyType: CurrencyType,
                    Amount: Number(form.idTransOut.value),
                    Description: form.idDescription.value
                };
                processing = true;
                window.parent.API_ShowLoading("Sending");
                c.callService(ApiUrl + "/RequireWithdrawal", postObj, function (success, o) {
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
            if (cb)
                cb();
        }
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
                    // build wallet list
                    if (obj.WalletList != null) {
                        if (obj.WalletList.length > 0) {
                            for (var i = 0; i < obj.WalletList.length; i++) {
                                var temp = c.getTemplate("templateWalletInfo");
                                var w = obj.WalletList[i];
                                if (temp != null) {
                                    temp.value = w.CurrencyType;
                                    c.setClassText(temp, "currenyType", null, w.CurrencyType);
                                    c.setClassText(temp, "currenyNum", null, c.toCurrency(w.PointValue));

                                    idWalletList.appendChild(temp);

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
            queryCurrentUserInfo();
        });

        if (toa != "") {
            document.getElementById("idTransOutAccount").value = toa;
        }
    }

    window.onload = init;

</script>
<body class="innerBody ">
    <main>
        <div class="container-fluid">
            <h1 class="page__title "><span class="language_replace">出款申請</span></h1>

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

                        <!-- 轉出錢包 -->
                        <div class="WalletType transferOut">
                            <div  class="form-group">
                                <label class="title">
                                    <span class="language_replace">轉出錢包</span>
                                </label>
                                <select id="idWalletList" class="custom-select custom-select-lg">
                                </select>
                            </div>
                            <div id="templateWalletInfo" style="display:none">
                                <option class="language_replace optCurrenyType" value=""><span class="currenyType">CNY</span> <span class="currenyNum">0</span></option>
                            </div>

                        </div>

                        <!-- 轉出金額 -->
                        <div class="Amount transferOut">
                            <div class="form-group">
                                <div class="form-control-underline form-input-icon">
                                    <input type="text" class="form-control" name="transferout" id="idTransOut" language_replace="placeholder" placeholder="出款金額">
                                    <label for="transferout" class="form-label ico-before-coin"><span class="language_replace">出款金額</span></label>
                                </div>
                            </div>

                        </div>


                        <!-- 錢包密碼 -->
<%--                        <div class="Password">
                            <div class="form-group">
                                <div class="form-control-underline form-input-icon">
                                    <input type="password" class="form-control" name="member" id="idWalletPassword" language_replace="placeholder" placeholder="錢包密碼">
                                    <label for="password" class="form-label ico-before-lock"><span class="language_replace">錢包密碼</span></label>
                                </div>
                            </div>
                        </div>--%>

                        <!-- 備註 -->
                        <div class="Remarks">
                            <div class="form-group">
                                <div class="form-control-underline input-notice form-input-icon">
                                    <textarea class="form-control" id="idDescription" rows="1" language_replace="placeholder" placeholder="備註" onkeyup="chkTextLength(this)"></textarea>
                                    <label for="" class="form-label ico-before-note"><span class="language_replace">加入備註</span></label>
                                   <%-- <div class="notice error"><i class="icon icon2020-information"></i><span class="language_replace">僅可輸入20字以內</span></div>--%>
                                </div>
                            </div>
                        </div>

                        <div class="wrapper_center btn-group-lg">
                            <button tyep="button" class="btn btn-full-main" onclick="submitCheck()"><i class="icon icon-before icon-ewin-input-transfer"></i><span class="language_replace">確認轉出</span></button>
                        </div>


                    </div>
                </section>

            </form>
        </div>
    </main>
</body>
</html>
