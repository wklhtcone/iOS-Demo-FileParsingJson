//
//  ViewController.swift
//  FileParsingJson
//
//  Created by 王凯霖 on 2/5/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    //json可能解析失败，因此result是可选型
    var result: Result?
    
    let tableView:UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        parseJson()
        view.addSubview(tableView)
        //设置subView在父视图中的位置frame
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
    }
    

    //TableView 数据源
    //section数
    func numberOfSections(in tableView: UITableView) -> Int {
        return result?.jsonData.count ?? 0
    }
    //section标题
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return result?.jsonData[section].title
    }
    
    //section中的行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let res = result {
            return res.jsonData[section].items.count
        }
        return 0
    }
    //行内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contents =  result?.jsonData[indexPath.section].items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = contents
        return cell
    }
    
    //Json
    func parseJson() {
        //获取path并转为url类型，可能获取失败，因此用guard
        guard let path = Bundle.main.path(forResource: "data",ofType: "json")
        else{
            return
        }
        let url = URL(fileURLWithPath: path)
        
        //Data(contentsOf: url)和JSONDecoder().decode()都可能失败抛出异常，因此放在do catch中，并try
        do {
            let jsonData = try Data(contentsOf: url)
            result = try JSONDecoder().decode(Result.self, from: jsonData)
//            if let res = result {
//                print(res)
//            }
//            else {
//                print("Json解析失败")
//            }
        }
        catch {
            print("Error:\(error)")
        }
    }
    



}

