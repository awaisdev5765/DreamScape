import StoreKit
import Observation

@MainActor @Observable
final class StoreKitService {
    static let shared = StoreKitService()

    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isPremium: Bool = false

    private let productIDs = [
        "com.dreamscape.premium.monthly",
        "com.dreamscape.premium.yearly"
    ]

    private var updateListenerTask: Task<Void, Error>?

    private init() {
        updateListenerTask = nil
        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
                .sorted { $0.price < $1.price }
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return true

        case .userCancelled:
            return false

        case .pending:
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }

    // MARK: - Update Status

    func updatePurchasedProducts() async {
        var purchased: Set<String> = []

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            purchased.insert(transaction.productID)
        }

        purchasedProductIDs = purchased
        isPremium = !purchased.isEmpty
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self, let transaction = try? self.checkVerified(result) else { continue }
                await self.updatePurchasedProducts()
                await transaction.finish()
            }
        }
    }

    // MARK: - Verify

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Helpers

    var monthlyProduct: Product? {
        products.first { $0.id.contains("monthly") }
    }

    var yearlyProduct: Product? {
        products.first { $0.id.contains("yearly") }
    }
}

enum StoreError: Error {
    case failedVerification
}
