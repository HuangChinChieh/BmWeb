var LobbyAPI = function (APIUrl) {
    this.HeartBeat = function (GUID, Echo, cb) {
        var url = APIUrl + "/HeartBeat";
        var postData;

        postData = {
            GUID: GUID,
            Echo: Echo
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

   

    this.UserAccountTransfer = function (WebSID, GUID, DstLoginAccount, DstCurrencyType, SrcCurrencyType, TransOutValue, WalletPassword, Description, cb) {
        var url = APIUrl + "/UserAccountTransfer";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            DstLoginAccount: DstLoginAccount,
            DstCurrencyType: DstCurrencyType,
            SrcCurrencyType: SrcCurrencyType,
            TransOutValue: TransOutValue,
            WalletPassword: WalletPassword,
            Description: Description
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.ConfirmUserAccountTransfer = function (WebSID, GUID, TransferGUID, cb) {
        var url = APIUrl + "/ConfirmUserAccountTransfer";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            TransferGUID: TransferGUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetTransferHistory = function (WebSID, GUID, BeginDate, EndDate, cb) {
        var url = APIUrl + "/GetTransferHistory";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            BeginDate: BeginDate,
            EndDate: EndDate
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetUserAccountProperty = function (WebSID, GUID, PropertyName, cb) {
        var url = APIUrl + "/GetUserAccountProperty";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            PropertyName: PropertyName
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.SetUserAccountProperty = function (WebSID, GUID, PropertyName, PropertyValue ,cb) {
        var url = APIUrl + "/SetUserAccountProperty";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            PropertyName: PropertyName,
            PropertyValue: PropertyValue
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };


    this.GetSIDParam = function (WebSID, GUID, ParamName, cb) {
        var url = APIUrl + "/GetSIDParam";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            ParamName: ParamName,
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.SetSIDParam = function (WebSID, GUID, ParamName, ParamValue, cb) {
        var url = APIUrl + "/SetSIDParam";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            ParamName: ParamName,
            ParamValue: ParamValue
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.KeepSID = function (WebSID, GUID, cb) {
        var url = APIUrl + "/KeepSID";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.SetUserMail = function (GUID, ValidateType, SendMailType, EMail, ContactPhonePrefix, ContactPhoneNumber, ReceiveRegisterRewardURL, cb) {
        var url = APIUrl + "/SetUserMail";
        var postData;

        postData = {
            GUID: GUID,
            ValidateType: ValidateType,
            SendMailType: SendMailType,
            EMail: EMail,
            ContactPhonePrefix: ContactPhonePrefix,
            ContactPhoneNumber: ContactPhoneNumber,
            ReceiveRegisterRewardURL: ReceiveRegisterRewardURL
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.CheckAccountExist = function (GUID, LoginAccount, cb) {
        var url = APIUrl + "/CheckAccountExist";
        var postData;

        postData = {
            LoginAccount: LoginAccount,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.CheckAccountExistEx = function (GUID, LoginAccount, PhonePrefix, PhoneNumber, EMail, cb) {
        var url = APIUrl + "/CheckAccountExistEx";
        var postData;

        postData = {
            LoginAccount: LoginAccount,
            PhonePrefix: PhonePrefix,
            PhoneNumber: PhoneNumber,
            EMail: EMail,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.CheckAccountExistByContactPhoneNumber = function (GUID, PhonePrefix, PhoneNumber, cb) {
        var url = APIUrl + "/CheckAccountExistByContactPhoneNumber";
        var postData;

        postData = {
            PhonePrefix: PhonePrefix,
            PhoneNumber: PhoneNumber,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.RequireRegister = function (GUID, ParentPersonCode, PS, UBC, cb) {
        var url = APIUrl + "/RequireRegister";
        var postData;

        postData = {
            GUID: GUID,
            ParentPersonCode: ParentPersonCode,
            PS: PS,
            UBC: UBC
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };


    this.SetValidateCodeOnlyNumber = function (GUID, PhonePrefix, PhoneNumber, cb) {
        var url = APIUrl + "/SetValidateCodeOnlyNumber";
        var postData;

        postData = {
            PhonePrefix: PhonePrefix,
            PhoneNumber: PhoneNumber,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };


    this.CheckValidateCodeOnlyNumber = function (GUID, PhonePrefix, PhoneNumber, ValidateCode, cb) {
        var url = APIUrl + "/CheckValidateCodeOnlyNumber";
        var postData;

        postData = {
            PhonePrefix: PhonePrefix,
            PhoneNumber: PhoneNumber,
            ValidateCode: ValidateCode,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.CreateAccount = function (GUID, LoginAccount, LoginPassword, ParentPersonCode, PS, cb) {
        var url = APIUrl + "/CreateAccount";
        var postData;

        postData = {
            GUID: GUID,
            LoginAccount: LoginAccount,
            LoginPassword: LoginPassword,
            ParentPersonCode: ParentPersonCode,            
            PS: PS
        };

        callService(url, postData, 300000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };



    this.GetUserInfo = function (WebSID, GUID, cb) {
        var url = APIUrl + "/GetUserInfo";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };


    this.GetUserBalance = function (WebSID, GUID, cb) {
        var url = APIUrl + "/GetUserBalance";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.KeepSIDByProduct = function (SID, GUID, cb) {
        var url = APIUrl + "/KeepSIDByProduct";
        var postData;

        postData = {
            CT: CT,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    function callService(URL, postObject, timeoutMS, cb) {
        var xmlHttp = new XMLHttpRequest;
        var postData;

        if (postObject)
            postData = JSON.stringify(postObject);

        xmlHttp.open("POST", URL, true);
        xmlHttp.onreadystatechange = function () {
            if (this.readyState == 4) {
                var contentText = this.responseText;

                if (this.status == "200") {
                    if (cb) {
                        cb(true, contentText);
                    }
                } else {
                    cb(false, contentText);
                }
            }
        };

        xmlHttp.timeout = timeoutMS;
        xmlHttp.ontimeout = function () {
            /*
            timeoutTryCount += 1;

            if (timeoutTryCount < 2)
                xmlHttp.send(postData);
            else*/
            if (cb)
                cb(false, "Timeout");
        };

        xmlHttp.setRequestHeader("Content-Type", "application/json; charset=utf-8");
        xmlHttp.send(postData);
    }

    function getJSON(text) {
        var obj = JSON.parse(text);

        if (obj) {
            if (obj.hasOwnProperty('d')) {
                return obj.d;
            } else {
                return obj;
            }
        }
    }
}