<%@ Page Language="C#" %>
<%
    string Token;
    int RValue;
    Random R = new Random();
    EWin.Login.GeoClass GC;
    EWin.Login.LoginAPI API = new EWin.Login.LoginAPI();
    EWin.Login.LoginResult Ret;
    string UserIP = CodingControl.GetUserIP();
    string LoginGUID;
    string Bulletin = string.Empty;
    string Lang;
    MultiLanguageParser MLP;
    bool IsChina = false;
    string FileData= string.Empty;
    string isModify = "0";
    string[] stringSeparators = new string[] { "&&_" };
    string[] Separators;


    //try { 
    //    if (System.IO.File.Exists(Server.MapPath("/App_Data/Bulletin.txt"))) {
    //        FileData = System.IO.File.ReadAllText(Server.MapPath("/App_Data/Bulletin.txt"));
    //        if (string.IsNullOrEmpty(FileData) == false) {
    //            Separators = FileData.Split(stringSeparators,StringSplitOptions.None);
    //            Bulletin = Separators[0];
    //            Bulletin = Bulletin.Replace("\r", "<br />").Replace("\n", string.Empty);
    //            if (Separators.Length >1) {
    //                isModify = Separators[1];
    //            }

    //            if (isModify == "1") {
    //                string userLang = CodingControl.GetDefaultLanguage();

    //                if (userLang.ToUpper() == "zh-TW".ToUpper()) { Lang = "CHT"; }
    //                else if (userLang.ToUpper() == "zh-HK".ToUpper()) { Lang = "CHT"; }
    //                else if (userLang.ToUpper() == "zh-MO".ToUpper()) { Lang = "CHT"; }
    //                else if (userLang.ToUpper() == "zh-CHT".ToUpper()) { Lang = "CHT"; }
    //                else if (userLang.ToUpper() == "zh-CHS".ToUpper()) { Lang = "CHS"; }
    //                else if (userLang.ToUpper() == "zh-SG".ToUpper()) { Lang = "CHS"; }
    //                else if (userLang.ToUpper() == "zh-CN".ToUpper()) { Lang = "CHS"; }
    //                else if (userLang.ToUpper() == "zh".ToUpper()) { Lang = "CHS"; }
    //                else if (userLang.ToUpper() == "en-US".ToUpper()) { Lang = "ENG"; }
    //                else if (userLang.ToUpper() == "en-CA".ToUpper()) { Lang = "ENG"; }
    //                else if (userLang.ToUpper() == "en-PH".ToUpper()) { Lang = "ENG"; }
    //                else if (userLang.ToUpper() == "en".ToUpper()) { Lang = "ENG"; }
    //                else if (userLang.ToUpper() == "ko-KR".ToUpper()) { Lang = "KOR"; }
    //                else if (userLang.ToUpper() == "ko-KP".ToUpper()) { Lang = "KOR"; }
    //                else if (userLang.ToUpper() == "ko".ToUpper()) { Lang = "KOR"; }
    //                else if (userLang.ToUpper() == "ja".ToUpper()) { Lang = "JPN"; }
    //                else { Lang = "ENG"; }

    //                Response.Redirect("maintenance.html?lang=" + Lang);
    //            }
    //        }
    //    }
    //}
    //catch (Exception ex) {};

    GC = API.GetGeoCode(UserIP);

    if (GC != null)
    {
        if ((GC.GeoCountry == "TW") && (UserIP != "112.121.69.46"))
        {
            //Response.Redirect("IPDenied.html");
            //Response.Flush();
            //Response.End();
        }
        else if (GC.GeoCountry == "CN")
        {
            IsChina = true;
        }
        //Response.Write(GC.GeoCountry)
    }

    IsChina = false;
    
    Token = EWinWeb.GetToken();

    if (CodingControl.FormSubmit())
    {
        string LoginAccount = Request["LoginAccount"];
        string LoginPassword = Request["LoginPassword"];
        string ImageCode = Request["ImageCode"];
        string GuestLogin = Request["GuestLogin"];
        string CT;

        Lang = Request["Lang"];
        LoginGUID = Request["LoginGUID"];
        MLP = new MultiLanguageParser(Lang);

        if (GuestLogin != "1")
        {
            if ((LoginAccount != string.Empty) && (LoginAccount != null))
            {
                if ((LoginPassword != string.Empty) && (LoginPassword != null))
                {
                    if ((ImageCode != string.Empty) && (ImageCode != null))
                    {
                        Ret = API.UserLogin(Token, LoginGUID, LoginAccount, LoginPassword, EWinWeb.CompanyCode, ImageCode, CodingControl.GetUserIP());
                        if (Ret.ResultState == EWin.Login.enumResultState.OK)
                        {
                            CT = Ret.CT;

                            if (IsChina == true)
                                Response.Redirect(EWinWeb.EWinUrl + ":1443"  + "/Game/Login.aspx?CT=" + Server.UrlEncode(CT) + "&Lang=" + Lang + "&Action=Game");
                            else
                                Response.Redirect(EWinWeb.EWinUrl + "/Game/Login.aspx?CT=" + Server.UrlEncode(CT) + "&Lang=" + Lang + "&Action=Game");
                        }
                        else
                        {
                            EWinWeb.AlertMessage(MLP.GetLanguageKey("Login failure:") + MLP.GetLanguageKey(Ret.Message), "/Refresh.aspx?index.aspx");
                        }
                    }
                    else
                    {
                        EWinWeb.AlertMessage(MLP.GetLanguageKey("invalid image validate code"), "/Refresh.aspx?index.aspx");
                    }
                }
                else
                {
                    EWinWeb.AlertMessage(MLP.GetLanguageKey("invalid login password"), "/Refresh.aspx?index.aspx");
                }
            }
            else
            {
                EWinWeb.AlertMessage(MLP.GetLanguageKey("invalid login account"), "/Refresh.aspx?index.aspx");
            }
        }
        else
        {
            // 訪客登入
            if ((ImageCode != string.Empty) && (ImageCode != null))
            {
                if (IsChina == true)
                    Response.Redirect("https://cngame.ewin-soft.com:1443/Game/LoginGuest.aspx?Lang=" + Lang + "&LoginGUID=" + LoginGUID + "&ImageCode=" + ImageCode + "&Action=Game");
                else
                    Response.Redirect("https://game.ewin-soft.com/Game/LoginGuest.aspx?Lang=" + Lang + "&LoginGUID=" + LoginGUID + "&ImageCode=" + ImageCode + "&Action=Game");
            }
            else
            {
                EWinWeb.AlertMessage(MLP.GetLanguageKey("invalid image validate code"), "/Refresh.aspx?index.aspx");
            }
        }
    }

    LoginGUID = API.CreateLoginGUID(Token);

    if (string.IsNullOrEmpty(Request["Lang"]))
    {
        string userLang = CodingControl.GetDefaultLanguage();

        if (userLang.ToUpper() == "zh-TW".ToUpper()) { Lang = "CHT"; }
        else if (userLang.ToUpper() == "zh-HK".ToUpper()) { Lang = "CHT"; }
        else if (userLang.ToUpper() == "zh-MO".ToUpper()) { Lang = "CHT"; }
        else if (userLang.ToUpper() == "zh-CHT".ToUpper()) { Lang = "CHT"; }
        else if (userLang.ToUpper() == "zh-CHS".ToUpper()) { Lang = "CHS"; }
        else if (userLang.ToUpper() == "zh-SG".ToUpper()) { Lang = "CHS"; }
        else if (userLang.ToUpper() == "zh-CN".ToUpper()) { Lang = "CHS"; }
        else if (userLang.ToUpper() == "zh".ToUpper()) { Lang = "CHS"; }
        else if (userLang.ToUpper() == "en-US".ToUpper()) { Lang = "ENG"; }
        else if (userLang.ToUpper() == "en-CA".ToUpper()) { Lang = "ENG"; }
        else if (userLang.ToUpper() == "en-PH".ToUpper()) { Lang = "ENG"; }
        else if (userLang.ToUpper() == "en".ToUpper()) { Lang = "ENG"; }
        else if (userLang.ToUpper() == "ko-KR".ToUpper()) { Lang = "KOR"; }
        else if (userLang.ToUpper() == "ko-KP".ToUpper()) { Lang = "KOR"; }
        else if (userLang.ToUpper() == "ko".ToUpper()) { Lang = "KOR"; }
        else if (userLang.ToUpper() == "ja".ToUpper()) { Lang = "JPN"; }
        else { Lang = "ENG"; }
    }
    else
    {
        Lang = Request["Lang"];
    }
