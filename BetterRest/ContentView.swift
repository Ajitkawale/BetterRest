//
//  ContentView.swift
//  BetterRest
//
//  Created by AJit Kawale on 28/09/25.
//
import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffieeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    
    var body: some View {
        NavigationStack{
            Form {
                VStack(alignment: .leading, spacing: 0){
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0){
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours" , value: $sleepAmount , in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 0){
                    Text("Daily coffee intake")
                        .font(.headline)
                    Stepper("^[\(coffieeAmount) cup](inflect: true)" , value: $coffieeAmount , in: 1...10)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showingAlert){
                Button("OK"){}
            } message: {Text(alertMessage)}
            
            
        
            
            
        
    }
  }
func calculateBedTime() {
    do{
        let config = MLModelConfiguration()
        let model = try SleepCalculator(configuration: config)
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffieeAmount))
        
        
        let sleepTime = wakeUp - prediction.actualSleep
        
        alertTitle = "Your ideal bedtime is..."
        alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        
        
    } catch {
        alertTitle = "Error"
        alertMessage = "Something went wrong please try again"
        
    }
    showingAlert = true
    
  }
}

#Preview {
    ContentView()
}
