//
//  ContentView.swift
//  Arvalap
//
//  Created by Caio on 02/07/24.
//

import SwiftUI

func areAllCharactersContained(in array1: [Character], within array2: [Character]) -> Bool {
    // Conta as ocorrências de cada caractere no array1
    var count1: [Character: Int] = [:]
    for char in array1 {
        count1[char, default: 0] += 1
    }

    // Conta as ocorrências de cada caractere no array2
    var count2: [Character: Int] = [:]
    for char in array2 {
        count2[char, default: 0] += 1
    }

    // Verifica se cada caractere em count1 tem ocorrências suficientes em count2
    for (char, count) in count1 {
        if count2[char, default: 0] < count {
            return false
        }
    }
    return true
}

func noString(_ searchString: String, in array: [(String, Bool)]) -> Bool {
    return !array.contains { $0.0 == searchString }
}


struct ContentView: View {
    @State private var words: [(word: String, correct: Bool)] = []
    @State private var currentWord = ""
    @State private var guess = ""
    @State private var cwArray: [Character] = []
    @State private var score = 0
    @State private var lives = 5
    @FocusState private var isFocused: Bool
    var body: some View {
        ZStack {
            Color(.secondaryLabel).frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea().onTapGesture {
                isFocused = false
            }
            VStack {
                Text(currentWord).font(.title.bold()).foregroundStyle(.white)
                VStack {
                    List {
                        ForEach(words.indices, id: \.self) { index in
                            Text(words[index].word).foregroundStyle(.white).listRowBackground(words[index].correct ? Color.green : Color.red)
                        }
                    }.listStyle(.plain).background(.white)
                }.frame(width: 300, height: 320).background(.thickMaterial).clipShape(.rect(cornerRadius: 30))
                
                Text("pontos = \(score) | vidas = \(lives)").font(.headline.bold()).foregroundStyle(.white)
                
                TextField("", text: $guess).background(.white).padding(.horizontal, 50).padding(.vertical, 20).foregroundStyle(.black).focused($isFocused).textInputAutocapitalization(.never).onSubmit {
                    checkWord()
                }
                
                HStack {
                    Button {
                        if guess != "" && guess.count >= 2 && guess != currentWord {
                            withAnimation(.bouncy(duration: 0.7)) {
                                checkWord()
                            }
                        }
                    } label: {
                        Text("Enviar").padding().font(.title2.bold()).background(.white).foregroundStyle(.blue).clipShape(.rect(cornerRadius: 20))
                    }
                    
                    Button {
                        start()
                    } label: {
                        Text("Mudar").padding().font(.title2.bold()).background(.white).foregroundStyle(.blue).clipShape(.rect(cornerRadius: 20))
                    }
                }
                
            }
        }.onAppear(perform: {
            start()
        })
    }
    
    func start() {
        do {
            currentWord = try getRandomWord()
            cwArray = currentWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).sorted()
            guess = ""
            words = []
            score = 0
            lives = 5
        } catch {
            currentWord = "erro"
        }

    }
    
    func getRandomWord() throws -> String {
        if let text = Bundle.main.url(forResource: "palavras", withExtension: ".txt") {
            if let array = try? String(contentsOf: text) {
                return array.components(separatedBy: "\n").randomElement() ?? "Erro"
            }
        }
        fatalError("Could not load words from bundle.")
    }

    func checkWord() {
        let word = guess.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).sorted()
        
        // Checando se a palavra está certa
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: guess.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: guess, range: range, startingAt: 0, wrap: false, language: "pt")
        
        let isValid = (areAllCharactersContained(in: word, within:  cwArray)) && (misspelledRange.location == NSNotFound) && noString(guess, in: words)
        
        if isValid {
            score += 1
        } else {
            lives -= 1
            if lives == 0 {
                start()
            }
        }
        
        words.insert((word: guess.lowercased(), correct: isValid), at: 0)
        guess = ""
    }
    
    func testStrings() {
        let input = "a b c"
        _ = input.components(separatedBy: " ")
        let word = "    ola mundo    "
        _ = word.trimmingCharacters(in: .whitespacesAndNewlines)
        //print(trimmed)
        
        let word2 = "trige"
        let checker = UITextChecker()
        
        let range = NSRange(location: 0, length: word2.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "pt-BR")
        
        let allGood = misspelledRange.location == NSNotFound
        if allGood {
            print("All good!")
        } else {
            print(misspelledRange.location)
        }
    }
}


#Preview {
    ContentView()
}

//List {
//    Section ("Section 1") {
//        Text("Static row 1")
//        Text("Static row 2")
//    }
//    
//    Section ("Section 2") {
//        ForEach(1..<5) {
//            Text("Dynamic row \($0)")
//        }
//    }
//    
//    Section ("Section 3") {
//        Text("Static row 3")
//        Text("Static row 4")
//    }
//}.listStyle(.grouped)
//
//List(5..<8) {
//    Text("Dynamic row \($0)")
//}