%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>BM VIP CLUB</title>
    <meta name="viewport" content="width=device-width, initial-scale=1,user-scalable=yes">
    <link rel="shortcut icon" href="images/ico.png" />
    <link rel="Bookmark" href="images/ico.png" />
    <link rel="apple-touch-icon-precomposed" sizes="144x144" href="images/App_144.png">
    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="images/App_144.png">
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="images/App_72.png">
    <link rel="apple-touch-icon-precomposed" href="images/App_72.png">
    <link rel="stylesheet" href="css/reset.css">
    <link rel="stylesheet" href="css/css.css">
    <link rel="stylesheet" href="css/iconfont.css">
    <link href="https://fonts.googleapis.com/css?family=Amiri|Open+Sans" rel="stylesheet">
    <!-- banner -->
    <link rel="stylesheet" href="css/flexslider.css" type="text/css" media="screen" />
    <link rel="stylesheet" href="css/magnific-popup.css">
    <link rel="stylesheet" href="css/magnific.css">
	<!--  script         -->
	<script type="text/javascript">
		function codepopup() {
		    var codeDivPopUp = document.getElementById("codeDiv");
		    var loginDivHidden = document.getElementById("loginDiv");
            codeDivPopUp.classList.add("codeDivPopUp");
            loginDivHidden.classList.add("loginDivHidden");
		}
		function codeHidden() {
		    var codeDivPopUp = document.getElementById("codeDiv");
		    var loginDivHidden = document.getElementById("loginDiv");
            codeDivPopUp.classList.remove("codeDivPopUp");
            loginDivHidden.classList.remove("loginDivHidden");
		}	
	</script>	


</head>
<script language="javascript" src="Scripts/MultiLanguage.js"></script>
<script language="javascript" src="Scripts/Math.uuid.js"></script>
<script language="javascript" src="Scripts/qcode-decoder.min.js"></script>
<script language="javascript">
    var mlp;
    var Lang = "<%=Lang%>";
    var qr = new QCodeDecoder();
    var hasBulletin = <%=(string.IsNullOrEmpty(Bulletin) ? "false" : "true")%>;

    function QRScan(el) {
        var QRCodeResult = document.getElementById("QRCodeResult");

        QRCodeResult.innerHTML = "";

        if (el.files != null) {
            if (el.files.length > 0) {
                var fr = new FileReader();
                var userImageFile = el.files[0];

                fr.onload = function () {
                    //alert(fr.result);
                    setTimeout(function () {
                        qr.decodeFromImage(fr.result, function (err, res) {
                            if (err) {
                                QRCodeResult.innerHTML = "No QR code found!";
                            } else {
                            if (res != null) {
                                if (res.length > 4) {
                                    if (res.substr(0, 4) == "http") {
                                        window.location.href = res;
                                    }
                                }
                            }
                            }
                        });
                    }, 500);
                    
                    //alert(fr.result);
                }

                //alert(userImageFile);
                fr.readAsDataURL(userImageFile);
            }
        }
    }

    function btnLoginGuest() {
        document.forms[0].GuestLogin.value = "1";
        createValidateImage();
        codepopup();
    }

    function btnLogin() {
        document.forms[0].GuestLogin.value = "0";
        createValidateImage();
        codepopup();
    }

    function createValidateImage() {
        var iGUID;
        var iURL;
        var ValidateImage = document.getElementById("ValidateImage");

        iGUID = "<%=LoginGUID%>";
        document.forms[0].LoginGUID.value = iGUID;

        iURL = "ValidateImage.aspx?LoginGUID=" + iGUID;

        ValidateImage.src = iURL;
        ValidateImage.style.display = "inline";
    }

    function setLanguage(c, cb) {
        Lang = c;

        window.localStorage.setItem("Lang", Lang);
        document.forms[0].Lang.value = Lang;

        mlp.loadLanguage(Lang, function () {
            if (cb)
                cb();
        });

    }

    function init() {
        if (window.localStorage.getItem("Lang") != null) {
            Lang = window.localStorage.getItem("Lang");
        }

        if ((Lang == "") || (Lang == null)) {
            Lang = "ENG";
        }

        mlp = new multiLanguage();
        setLanguage(Lang, function() {
            //createValidateImage();
        });
    }

    window.onload = init;
