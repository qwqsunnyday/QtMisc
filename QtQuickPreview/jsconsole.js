.pragma library

// var scope = {
//     window: 1
// }


function call(msg, scope) {
    var exp = msg.toString();
    console.log(scope)
    console.log(exp)
    console.log(_QObjectToJson(exp))
    var data = {
        expression: msg
    }
    try {
        var fun = new Function('return (' + exp + ');');
        data.result = JSON.stringify(fun.call(scope), null, 2)
        console.log('scope: ' + JSON.stringify(scope, null, 2) + 'result: ' + result)
    } catch (e) {
        console.log(e.toString())
        data.error = e.toString();
    }
    return data;
}


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
