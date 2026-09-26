import Observation
import StoreKit

@MainActor @Observable
final class EntitlementStore {
    static let monthlyID = "com.stillpath.premium.monthly"
    static let annualID = "com.stillpath.premium.annual"
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    @ObservationIgnored private var updatesTask: Task<Void, Never>?

    var hasPremium: Bool { !purchasedProductIDs.isDisjoint(with: [Self.monthlyID, Self.annualID]) }

    init() {
        updatesTask = observeTransactions()
        Task { await refresh() }
    }

    deinit { updatesTask?.cancel() }

    func refresh() async {
        isLoading = true; defer { isLoading = false }
        do {
            products = try await Product.products(for: [Self.monthlyID, Self.annualID]).sorted { $0.price < $1.price }
            await updateEntitlements()
        } catch { errorMessage = error.localizedDescription }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result {
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updateEntitlements()
            }
        } catch { errorMessage = error.localizedDescription }
    }

    func restore() async {
        do { try await AppStore.sync(); await updateEntitlements() }
        catch { errorMessage = error.localizedDescription }
    }

    private func observeTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await update in Transaction.updates {
                guard let self else { return }
                if let transaction = try? self.checkVerified(update) { await transaction.finish(); await self.updateEntitlements() }
            }
        }
    }

    private func updateEntitlements() async {
        var current: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result), transaction.revocationDate == nil { current.insert(transaction.productID) }
        }
        purchasedProductIDs = current
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result { case .verified(let value): value; case .unverified: throw StoreError.failedVerification }
    }
    enum StoreError: Error { case failedVerification }
}

