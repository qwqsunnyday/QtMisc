
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

function getRepeaterItem(repeater, uuid) {
    for (let i = 0; i < repeater.count ; i++) {
        if (repeater.itemAt(i).uuid == uuid) {
            return repeater.itemAt(i)
        }
    }
    return undefined
}

function modelToJSON(model) {
    let str = "[\n"
    for (var i = 0; i < model.count; i++) {
        str += JSON.stringify(model.get(i)) + (i===model.count-1 ? "":",")+"\n"
    }
    str += "]"
    return str
}

function uuid() {
    uuid.count = ((typeof(uuid.count)=="undefined") ? 0 : uuid.count) + 1;

    // let str = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    let str = 'xxxxxxxx'
    return uuid.count + "-" + str.replace(/[xy]/g, item => {
      const r =Math.random() * 0x10 | 0
      const v = item === 'x' ? r : (r & 0x3 | 0x8)
      return v.toString(0x10)
    })
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

class DataProvider {
    constructor() {
        this.data = new Map();  // 使用 Map 来存储 uuid 和对象的键值对
    }

    // 生成UUID的简单实现
    generateUUID() {
        return uuid()
        // return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        //     const r = Math.random() * 16 | 0, v = c === 'x' ? r : (r & 0x3 | 0x8);
        //     return v.toString(16);
        // });
    }

    // 添加对象并返回其UUID
    append(object) {
        const uuid = this.generateUUID();
        this.data.set(uuid, object);
        return uuid;
    }

    // 根据UUID获取对象
    get(uuid) {
        return this.data.get(uuid) || null;  // 如果找不到，返回 null
    }

    // 根据UUID移除对象并返回被移除的对象
    remove(uuid) {
        const object = this.data.get(uuid);
        this.data.delete(uuid);
        return object || null;  // 如果找不到，返回 null
    }

    // 将数据转换为 JSON 字符串
    toJSON(uuid) {
        if (typeof(uuid) != "undefined") {
            return JSON.stringify(this.get(uuid), null, 2)
        }

        const jsonObject = {};
        this.data.forEach((value, key) => {
            jsonObject[key] = value;
        });
        return JSON.stringify(jsonObject, null, 2);  // 格式化 JSON 输出
    }

    // 将数据转换为字符串形式
    toString() {
        let str = '';
        this.data.forEach((value, key) => {
            str += `UUID: ${key}, Object: ${JSON.stringify(value)}\n`;
        });
        return str;
    }
    // // 使用示例
    // const provider = new DataProvider();

    // const uuid1 = provider.append({ name: "Alice", age: 30 });
    // const uuid2 = provider.append({ name: "Bob", age: 25 });

    // console.log("All data:");
    // console.log(provider.toString());

    // console.log("Get by UUID:");
    // console.log(provider.get(uuid1));

    // console.log("Remove by UUID:");
    // console.log(provider.remove(uuid2));

    // console.log("Data after removal:");
    // console.log(provider.toString());

    // console.log("Data in JSON format:");
    // console.log(provider.toJSON());
}

function dataProvider() {

    var provider = (typeof(provider) == "undefined") ? new DataProvider() : provider
    return provider
}

function copyToClipBoard(txt) {
    var object = Qt.createQmlObject("import QtQuick; TextEdit{id: textEdit; visible: false}", root)
    object.text = txt
    object.selectAll()
    object.copy()
}
