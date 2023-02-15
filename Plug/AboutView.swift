import SwiftUI

struct AboutView: View {
	var body: some View {
		VStack {
			Image(nsImage: NSImage(named: "Login-Logo")!)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 64, height: 64)
			Text(AppMeta.name)
				.font(.title3)
				.fontWeight(.bold)
			Spacer()
			Text("Version \(AppMeta.version) (\(AppMeta.build))")
			Spacer()
			Text(AppMeta.copyright)
			Spacer(minLength: 16)
			VStack(spacing: 2) {
				Text("Created by")
					.padding(.bottom, 2)
				Link("Sindre Sorhus", destination: "https://sindresorhus.com")
				Link("Alex Marchant", destination: "https://twitter.com/alex_marchant")
				Link("Glenn Hitchcock", destination: "https://glenn.me")
			}
				.buttonStyle(.link)
		}
			.font(.smallSystem())
			.padding()
			.frame(width: 280)
	}
}

#Preview {
	AboutView()
}