</script>
<style type="text/css">
	.downloadBtn{
		vertical-align: middle;
		text-align: center;
		color: #fff;
		width: 100%;
	}
	/*.downloadBtn a{
		display: block;
		width: 90%;
		line-height: 55px;
		background:  linear-gradient(to top, #eae0bc 0%, #dec284 27%, #debf7a 52%, #d5b66d 92%, #eae0bc 100%);
		border: 1px #aa822d solid;
		vertical-align: middle;
		color: #5a4415;
		border-radius: 10px;
		margin: 10px auto;
		box-shadow: 0px 0px 8px 2px rgba(0,0,0,0.5);
		margin-top: 10px;
	}*/
	.downloadBtn a{
		display: block;
		width: 90%;
		line-height: 55px;
		background:  linear-gradient(to top, #eae0bc 0%, #dec284 27%, #debf7a 52%, #d5b66d 92%, #eae0bc 100%);
		border: 1px #aa822d solid;
		vertical-align: middle;
		color: #5a4415;
		border-radius: 10px;
		margin: 10px auto;
		box-shadow: 0px 0px 8px 2px rgba(0,0,0,0.5);
		margin-top: 10px;
	}
	.downloadBtn a:hover{
	  margin-top: 10px;
	}
	.downloadBtn img{
		position: relative;
		top:-2px;
		width: auto;
		height: 25px;
		vertical-align: middle;
		opacity: 0.8;
		margin-right: 8px;
	}
	.downloadBtn img:first-child{
		width: 28px;
		height: 28px;
		margin-right: 2px;
	}
	.downloadBtn img:last-child{
		
	}

	.width-wrap__qrcodebox{
		max-width: 280px !important;
	}
	@media only screen and (max-width: 640px){
		.width-wrap .width-wrap__qrcodebox{
			bottom: -4vw;
		}
	}

</style>	
<body>
    <!--logo action-->
    <!--<div class="logo-action">
        <div class="action-box">
            <svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
                 viewBox="0 0 800 800" style="enable-background:new 0 0 800 800;" xml:space="preserve" class="logo">
            <style type="text/css">
                .st0 {
                    fill: url(#SVGID_1_);
                }

                .st1 {
                    fill: url(#SVGID_2_);
                }

                .st2 {
                    fill: url(#SVGID_3_);
                }

                .st3 {
                    fill: url(#SVGID_4_);
                }

                .st4 {
                    fill: url(#SVGID_5_);
                }

                .st5 {
                    fill: url(#SVGID_6_);
                }

                .st6 {
                    fill: url(#SVGID_7_);
                }

                .st7 {
                    fill: url(#SVGID_8_);
                }

                .st8 {
                    fill: url(#SVGID_9_);
                }

                .st9 {
                    opacity: 0.9;
                    fill: url(#SVGID_10_);
                    enable-background: new;
                }

                .st10 {
                    fill: url(#SVGID_11_);
                }

                .st11 {
                    fill: url(#SVGID_12_);
                }

                .st12 {
                    fill: url(#SVGID_13_);
                }

                .st13 {
                    fill: url(#SVGID_14_);
                }
</style>
            <g id="layer4">
            <linearGradient id="SVGID_1_" gradientUnits="userSpaceOnUse" x1="158.5071" y1="685.8101" x2="210.3675" y2="655.8685">
            <stop offset="0.1064" style="stop-color:#FEDD29" />
            <stop offset="1" style="stop-color:#FFFFBF" />
					</linearGradient>
            <path class="st0" d="M218.4,689.7h-14.8l-3.9-11.2h-20.6l-3.9,11.2h-14.5l20.5-55.6h16.5L218.4,689.7z M196.2,668.3l-6.8-19.9
								l-6.8,19.9H196.2z" />
            <linearGradient id="SVGID_2_" gradientUnits="userSpaceOnUse" x1="218.6601" y1="678.3726" x2="274.1349" y2="646.3443">
            <stop offset="0.1064" style="stop-color:#FEDD29" />
            <stop offset="1" style="stop-color:#FFFFBF" />
					</linearGradient>
            <path class="st1" d="M270.9,672.3c0,5.5-2.3,9.9-7,13.4s-10.9,5.1-18.9,5.1c-4.6,0-8.6-0.4-12-1.2c-3.4-0.8-6.6-1.8-9.6-3.1v-13.3
								h1.6c3,2.4,6.3,4.2,10,5.5c3.7,1.3,7.2,1.9,10.6,1.9c0.9,0,2-0.1,3.4-0.2c1.4-0.1,2.6-0.4,3.5-0.7c1.1-0.4,2-1,2.7-1.7
								s1.1-1.7,1.1-3c0-1.2-0.5-2.3-1.5-3.2c-1-0.9-2.5-1.6-4.5-2c-2.1-0.5-4.3-1-6.6-1.4c-2.3-0.4-4.5-1-6.6-1.7
								c-4.7-1.5-8-3.6-10.1-6.2c-2.1-2.6-3.1-5.8-3.1-9.7c0-5.2,2.3-9.4,7-12.7c4.6-3.3,10.6-4.9,17.9-4.9c3.7,0,7.3,0.4,10.8,1.1
								c3.6,0.7,6.7,1.6,9.3,2.7v12.8h-1.5c-2.2-1.8-5-3.3-8.2-4.5c-3.2-1.2-6.6-1.8-10-1.8c-1.2,0-2.4,0.1-3.6,0.2
								c-1.2,0.2-2.3,0.5-3.4,0.9c-1,0.4-1.8,0.9-2.5,1.7c-0.7,0.8-1,1.6-1,2.6c0,1.5,0.6,2.6,1.7,3.4c1.1,0.8,3.2,1.5,6.3,2.1
								c2,0.4,4,0.8,5.9,1.2c1.9,0.4,3.9,0.9,6.1,1.6c4.3,1.4,7.4,3.3,9.4,5.7C269.9,665.3,270.9,668.4,270.9,672.3z" />
            <linearGradient id="SVGID_3_" gradientUnits="userSpaceOnUse" x1="270.219" y1="675.9463" x2="318.7182" y2="647.9452">
            <stop offset="0.1064" style="stop-color:#FEDD29" />
            <stop offset="1" style="stop-color:#FFFFBF" />
					</linearGradient>
            <path class="st2" d="M310.8,689.7h-32.6v-9.9h9.1V644h-9.1v-9.9h32.6v9.9h-9.1v35.9h9.1V689.7z" />
            <linearGradient id="SVGID_4_" gradientUnits="userSpaceOnUse" x1="313.9661" y1="685.8101" x2="365.8264" y2="655.8685">
            <stop offset="0.1064" style="stop-color:#FEDD29" />
            <stop offset="1" style="stop-color:#FFFFBF" />
					</linearGradient>
            <path class="st3" d="M373.8,689.7H359l-3.9-11.2h-20.6l-3.9,11.2h-14.5l20.5-55.6h16.5L373.8,689.7z M351.7,668.3l-6.8-19.9
								l-6.8,19.9H351.7z" />
            <linearGradient id="SVGID_5_" gradientUnits="userSpaceOnUse" x1="408.8513" y1="678.4091" x2="462.3976" y2="647.4941">
            <stop offset="0.1064" style="stop-color:#FEDD29" />
            <stop offset="1" style="stop-color:#FFFFBF" />
					</linearGradient>
            <path class="st4" d="M457.1,686.6c-2.5,1-5.8,1.9-9.9,2.9c-4.1,1-8.2,1.4-12.3,1.4c-9.5,0-16.9-2.6-22.2-7.7s-8-12.2-8-21.3
								c0-8.6,2.7-15.6,8.1-20.9c5.4-5.3,12.9-7.9,22.6-7.9c3.7,0,7.1,0.3,10.5,1c3.3,0.7,7,2,11.1,3.9v13h-1.6c-0.7-0.5-1.7-1.3-3.1-2.2
								c-1.3-1-2.6-1.8-3.9-2.4c-1.4-0.8-3.1-1.5-5.1-2.1c-1.9-0.6-4-0.9-6.1-0.9c-2.5,0-4.8,0.4-6.9,1.1c-2.1,0.7-3.9,1.9-5.6,3.4
								c-1.6,1.5-2.8,3.4-3.7,5.7c-0.9,2.3-1.4,5-1.4,8c0,6.1,1.6,10.9,4.9,14.1c3.3,3.3,8.1,4.9,14.5,4.9c0.5,0,1.2,0,1.8,0
								c0.7,0,1.3-0.1,1.8-0.1v-10.9h-11.1v-10.5h25.7V686.6z" />
            <linearGradient id="SVGID_6_" gradientUnits="userSpaceOnUse" x1="469.7848" y1="676.7203" x2="520.9984" y2="647.1522">
            <stop offset="0.1064" style="stop-color:#FEDD29" />
            <stop offset="1" style="stop-color:#FFFFBF" />
				</linearGradient>
            <path class="st5" d="M524.1,662c0,8.9-2.5,15.9-7.6,21.1c-5.1,5.2-12.1,7.8-21.1,7.8c-8.9,0-15.9-2.6-21-7.8
								c-5.1-5.2-7.6-12.3-7.6-21.1c0-8.9,2.5-16,7.6-21.2c5.1-5.2,12.1-7.8,21-7.8c8.9,0,15.9,2.6,21,7.8C521.5,646,524.1,653,524.1,662z
								 M505,676c1.4-1.7,2.4-3.7,3.1-6s1-5,1-8.1c0-3.3-0.4-6.2-1.2-8.5c-0.8-2.3-1.8-4.2-3-5.7c-1.3-1.5-2.7-2.6-4.4-3.2
								c-1.7-0.7-3.4-1-5.2-1c-1.8,0-3.5,0.3-5.1,1c-1.6,0.6-3.1,1.7-4.4,3.2c-1.2,1.4-2.3,3.3-3,5.8c-0.8,2.5-1.2,5.3-1.2,8.5
								c0,3.3,0.4,6.1,1.1,8.5c0.8,2.3,1.8,4.2,3,5.7c1.2,1.5,2.7,2.6,4.4,3.2c1.7,0.7,3.4,1,5.3,1c1.8,0,3.6-0.4,5.3-1.1
								C502.3,678.6,503.8,677.5,505,676z" />
            <linearGradient id="SVGID_7_" gradientUnits="userSpaceOnUse" x1="527.9691" y1="677.5795" x2="562.801" y2="657.4693">
            <stop offset="0.1064" style="stop-color:#FEDD29" />
            <stop offset="1" style="stop-color:#FFFFBF" />
					</linearGradient>
            <path class="st6" d="M575.1,689.7H535v-55.6h14.3V679h25.8V689.7z" />
            <linearGradient id="SVGID_8_" gradientUnits="userSpaceOnUse" x1="575.7406" y1="675.9136" x2="630.758" y2="644.1493">
            <stop offset="0.1064" style="stop-color:#FEDD29" />
            <stop offset="1" style="stop-color:#FFFFBF" />
					</linearGradient>
            <path class="st7" d="M636.3,662c0,5.2-1.2,9.8-3.5,13.9c-2.4,4.1-5.4,7.2-9,9.4c-2.7,1.6-5.7,2.8-8.9,3.4c-3.2,0.6-7.1,1-11.5,1
								h-19.6v-55.6h20.2c4.5,0,8.4,0.4,11.7,1.1s6,1.8,8.3,3.2c3.8,2.3,6.9,5.5,9.1,9.5S636.3,656.6,636.3,662z M621.4,661.9
								c0-3.7-0.7-6.8-2-9.4s-3.4-4.6-6.3-6.1c-1.5-0.7-3-1.2-4.5-1.5s-3.8-0.4-6.9-0.4h-3.6v34.8h3.6c3.4,0,5.9-0.2,7.5-0.5
								c1.6-0.3,3.1-0.9,4.7-1.7c2.6-1.5,4.5-3.5,5.8-6S621.4,665.6,621.4,661.9z" />
			</g>
            <g id="layer3">

            <radialGradient id="SVGID_9_" cx="399.8" cy="449.9745" r="241" gradientTransform="matrix(1 0 0 -1 0 800.0698)"
                            gradientUnits="userSpaceOnUse">
            <stop offset="0.8511" style="stop-color:#FFFF7E" />
            <stop offset="0.9202" style="stop-color:#E9A900" />
            <stop offset="0.9947" style="stop-color:#FFFF7E" />
					</radialGradient>
            <path class="st8" d="M399.8,109.1c-133.1,0-241,107.9-241,241s107.9,241,241,241s241-107.9,241-241S532.9,109.1,399.8,109.1z
								 M399.8,552.6c-111.8,0-202.5-90.7-202.5-202.5s90.6-202.5,202.5-202.5s202.5,90.7,202.5,202.5S511.6,552.6,399.8,552.6z" />
				</g>
            <g id="layer2">

            <linearGradient id="SVGID_10_" gradientUnits="userSpaceOnUse" x1="236.3125" y1="286.4871" x2="563.2687" y2="613.4433"
                            gradientTransform="matrix(1 0 0 -1 0 800.0698)">
            <stop offset="0" style="stop-color:#A4883B" />
            <stop offset="1" style="stop-color:#876D18" />
					</linearGradient>
            <path class="st9" d="M399.8,118.9c-127.7,0-231.2,103.5-231.2,231.2s103.5,231.2,231.2,231.2S631,477.8,631,350.1
								S527.4,118.9,399.8,118.9z M469.2,547.6l-26.9-15.5l26.1-15c10,5.8,20.1,11.6,30.4,17.5C489.3,539.6,479.4,544,469.2,547.6z
								 M300,534.2c10.6-6.1,21-12.1,31.1-18l27.5,15.9l-27.4,15.8C320.4,544.2,310,539.6,300,534.2z M262.5,508.1v-29.8l28,16.2v34.2
								C280.6,522.6,271.2,515.7,262.5,508.1z M190.6,356.9c10.4,6,20.7,12,30.9,17.8v33.1l-26.8-15.4C192.4,380.9,191,369,190.6,356.9z
								 M233.3,371.7l22.7-13.1v26.2L233.3,371.7z M250.4,391.4l-22.9,13.3v-26.5C235.2,382.7,242.8,387.1,250.4,391.4z M227.5,368.1
								v-32.6l28.3,16.2L227.5,368.1z M231.2,330.6c8.4-4.8,16.7-9.6,24.8-14.3V345L231.2,330.6z M227,324.2v-29l25.1,14.5L227,324.2z
								 M227.5,418.3l22.6,13.1l-22.6,13V418.3z M230.4,409.9l26-15c0,0,0,0,0.1,0v30L230.4,409.9z M229.5,289.7l27-15.6v31.2L229.5,289.7
								z M227,284.2v-28.7l24.8,14.3L227,284.2z M232.9,248.6l23.6-13.6v27.2L232.9,248.6z M227.5,244.8v-13.5c2.8-4,5.7-8,8.8-11.8
								l17.6,10.1L227.5,244.8z M221,252.1v32.8l-16.7-9.6c3.4-8.9,7.4-17.5,12-25.8L221,252.1z M220.8,241.6c0.2-0.4,0.5-0.8,0.7-1.2v1.6
								L220.8,241.6z M221.5,336.2v28.7l-24.9-14.4C205,345.7,213.3,340.9,221.5,336.2z M217.5,289.7L196,302.1c1.7-7.2,3.8-14.3,6.2-21.2
								L217.5,289.7z M194.3,310l26.7-15.4v33.1l-30.5,17.6C190.8,333.3,192.1,321.5,194.3,310z M215.7,411.5l-13.5,7.8
								c-2.2-6.2-4-12.5-5.6-18.9L215.7,411.5z M221.5,415.1v32.8l-5.2,3c-4.6-8.3-8.6-16.9-12-25.9L221.5,415.1z M224.6,456.5l26.1,15.1
								l-14.9,8.6c-5.4-6.8-10.4-14-15-21.5L224.6,456.5z M230.6,453l25.9-15v29.9L230.6,453z M500.5,166.6v0.9
								c-10.6,6.1-21.1,12.2-31.4,18.1l-27.7-16l28.8-16.6C480.7,156.8,490.8,161.3,500.5,166.6z M576,284.3v-30.7l7.2-4.2
								c4.3,7.8,8.1,15.8,11.4,24.2L576,284.3z M596.7,279.2c2.9,8,5.3,16.2,7.2,24.6L579,289.4L596.7,279.2z M576.5,242.9V238
								c0.8,1.2,1.5,2.4,2.3,3.6L576.5,242.9z M570.5,417.7v25.8l-22.4-12.9L570.5,417.7z M540.5,425.5v-30l0,0l26,15L540.5,425.5z
								 M546.6,392c7.9-4.5,15.9-9.1,23.9-13.8v27.6L546.6,392z M570.2,367.9l-28.5-16.5l28.8-16.6v32.9L570.2,367.9z M567,289.5
								l-26.5,15.3v-30.6L567,289.5z M546.4,270.6L570,257v27.2L546.4,270.6z M570,294.7v29.6l-25.6-14.8L570,294.7z M565.7,330.7
								L540,345.5v-29.7C548.4,320.7,557,325.7,565.7,330.7z M543.5,229.7l19.2-11.1c2.7,3.4,5.4,6.8,7.9,10.4v16.3L543.5,229.7z
								 M565.4,249.3l-24.9,14.4V235L565.4,249.3z M529.7,351.5l-22.2,12.8v-25.7L529.7,351.5z M507.5,331.7V297
								c8.7,5.1,17.5,10.2,26.5,15.3v34.6L507.5,331.7z M534,355.9v35.2c-8.9,5.2-17.8,10.2-26.5,15.3v-35.2L534,355.9z M509.1,450.6
								l25.4-14.7v29.4L509.1,450.6z M534.3,472.1l-26.8,15.5v-31L534.3,472.1z M507.5,444.6v-27.1l23.4,13.5L507.5,444.6z M513.9,410.8
								c6.8-3.9,13.7-7.9,20.6-11.9v23.8L513.9,410.8z M511.3,290.9l23.2-13.4v26.8L511.3,290.9z M507.5,282.7v-32.2l27-15.6v32.2
								L507.5,282.7z M507.5,243.6v-27.7l24,13.8L507.5,243.6z M507.5,209v-37.5c0.3-0.1,0.5-0.3,0.8-0.4c9.2,5.6,18,11.9,26.2,18.9v34.6
								L507.5,209z M472.5,225.1v-33.4c9.2-5.3,18.5-10.7,28-16.1V209L472.5,225.1z M500.5,215.9V243L477,229.5L500.5,215.9z M500.5,249.9
								V283l-28-16.2v-33.1L500.5,249.9z M495.1,289.9l-22.6,13v-26.2C480,281.1,487.5,285.4,495.1,289.9z M500.5,297.2v35.1l-27.7,16
								l-0.8-0.4v-34.2L500.5,297.2z M500.5,339.2v25.1l-21.7-12.6L500.5,339.2z M472.8,355.2l27.7,16v31.9L472,386.6v-31L472.8,355.2z
								 M500.5,457.2V487l-25.8-14.9L500.5,457.2z M472.5,466.4v-31.7l27.4,15.8L472.5,466.4z M478.4,431.3c7.3-4.2,14.7-8.5,22.1-12.7
								v25.5L478.4,431.3z M472.5,426.6v-29.3l25.4,14.7C489.4,416.9,480.9,421.8,472.5,426.6z M472.5,477.8l28,16.2v33.6
								c-9.4-5.5-18.8-10.8-28-16.2V477.8z M403.3,184.7v-30.2l26.2,15.1L403.3,184.7z M432.5,174.8v29.7l-25.7-14.8L432.5,174.8z
								 M428.4,209c-8.5,4.9-16.9,9.7-25.2,14.5v-29L428.4,209z M432.5,214.8v30.7c-8.8-5.1-17.6-10.2-26.6-15.4
								C414.7,225,423.5,219.9,432.5,214.8z M432,253.3v32.2l-28.7-16.6v-32.2C412.9,242.2,422.5,247.8,432,253.3z M432.5,336.4v27.4
								l-23.7-13.7L432.5,336.4z M427.5,289.7l-24.2,14v-27.9L427.5,289.7z M432,294.1v32.3L403.3,343v-32.3L432,294.1z M432.5,374.2v33.3
								l-0.8,0.4l-28.5-16.4v-34.2L432.5,374.2z M425.7,411.5l-22.5,13v-25.9L425.7,411.5z M431.7,414.9l0.8,0.4v34.4
								c-9.7,5.6-19.4,11.2-29.2,16.9v-35.2L431.7,414.9z M405.1,510.6l26-15c0.5,0.3,0.9,0.5,1.4,0.8v30.1L405.1,510.6z M430.3,532.1
								l-27,15.6v-31.2L430.3,532.1z M403.3,504.7v-25.2c7.2,4.2,14.5,8.4,21.8,12.6L403.3,504.7z M432.1,488.1
								c-8.8-5.1-17.5-10.1-26.1-15c9.8-5.6,19.5-11.2,29.1-16.8l26.1,15L432.1,488.1z M445.2,371.1l20.8-12v24L445.2,371.1z M461.4,390.9
								l-22.9,13.2v-26.4L461.4,390.9z M439.2,367.7l-0.7-0.4v-31.9l27.5,15.9v0.9L439.2,367.7z M442.4,330.7l23.6-13.6v27.3L442.4,330.7z
								 M438,322.8v-27l23.4,13.5L438,322.8z M462.2,432.5c-4.5,2.6-9,5.2-13.5,7.8c-3.4,2-6.8,3.9-10.3,5.9v-27.4L462.2,432.5z
								 M438.5,499.8c7.9,4.5,15.8,9.1,23.9,13.8l-23.9,13.8V499.8z M439.6,492.4l26.9-15.5V508C457.4,502.7,448.5,497.5,439.6,492.4z
								 M441.2,452.7c3.7-2.1,7.4-4.3,11.1-6.4c4.7-2.7,9.5-5.5,14.2-8.2v29.2L441.2,452.7z M440.9,409.6l25.6-14.8v29.5L440.9,409.6z
								 M439.5,289.7l27-15.6v31.2L439.5,289.7z M438,283.7v-27c4.3,2.5,8.6,5,12.8,7.4c3.5,2,7,4,10.5,6.1L438,283.7z M442.4,249.5
								l24.1-13.9v27.8L442.4,249.5z M438.5,244.8v-29.9l25.9,15L438.5,244.8z M442.1,209.3c8.1-4.6,16.2-9.3,24.4-14.1v28.2L442.1,209.3z
								 M438.5,203.2v-28.4l24.6,14.2C454.8,193.8,446.6,198.6,438.5,203.2z M438.5,164.1v-19.7c8.2,1.5,16.1,3.5,23.9,6L438.5,164.1z
								 M432.5,164.4l-29.2-16.9v-6.7c9.9,0.2,19.7,1,29.2,2.5V164.4z M356,209.2l-21.5,12.4v-24.8C341.8,201,348.9,205.1,356,209.2z
								 M336.5,189.9l23-13.3v26.6C351.9,198.8,344.3,194.4,336.5,189.9z M359.5,216.6v28.8L334.6,231L359.5,216.6z M355.1,249.7
								l-20.6,11.9v-23.8L355.1,249.7z M359,257v24.3l-21.1-12.2c5-2.9,9.9-5.7,14.8-8.5C354.8,259.4,356.9,258.2,359,257z M359,288.3v2.4
								l-24.5,14.1v-30.6L359,288.3z M359,297.6v23.8l-20.6-11.9L359,297.6z M355.9,330L334,342.6v-25.3L355.9,330z M359.5,334.8V368
								L334,353.3v-3.8L359.5,334.8z M347.4,439.2c-3.4-1.9-6.8-3.9-10.1-5.8l22.2-12.8v25.6C355.5,443.9,351.4,441.6,347.4,439.2z
								 M356.8,452.7l-22.3,12.9v-25.8c3.1,1.8,6.3,3.6,9.4,5.4C348.2,447.8,352.5,450.3,356.8,452.7z M334.5,422.6v-27.2l23.6,13.6
								L334.5,422.6z M338.4,390.7l21.1-12.2v24.4L338.4,390.7z M353.6,371.6L334,382.9v-22.6L353.6,371.6z M334.5,478.6l23.9,13.8
								c-7.9,4.5-15.8,9.1-23.9,13.8V478.6z M359.5,499.8v25.8l-22.3-12.9C344.7,508.4,352.1,504.1,359.5,499.8z M338.3,470.4l24.6-14.2
								c9.6,5.6,19.4,11.2,29.2,16.8c-8.1,4.7-16.3,9.4-24.6,14.2L338.3,470.4z M365.5,496.4c1-0.6,1.9-1.1,2.9-1.7l27.5,15.9l-30.4,17.6
								V496.4z M396.3,517.3v29.5L370.7,532L396.3,517.3z M374.4,491.2c7.3-4.2,14.6-8.4,21.9-12.6v25.2L374.4,491.2z M365.5,449.7v-32.6
								l3.3-1.9l27.5,15.9v36.3C385.9,461.4,375.7,455.5,365.5,449.7z M374.8,411.7l21.5-12.4v24.8L374.8,411.7z M368.8,408.3l-3.3-1.9
								v-31.3l30.8-17.8v35.1L368.8,408.3z M365.5,364.7v-29.2l25.3,14.6L365.5,364.7z M365,324.8v-30.7l2-1.2l29.2,16.9v33.1L365,324.8z
								 M373,289.5l23.2-13.4v26.8L373,289.5z M367,286l-2-1.2v-31.2c10.3-5.9,20.7-11.9,31.3-18v33.5L367,286z M365.5,245.2v-30.5
								c8.9,5.2,17.7,10.3,26.4,15.3C383,235.1,374.2,240.2,365.5,245.2z M371.1,209.9l25.2-14.5v29.1C388,219.7,379.6,214.8,371.1,209.9z
								 M365.5,206.2v-33.1h0.1l28.6,16.5L365.5,206.2z M371.6,169.6l24.7-14.3v28.5L371.6,169.6z M365.6,166.1L365.6,166.1l-0.1-22.5
								c10-1.7,20.3-2.6,30.8-2.8v7.5L365.6,166.1z M359.5,162.6l-21.6-12.5c7.1-2.2,14.3-4,21.6-5.4V162.6z M358.3,170.3l-27.8,16.1
								c-10.7-6.2-21.6-12.5-32.8-19c9.9-5.6,20.4-10.4,31.3-14.3L358.3,170.3z M297.5,216.5l23,13.3l-23,13.3V216.5z M324.7,354.9
								l3.3,1.9v29.5L297.5,404v-33.3L324.7,354.9z M297.5,363.7v-24.5l21.2,12.3L297.5,363.7z M324.7,348l-27.2-15.7v-36l30.5,17.6v32.2
								L324.7,348z M319.6,431.3L297.5,444v-25.4C304.9,422.8,312.2,427.1,319.6,431.3z M323.3,472.1L297.5,487v-29.8L323.3,472.1z
								 M297.5,493.9l31-17.9v33.6c-10.1,5.8-20.4,11.8-31,17.9V493.9z M298.1,450.6l27.5-15.9c1,0.6,2,1.1,2.9,1.7v31.7L298.1,450.6z
								 M326.6,427.2c-8.5-4.9-17.1-9.8-25.7-14.8l27.6-16V426L326.6,427.2z M303.2,289.1c8.5-4.9,17-9.8,25.3-14.6v29.2L303.2,289.1z
								 M297.5,283v-33.1l29-16.7l2,1.2v30.7L297.5,283z M326.5,226.3l-29-16.7v-34.2c10.6,6.1,20.9,12.1,31,17.9v31.8L326.5,226.3z
								 M262,348.1v-35.3c9.6-5.5,19.1-11,28.5-16.4v35.3L262,348.1z M290.5,338.6v26.2l-22.7-13.1L290.5,338.6z M262.5,304.5v-28.4
								l24.6,14.2C279,295,270.8,299.7,262.5,304.5z M262.5,265.7v-31.3l28,16.2v31.3L262.5,265.7z M266,229.5l24.5-14.1v28.2L266,229.5z
								 M262.5,224.6v-32.5c8.7-7.6,18.1-14.5,28-20.5v36.8L262.5,224.6z M262,355.3l28.5,16.5v34.7c-9.2-5.3-18.6-10.7-28-16.1v-1.8
								l-0.5-0.3V355.3z M290.5,456.6v31l-26.8-15.5L290.5,456.6z M262.5,465.9v-30.5l26.4,15.3L262.5,465.9z M267.8,431.5l22.7-13.1v26.2
								L267.8,431.5z M262.5,424.2v-25.8c7.5,4.3,15,8.6,22.3,12.9L262.5,424.2z M359.5,538.6v17c-7-1.4-13.8-3.1-20.6-5.1L359.5,538.6z
								 M365.5,536l30.8,17.8v5.6c-10.5-0.2-20.7-1.1-30.8-2.8V536z M403.3,554.6l29.2-16.9v19.1c-9.5,1.5-19.3,2.3-29.2,2.5V554.6z
								 M438.5,536.8l23,13.3c-7.5,2.3-15.2,4.2-23,5.7V536.8z M507.5,494.5l27-15.6v31.3c-8.5,7.1-17.5,13.6-27,19.3V494.5z M540,357.4
								l24.2,14l-24.2,14V357.4z M540.5,436.6l27.7,16l-27.4,15.8l-0.3-0.2V436.6L540.5,436.6z M574.2,456l4.6,2.6
								c-4.8,7.9-10.1,15.5-15.9,22.7l-16.1-9.5L574.2,456z M576.5,447v-30.8l18.1,10.5c-3.3,8.3-7.1,16.4-11.4,24.2L576.5,447z
								 M580.8,411.7l22.6-13.1c-1.8,7.6-4,15-6.6,22.3L580.8,411.7z M605.1,390.8C605.1,390.8,605,390.8,605.1,390.8l-28.6,16.5v-32.6
								c10.6-6.1,21.4-12.4,32.5-18.7C608.6,367.9,607.3,379.5,605.1,390.8z M576.5,364.3V337c7.8,4.5,15.6,9,23.6,13.7L576.5,364.3z
								 M608,346.2l-32-18.5v-33.1l29,16.7c0.2,0.1,0.3,0.1,0.5,0.2c2.2,11.6,3.3,23.5,3.5,35.6C608.8,346.8,608.4,346.4,608,346.2z
								 M558.4,213.6L540.5,224v-28.8C546.8,201,552.8,207.1,558.4,213.6z M256.5,197.6V224l-16.2-9.4
								C245.4,208.6,250.8,202.9,256.5,197.6z M240.3,485.6l16.2-9.4v26.5C250.8,497.3,245.4,491.6,240.3,485.6z M540.5,505v-29.3
								l18.3,10.5C553.1,492.9,547,499.1,540.5,505z" />
				</g>
            <g id="layer1">

            <linearGradient id="SVGID_11_" gradientUnits="userSpaceOnUse" x1="417.875" y1="426.0995" x2="512.125" y2="520.3495"
                            gradientTransform="matrix(1 0 0 -1 0 800.0698)">
            <stop offset="0.1064" style="stop-color:#FEDD29" />
            <stop offset="1" style="stop-color:#FFFFBF" />
					</linearGradient>
            <polygon class="st10" points="366,297.6 366,322.1 508,322.1 508,366.1 454,366.1 454,390.1 530,390.1 530,297.6 	" />
            <linearGradient id="SVGID_12_" gradientUnits="userSpaceOnUse" x1="281.625" y1="395.3495" x2="369.375" y2="483.0995"
                            gradientTransform="matrix(1 0 0 -1 0 800.0698)">
            <stop offset="0.1064" style="stop-color:#FEDD29" />
            <stop offset="1" style="stop-color:#FFFFBF" />
					</linearGradient>
            <polygon class="st11" points="418,390.1 418,365.6 289,365.6 289,321.6 330,321.6 330,297.6 267,297.6 267,390.1 	" />
            <linearGradient id="SVGID_13_" gradientUnits="userSpaceOnUse" x1="307.75" y1="470.2245" x2="478.25" y2="640.7245"
                            gradientTransform="matrix(1 0 0 -1 0 800.0698)">
            <stop offset="0.1064" style="stop-color:#FEDD29" />
            <stop offset="1" style="stop-color:#FFFFBF" />
					</linearGradient>
            <polygon class="st12" points="530.5,211.6 265.5,211.6 265.5,235.1 508,235.1 508,243.1 336,243.1 336,358.1 359,358.1 359,267.6
								425,267.6 425,291.1 447,291.1 447,267.6 530.5,267.6 	" />
            <linearGradient id="SVGID_14_" gradientUnits="userSpaceOnUse" x1="326.25" y1="250.7245" x2="496.25" y2="420.7245"
                            gradientTransform="matrix(1 0 0 -1 0 800.0698)">
            <stop offset="0.1064" style="stop-color:#FEDD29" />
            <stop offset="1" style="stop-color:#FFFFBF" />

					</linearGradient>
            <polygon class="st13" points="447,432.1 447,330.1 425,330.1 425,432.1 359,432.1 359,397.1 336,397.1 336,457.1 508,457.1
								508,465.1 266,465.1 266,489.1 531,489.1 531,432.1 	" />

				</g>
			</svg>

        </div>
    </div>-->
    <!-- container -->
    <div class="container">
        <div id="myModal" class="reveal-modal">
            <!--<p>Welcome to the Resorts World Manila ASIA GOLD</p>-->
            <p><%=Bulletin %></p>
            <a class="close-reveal-modal">&#215;</a>
        </div>

        <!-- banner -->
        <div class="container__banner">
            <div class="width-wrap">
                <div class="width-wrap__qrcodebox">
                    <div class="qrcode">
                        <span class="language_replace">Scan for mobile phones</span>
                        <img src="images/qrcode.png">
                    </div>
                    <ul class="flex">
                        <li>
                            <a data-toggle="tooltip"  data-placement="bottom" title="日本語" onclick="setLanguage('JPN')"><img src="images/JP.svg"></a>
                        </li>
                        <li>
                            <a data-toggle="tooltip"  data-placement="bottom" title="한국어" onclick="setLanguage('KOR')"><img src="images/KR.svg"></a>
                        </li>
          <%--              <li>
                            <a data-toggle="tooltip"  data-placement="bottom" title="简体中文" onclick="setLanguage('CHS')"><img src="images/CN.svg"></a>
                        </li>--%>
						<li>
                            <a data-toggle="tooltip"  data-placement="bottom" title="正體中文" onclick="setLanguage('CHT')"><img src="images/TN.svg"></a>
                        </li>
                        <li>
                            <a data-toggle="tooltip"  data-placement="bottom" title="English" onclick="setLanguage('ENG')"><img src="images/EN.svg"></a>
                        </li>
                    </ul>
					<div class="downloadBtn">
						<!--div><a href="pcdownload.aspx"><img src="images/APPSTOREICON4.png"><img src="images/APPSTOREICON3.png"><span class="language_replace">APP Download</span></a></div-->
						<div><a href="pcdownload.aspx"><img src="images/APPSTOREICON4.png"><img src="images/APPSTOREICON3.png"><span class="language_replace">APP Download</span></a></div>
					</div>
                </div>
                <div class="width-wrap__login">
                    <div class="login-logo">
                        <img src="images/login.png">
                        <p><span>BM VIP CLUB</span></p>
                    </div>
                    <form method="post">
                        <input type="hidden" name="LoginGUID" value="" />
                        <input type="hidden" name="GuestLogin" value="" />
                        <input type="hidden" name="Lang" value="ENG" />
                        <div id="loginDiv" class="form">
                            <fieldset>
                                <div class="form__field">
                                    <label class="form__label form__label--hide" for="Account"><span class="language_replace">Account</span></label>
                                    <div class="form__inputgroup">
                                        <i class="form-icon icon-user"></i>
                                        <input class="form__control boxsizing" id="LoginAccount" name="LoginAccount" type="text" language_replace="placeholder" placeholder="Please Input Account">
                                    </div>
                                </div>
                                <div class="form__field">
                                    <label class="form__label form__label--hide" for="Password"><span class="language_replace">Password</span></label>
                                    <div class="form__inputgroup">
								
                                        <i class="form-icon icon-more-horizontal"></i>
                                        <input class="form__control boxsizing" id="LoginPassword" name="LoginPassword" type="password" language_replace="placeholder" placeholder="Please Input Password">
											
                                    </div>
                                </div>
                                <!--button class="btn btn--mt" type="button" value="LOGIN">
                                    <span class="language_replace">系統維護中</span>
                                <button-->
                                
                                <button class="btn btn--mt" type="button" value="LOGIN" onClick="btnLogin()">
                                    <i class="btn__icon icon-log-in"></i><span class="language_replace">LOGIN</span>
                                </button>
<%--								<button class="btn guestBtn" type="button" value="GUEST LOGIN" onClick="btnLoginGuest()">
                                    <span class="language_replace">GUEST LOGIN</span>
                                </button>--%>
                    <!--div class="btn btn--mt">
						<label class="QRcodeFileBtn_m">
                        <input type="file" onchange="QRScan(this)" accept="image/*" id="idQRImage" name="idQRImage"><span class="inputfile"><img src="images/QRcodeIcon.png" width="20px" height="20px" alt="QRcodeIcon"><span class="language_replace">QR CODE LOGIN</span></span>
						</label>	
                    </div-->
                                <!--
								<button class="btn btn--mt" type="button" value="QRCODE LOGIN">
                                    <i class="btn__icon icon-log-in"></i><span class="language_replace">QR CODE LOGIN</span>
                                </button>
                                -->
                            </fieldset>
                        </div>
                        <div id="QRCodeResult" style="width: 100%; color: #ffffff; text-align: center"></div>
                        <div id="codeDiv" class="codeDiv">
						    <div class="form">
						       <fieldset>
						   		    <div class="form__field">
                                        <label class="form__label form__label--hide" for="Code"><span class="language_replace">Code</span></label>
									    <div class="form__img"><img id="ValidateImage" style="display: none"></div>
                                        <div class="form__inputgroup">
                                            <i class="form-icon icon-lock"></i>
                                            <input class="form__control boxsizing" id="ImageCode" name="ImageCode" type="text" language_replace="placeholder" placeholder="Please Input Code">
                                        </div>
                           		    </div>
							        <button class="btn btn--mt" type="submit" value="LOGIN" >
                                        <span class="language_replace">CONFIRM</span>
                                    </button>
							       <button class="btn btn--mt" type="button" value="LOGIN" onClick="codeHidden()">
                                        <span class="language_replace">CANCEL</span>
                                    </button>
						       </fieldset>	
						    </div>	
					    </div>	
                    </form>
                </div>
            </div>
            <div class="flexslider">
				<div class="flexsMask"></div>
                <ul class="slides">
                    <li>
                        <a href="javascript:;" title="LST">
                            <picture>
                                <!--
                                上傳大小   1920x800(desktop)
                                                768x800(mobile)
                            -->
                                <!--[if IE 9]><video style="display: none;"><![endif]-->
                                <source media="(min-width: 1024px)" srcset="images/banner2.jpg">
                                <source media="(max-width: 768px)" srcset="images/banner2-s.jpg">
                                <!--[if IE 9]></video><![endif]-->
                                <img src="images/banner2.jpg" alt="LST">
                            </picture>
                        </a>
                    </li>

                    <li>
                        <a href="javascript:;" title="LST">
                            <picture>
                                <!--
                                上傳大小   1920x800(desktop)
                                                768x800(mobile)
                            -->
                                <!--[if IE 9]><video style="display: none;"><![endif]-->
                                <source media="(min-width: 1024px)" srcset="images/banner.jpg">
                                <source media="(max-width: 768px)" srcset="images/banner-s.jpg">
                                <!--[if IE 9]></video><![endif]-->
                                <img src="images/banner.jpg" alt="LST">
                            </picture>
                        </a>
                    </li>

                </ul>
            </div>
        </div>
        <!-- banner// -->
        <!-- step -->
        <div class="container__step flex">
            <dl class="step">
                <dt class="step__dt flex">
                    <span class="num">01</span>
                    <span class="steptitle language_replace">Login</span>
                </dt>
                <dd class="step__dd language_replace">Players can log into the system after becoming a member.</dd>
            </dl>
            <dl class="step">
                <dt class="step__dt flex">
                    <span class="num">02</span>
                    <span class="steptitle language_replace">Select the table</span>
                </dt>
                <dd class="step__dd language_replace">
                    Players can choose their favorite table then start game. If easybet table is selected, players can bet immeditately without waiting for buying chips.
                </dd>
            </dl>
            <dl class="step">
                <dt class="step__dt flex">
                    <span class="num">03</span>
                    <span class="steptitle language_replace">Buy chips(apply to telebet)</span>
                </dt>
                <dd class="step__dd language_replace">Contact cage to buy chips, or requesting buy chip by clicking on the page.</dd>
            </dl>
            <dl class="step">
                <dt class="step__dt step__dt--sm flex">
                    <span class="num">04</span>
                    <span class="steptitle language_replace">Call from phone betting personnel(apply to telebet)</span>
                </dt>
                <dd class="step__dd language_replace">After chip buy in successfully, the phone betting personnel will immediately call the member.</dd>
            </dl>
            <dl class="step">
                <dt class="step__dt flex">
                    <span class="num">05</span>
                    <span class="steptitle language_replace">Bet</span>
                </dt>
                <dd class="step__dd language_replace">
                    Once the VIPs receive calls from phone beting personnel,they can bet directly from the web or instruct phone beting personnel to bet on behalf of them.
                </dd>
            </dl>
            <dl class="step">
                <dt class="step__dt flex">
                    <span class="num">06</span>
                    <span class="steptitle language_replace">End Game</span>
                </dt>
                <dd class="step__dd language_replace">
                    Upon completion of the game of traditional phone betting,the phone better will go to cage and make settlement for the VIPs.If Players are playing easybet,they can just leave the website straightly without noticing us.
                </dd>
            </dl>
        </div>
        <!-- step// -->
        <!-- contact -->
        <!--div class="container__contact contact flex">
            <div class="contact__bg"></div>
            <dl class="contact__info">
                <dt><span class="language_replace">contact us</span></dt>
                <dd>+XX XXX XXX XXXX</dd>
                <dd>+XX XXX XXX XXXX</dd>
                <dd><span class="language_replace">24 hour service</span></dd>
            </dl>
        </div-->
        <!-- contact// -->
        <div class="container__ft">
            <a  class="popup1" id="popup1" onClick="termsDivSwitch()" href="#popup1"><span class="language_replace">Terms of Member Responsibilities</span></a>
        </div>
    </div>
    <!-- container// -->
    <div id="Terms-popup1" class="TermsDiv">
    <div class="white-popup" style="max-width:1200px; color:#272727;">
        <h3 style="font-weight:bolder; margin-bottom:10px;"><span class="language_replace">As a lawful internet gaming institution, our Company has the responsibility to remind all potential players to pay attention to the relevant laws and regulations of the countries or the regions of residence.</span></h3>
        <ul>
            <li><span class="language_replace">1.The player should verify and perform due diligence if on-line gaming complies with the local laws before starting the games.</span></li>
            <li><span class="language_replace">2.Our website provides services only for the players with the statutory age. Any misrepresentation as to the age of the player shall not make the company liable for any losses of said player.</span></li>
            <li><span class="language_replace">3.Our Company shall not be responsible for any liability to the player's illegal activities resulting from violating the local laws or participating into the games of our Company.</span></li>
            <li><span class="language_replace">4.Any user who installs, uses and participates into any game of the software is deemed to comply with the local legal age, understand and agree with the contents of this Agreement totally.</span></li>
            <li><span class="language_replace">5.Our website has the right to refuse any user who signs in in an illegal way to participate into any game in our website.</span></li>
            <li><span class="language_replace">6.If black screen or network delay occurs in the game, in order to protect your rights, the telephone betting agent will take back the chips on the gambling table after losing contact</span></li>
            <li><span class="language_replace">7.Cards dealing errors due to human factors, our Company will restore to the correct results, The final results will be subject to the restored correct results.</span></li>
            <li><span class="language_replace">8.When the player bets through telephone, the telephone betting agent will confirm the final betting amount and direction with player, if there is any question or if the bet amount needs to be revised prior to opening, the player should immediately contact the agent; once the bet is opened, the player is not allowed to make any change. Our company will take the final betting on system data as prevail, the chip amount is also subject to the total chips on system data, and our Company bears no liabilities.</span></li>
            <li><span class="language_replace">9.Website display is only for reference, and makes no difference to the gaming results. If there are abnormal results of the website display caused by internet errors, the gaming results on site gambling table shall prevail.</span></li>
            <li><span class="language_replace">10.In case of the website faults or information damage resulting from Force Majeure or man-made intrusion, the final data of our website shall be final.</span></li>
            <li><span class="language_replace">11.In any case, the decision of our Company is final.</span></li>
            <li><span class="language_replace">12.In any case that one or more provisions contained in this agreement shall be declared invalid, illegal or unenforceable in any respect by a competent authority, the validity and legality and enforceability of the remaining provisions herein shall not in any way be affected or impaired thereby.</span></li>
            <li><span class="language_replace">13.I hold the gaming institution / company, its officers and employees free from any and all liabilities of whatever nature and kind which may result from my activities of engaging and utilizing the services they provide.</span></li>
            <li><span class="language_replace">14.Any and all data or information that may come to the knowledge of the player shall be kept in strict confidence. However, the website is entitled to disclose such data and information to the third parties, its officers, employees and affiliates upon such disclosure is necessary for the performance of gaming and other judicial investigation.</span></li>
        </ul>

    </div>
    </div>



</body>
<!-- banner -->
<script src="scripts/jquery-1.11.3.min.js"></script>
<script defer src="scripts/jquery.flexslider.js"></script>
<script defer src="scripts/jquery.fancybox.js"></script>
<script type="text/javascript">
    $(window).load(function () {
        $('.flexslider').flexslider({
            animation: "slide",
            start: function (slider) {
                $('body').removeClass('loading');
            }
        });
    });

</script>
<!-- banner// -->
<link rel="stylesheet" href="css/reveal.css">
<script type="text/javascript" src="https://code.jquery.com/jquery-1.6.min.js"></script>
<script type="text/javascript" src="scripts/jquery.reveal.js"></script>
<script type="text/javascript">
    $(document).ready(function () {
        if (hasBulletin)
            $('#myModal').reveal();
    });
</script>
<!--GSAP-->
<script src="//cdnjs.cloudflare.com/ajax/libs/gsap/2.0.2/TweenMax.min.js" type="text/javascript" charset="utf-8"></script>
<script src="//s3-us-west-2.amazonaws.com/s.cdpn.io/35984/AnticipateEase.min.js" type="text/javascript" charset="utf-8"></script>
<!-- <script src="js/action.js"></script> -->
	
<!--  Terms of Member Responsibilities        -->	
<script type="text/javascript">
	function termsDivSwitch() {
		    var Termspopup1 = document.getElementById("Terms-popup1");
            Termspopup1.classList.toggle("termsDivSwitch");
		}
</script>	
</html>