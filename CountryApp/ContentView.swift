//
//  ContentView.swift
//  CountryApp
//
//  Created by Denisa Suciu on 19.09.2022.
//

import SwiftUI

struct Country: Hashable, Codable {
    let country: String
}
struct University: Hashable, Codable {
    let name: String
  
}

extension String {
    func containsWhitespaceAndNewlines() -> Bool {
        return rangeOfCharacter(from: .whitespacesAndNewlines) != nil
    }
}

class ViewModel: ObservableObject {
    @Published var countries: [Country] = []
    @Published var universities: [University] = []
    
    
    func fetch(url: String) {
        guard let url2 = URL(string:  url) else {
            isLoadingContries = false
                 return
             }
        
       
           
        let task = URLSession.shared.dataTask(with: url2) { [weak self] data, _, error in
            guard let data = data, error == nil else{
                isLoadingContries = false
                return
        }
            do {
                let countries = try JSONDecoder().decode([Country].self, from: data)
                DispatchQueue.main.async {
                    self?.countries = countries
                    isLoadingContries = false
                }
            }
            catch {
                print(error)
            }
        }
        
       task.resume()
    }
    
    
    func fetchDetails(country: String){
        var country = country
        let components: [String]
        
        if(country.containsWhitespaceAndNewlines()){
           components  = country.components(separatedBy: " ")
            country =  components.joined(separator: "%20")
        }
        
        guard let url = URL(string:
                "http://universities.hipolabs.com/search?country=\(country)") else {
            isLoadingDetails = false
          return
          }
        
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else{
                    isLoadingDetails = false
                    return
            }
                do {
                    let universities = try JSONDecoder().decode([University].self, from: data)
                    DispatchQueue.main.async {
                        self?.universities = universities
                        isLoadingDetails = false
                    }
                }
                catch {
                    print(error)
                }
            }
       
           task.resume()
    }
 }

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

 var isLoadingContries = true
var isLoadingDetails = true

struct ContentView: View {
    @StateObject var viewModel = ViewModel()

    var body: some View {
       
        NavigationView{
            
            List {
                if isLoadingContries {
                    HStack(spacing: 15) {
                        ProgressView()
                        Text("Loading…")
                    }
                } else {
                    ForEach(viewModel.countries.uniqued(), id: \.self){
                        country in HStack {
                            
                            NavigationLink("\(country.country)".capitalized,
                                           destination:
                                            
                                            List {
                                if isLoadingDetails {
                                    HStack(spacing: 15) {
                                        ProgressView()
                                        Text("Loading…")
                                    }
                                } else {
                                ForEach(viewModel.universities.uniqued(), id: \.self){
                                    university in HStack {
                                        Text (" \(university.name)")
                                    }
                                    
                                }
                            }
                                           }
                                .navigationBarTitle("Universities of \(country.country)",displayMode: .inline)
                                .onAppear{
                                    viewModel.fetchDetails(country: country.country ) }
                            )
                        }
                        
                    } .padding(3)
                }
            } .navigationTitle("Countries")
                .onAppear{
                    viewModel.fetch(url: "http://universities.hipolabs.com/search?country") }
        }
           
    }
    
}
       
    


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
