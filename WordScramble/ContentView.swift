//
//  ContentView.swift
//  WordScramble
//
//  Created by PRABALJIT WALIA     on 01/09/20.
//  Copyright © 2020 PRABALJIT WALIA    . All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var points = 0
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMsg = ""
    @State private var showingError = false
    var body: some View {
        NavigationView{
            VStack{
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                .padding()
                    .navigationBarItems(trailing: Button(action: startGame){
                        Text("Restart")
                    })
                
                List(usedWords,id: \.self){word in
                    HStack{
                    Image(systemName:"\(word.count).circle")
                    Text(word)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibility(label: Text("\(word), \(word.count) letters"))
                }
                Text("Your Score: \(points)")
            }
            .navigationBarTitle(rootWord)
        .onAppear(perform: startGame)
            .alert(isPresented: $showingError){
                Alert(title: Text(errorTitle), message: Text(errorMsg), dismissButton: .default(Text("OK")))
            }
        
        }
    }
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else{
            return
        }
        //Extra Validation
        guard isOriginal(word: answer) else{
            wordError(title: "Word used already", msg: "Think Different")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognised", msg: "You thought we won't notice. But We did.")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", msg: "That isn't a real word.")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
        points += 1*(answer.count)
        print(points)
    }
   
    func startGame(){
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL){
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
                // If we are here everything has worked, so we can exit

                return
            }
        }
        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("could not load start.txt from bundle")
    }
    func isOriginal(word: String)->Bool{
        !usedWords.contains(word)
    }
    func isPossible(word:String)->Bool{
        var tempWord = rootWord.lowercased()
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else{
                return false
            }
        }
        return true
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    func wordError(title: String, msg: String){
        errorMsg = msg
        errorTitle = title
        showingError = true
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
