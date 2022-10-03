//
//  Alert.swift
//  JuneTestLesson1
//
//  Created by Админ on 03.10.2022.
//

import UIKit

// здесь мы создаем расширение для вью контроллера в котором создаем алерт контроллер для оповещения об ошибке и ввода адреса
extension UIViewController {
    
    func alertAddAdress(title: String, placeholder: String, completionHandler: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default) { action in
            // создаем захват текста из текстфилда(захватывает первый так как он у нас единственный).
            let tfText = alertController.textFields?.first
            // так как текст у нас опцианальный мы проверяем, если мы сможем получить текст из нашего текстфилда то мы присваиваем его в нашу переменную text, если нет то мы выходим из метода ({ ruturn }).
            guard let text = tfText?.text else { return }
            completionHandler(text)
            
            
        }
        
        // создаем текст филд внутри алерта с перменной тф из которой мы будем доставать текст, так же указываем плейсхолдер
        alertController.addTextField { (tf) in
            tf.placeholder = "\(placeholder)"
        }
        // кнопка отмены
        let alertCancel = UIAlertAction(title: "Отмена", style: .default) { _ in
        }
        
        //добавляем экшены
        alertController.addAction(alertOk)
        alertController.addAction(alertCancel)
        //вызываем алерт контроллер
        present(alertController, animated: true, completion: nil)
        
    }
    
    //добавили алерт ошибки, все так же как и с алертом ввода текста
    func alertError(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(alertOk)
        present(alertController, animated: true, completion: nil)
        
    }
    
}
