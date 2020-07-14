//
//  Question.swift
//  QuizApp
//
//  Created by Rebecca Banks on 05/06/2020.
//  Copyright © 2020 Rebecca Banks. All rights reserved.
//

import Foundation

struct Question: Codable {
    
    var question:String?
    var answers:[String]?
    var correctAnswerIndex:Int?
    var feedback:String?
    
}
