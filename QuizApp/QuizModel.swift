//
//  QuizModel.swift
//  QuizApp
//
//  Created by Rebecca Banks on 05/06/2020.
//  Copyright © 2020 Rebecca Banks. All rights reserved.
//

import Foundation

protocol QuizProtocol {
    
    // list of methods that the conformer has to implement
    
    func questionsRetrieved(_ questions:[Question])
}

class QuizModel {
    
    var delegate:QuizProtocol?
    
    func getQuestions() {
        
        // Fetch the questions
        getRemoteJsonFile()
    }
    
    func getLocalJsonFile() {
        
        // Get bundle path to json file
        let path = Bundle.main.path(forResource: "QuestionData", ofType: "json")
        
        // Double check that path isn't nil
        guard path != nil else{
            print ("Couldn't find the json data file")
            return
        }
        
        // Create URL object from the path
        let url = URL(fileURLWithPath: path!)
        
        do {
            // Get the data from the URL
            let data = try Data(contentsOf: url)
            
            // Try to decode the data into objects
            let decoder = JSONDecoder()
            let array = try decoder.decode([Question].self, from: data) // Don't need another "do" statement as it is already inside of one
            
            // Notify the delegate of the parsed objects
            delegate?.questionsRetrieved(array)
        }
        catch {
            // Error: Couldn't download the data at that URL
        }
    }
    
    func getRemoteJsonFile() {
        
        // Get a URL object
        let urlString = "https://raw.githubusercontent.com/rsbanks/JSON-For-Quiz-App/master/QuestionData.json"
        let url = URL(string: urlString)
        
        guard url != nil else{
            print("Couldn't create the URL object")
            return
        }
        
        // Get a URL session object
        let session = URLSession.shared
        
        // Get a datatask object
        let datatask = session.dataTask(with: url!) { (data, response, error) in
            
            // Check that there wasn't an error
            if error == nil && data != nil {
                
                do {
                    // Create a JSON Decoder object
                    let decoder = JSONDecoder()
                    
                    // Parse the data
                    let array = try decoder.decode([Question].self, from: data!)
                    
                    // Use the main thread to notify the main thread for UI work
                    DispatchQueue.main.async {
                        
                        // Notify the delegate
                        self.delegate?.questionsRetrieved(array)
                    }
                    
                }
                catch {
                    print("Could't parse JSON")
                }
                
            }
            
        }
        
        
        // Call resume on the data task
        datatask.resume()
        
        
    }
    
}
