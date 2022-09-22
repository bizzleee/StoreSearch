//
//  ViewController.swift
//  StoreSearch
//
//  Created by Alejandro Pallares on 09/07/22.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
   

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.contentInset = UIEdgeInsets(top: 51, left: 0, bottom: 0, right: 0)
        
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        searchBar.becomeFirstResponder()
    }
    
    
    var searchResults = [SearchResult]()
    
    var hasSearch = false
    
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
        }
    }
    
//MARK: Helper methods
    
    func iTunesURL(searchText: String) -> URL {
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let urlString = String(format: "https://itunes.apple.com/search?term=%@", encodedText)
        
        let url = URL(string: urlString)
        
        return url!
    }
    
    func performStoreRequest(with url: URL) -> Data? {
        do {
            return try Data(contentsOf: url)
        } catch {
            print("Error: \(error.localizedDescription)")
            showNetworkError()
            return nil
        }
    }
    
    func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch {
            print("JSON Error: \(error)")
            return []
        }
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops..", message: "There was an error accesing the iTunes store. Please try again.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        
        present(alert, animated: true,completion: nil)
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if !searchBar.text!.isEmpty {
            
            hasSearch = true
            searchResults = []
            
            let url = iTunesURL(searchText: searchBar.text!)
            
            print("URL: \(url)")
            
            if let jsonData = performStoreRequest(with: url) {
                searchResults = parse(data: jsonData)
                searchResults.sort(by: <)
                print("Results: \(searchResults)")
            }
 
            tableView.reloadData()

        }
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !hasSearch {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchResults.count == 0 {
            
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            
            let searchResult = searchResults[indexPath.row]
            
            cell.nameLabel.text = searchResult.name
            
            if searchResult.artist.isEmpty {
                cell.artistNameLabel.text = "UnKnown"
            } else {
                cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artist, searchResult.type)
            }
            return cell
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
