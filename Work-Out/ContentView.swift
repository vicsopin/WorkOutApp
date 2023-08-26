//
//  ContentView.swift
//  Work-Out
//
//  Created by Victor Sopin on 04/06/2023.
//

import SwiftUI

// Define a gradient for the background
let backgroundGradient = LinearGradient(
    colors: [Color.blue, Color.red],
    startPoint: .top, endPoint: .bottom)

// Structure to represent an exercise
struct Exercise: Identifiable, Equatable {
    let id = UUID()
    let name: String
    var weight: Double
}

// Button style for a set number
struct SetButton: View {
    let number: Int
    let isSelected: Bool
    
    var body: some View {
        Text("\(number)")
            .font(.caption)
            .foregroundColor(isSelected ? .white : .white)
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
            .background(isSelected ? Color.red : Color.init(red: 0, green: 0, blue: 0))
            .cornerRadius(18)
    }
}

// Row representing an exercise in the workout view
struct ExerciseRow: View {
    @Binding var exercise: Exercise
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var selectedSet = 0
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack {
            // Display exercise name and weight input
            HStack {
                Text(exercise.name)
                    .font(.title)
                
                TextField("Weight", value: $exercise.weight, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .frame(width: 40)
                    .focused($isTextFieldFocused)
                
                Text("kg") // Add "kg" suffix here
                
                Spacer()
            }
            .padding()
            .onTapGesture {
                isTextFieldFocused = true
            }
            
            // Display buttons for sets and handle set selection
            HStack {
                ForEach(1...5, id: \.self) { setNumber in
                    SetButton(number: setNumber, isSelected: selectedSet == setNumber)
                        .onTapGesture {
                            selectedSet = setNumber
                            startTimer()
                        }
                }
            }
            .padding()
        }
    }
    
    // Start a countdown timer for the selected set
    func startTimer() {
        if !viewModel.isTimerRunning {
            viewModel.timerLabel = "1:30"
            viewModel.isTimerRunning = true
            
            let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                let minutes = Int(viewModel.timerLabel.split(separator: ":")[0]) ?? 0
                let seconds = Int(viewModel.timerLabel.split(separator: ":")[1]) ?? 0
                
                if minutes == 0 && seconds == 0 {
                    timer.invalidate()
                    viewModel.timerLabel = "Start next set!"
                    viewModel.isTimerRunning = false
                } else if seconds == 0 {
                    viewModel.timerLabel = "\(minutes - 1):59"
                } else {
                    viewModel.timerLabel = "\(minutes):\(String(format: "%02d", seconds - 1))"
                }
            }
            
            RunLoop.current.add(timer, forMode: .common)
        }
    }
}

// View model for the workout
class WorkoutViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var isTimerRunning = false
    @Published var timerLabel = "Timer"
    
    init() {
        // Initialize exercises with default weights
        exercises.append(Exercise(name: "Squat: ", weight: 20))
        exercises.append(Exercise(name: "Bench Press: ", weight: 20))
        exercises.append(Exercise(name: "Overhead Press: ", weight: 20))
        exercises.append(Exercise(name: "Barbell Row: ", weight: 20))
        exercises.append(Exercise(name: "Deadlift: ", weight: 20))
    }
}

// Timer display
struct TimerView: View {
    @Binding var timerLabel: String
    
    var body: some View {
        Text(timerLabel)
            .font(.title)
            .padding(1)
    }
}

// Main workout view
struct WorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.exercises.indices, id: \.self) { index in
                    ExerciseRow(exercise: $viewModel.exercises[index], viewModel: viewModel)
                }
            }
            .padding()
            .background(backgroundGradient)
        }
        .navigationBarTitle("WorkOut!")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(red: 250/255, green: 200/255, blue: 152/255))
        .overlay(
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    TimerView(timerLabel: $viewModel.timerLabel)
                        .font(.largeTitle)
                        .padding(.bottom, 16)
                        .frame(width: geometry.size.width)
                        .background(Color.white)
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
            }
        )
        .edgesIgnoringSafeArea(.bottom)
    }
}

// Main content view
struct ContentView: View {
    var body: some View {
        NavigationView {
            WorkoutView(viewModel: WorkoutViewModel())
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
