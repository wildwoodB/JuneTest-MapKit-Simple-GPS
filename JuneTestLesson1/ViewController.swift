//
//  ViewController.swift
//  JuneTestLesson1
//
//  Created by Админ on 03.10.2022.
//

import UIKit
import MapKit // библиотека для работы с эпловской картой
import CoreLocation // бибилиотека благодоря которой мы будем определять локацию по координатам из адреса

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    
    
    // создадим карту во вью контроллере.
    let mapView : MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        return mapView
    }()
    
    // создаем кнопки
    let addAdressButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "addAdress"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let routeButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "route"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let resetButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "reset"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let gpsButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "home"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // создаем массив анотаций (пустой)
    var annotationArray = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        setConstraints()
        // создаем таргеты для кнопок
        addAdressButton.addTarget(self, action: #selector(addAdressButtonTapped), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        gpsButton.addTarget(self, action: #selector(requestGpsButton), for: .touchUpInside)
        
        locationManager.delegate = self
        // запрос к пользователю на разрешение шеринга локации
        locationManager.requestWhenInUseAuthorization()
        // одноразовая доставка локации
        //locationManager.requestLocation()
        //mapView.showsUserLocation = true
    }
    
    @objc func requestGpsButton() {
        locationManager.requestLocation()
        gpsButton.alpha = 0.1
        UIView.animate(withDuration: 0.3) {
            self.gpsButton.alpha = 1.0
        }
    }
    
    // создаем методы экшена кнопок
    //кнопка добавить адрес
    @objc func addAdressButtonTapped() {
        //добаили экшена вызов алерт контроллера с хенделом текст, захватили текст из текстфилда.
        alertAddAdress(title: "Добавить", placeholder: "Введите адрес") { [self](text) in
            // установка анотации после нажатия на экшн алерт(текст передается из алерта филд текст!!)
            setupPlacemark(adresPlace: text)
        }
        addAdressButton.alpha = 0.1
        UIView.animate(withDuration: 0.3) {
            self.addAdressButton.alpha = 1.0
        }
    }
    // кнопка проложить маршурт
    @objc func routeButtonTapped() {
        //цикл для отрисовки линий пути между плейсмарками по индексу
        for index in 0...annotationArray.count - 2{
            //
            CreateDirectionRequest(startCoordinate: annotationArray[index].coordinate, destinationCoordinate: annotationArray[index + 1].coordinate)
        }
        
        mapView.showAnnotations(annotationArray, animated: true)
        routeButton.alpha = 0.1
        UIView.animate(withDuration: 0.3) {
            self.routeButton.alpha = 1.0
        }
    }
    // кнопка сброса
    @objc func resetButtonTapped() {
        // удаляем все оверлэи с карты
        mapView.removeOverlays(mapView.overlays)
        // удаляем все анотации
        mapView.removeAnnotations(mapView.annotations)
        // указываем пустой массив точек
        annotationArray = [MKPointAnnotation]()
        // прячем кнопки
        routeButton.isHidden = true
        resetButton.alpha = 0.1
        UIView.animate(withDuration: 0.3) {
            self.resetButton.alpha = 1.0
        }
        
    }
    
    // созждаем функцию добавления точек на карту
    private func setupPlacemark(adresPlace: String) {
        // создаем метод преобразования строки с адресом в координаты
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(adresPlace) { [self] placemarks, error in
            
            
            
            // создаем метод обработки ошибки (все просто)
            if let error = error {
                print(error)
                alertError(title: "Ошибка", message: "Сервер недоступен. Попробуйте ввести адрес снова.")
                return
            }
            // делаем проверку при помощи оператора гуард (?)
            guard let placemarks = placemarks else { return }
            // суть в том, что мы получаем массив из плейсмарков после запроса, так как улицы в разных городах могут повторяться, мы выбираем из массива первый = самый точный.
            let placemark = placemarks.first
            //создаем аннотацию (?), вставляем в его тайтл строку с адресом из текстфилда
            let annotation = MKPointAnnotation()
            annotation.title = "\(adresPlace)"
            // забираем из нашего плейсмарка координаты
            guard let placemarkLocation = placemark?.location else { return }
            // для нашей анотации мы присвоили координат от плейсмарка (?)
            annotation.coordinate = placemarkLocation.coordinate
            
            // метод доабвления нашей анностации в соотвествующий массив
            annotationArray.append(annotation)
            // метод показывающий кнопки после доабвления в массив 3х и более адресов
            if annotationArray.count > 1 {
                routeButton.isHidden = false
            }
            // вызываем метод показа анотации на карте
            mapView.showAnnotations(annotationArray, animated: true)
            
        }
        
    }
    
    private func setupPlacemarkGPS(latitude: Double, longitude: Double) {
        // создаем метод преобразования строки с адресом в координаты
        
        
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geocoder.reverseGeocodeLocation(location) { [self] placemarks, error in
            
            
            
            // создаем метод обработки ошибки (все просто)
            if let error = error {
                print(error)
                alertError(title: "Ошибка", message: "Сервер недоступен. Попробуйте ввести адрес снова.")
                return
            }
            
            // делаем проверку при помощи оператора гуард (?)
            guard let placemarks = placemarks else { return }
            // суть в том, что мы получаем массив из плейсмарков после запроса, так как улицы в разных городах могут повторяться, мы выбираем из массива первый = самый точный.
            let placemark = placemarks.first
            let city = placemark?.addressDictionary?["City"] as! String
            let name = placemark?.addressDictionary?["Name"] as! String
            //создаем аннотацию (?), вставляем в его тайтл строку с адресом из текстфилда
            let annotation = MKPointAnnotation()
            annotation.title = "\(city), \(name)"
            // забираем из нашего плейсмарка координаты
            guard let placemarkLocation = placemark?.location else { return }
            // для нашей анотации мы присвоили координат от плейсмарка (?)
            annotation.coordinate = placemarkLocation.coordinate
            
            // метод доабвления нашей анностации в соотвествующий массив
            annotationArray.append(annotation)
            // метод показывающий кнопки после доабвления в массив 3х и более адресов
            if annotationArray.count > 1 {
                routeButton.isHidden = false
            }
            // вызываем метод показа анотации на карте
            mapView.showAnnotations(annotationArray, animated: true)
            
        }
        
    }
    
    
    
    
    
    // метод сравнения точки старта и конца пути с помощью двух точек
    private func CreateDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        // создаем наальную и конечную локацию и присваиваем ей координаты
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        // делеаем сам запрос
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        // указываем свойство типа транспорта
        request.transportType = .walking
        // свойство показывающее альтернативные пути между точками
        request.requestsAlternateRoutes = true
        // создаем дерекшен (?)
        let diraction = MKDirections(request: request)
        diraction.calculate { responce, error in
            // проверяем респонс на наличие
            guard let responce = responce else {
                self.alertError(title: "Ошибка", message: "Маршрут недоступен.")
                return
            }
            
            if let error = error {
                print(error)
                return
            }
            // метод проверки и сверки длины дитсанции маршрутов (выдает самый минимальный короткий маршрут)
            var minRoute = responce.routes[0]
            // для маршрутов во всех маршрутах
            for route in responce.routes{
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            // метод добавления линии построения маршрута
            self.mapView.addOverlay(minRoute.polyline)
        }
    }
}
// расширение для вьюконтроллера для добавления и отрисовки линий между точками
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .green
        return renderer
    }
    
}


