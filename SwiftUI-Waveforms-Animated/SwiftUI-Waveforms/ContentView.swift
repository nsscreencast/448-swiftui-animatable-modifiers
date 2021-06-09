import SwiftUI

struct WaveFormShape: Shape {
    
    var points: [Double]
    
    private func normalizedPoints(in rect: CGRect) -> [CGPoint] {
        let points = self.points
        return points.enumerated().map { (offset, point) in
            let screenX = CGFloat(offset) * rect.width / CGFloat(points.count - 1)
            let screenY = rect.midY - rect.height/2 * CGFloat(point)
            return CGPoint(x: screenX, y: screenY)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { p in
            let points = self.normalizedPoints(in: rect)
            p.addLines(points)
        }
    }
}

struct AnimatableGraph: AnimatableModifier {
    var amplitude: Double
    var frequency: Double
    var phase: Double
    
    var animatableData: AnimatablePair<Double, AnimatablePair<Double, Double>> {
        get { .init(amplitude, .init(frequency, phase)) }
        set {
            amplitude = newValue.first
            frequency = newValue.second.first
            phase = newValue.second.second
        }
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(GraphView(amplitude: amplitude, frequency: frequency, phase: phase))
    }
}

struct GraphView: View {
    
    var amplitude: Double = 2
    var frequency: Double = 1
    var phase: Double = 0
        
    var range: ClosedRange<Double> = (-2 * .pi)...(2 * .pi)
    var steps: Int = 300
    
    var points: [Double] {
        var points: [Double] = []
        
        let xStride = (range.upperBound - range.lowerBound) / Double(steps-1)
        
        for x in stride(from: range.lowerBound, through: range.upperBound, by: xStride) {
            let y = sineFunc(x: x) * taperFunc(x: x)
            points.append(y)
        }
        
        return points
    }
    
    private func sineFunc(x: Double) -> Double {
        amplitude * sin(frequency * x - phase)
    }
    
    private func taperFunc(x: Double) -> Double {
        let K: Double = 1
        return pow((
            K /
            (K + pow(x, 4))
        ), K)
    }
    
    var body: some View {
        WaveFormShape(
            points: points
        )
        .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
    }
}

struct ContentView: View {
    
    @State var amplitude: Double = 1
    @State var frequency: Double = 2
    @State var phase: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient.pinkToBlack
            VStack {
                Color.clear
                    .modifier(AnimatableGraph(amplitude: amplitude, frequency: frequency, phase: phase))
//                    .animation(.interpolatingSpring(stiffness: 20, damping: 2), value: frequency)
//                    .animation(.default, value: amplitude)
                    .blendMode(.overlay)
                    .frame(height: 200)
                
                HStack {
                    Button(action: {
                        withAnimation(.default) {
                            amplitude = Double.random(in: 0...3)
                            frequency = Double.random(in: 1...10)
                        }
                    }) {
                        Text("Randomize")
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(Animation.linear(duration: 0.15).repeatForever(autoreverses: false)) {
                            phase -= 2 * .pi
                        }
                    }) {
                        Text("Phase Animation")
                    }
                }
                .padding()
                
                VStack {
                    ParamSlider(label: "A", value: $amplitude, range: 0...3)
                    ParamSlider(label: "k", value: $frequency, range: 1...10)
                    ParamSlider(label: "t", value: $phase, range: 0...(.pi * 40))
                }
                .padding()
            }
        }.edgesIgnoringSafeArea(.all)
    }
}



















extension LinearGradient {
    static var pinkToBlack = LinearGradient(gradient: Gradient(colors: [Color.pink, Color.black]), startPoint: .top, endPoint: .bottom)
}


struct ParamSlider: View {
    var label: String
    var value: Binding<Double>
    var range: ClosedRange<Double>
    
    var body: some View {
        HStack {
            Text(label)
            Slider(value: value, in: range)
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.colorScheme, .dark)
            .accentColor(.pink)
    }
}
