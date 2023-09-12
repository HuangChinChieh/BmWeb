function SelectItem(object, itemValue) {
    var i;

    if (itemValue != "") {
        for (i = 0; i < object.options.length; i++) {
            if (object.options[i].value == itemValue || object.options[i].text == itemValue) {
                object.options[i].selected = true;
                break;
            }
        }
    } else {
        object.selectedIndex = -1;
    }
}

function SearchItem(object, itemValue) {
    var i;

    if (itemValue != "") {
        for (i = 0; i < object.options.length; i++) {
            if (object.options[i].value.substr(0, itemValue.length).toUpperCase() == itemValue.toUpperCase() || object.options[i].text.substr(0, itemValue.length).toUpperCase() == itemValue.toUpperCase()) {
                object.options[i].selected = true;
                break;
            }
        }
    } else {
        object.selectedIndex = -1;
    }
}

function addSelectItem(obj, newText, newValue) {
    var newOption;
    var doc;

    if (obj.form.ownerDocument) {
        doc = obj.form.ownerDocument;
    } else {
        doc = document;
    }
    newOption = doc.createElement("OPTION");
    newOption.text = newText;

    newOption.value = newValue;
    obj.options.add(newOption);
}

function clearSelectItem(obj) {
    var optLength;
    var i;

    optLength = obj.options.length;
    for (i = 0; i < optLength; i++) {
        obj.options.remove(0);
    }
}