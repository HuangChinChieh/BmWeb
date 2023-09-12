var multiLanguage = function () {
    var _LanguageContextJSON = [];

    function loadLanguageFromFile(langFile, cb) {
        readTextFile(langFile, function (success, text) {
            if (success) {
                var langObj = JSON.parse(text);

                _LanguageContextJSON[_LanguageContextJSON.length] = langObj;
            }

            if (cb != null)
                cb();
        });
    }

    function readTextFile(file, callback) {
        var rawFile = new XMLHttpRequest();
        //rawFile.overrideMimeType("application/json");
        rawFile.open("GET", file, true);
        //rawFile.setRequestHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        rawFile.onreadystatechange = function () {
            if (rawFile.readyState === 4) {
                if (rawFile.status == "200") {
                    callback(true, rawFile.responseText);
                } else {
                    callback(false, rawFile.responseText);
                }

            }
        }
        rawFile.send(null);
    }

    function DoLanguageReplace(cb) {
        var langCls = document.getElementsByClassName("language_replace");
        var langInputCls = document.getElementsByTagName("INPUT");
        var langButtonCls = document.getElementsByTagName("BUTTON");
        var langSelectCls = document.getElementsByTagName("SELECT");
        var langDatalistCls = document.getElementsByTagName("DATALIST");

        function _languageReplaceElement(langObj, el, attr, langKey) {
            if (el) {
                var keyName;
                var textValue;

                if (langKey == null) {
                    if (attr == null) {
                        switch (el.nodeName) {
                            case "INPUT":
                                keyName = el.value;

                                break;
                            default:
                                if (el.innerText) {
                                    if ((el.innerText != "") && (el.innerText != null)) {
                                        keyName = el.innerText;
                                    } else {
                                        if (el.textContent) {
                                            keyName = el.textContent;
                                        } else {
                                            keyName = el.innerHTML;
                                        }
                                    }
                                } else {
                                    if (el.textContent) {
                                        keyName = el.textContent;
                                    } else {
                                        keyName = el.innerHTML;
                                    }
                                }

                                break;
                        }
                    } else {
                        if (el.hasAttribute(attr))
                            keyName = el.getAttribute(attr);
                    }
                } else {
                    keyName = langKey;
                }

                if ((el.nodeName == "SELECT") || (el.nodeName.toUpperCase() == "DATALIST")) {

                    if (el.options) {
                        for (j = 0; j < el.options.length; j++) {
                            var el_option = el.options[j];
                            var opt_value = el_option.value;
                            var text = langObj[keyName + "." + opt_value];

                            if (text) {
                                el_option.text = text;
                            }
                        }
                    }
                } else {
                    if (el.hasAttribute("langKey")) {
                        keyName = el.getAttribute("langKey");
                    } else {
                        el.setAttribute("langKey", keyName);
                    }

                    textValue = langObj[keyName];

                    if (textValue) {
                        if (attr == null) {
                            switch (el.nodeName) {
                                case "INPUT":
                                    el.value = textValue;
                                    break;
                                default:
                                    el.innerHTML = textValue;
                            }
                        } else {
                            el.setAttribute(attr, textValue);
                        }
                    }
                }

                el.style.display = "";
            }
        }

        function replaceByTag(langObj, TagName) {
            var els = document.getElementsByTagName(TagName);

            if (els) {
                for (i = 0; i < els.length; i++) {
                    var el = els[i];

                    if (el) {
                        if (el.hasAttribute("language_replace")) {
                            if (el.getAttribute("language_replace") == "1") {
                                _languageReplaceElement(langObj, el);
                            }
                        } else {
                            if (el.id) {
                                _languageReplaceElement(langObj, el, null, el.id);
                            }
                        }
                    }
                }
            }
        }

        function processLanguageReplaceAttrib(value, langObj, o) {
            if (value == "1") {
                _languageReplaceElement(langObj, o);
            } else {
                _languageReplaceElement(langObj, o, value);
            }
        }

        if (langCls) {
            for (var i = 0; i < langCls.length; i++) {
                var clsObject = langCls[i];

                for (var j = 0; j < _LanguageContextJSON.length; j++) {
                    var langObj = _LanguageContextJSON[j];

                    _languageReplaceElement(langObj, clsObject);
                }
            }
        }

        if (langInputCls) {
            for (var i = 0; i < langInputCls.length; i++) {
                var clsObject = langInputCls[i];

                if (clsObject.hasAttribute("language_replace")) {
                    for (var j = 0; j < _LanguageContextJSON.length; j++) {
                        var langObj = _LanguageContextJSON[j];

                        processLanguageReplaceAttrib(clsObject.getAttribute("language_replace"), langObj, clsObject);
                    }
                }
            }
        }

        if (langButtonCls) {
            for (var i = 0; i < langButtonCls.length; i++) {
                var clsObject = langButtonCls[i];

                if (clsObject.hasAttribute("language_replace")) {
                    for (var j = 0; j < _LanguageContextJSON.length; j++) {
                        var langObj = _LanguageContextJSON[j];

                        processLanguageReplaceAttrib(clsObject.getAttribute("language_replace"), langObj, clsObject);
                    }
                }
            }
        }

        if (langSelectCls) {
            for (var i = 0; i < langSelectCls.length; i++) {
                var clsObject = langSelectCls[i];

                if (clsObject.hasAttribute("language_replace")) {
                    for (var jj = 0; jj < _LanguageContextJSON.length; jj++) {
                        var langObj = _LanguageContextJSON[jj];

                        if (clsObject.getAttribute("language_replace") == "1") {
                            if (clsObject.id) {
                                _languageReplaceElement(langObj, clsObject, null, clsObject.id);
                            } else if (clsObject.name) {
                                _languageReplaceElement(langObj, clsObject, null, clsObject.name);
                            }
                        } else {
                            processLanguageReplaceAttrib(clsObject.getAttribute("language_replace"), langObj, clsObject);
                        }
                    }
                }
            }
        }

        if (langDatalistCls) {
            for (var i = 0; i < langDatalistCls.length; i++) {
                var clsObject = langDatalistCls[i];

                if (clsObject.hasAttribute("language_replace")) {
                    for (var j = 0; j < _LanguageContextJSON.length; j++) {
                        var langObj = _LanguageContextJSON[j];

                        if (clsObject.getAttribute("language_replace") == "1") {
                            if (clsObject.id) {
                                _languageReplaceElement(langObj, clsObject, null, clsObject.id);
                            } else if (clsObject.name) {
                                _languageReplaceElement(langObj, clsObject, null, clsObject.name);
                            }
                        } else {
                            processLanguageReplaceAttrib(clsObject.getAttribute("language_replace"), langObj, clsObject);
                        }
                    }
                }
            }
        }

        if (cb)
            cb();
    }

    this.getLanguageKey = function (key) {
        var retValue = key;

        if (key) {
            if (key != "") {
                if (_LanguageContextJSON != null) {
                    for (var _i = 0; _i < _LanguageContextJSON.length; _i++) {
                        var _o = _LanguageContextJSON[_i];

                        if (typeof _o[key] != 'undefined') {
                            retValue = _o[key];
                        }
                    }
                }
            }
        }

        return retValue;
    }

    this.loadLanguage = function (lang, cb) {
        if (lang) {
            if (lang != "") {
                var tmpIndex;
                var pageName;

                tmpIndex = window.location.pathname.lastIndexOf("/");
                if (tmpIndex != -1) {
                    pageName = window.location.pathname.substring(tmpIndex + 1);
                } else {
                    pageName = window.location.pathname;
                }

                _LanguageContextJSON = [];

                loadLanguageFromFile("/_Global." + lang + ".json", function () {
                    loadLanguageFromFile(pageName + "." + lang + ".json", function () {
                        DoLanguageReplace(cb);
                    });
                });
            } else {
                if (cb)
                    cb();
            }
        } else {
            if (cb)
                cb();
        }
    }
}