// создаем расширение для вью контроллера...
extension ViewController {
    // задаем констрейты
    func setConstraints() {
        // добавляем наш вью на основной вью
        view.addSubview(mapView)
        // указываем и активируем контрейнты
        NSLayoutConstraint.activate([
            // хадаем верхний/левый/правый/нижний контрейнты по 0
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        
        // размещаем наши кнопки во вью контроллере
        mapView.addSubview(addAdressButton)
        NSLayoutConstraint.activate([
            addAdressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            addAdressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            //задаем высоту и ширину кнопки
            addAdressButton.heightAnchor.constraint(equalToConstant: 70),
            addAdressButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        mapView.addSubview(routeButton)
        NSLayoutConstraint.activate([
            routeButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -30),
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -190),
            //задаем высоту и ширину кнопки
            routeButton.heightAnchor.constraint(equalToConstant: 50),
            routeButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        mapView.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -30),
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            //задаем высоту и ширину кнопки
            resetButton.heightAnchor.constraint(equalToConstant: 45),
            resetButton.widthAnchor.constraint(equalToConstant: 45)
        ])
        
        mapView.addSubview(gpsButton)
        NSLayoutConstraint.activate([
            gpsButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            gpsButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -100),
            gpsButton.heightAnchor.constraint(equalToConstant: 70),
            gpsButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
    }
    
}

extension ViewController {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations location: [CLLocation]) {
        if let location = location.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            setupPlacemarkGPS(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
