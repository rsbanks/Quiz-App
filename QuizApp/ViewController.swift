//
//  ViewController.swift
//  QuizApp
//
//  Created by Rebecca Banks on 05/06/2020.
//  Copyright © 2020 Rebecca Banks. All rights reserved.
//

import UIKit

class ViewController: UIViewController, QuizProtocol, UITableViewDelegate, UITableViewDataSource, resultViewControllerProtocol {
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var stackViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stackViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rootStackView: UIStackView!
    
    var model = QuizModel()
    var questions = [Question]()
    var currentQuestionIndex = 0
    var numCorrect = 0
    
    var resultDialog:ResultViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialise the result dialog
        resultDialog = storyboard?.instantiateViewController(identifier: "ResultVC") as? ResultViewController
        resultDialog?.modalPresentationStyle = .overCurrentContext
        resultDialog?.delegate = self
        
        // Set self as the delegate and the datasource of the tableview
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set up the model
        model.delegate = self
        model.getQuestions()
        
    }
    
    func slideInQuestion() {
        
        // Set the initial state
        stackViewTrailingConstraint.constant = -1000
        stackViewLeadingConstraint.constant = 1000
        rootStackView.alpha = 0
        view.layoutIfNeeded()
        
        // Animate it to the end state
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.stackViewTrailingConstraint.constant = 0
            self.stackViewLeadingConstraint.constant = 0
            self.rootStackView.alpha = 1
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func slideOutQuestion() {
        
        // Set the initial state
        stackViewTrailingConstraint.constant = 0
        stackViewLeadingConstraint.constant = 0
        rootStackView.alpha = 1
        view.layoutIfNeeded()
        
        // Animate it to the end state
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.stackViewTrailingConstraint.constant = 1000
            self.stackViewLeadingConstraint.constant = -1000
            self.rootStackView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func displayQuestion() {
        
        // Check if there are questions & check that the curent question index is not out of bounds
        guard questions.count > 0 && currentQuestionIndex < questions.count else {
            return
        }
        
        // Display the question text
        questionLabel.text = questions[currentQuestionIndex].question
        
        // Reload the answers table
        tableView.reloadData()
        
        // Slide in the next question
        slideInQuestion()
    
    }
    
    // MARK: - Quiz Protocol Methods
    
    func questionsRetrieved(_ questions: [Question]) {
        // Get a reference to the questions
        self.questions = questions
        
        // Check of we should restore the state, before showing question #1
        let savedIndex = StateManager.retrieveValue(key: StateManager.questionIndexKey) as? Int
        
        if savedIndex != nil && savedIndex! < self.questions.count {
            // There is saved data
            
            // Set the current question to the saved index
            currentQuestionIndex = savedIndex!
            
            // Retrieve the number correct from storage
            let savedNumCorrect = StateManager.retrieveValue(key: StateManager.numCorrectKey) as? Int
            
            if savedNumCorrect != nil {
                numCorrect = savedNumCorrect!
            }
        }
        
        // Display the first question
        displayQuestion()
    }
    
    // MARK: - UITableView Delgate Methods
    
    // How many rows do you want the table to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Make sure that the questions array contains at least one question
        guard questions.count > 0 else {
            return 0
        }
        
        // Return the number of answers for this question
        let currentQuestion = questions[currentQuestionIndex]
        if currentQuestion.answers != nil {
            return currentQuestion.answers!.count
        }
        else {
            return 0
        }
        
    }
    
    // For row number, what tableview cell should I be displaying
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath)
        
        // Customise it
        let label = cell.viewWithTag(1) as? UILabel
        
        if label != nil {
            
            let question = questions[currentQuestionIndex]
            
            if question.answers != nil && indexPath.row < question.answers!.count {
                // Set the answer text for the label
                label!.text = question.answers![indexPath.row]
            }
            
        }
        
        // Return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var titleText = ""
        
        // User has tapped on a row, check if it's the right answer
        let question = questions[currentQuestionIndex]
        
        if question.correctAnswerIndex! == indexPath.row {
            // User got it right
            print("You got it right")
            
            titleText = "Correct!"
            numCorrect += 1
        }
        else {
            // User got it wrong
            print("You got it wrong")
            
            titleText = "Wrong!"
        }
        
        // Show the popup
        if resultDialog != nil {
            
            // Slide out question
            DispatchQueue.main.async {
                self.slideOutQuestion()
            }
            
            // Customise the dialog text 
            resultDialog!.titleText = titleText
            resultDialog!.feedbackText = question.feedback!
            resultDialog!.buttonText = "Next"
            
            DispatchQueue.main.async {
                self.present(self.resultDialog!, animated: true, completion: nil)
            }
        
        }
        
    }
    
    // MARK: - Result View Controller Protocol Methods
    
    func dialogDismissed() {
        
        // Increment the question
        currentQuestionIndex += 1
        
        // Check if there are more questions
        if currentQuestionIndex == questions.count {
            
            // The user has just answered the last question
            
            // Show a summary dialog
            if resultDialog != nil {
                
                // Customise the dialog text
                resultDialog!.titleText = "Summary"
                resultDialog!.feedbackText = "You got \(numCorrect) correct out of \(questions.count)"
                resultDialog!.buttonText = "Restart"
                
                present(resultDialog!, animated: true, completion: nil)
                
                // Clear state
                StateManager.clearState()
            }
            
        }
        else if currentQuestionIndex > questions.count {
            
            // Restart
            numCorrect = 0
            currentQuestionIndex = 0
            
            // Display and animate in the question
            displayQuestion()
            
        }
        else if currentQuestionIndex < questions.count {
            
            // Have more questions to show
            // Display the next question
            displayQuestion()
            
            // Save the state
            StateManager.saveState(numCorrect: numCorrect, questionIndex: currentQuestionIndex)
            
        }
        
    }

}

