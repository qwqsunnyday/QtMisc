
function _QObjectToJson(qObject) {
    var jsonObject = {};
    var keys = Object.keys(qObject);
    // console.log(keys)
    // console.log(keys[0]+" _ "+qObject[keys[0]]+" _ "+qObject.valueOf(keys[0])["text"]+" _ "+qObject["text"])
    for (var i = 0; i < keys.length ; i++) {
        var value = qObject[keys[i]]
        // 防止循环引用
        if (value !== undefined && keys[i] !== "parent") {
            jsonObject[keys[i]] = value;
        }
    }
    // return JSON.stringify(jsonObject, ["text"], 4);
    return JSON.stringify(jsonObject, null, 4);
}

function getModelIndex(model, idFieldString) {
    for (var i = 0; i < model.count; i++) {
        if (model.get(i).modelData === value) {
            return i;
        }
    }
    return -1;
}
