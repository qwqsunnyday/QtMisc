
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

function getModelIndex(model, idFieldString, value) {
    for (var i = 0; i < model.count; i++) {
        if (model.get(i)[idFieldString] === value) {
            return i;
        }
    }
    return -1;
}

function modelToJSON(model) {
    let str = "\n"
    for (var i = 0; i < model.count; i++) {
        str = str + JSON.stringify(model.get(i)) + "\n"
    }
    return str
}

function uuid() {
    uuid.count = ((typeof(uuid.count)=="undefined") ? 0 : uuid.count) + 1;
    console.log("uuid: " + uuid.count)
    return uuid.count
}

function printf(format, num) {
  // 匹配类似 %3d 的格式
  let match = format.match(/%(\d+)d/);
  if (match) {
    let width = parseInt(match[1], 10);
    let numStr = num.toString();

    // 计算需要填充的空格数
    let padding = ' ';
    let padLength = width - numStr.length;

    // 生成指定长度的空格字符串
    let paddedStr = '';
    for (let i = 0; i < padLength; i++) {
      paddedStr += padding;
    }

    // 返回格式化的字符串
    // console.log(paddedStr + numStr)
    return paddedStr + numStr;
  }
  return num.toString();
}
