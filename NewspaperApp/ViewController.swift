//
//  ViewController.swift
//  NewspaperApp
//
//  Created by Kaan Ezerrtaş on 19.10.2023.
//

import UIKit
import SafariServices

//    KULLANILACAK KONTROLLER

// TableView
//Custom Cell
//API
//

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = { //UITableView Oluşturmak
        let table = UITableView() //UITableView özelliği oluşturmak-dışardan erişilemez
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier) //Oluşturulan tabloya, NewsTableViewCell adında bir hücre sınıfını ve bu hücre için bir tanımlayıcı (identifier) ekler. Bu, tablo görünümünün bu özel hücre sınıfını ve tanımlayıcıyı kullanarak hücreleri yeniden kullanmasını sağlar.
        return table
    }()
    private var articles = [Article]() //Bu dizi, makale verilerini saklamak için kullanılır.
    private var viewModel = [NewsTableViewCellModel]() // haber hücrelerinin (cell) görünüm modelini temsil eden bir türdür. Bu dizi, tablonuzdaki hücrelerin görünüm modeli bilgilerini saklamak için kullanılır.
    
    override func viewDidLoad() {
        super.viewDidLoad() //
        title = "Apple Makaleler" //Başlık
        view.addSubview(tableView) // TableView'ı görünüm hiyerarşisine ekle
        tableView.delegate = self //TableView için delegeleri ve veri kaynaklarını ayarla
        tableView.dataSource = self //TableView için delegeleri ve veri kaynaklarını ayarla
        view.backgroundColor = .systemBackground //Görünüm arkaplan rengini ayarla (sistem arkaplan rengine uyumlu)
        
        fetchTopStories() //En popüler haberleri getiren bir fonksiyonu çağır
    }
    
    private func fetchTopStories() {
        
        APICaller.shared.getTopStories { [weak self] result in // fonksiyonunu kullanarak bir API çağrısı yapar ve dönen sonuca (result) göre bir switch-case ifadesi ile işlem yapar.
            switch result{
            case.success(let articles): //case .success(let articles): durumunda, API çağrısı başarılı olmuşsa:
                self?.articles = articles //Gelen haberleri (articles) self?.articles adlı özelliğe atar.
                self?.viewModel = articles.compactMap({ //.compactMap bu dizi üzerinde bir dönüşüm işlemi yapar.Bu durumda, her bir Article nesnesini NewsTableViewCellModel'e dönüştürmek için kullanılır.
                    NewsTableViewCellModel(title: $0.title, subTitle: $0.description ?? "No Description", imageURL: URL(string: $0.urlToImage ?? "")) //Bu, her bir Article nesnesini NewsTableViewCellModel türünden bir nesneye dönüştürmek için kullanılır
                })
                
                DispatchQueue.main.async{
                    self?.tableView.reloadData() //Bu, tableView adlı UITableView'ın reloadData metodunu çağırarak tablonun verilerini güncellemesini sağlar.Güncel verileri göstermesini sağlar
                }
            case .failure(let error): //case .failure(let error): durumunda, API çağrısı başarısız olmuşsa, bir hata mesajını yazdırır.
                print(error)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else {
            fatalError()
        }
        
        cell.configure(with: viewModel[indexPath.row])
        return cell
    }
    //Table View
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = articles[indexPath.row]
        
        guard let url = URL(string: article.url ?? "") else {
            return
        }
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

