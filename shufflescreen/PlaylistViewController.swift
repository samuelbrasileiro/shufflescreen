//
//  PlaylistViewController.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 08/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit

class PlaylistsViewController: UITableViewController {
    
    var selectedItem: Int = -1
    var playlists: [Item] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.lightGray
        self.load()
    }
    
    
    func load() {
        let semaphore = DispatchSemaphore(value: 0)
        
        let spotifyCode = ""
        
        var request = URLRequest(url: URL(string: "https://api.spotify.com/v1/me/playlists")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.addValue("Bearer \(spotifyCode)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                let decoder = JSONDecoder()
                //           let playlists = try JSONSerialization.jsonObject(with: data, options: [])
                let playlists = try decoder.decode(Playlists.self, from: data!)
                
                DispatchQueue.main.async {
                    //           print(playlists)
                    self.playlists = playlists.items
                    self.tableView.reloadData()
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                }
            }
            guard let data = data else {
                print(String(describing: error))
                return
            }
            print(String(data: data, encoding: .utf8)!)
            print(self.playlists)
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
    
    
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Qual a sua preferida?"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! PlaylistsTableViewCell
        
        cell.textLabel?.text = playlists[indexPath.row].name
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if segue.identifier == "PlaylistsToPlayer", case let nextVC = segue.destination as? PlayerViewController {
        //    nextVC?.item = playlists[self.selectedItem]
        //}
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.selectedItem = indexPath.row
        
        return indexPath
        
    }
}

class PlaylistsTableViewCell: UITableViewCell{
    
}
