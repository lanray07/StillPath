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
            ForEach(store.products, id: \.id) { product in
                PremiumPurchaseButton(product: product) {
                    Task { await store.purchase(product) }
                }
            }
            Button("premium.restore") { Task { await store.restore() } }
            PremiumLegalDisclosure()
        }.padding().frame(maxWidth: 620).frame(maxWidth: .infinity) }.background(CalmBackground()).navigationTitle("StillPath Premium").toolbar { ToolbarItem(placement: .cancellationAction) { Button("common.close") { dismiss() } } }.task { await store.refresh() }
    }
}

private struct Benefit: View { let icon: String; let text: LocalizedStringKey; var body: some View { Label { Text(text) } icon: { Image(systemName: icon).foregroundStyle(StillPathColor.sage).frame(width: 28) } } }

enum PremiumPurchaseLayout {
    static let horizontalInset: CGFloat = StillPathSpacing.md
    static let minimumTapHeight: CGFloat = 64
}

enum PremiumLegalLinks {
    static let privacyURL = URL(string: "https://lanray07.github.io/StillPath/privacy.html")!
    static let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
}

enum PremiumSubscriptionDisclosure {
    static func billingPeriod(for productID: String) -> String {
        switch productID {
        case EntitlementStore.monthlyID: String(localized: "premium.period.month")
        case EntitlementStore.annualID: String(localized: "premium.period.year")
        default: String(localized: "premium.period.subscription")
        }
    }

    static func monthlyEquivalent(for price: Decimal, productID: String) -> Decimal? {
        guard productID == EntitlementStore.annualID else { return nil }
        return price / 12
    }
}

private struct PremiumPurchaseButton: View {
    let product: Product
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: StillPathSpacing.md) {
                    productDetails
                    Spacer(minLength: StillPathSpacing.sm)
                    price
                }
                VStack(alignment: .leading, spacing: StillPathSpacing.sm) {
                    productDetails
                    price
                }
            }
            .padding(.horizontal, PremiumPurchaseLayout.horizontalInset)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, minHeight: PremiumPurchaseLayout.minimumTapHeight, alignment: .leading)
            .foregroundStyle(.white)
            .background(
                StillPathColor.moss,
                in: RoundedRectangle(cornerRadius: StillPathRadius.card, style: .continuous)
            )
            .contentShape(RoundedRectangle(cornerRadius: StillPathRadius.card, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityHint("premium.purchaseHint")
    }

    private var productDetails: some View {
        VStack(alignment: .leading, spacing: StillPathSpacing.xs) {
            Text(product.displayName)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
            if let offer = product.subscription?.introductoryOffer {
                Text("premium.introductoryOffer \(offer.displayPrice)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var price: some View {
        VStack(alignment: .trailing, spacing: StillPathSpacing.xs) {
            Text("\(product.displayPrice) / \(PremiumSubscriptionDisclosure.billingPeriod(for: product.id))")
                .font(.headline.monospacedDigit())
            if let monthlyEquivalent = PremiumSubscriptionDisclosure.monthlyEquivalent(
                for: product.price,
                productID: product.id
            ) {
                Text("premium.pricePerMonth \(monthlyEquivalent.formatted(product.priceFormatStyle))")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.82))
            }
        }
        .multilineTextAlignment(.trailing)
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct PremiumLegalDisclosure: View {
    var body: some View {
        VStack(spacing: StillPathSpacing.sm) {
            Text("premium.terms")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: StillPathSpacing.md) {
                Link("premium.privacyPolicy", destination: PremiumLegalLinks.privacyURL)
                Link("premium.termsOfUse", destination: PremiumLegalLinks.termsURL)
            }
            .font(.caption.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
    }
}

