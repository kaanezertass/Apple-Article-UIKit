//
//  APICaller.swift
//  NewspaperApp
//
//  Created by Kaan Ezerrtaş on 19.10.2023.
//

import Foundation


final class APICaller{
    static let shared = APICaller() //Api çağırma metodunu shared değişkenine atıyoruz
    
    struct Constants { //Bu URL, "apple" kelimesini içeren haber başlıklarını belirli bir tarihe (18 Ekim 2023) kadar olan popülerlik sırasına göre sıralayan bir isteği temsil eder.
        static let topHeadLinesURL = URL(string:  "https://newsapi.org/v2/everything?q=apple&from=2023-10-18&to=2023-10-18&sortBy=popularity&apiKey=f70fbb79c5cd4b64a9f62615523ac879")
    }
    
    private init() {}
    
    public func getTopStories(completion: @escaping (Result<[Article], Error>) -> Void){ //Bu, dışarıdan çağrılabilen ve haberleri almak için tasarlanmış bir fonksiyonu temsil eder. Result türü, bu fonksiyonun çağrıldığı yerde başarılı veya başarısız durumları iletmek için kullanılır.
        guard let url = Constants.topHeadLinesURL else{ //Bu, Constants yapısındaki topHeadlinesURL özelliğini kullanarak bir URL oluşturur.  
            return
        }
        let task = URLSession.shared.dataTask(with: url) {  data, _, error in //Bu ifade, belirli bir URL ile bir HTTP GET isteği oluşturan bir URLSessionDataTask nesnesini döndürür. Bu nesne, asenkron olarak çalışır ve veri transferi tamamlandığında bir kapanma (closure) çağırır.
            if let error = error { //herhangi bir hata durumunda yapılan işlemler
                completion(.failure(error))
            }
            else if let data = data { //Eğer data değişkeni değeri nil değilse, bu bloğa girilir. Bu blok, veri varsa bir sonraki işlemleri gerçekleştirecek.
                
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data) //Bu satır, JSONDecoder'ı kullanarak data'yı APIResponse yapısına dönüştürmeye çalışır. Bu işlem, try ve catch blokları içinde gerçekleştirilir çünkü dönüştürme işlemi başarısız olabilir
                    
                    print("Articles: \(result.articles.count)")
                    completion(.success(result.articles))
                }
                catch{
                    completion(.failure(error)) //Hata mesajı
                }
            }
        }
        
        task.resume()
    }
}

//Models

struct APIResponse: Codable{ //Bu, bir haber API'sinden alınan verileri temsil eden yapıdır. articles adlı bir özellik içerir, bu özellik bir [Article] türünden bir dizi (array) içerir.
    let articles: [Article]
}

struct Article: Codable { //Codable protokolü sayesinde, Swift yapıları otomatik olarak JSON formatındaki verilerle uyumlu hale getirilebilir ve bu yapılar arasında kolayca dönüşüm yapılabilir.
    let sourche: Source?
    let title: String //Haber makalesinin başlığı tutulur
    let description: String? //Haber makalesinin açıklamasını tutar
    let url: String? //Haber makalesinin web sayfasının urlini tutar
    let urlToImage: String? //Haber makalesinin resminin urlini tutar
    let publishedAt: String //Haber makalesinin yayınlanma tarihini tutar
}

struct Source: Codable{
    let name: String //Haber kaynadğının adını tutar
    
}
