<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UserAccountAgent_Maint.aspx.cs" Inherits="UserAccountAgent_Maint" %>
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
    <link rel="stylesheet" href="css/downline.css?<%:AgentVersion%>">
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
        var ApiUrl = "UserAccountAgent_Maint.aspx";
        var mlp;
        var EWinInfo;
        var api;
        var lang;
        var childList;


        function EditAccount(LoginAccount) {
            window.parent.API_NewWindow(mlp.getLanguageKey("助手編輯"), "UserAccountAgent_Edit.aspx?LoginAccount=" + LoginAccount);
        }

        function queryUserAccountAgent(cb) {
            var idUserList = document.getElementById("idUserList");
            var postObj;
            var hasNoData = true;

            c.clearChildren(idUserList);

            postObj = {
                AID: EWinInfo.ASID
            };

            c.callService(ApiUrl + "/QueryUserAccountAgentList", postObj, function (success, o) {
                if (success) {
                    var obj = c.getJSON(o);
                    if (obj.Result == 0) {
                        
                        // build child list
                        if (obj.UserAccountList != null) {
                            for (var i = 0; i < obj.UserAccountList.length; i++) {
                                var temp = c.getTemplate("templateTableItem");
                                var wtemp;
                                var ctemp;
                                var ChildUser = obj.UserAccountList[i];
                                var mtAgentPermission;
                                var mtAgentState;
                                var btnShow;

                                if (temp != null) {
                                    var btnEditUser = null;

                                    if (ChildUser.LoginAccount != "") {
                                        temp.classList.add(ChildUser.LoginAccount);
                                        c.setClassText(temp, "mtAgentLoignAccount", null, ChildUser.LoginAccount);

                                        mtAgentState = temp.getElementsByClassName("mtAgentState");
                                        if (mtAgentState) {
                                            switch (ChildUser.AgentLoginState) {
                                                case 0:
                                                    c.setClassText(temp, "mtAgentState", null, mlp.getLanguageKey("正常"));
                                                    mtAgentState[0].parentNode.classList.add("status-active");
                                                    break;
                                                case 1:
                                                    c.setClassText(temp, "mtAgentState", null, mlp.getLanguageKey("停用"));
                                                    mtAgentState[0].parentNode.classList.add("status-deactive");
                                                    break;
                                            }
                                        }

                                        mtAgentPermission = temp.getElementsByClassName("mtAgentPermission");
                                        if (mtAgentPermission) {
                                            switch (ChildUser.AgentPermission) {
                                                case 0:
                                                    c.setClassText(temp, "mtAgentPermission", null, mlp.getLanguageKey("管理者"));

                                                    break;
                                                case 1:
                                                    c.setClassText(temp, "mtAgentPermission", null, mlp.getLanguageKey("允許檢視"));

                                                    break;
                                                case 2:
                                                    c.setClassText(temp, "mtAgentPermission", null, mlp.getLanguageKey("允許檢視+轉帳"));

                                                    break;
                                            }
                                        }

                                        btnEditUser = c.getFirstClassElement(temp, "btnEditUser");
                                        btnEditUser.onclick = new Function("EditAccount('" + ChildUser.LoginAccount + "')");

                                        idUserList.appendChild(temp);
                                        hasNoData = false;
                                    }
                                   
                                }
                            }
                        }

                        idUserList.classList.remove("tbody__hasNoData");
                        //document.getElementById("idResultTable").classList.remove("MT_tableDiv__hasNoData");
                        if (hasNoData) {
                            var div = document.createElement("DIV");

                            div.innerHTML = mlp.getLanguageKey("無數據");
                            div.classList.add("td__content", "td__hasNoData");
                            //document.getElementById("idResultTable").classList.add("MT_tableDiv__hasNoData");
                            idUserList.classList.add("tbody__hasNoData");
                            idUserList.appendChild(div);
                        }
                    }
                    else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o.Message));

                        if (cb)
                            cb(false);
                    }

                }
                else {
                    if (o == "Timeout") {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後再嘗試"));
                    } else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o));
                    }

                    if (cb)
                        cb(false);
                }

                window.parent.API_CloseLoading();

            });


        }


        function showFnUserAccount(el) {
            var idFnUserAccount = document.getElementById("idFnUserAccount");
            var account;
            var personCode = el.getAttribute("PersonCode");
            var btnEditUser;
            var divLastLoginDate;
            var btnEditUserWallet;
            var btnTransfer;

            for (var i = 0; i < childList.length; i++) {
                if (childList[i].PersonCode == personCode) {
                    c.setClassText(idFnUserAccount, "account", null, childList[i].LoginAccount);
                    c.setClassText(idFnUserAccount, "createDate", null, childList[i].CreateDate);
                    c.setClassText(idFnUserAccount, "lastLoginDate", null, childList[i].LastLoginDate);
                    if (childList[i].LastLoginDate == "") {
                        divLastLoginDate = c.getFirstClassElement(idFnUserAccount, "divLastLoginDate");
                        divLastLoginDate.style.display = "none";
                    }

                    btnEditUser = c.getFirstClassElement(idFnUserAccount, "btnEditUser");
                    btnEditUser.onclick = new Function("EditAccount('" + personCode + "')");

                    btnEditUserWallet = c.getFirstClassElement(idFnUserAccount, "btnEditUserWallet");
                    btnEditUserWallet.onclick = new Function("EditAccount('" + personCode + "', '1')");

                    btnTransfer = c.getFirstClassElement(idFnUserAccount, "btnTransfer");
                    btnTransfer.onclick = new Function("Transfer('" + childList[i].LoginAccount + "')");
                }
            }

            ac.dataTogglePopup(el);
        }

    function showNote() {
        window.event.stopPropagation();
        window.parent.API_ShowMessageOK(mlp.getLanguageKey("提醒"),mlp.getLanguageKey("注意事項")
        );
    }

        function init() {
            EWinInfo = window.parent.EWinInfo;
            api = window.parent.API_GetAgentAPI();

            lang = window.localStorage.getItem("agent_lang");
            mlp = new multiLanguage();
            mlp.loadLanguage(lang, function () {
                queryUserAccountAgent();
            });
        }

        window.onload = init;

    </script>
<body class="innerBody">
    <main>
        <div class="container-fluid">
            <div class="collapse-box">
                <h2 class="collapse-header has-arrow zIndex_overMask_SafariFix">
                    <span class="language_replace">助手維護</span>
                    <btn style="font-size: 12px; right: 5px; position: absolute; border: 2px solid; width: 22px; text-align: center; border-radius: 11px; color: #bba480; cursor: pointer;" onclick="showNote()">!</btn>
                </h2>
            </div>

            <div class="MemberList MemberList__Assistant">
                <div id="idUserList" class="row">
                </div>

            </div>
        </div>
    </main>

    <div id="templateTableItem" style="display: none">
        <div class="col-12 col-md-6 col-xl-4">
            <div class="item">
                <div class="downline__overview">
                    <div class="downline__header">
                        <span class="downline__account mtAgentLoignAccount">--</span>
                        <div class="function-execute">
                            <span class="downline__enterance downline-link btnEditUser">
                                <a class="" href=""><i class="icon icon2020-pencil-1"></i><span class="language_replace">編輯</span></a>
                            </span>
                        </div>
                    </div>
                    <div class="downline__info">
                        <div class="name "><span class="language_replace mtAgentPermission">權限</span></div>
                        <!-- 帳戶啟用 狀態加入 class="status-active" -->
                        <div class="downline__accountStatus"><span class="language_replace mtAgentState">啟用</span></div>
                    </div>

                </div>
            </div>
        </div>
    </div>

</body>
</html>
