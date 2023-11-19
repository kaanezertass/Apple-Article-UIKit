//
//  NewsTableViewCell.swift
//  NewspaperApp
//
//  Created by Kaan Ezerrtaş on 20.10.2023.
//

import UIKit

class NewsTableViewCellModel { //Bu, haber hücresinin görünüm modelini temsil eden sınıftır.
    let title: String //Haber başlığını temsil eden değişken.
    let subTitle: String //Haber alt başlığını temsil eden değişken.
    let imageURL: URL? // Haber resminin URL'sini temsil eden opsiyonel bir URL değişkenidir.
    var imageData: Data? = nil //Resim verilerini depolamak için kullanılan değişken bir Data özelliğidir.Başlangıç nil olarak tanımnlanmıştır çünkü resim verileri henüz yüklenmedi
    
    init(
        title: String,
        subTitle: String,
        imageURL: URL?
       
    ) {
        self.title = title
        self.subTitle = subTitle
        self.imageURL = imageURL
       
    }
}

class NewsTableViewCell: UITableViewCell {

   static let identifier = "NewsTableViewCell"
    
    private let newsTitleLbael: UILabel = { //UILabel oluşturma
       let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let subTitleLabel: UILabel = { //UILabel oluşturma
       let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    private let newsImageView: UIImageView = { //ImageView Oluşturmak
       let imageView = UIImageView()
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(newsImageView)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(newsTitleLbael)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Görünüm ayarlama
        newsTitleLbael.frame = CGRect(x: 10, y: 0, width: contentView.frame.size.width - 170, height: 70)
        subTitleLabel.frame = CGRect(x: 10, y: 70, width: contentView.frame.size.width - 170, height: contentView.frame.size.height/2)
        newsImageView.frame = CGRect(x: contentView.frame.size.width - 140, y: 5, width: 150, height: contentView.frame.size.height - 10)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        newsTitleLbael.text = nil
        subTitleLabel.text = nil
        newsImageView.image = nil
    }
    
    func configure(with viewModel: NewsTableViewCellModel){
        newsTitleLbael.text = viewModel.title
        subTitleLabel.text = viewModel.subTitle
        
        //Image
        if let data = viewModel.imageData { //Bu blok, viewModel'in imageData özelliğini kontrol eder. Eğer imageData doluysa, bu veriyi kullanarak bir UIImage oluşturur ve bu görüntüyü newsImageView adlı UIImageView'a ekler.
            newsImageView.image = UIImage(data: data)
        }
        else if let url = viewModel.imageURL{ //Bu blok, imageData özelliği boşsa ve imageURL özelliği doluysa çalışır.
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in //URLSession.shared.dataTask(with: url) ifadesi, verilen URL'den asenkron olarak veri indirmek için kullanılır.
                guard let data = data, error == nil else{ //Bu satır, indirilen verinin ve bir hata olup olmadığının kontrolünü yapar. Eğer hata varsa veya veri nil ise, işlemi sonlandırır.
                    return
                }
                viewModel.imageData = data //Bu satır, başarıyla indirilen veriyi viewModel'in imageData özelliğine atar.
                DispatchQueue.main.async {
                    self?.newsImageView.image = UIImage(data: data)
                } //Bu tür bir yapı, özellikle sunucudan resim indirme ve görüntüleme işlemleri gibi ağ tabanlı işlemleri gerçekleştirmek için kullanılır.
            }.resume()
        }
    }
}
