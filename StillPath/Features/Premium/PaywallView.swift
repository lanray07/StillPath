import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(EntitlementStore.self) private var store

    var body: some View {
        ScrollView { VStack(spacing: StillPathSpacing.lg) {
            Image(systemName: "circle.hexagongrid.fill").font(.system(size: 54)).foregroundStyle(StillPathColor.sage)
            VStack(spacing: StillPathSpacing.sm) { Text("premium.title").font(.system(.largeTitle, design: .serif, weight: .semibold)).multilineTextAlignment(.center); Text("premium.body").foregroundStyle(.secondary).multilineTextAlignment(.center) }
            StillPathCard { VStack(alignment: .leading, spacing: StillPathSpacing.md) { Benefit(icon: "waveform", text: "premium.voice"); Benefit(icon: "translate", text: "premium.translation"); Benefit(icon: "sparkles", text: "premium.ai"); Benefit(icon: "magnifyingglass", text: "premium.search"); Benefit(icon: "icloud", text: "premium.sync") } }
            if store.products.isEmpty { if store.isLoading { ProgressView() } else { Text("premium.unavailable").foregroundStyle(.secondary) } }
            ForEach(store.products, id: \.id) { product in Button { Task { await store.purchase(product) } } label: { HStack { VStack(alignment: .leading) { Text(product.displayName).font(.headline); if let offer = product.subscription?.introductoryOffer { Text(offer.displayPrice).font(.caption) } }; Spacer(); Text(product.displayPrice) } }.buttonStyle(PrimaryButtonStyle()) }
            Button("premium.restore") { Task { await store.restore() } }
            Text("premium.terms").font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }.padding().frame(maxWidth: 620).frame(maxWidth: .infinity) }.background(CalmBackground()).navigationTitle("StillPath Premium").toolbar { ToolbarItem(placement: .cancellationAction) { Button("common.close") { dismiss() } } }.task { await store.refresh() }
    }
}

private struct Benefit: View { let icon: String; let text: LocalizedStringKey; var body: some View { Label { Text(text) } icon: { Image(systemName: icon).foregroundStyle(StillPathColor.sage).frame(width: 28) } } }

