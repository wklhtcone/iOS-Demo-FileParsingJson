## 1. 本地Json文件与运行效果

```javascript
{
    "jsonData": [
        {
            "title": "水果",
            "items": [
                "苹果",
                "香蕉",
                "梨",
                "西瓜"
            ]
        },
        {
            "title": "汽车",
            "items": [
                "宝马",
                "奔驰",
                "本田",
                "起亚"
            ]
        },
        {
            "title": "省份",
            "items": [
                "北京",
                "天津",
                "河北"
            ]
        }
    ]
}
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210206204820204.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM1MDg3NDI1,size_16,color_FFFFFF,t_70)
## 2. Json解析
### 数据结构

> Json是key-value的键值对，根据Json中的内容设计相应的数据结构才能正确解析数据：变量名和key一致、变量类型和value类型一致

1. 整个Json看作一个自定义结构体`Result`
- key是`"jsonData"`，value是另一个自定义结构体`ResultItem`的数组
2. `ResultItem`结构体：
- key是`"title"`，value是具体种类、类型为`String`；
- key是`"items"`，value是该种类具体内容、类型为`String`数组
3. 两个结构体都要遵守`Codable`协议
- Swift 4引入了`Codable`协议，与`NSCoding`协议不同的是：如果自定义的类中全都是基本数据类型、基本对象类型，它们都已经实现了`Codable`协议，那么这个自定义的类也默认实现了`Codable`，无需再实现编解码，只需要在自定义的类声明它遵守`Codable`协议即可

```swift
struct Result: Codable {
    let jsonData: [ResultItem]
}
struct ResultItem: Codable {
    let title: String
    let items: [String]
}
```

### 获取本地Json文件路径并转为URL
- 通过`mainBundle`获取 json 文件路径，因为可能找不到路径，比如文件名、类型名参数写错或文件不存在，因此要用`guard ... else`处理读不到的情况
- `URL(fileURLWithPath:)`方法将文件路径转为 url
```swift
guard let path = Bundle.main.path(forResource: "data",ofType: "json")
else{
    return
}
let url = URL(fileURLWithPath: path)
```

### 将URL内容读入NSData、再读入结构体
- `Data(contentsOf: url)`和`JSONDecoder().decode()`都可能失败`throw`异常，因此放在`do{} catch{}`中，并`try`
- 上面两个方法任意一个执行出错，`result`就成了`nil`，因此声明为可选型
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210206213107405.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM1MDg3NDI1,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/2021020621313046.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM1MDg3NDI1,size_16,color_FFFFFF,t_70)

```swift
var result: Result?
do {
    let jsonData = try Data(contentsOf: url)
    result = try JSONDecoder().decode(Result.self, from: jsonData)
}
catch {
    print("Error:\(error)")
}
```

## 3. 创建Table View并读入数据
###  代码方式创建Table View
- 设置Table View样式、cell复用identifier
- `{//代码体}()`，匿名函数格式，小括号表示立即调用大括号中定义的函数体

```swift
let tableView:UITableView = {
    let table = UITableView(frame: .zero, style: .grouped)
    table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    return table
}()
```


###  设置Table View
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    parseJson()
    //加入当前视图的子树图，并设置在父视图中的位置frame
    view.addSubview(tableView)
    tableView.frame = view.bounds
    //设置数据源和代理
    tableView.delegate = self
    tableView.dataSource = self
}
```

### 实现Table View的数据源方法
1. section数，即`ResultItem`数组中的元素个数，`result`为`nil`时返回 0

```swift
func numberOfSections(in tableView: UITableView) -> Int {
    return result?.jsonData.count ?? 0
}
```

2. section标题，`ResultItem`的`title`值

```swift
func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return result?.jsonData[section].title
}
```

3. 行数，`ResultItem`的`items`数组中的元素个数

```swift
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let res = result {
        return res.jsonData[section].items.count
    }
    return 0
}
```

4. 行内容，`ResultItem`的`items`数组中的值

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let contents =  result?.jsonData[indexPath.section].items[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = contents
    return cell
}
```

