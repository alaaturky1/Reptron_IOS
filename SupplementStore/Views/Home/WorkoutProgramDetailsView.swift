import SwiftUI

struct WorkoutProgramDetailsView: View {
    let program: WorkoutProgram

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 15/255, green: 23/255, blue: 42/255),
                    Color(red: 30/255, green: 41/255, blue: 59/255),
                    Color(red: 15/255, green: 23/255, blue: 42/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Image(program.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 220)
                        .clipped()
                        .cornerRadius(16)
                        .padding(.top, 16)

                    Text(program.title)
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text(program.description)
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))

                    PageFooterView()
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle(program.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        WorkoutProgramDetailsView(program: WorkoutProgram(id: 1, image: "Strength Training", title: "Strength Training", description: "Build maximum muscle and increase explosive power."))
    }
}
