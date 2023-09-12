var AgentAPI = function (APIUrl) {
    this.HeartBeat = function (GUID, EchoString, cb) {
        var url = APIUrl + "/HeartBeat";
        var postData;

        postData = {
            GUID: GUID,
            Echo: echoString
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

    this.ValidatePassword = function (AID, GUID, PasswordType, Password, cb) {
        var url = APIUrl + "/ValidatePassword";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID,
            PasswordType: PasswordType,
            Password: Password
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

    this.GetETHCoinTxLog = function (AID, GUID, BeginDate, EndDate, cb) {
        var url = APIUrl + "/GetETHCoinTxLog";
        var postData;

        postData = {
            AID: AID,
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

    this.ETHBitCoinTx = function (AID, GUID, WalletPassword, ToAddress, CurrencyType, Amount, cb) {
        var url = APIUrl + "/ETHBitCoinTx";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID,
            WalletPassword: WalletPassword,
            ToAddress: ToAddress,
            CurrencyType: CurrencyType,
            Amount: Amount
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

    this.ETHCheckBitCoinTxState = function (AID, GUID, cb) {
        var url = APIUrl + "/ETHCheckBitCoinTxState";
        var postData;

        postData = {
            AID: AID,
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

    this.KeepAID = function (AID, GUID, cb) {
        var url = APIUrl + "/KeepAID";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID
        };

        callService(url, postData, 5000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (text != "Timeout") 
                    if (cb)
                        cb(false, text);
            }
        });
    };

    this.GetOrderSummary = function (AID, GUID, LoginAccount, QueryBeginDate, QueryEndDate, CurrencyType, cb) {
        var url = APIUrl + "/GetOrderSummary";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID,
            LoginAccount: LoginAccount,
            QueryBeginDate: QueryBeginDate,
            QueryEndDate: QueryEndDate,
            CurrencyType: CurrencyType
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

    this.GetOrderDetail = function (AID, GUID, LoginAccount, QueryDate, OrderType, CurrencyType, cb) {
        var url = APIUrl + "/GetOrderDetail";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID,
            LoginAccount: LoginAccount,
            QueryDate: QueryDate,
            OrderType: OrderType,
            CurrencyType: CurrencyType
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

    this.GetCompanyInfo = function (AID, GUID, cb) {
        var url = APIUrl + "/GetCompanyInfo";
        var postData;

        postData = {
            AID: AID,
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

    this.DisableChildUser = function (AID, GUID, LoginAccount, cb) {
        var url = APIUrl + "/DisableChildUser";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID,
            LoginAccount: LoginAccount
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


    this.QueryChildUserAccountList = function (AID, GUID, ParentLoginAccount, cb) {
        var url = APIUrl + "/QueryChildUserAccountList";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID,
            ParentLoginAccount: ParentLoginAccount
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

    this.AddMultiLogin = function (AID, GUID, LoginAccount, LoginPassword, Description, cb) {
        var url = APIUrl + "/AddMultiLogin";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID,
            LoginAccount: LoginAccount,
            LoginPassword: LoginPassword,
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

    this.SetMultiLogin = function (AID, GUID, LoginAccount, Description, cb) {
        var url = APIUrl + "/SetMultiLogin";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID,
            LoginAccount: LoginAccount,
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

    this.RemoveMultiLogin = function (AID, GUID, LoginAccount, cb) {
        var url = APIUrl + "/RemoveMultiLogin";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID,
            LoginAccount: LoginAccount
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

    this.QueryUserInfo = function (AID, GUID, cb) {
        var url = APIUrl + "/QueryUserInfo";
        var postData;

        postData = {
            AID: AID,
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

    this.GetWalletHistory = function (AID, GUID, LoginAccount, StartDate, EndDate, ActionType, CurrencyType, cb) {
        var url = APIUrl + "/GetWalletHistory";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID,
            LoginAccount: LoginAccount,
            StartDate: StartDate,
            EndDate: EndDate,
            ActionType: ActionType,
            CurrencyType: CurrencyType
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

    this.GetAccountingSummary = function (AID, GUID, LoginAccount, QueryBeginDate, QueryEndDate, CurrencyType, cb) {
        var url = APIUrl + "/GetAccountingSummary";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID,
            LoginAccount: LoginAccount,
            QueryBeginDate: QueryBeginDate,
            QueryEndDate: QueryEndDate,
            CurrencyType: CurrencyType
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
    this.UpdateDeviceInfo = function (AID, GUID, DeviceGUID, PushType, DeviceName, DeviceKey, DeviceType, NotifyToken, GPSPosition, UserAgent, cb) {
        var url = APIUrl + "/UpdateDeviceInfo";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID,
            DeviceGUID: DeviceGUID,
            PushType: PushType,
            DeviceName: DeviceName,
            DeviceKey: DeviceKey,
            DeviceType: DeviceType,
            NotifyToken: NotifyToken,
            GPSPosition: GPSPosition,
            UserAgent: UserAgent
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

    this.getSQLReport = function (AID, GUID, ReportGUID, Param, cb) {
        var url = APIUrl + "/RunReport";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID,
            ReportGUID: ReportGUID,
            Param: Param
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

    this.queryReportInfo = function (AID, GUID, ReportGUID, cb) {
        var url = APIUrl + "/QueryReportInfo";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID,
            ReportGUID: ReportGUID
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

    this.addUserBankCard = function (AID, GUID, CurrencyType, PaymentMethod, BankName, BranchName, BankNumber, AccountName, BankProvince, BankCity, Description, cb) {
        var url = APIUrl + "/AddUserBankCard";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID,
            CurrencyType: CurrencyType,
            PaymentMethod: PaymentMethod,
            BankName: BankName,
            BranchName: BranchName,
            BankNumber: BankNumber,
            AccountName: AccountName,
            BankProvince: BankProvince,
            BankCity: BankCity,
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

    this.updateUserBankCard = function (AID, GUID, BankCardGUID, CurrencyType, PaymentMethod, BankName, BranchName, BankNumber, AccountName, BankProvince, BankCity, Description, cb) {
        var url = APIUrl + "/UpdateUserBankCard";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID,
            BankCardGUID: BankCardGUID,
            CurrencyType: CurrencyType,
            PaymentMethod: PaymentMethod,
            BankName: BankName,
            BranchName: BranchName,
            BankNumber: BankNumber,
            AccountName: AccountName,
            BankProvince: BankProvince,
            BankCity: BankCity,
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

    this.removeUserBankCard = function (AID, GUID, BankCardGUID, cb) {
        var url = APIUrl + "/RemoveUserBankCard";
        var postData;

        postData = {
            AID: AID,
            GUID: GUID,
            BankCardGUID: BankCardGUID
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


    this.queryUserBankCard = function (AID, GUID, cb) {
        var url = APIUrl + "/GetUserBankCard";
        var postData;

        postData = {
            AID: AID,
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
};