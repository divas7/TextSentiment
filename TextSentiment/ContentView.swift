import SwiftUI
import CoreML
import NaturalLanguage

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var sentiment: String = "Enter a sentence to analyze sentiment"
    @State private var sentimentImage: String = ""

    var body: some View {
        ZStack {
            // Subtle blue background gradient
            LinearGradient(gradient: Gradient(colors: [Color(.sRGB, red: 0.6, green: 0.7, blue: 0.9, opacity: 1), Color(.sRGB, red: 0.3, green: 0.4, blue: 0.6, opacity: 1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Text("Sentiment Analyzer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 50)
                    .shadow(radius: 5)

                TextField("Type your text here...", text: $userInput)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal, 20)

                Button(action: {
                    self.analyzeSentiment()
                }) {
                    Text("Analyze Sentiment")
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: 250)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)]), startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .padding(.top, 20)

                Text(sentiment)
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding()
                    .background(
                        BlurView(style: .systemMaterial)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .animation(.easeInOut(duration: 0.3))

                if !sentimentImage.isEmpty {
                    Image(sentimentImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .transition(.scale)
                        .animation(.spring())
                }

                Spacer()
            }
            .padding()
        }
    }

    func analyzeSentiment() {
        // Handle model loading with proper configuration
        do {
            let config = MLModelConfiguration()
            let model = try TwitterSentiment(configuration: config)

            let sentimentPredictor = try NLModel(mlModel: model.model)
            
            // Predict the sentiment from text
            if let prediction = sentimentPredictor.predictedLabel(for: userInput) {
                DispatchQueue.main.async {
                    self.updateSentiment(result: prediction)
                }
            } else {
                sentiment = "Could not analyze sentiment"
            }

        } catch {
            sentiment = "Error loading model: \(error.localizedDescription)"
        }
    }

    func updateSentiment(result: String) {
        switch result {
        case "Pos":
            sentiment = "The sentiment is Positive"
            sentimentImage = "positiveImage"
        case "Neg":
            sentiment = "The sentiment is Negative"
            sentimentImage = "negativeImage"
        case "Neutral":
            sentiment = "The sentiment is Neutral"
            sentimentImage = "neutralImage"
        default:
            sentiment = "Unable to determine sentiment"
            sentimentImage = ""
        }
    }
}

// Custom blur view for frosted glass effect
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
