import SwiftUI

struct ContentView: View {
    @Environment(EchoStore.self) private var store
    @Environment(EchoRouter.self) private var router

    var body: some View {
        QuizSurface()
            .sheet(item: Bindable(router).sheet) { sheet in
                Group {
                    switch sheet {
                    case .explore:
                        ExploreShelf()
                    case .saved:
                        SavedLedger()
                    case .settings:
                        EchoSettings()
                    case .twist:
                        EchoThenElide()
                    }
                }
                .presentationCornerRadius(EchoRadius.card)
                .presentationBackground(EchoColor.background)
            }
            .fullScreenCover(isPresented: Bindable(router).showsOnboarding) {
                EchoOnboarding {
                    store.markOnboardingComplete()
                    router.showsOnboarding = false
                    router.consumeReviewArguments()
                }
            }
            .onAppear {
                if store.document.onboardingComplete {
                    router.consumeReviewArguments()
                } else {
                    router.showsOnboarding = true
                }
            }
    }
}
