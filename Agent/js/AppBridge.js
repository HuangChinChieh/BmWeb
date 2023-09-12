var AppBridge = function (an, ios, event) {
    var myCount = 0;
    var windowCloseEvent = [];

    this.getWindowCloseEvent = function () {
        return windowCloseEvent;
    }

    //#region Public

    /**
     * 寫入暫存
     * @param {function} cb callBack方法
     * @returns {object} retvalue 狀態回報
     */
    this.SetDataByKey = function (key, value, cb) {
        var content = [key, value];
        return postMessage.call(this, "SetDataByKey", content, cb);
    };

    /**
     * 讀取暫存
     * @param {function} cb callBack方法
     * @returns {object} retvalue 狀態回報
     */
    this.GetDataByKey = function (key, cb) {
        var content = [key];
        return postMessage.call(this, "GetDataByKey", content, cb);
    };

    /**
     * fbLogin功能
     * @param {function} cb callBack方法
     * @returns {object} retvalue 狀態回報
     */
    this.fbLogin = function (cb) {
        return postMessage.call(this, "FBLogin", null, cb);
    };

    /**
     * 開啟QRCode功能
     * @param {function} eventList 關閉事件陣列 obj => { tag:..,event:.. }  
     */
    this.setWindowCloseEvent = function (eventObj) {
        
        var allowCheck = true;
        
        for (var i = 0; i < windowCloseEvent.length; i++) {
            if(windowCloseEvent[i].tag == eventObj.tag){
                allowCheck = false;
                windowCloseEvent[i].event = eventObj.event;
                break;
            }
        }
        
        if (allowCheck) {
            windowCloseEvent.push(eventObj);
        }
    };

    /**
    * 開啟Game Webview
    * @returns {object} retvalue 狀態回報
    */
    this.openGame = function (url, cb) {
        var content = [url];
        if (cb) {
            return postMessage.call(this, "OpenGame", content, cb);
        } else {
            return postMessage.call(this, "OpenGame", content, null);
        }       
    };
    
    /**
     * 開啟Camera功能
     * @param {function} cb callBack方法
     * @returns {object} retvalue 狀態回報
     */
    this.openCamera = function (cb) {
        return postMessage.call(this, "Camera", null, cb);
    };

    /**
     * 開啟Gallery功能
     * @param {function} cb callBack方法
     * @returns {object} retvalue 狀態回報
     */
    this.openGallery = function (cb) {
        return postMessage.call(this, "Gallery", null, cb);
    };

    /**
     * 開啟QRCode功能
     * @param {function} cb callBack方法
     * @returns {object} retvalue 狀態回報
     */
    this.openQRCode = function (cb) {
        return postMessage.call(this, "QRCode", null, cb);        
    };

    /**
     * 開啟相簿使用QRCode功能
     * @param {function} cb callBack方法
     * @returns {object} retvalue 狀態回報
     */
    this.openQRCodeByAlbum = function (cb) {
        return postMessage.call(this, "QRCodeByAlbum", null, cb);
    };

    /**
     * 取得手機資訊
     * @param {function} cb callBack方法
     * @returns {object} retvalue 狀態回報
     */
    this.getMobileInfo = function (cb) {
        return postMessage.call(this, "MobileInfo", null, cb);
    };

    /**
    * 取得GPS位置
    * @param {function} cb callBack方法
    * @returns {object} retvalue 狀態回報
    */
    this.getGPS = function (cb) {
        return postMessage.call(this, "GPS", null, cb);
    };

    /**
    * 取得UUID
    * @param {function} cb callBack方法
    * @returns {object} retvalue 狀態回報
    */
    this.getUUID = function (cb) {
        
        return postMessage.call(this, "UUID", null, cb);
    };


    /**
   * 取得手機資訊
   * @param {function} cb callBack方法
   * @returns {object} retvalue 狀態回報
   */
    this.getToken = function (cb) {
        return postMessage.call(this, "Token", null, cb);
    };

    /**
   * 取得FCM資訊
   * @param {function} cb callBack方法
   * @returns {object} retvalue 狀態回報
   */
    this.getFCMData = function (cb) {
        return postMessage.call(this, "FCMData", null, cb);
    };

    /**
      * 取得APP版本
      * @param {function} cb callBack方法
      * @returns {object} retvalue 狀態回報
      */
    this.getCurrentVersion = function (cb) {
        return postMessage.call(this, "GetCurrentVersion", null, cb);
    };

    /**
      * 重設APP Domain
      * @param {function} cb callBack方法
      * @returns {object} retvalue 狀態回報
      */
    this.resetDomain = function (domain, cb) {
        var content = [domain];
        return postMessage.call(this, "ResetDomain", content, cb);
    };

    /**
      * applelogin
      * @param {function} cb callBack方法
      * @returns {object} retvalue 狀態回報
      */
    this.appleLogin = function (cb) {
        return postMessage.call(this, "AppleLogin", null, cb);
    };



    /**
    * 取得手機全部可取資料
    * @param {function} cb callBack方法
    * @returns {object} retvalue 狀態回報
    */
    this.getPhoneAllData = function (cb) {
        var _ret = {
            status: 1,
            message: null,
        };

        var returnData = {
            deviceType: null,
            deviceName: null,
            systemInfo: null,
            ID: null,
            latitude: null,
            longitude: null,
            time: null,
            uuid: null,
            token: null,
            fcm: null,
            version: null
        };
        var promiseList = [];
        var _this = this;
        promiseList.push(new Promise(function (resolve, reject) {
            var check = postMessage.call(_this, "FCMData", null, function (uuid, token){
                returnData.uuid = uuid;
                returnData.token = token;
                resolve();
                //alert(1);
           });
           if (!check) {
               reject();
           }
        }));

        promiseList.push(new Promise(function (resolve, reject) {
            var check = postMessage.call(_this, "MobileInfo", null, function (deviceType, deviceName, systemInfo, ID, version) {
                returnData.deviceType = deviceType;
                returnData.deviceName = deviceName;
                returnData.systemInfo = systemInfo;
                returnData.version = version;
                returnData.ID = ID;
                resolve();
                //alert(2);
            });
            if (!check) {
                reject();
            }
        }));
        
        promiseList.push(new Promise(function (resolve, reject) {
            var timer = window.setTimeout(function () {
                returnData.latitude = "";
                returnData.longitude = "";
                returnData.time = "";
                resolve();
            },5000)

            var check = postMessage.call(_this, "GPS", null, function (latitude, longitude, time) {
                window.clearTimeout(timer);

                returnData.latitude = latitude;
                returnData.longitude = longitude;
                returnData.time = time;
                resolve();
               
            });
            if (!check) {
                
                reject();
            }
        }));
        Promise.all(promiseList).then(values => {
            cb(returnData);
        });

        return _ret;
    };


    /**
     * 呼叫指定 APP(限 Android)，APP未安裝導入到指定URL
     * @param {any} appID
     * @param {any} noInstallURL
     * @param {any} SID
     */
    this.callAndroidAPP = function (appID, noInstallURL, SID, cb) {
        var content = [appID, noInstallURL, SID];
        return postMessage.call(this, "CallApp", content, cb);
    };

    /**
     * 呼叫指定 APP(限 Ios)，APP未安裝導入到指定URL
     * @param {any} UrlScheme
     * @param {any} noInstallURL
    */
    this.callIosAPP = function (appUrl, noInstallURL, cb) {
        var content = [appUrl, noInstallURL];

        return postMessage.call(this, "CallApp", content, cb);
    };


    /**
    * 呼叫指定 APP(限 Ios)，APP未安裝導入到指定URL
    * @param {any} UrlScheme
    * @param {any} noInstallURL
   */
    this.callAPP = function (appUrl, noInstallURL, cb) {
        var content = [appUrl, noInstallURL];

        return postMessage.call(this, "CallApp", content, cb);
    };
    /**
     * 
     * @param a 測試文字a
     * @param b 測試文字b
     * @param cb callBack方法
     * @returns {object} retvalue 狀態回報
     */
    this.getTest = function (a, b, cb) {
        var content = ["a", "b"];

        return postMessage.call(this, "Test", content, cb);
    };

    /**
     * 統一APP呼叫接口
     * @param {string} type 功能類型
     * @param {array/jStr} result 回傳陣列
     * @param {string} tag 任務編號
     */
    this.handleResult = function (type, result, tag) {
        //alert(type);
        switch (type.toUpperCase()) {
            case "AppleLogin".toUpperCase():
                for (var i = 0; i < appQueue.length; i++) {
                    if (appQueue[i].tag == tag) {
                        var _sendBody = appQueue[i];
                        if (type == "AppleLogin") {
                            _sendBody.callback(result);
                        }
                        //檢查兩邊方法名稱是否一致

                        appQueue.splice(i, 1);
                        break;
                    }
                }

                break;
            case "CloseEvent".toUpperCase():
                for (var i = 0; i < windowCloseEvent.length; i++) {
                    if (windowCloseEvent[i].tag == tag) {
                        windowCloseEvent[i].event.apply(this, result);
                        break;
                    }
                }
                break;
            default:
                for (var i = 0; i < appQueue.length; i++) {
                    if (appQueue[i].tag == tag) {
                        var _sendBody = appQueue[i];
                        
                        //if (type == "GPS") {
                        //    alert(result);
                        //}
                        //檢查兩邊方法名稱是否一致
                        if (_sendBody.type == type) {
                            _sendBody.callback.apply(this, result);
                        }

                        
                        

                        appQueue.splice(i, 1);
                        break;
                    }
                }

                

        }
    };



    //物件狀態描述
    this.config = {
        iosCanUse: false,
        anCanUse: false,
        inAPP: false,
        isTest:false
    };


    //#endregion

    //#region Private

    //Android橋梁
    var anBridge;
    //IOS橋梁
    var iosBridge;
    //任務排程
    var appQueue = [];


    /**
     * 建構式
     * @param {string} anStr 安卓Bridge文字
     * @param {string} iosStr 蘋果Bridge文字
     */
    function init(anStr, iosStr) {
        
        if (window[anStr]) {
            //an check
            this.anBridge = window[anStr];
            this.config.inAPP = true;
            this.config.anCanUse = true;
  
    
        } else if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers[iosStr]) {
            //ios check
            this.iosBridge = window.webkit.messageHandlers[iosStr]
            this.config.inAPP = true;
            this.config.iosCanUse = true;
        } else {
            //not ios not an
        }
    };



    /**
     * 呼叫功能至APP
     * @param {string} type 功能名稱
     * @param {string} content 傳入參數
     * @param {function} cb callback呼叫
     * @returns {object} retvalue 狀態回報
     */
    function postMessage(type, content, cb) {

        //送入app的物件
        // type:功能名稱
        // content:功能所需參數
        // tag:callback回傳函數之編號
        myCount++;
        var myTag = (new Date().getTime().toString()) + "_" + myCount;
        var _sendBody = {
            type: type,
            content: content,
            tag: myTag
        };

        //回傳 狀態回報
        var _ret = {
            status: 0,
            message: null,
        };

        var _config = this.config;

        //測試中
        if (_config.isTest) {
            _sendBody.callback = cb;
            appQueue.push(_sendBody);
            return _ret;
        }

        if (_config.inAPP) {
            if (_config.anCanUse) {
                //補上回傳函式，加入queue中
                _sendBody.callback = cb;
                appQueue.push(_sendBody);

                //alert(appQueue.length);
                //送入至Android內
                this.anBridge.PostMessage(_sendBody.type, _sendBody.content, _sendBody.tag);

                
                _ret.status = 1;
            } else if (_config.iosCanUse) {
                //送入至ios內
                this.iosBridge.postMessage(_sendBody);

                //補上回傳函式，加入queue中
                _sendBody.callback = cb;
                appQueue.push(_sendBody);
                _ret.status = 1;
            } else {
                _ret.status = 0;
                _ret.message = "Error, Not Support";
            }
        } else {
            _ret.status = 0;
            _ret.message = "Error, Not Support";
        }

        return _ret;
    };

    //#endregion
      
    init.call(this, an, ios);
}