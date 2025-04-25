//
//  CartViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 15/4/25.
//

import SwiftUI
import Combine // Or Foundation

@MainActor
class CartViewModel: ObservableObject {
    // --- State ---
    @Published private(set) var cartItems: [CartItem] = [] // UI Model
    @Published var isLoading: Bool = false // For initial load or full cart operations
    @Published var isUpdatingItem: Set<String> = [] // Track specific item updates (use product IDs)
    @Published var cartError: String? = nil // Error message for UI
    
    // --- Dependencies ---
    private let cartService: CartServicing
    // Optional: Inject Snackbar VM or handle errors internally
    // private let snackbarViewModel: SnackBarViewModel
    
    // --- Computed Properties (remain the same) ---
    var totalPrice: Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    var totalQuantity: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    // --- Initializer ---
    init(cartService: CartServicing /*, snackbarViewModel: SnackBarViewModel */) {
        self.cartService = cartService
        // self.snackbarViewModel = snackbarViewModel
        // Optionally load cart on init if appropriate
        Task { await fetchCart() }
    }
    
    // MARK: - API Integrated Functions
    
    func fetchCart() async {
        guard !isLoading else { return }
        print("CartViewModel: Fetching cart...")
        isLoading = true
        cartError = nil
        
        do {
            let cartResponse = try await cartService.getCart()
            self.cartItems = mapCartResponseToUIModel(response: cartResponse)
            print("CartViewModel: Cart fetched successfully. Items: \(cartItems.count)")
        } catch {
            print("❌ CartViewModel: Failed to fetch cart - \(error)")
            cartError = "Failed to load your cart. Please try again."
            // self.snackbarViewModel.showSnackbar(message: cartError!) // Show error
        }
        isLoading = false
    }
    
    func addProductToCart(product: Product, quantityToAdd: Int = 1) async {
        let productId = product.id
        guard !isUpdatingItem.contains(productId) else { return } // Prevent multiple simultaneous updates for same item
        
        print("CartViewModel: Attempting to add/update product \(productId)")
        isUpdatingItem.insert(productId)
        cartError = nil
        var originalItems = self.cartItems // Store state for potential rollback
        
        // --- Optimistic UI Update ---
        if let index = cartItems.firstIndex(where: { $0.product.id == productId }) {
            // Item exists - update quantity locally
            objectWillChange.send()
            var itemToModify = cartItems[index]
            itemToModify.quantity += quantityToAdd
            cartItems[index] = itemToModify
            print("CartViewModel (Optimistic): Updated quantity for \(productId) to \(itemToModify.quantity)")
        } else {
            // New item - append locally
            let newCartItem = CartItem(product: product, quantity: quantityToAdd)
            cartItems.append(newCartItem) // Append triggers objectWillChange
            originalItems = self.cartItems // Update originalItems AFTER append
            print("CartViewModel (Optimistic): Added new item \(productId)")
        }
        
        // --- End Optimistic UI Update ---
        
        do {
            // --- API Call ---
            // Assuming service 'addItem' handles both add new & update quantity logic
            let updatedCartResponse = try await cartService.addItem(productId: productId, quantity: quantityToAdd)
            // Sync local state with the confirmed server state
            self.cartItems = mapCartResponseToUIModel(response: updatedCartResponse)
            print("CartViewModel (Success): Item \(productId) added/updated on server.")
            // snackbarViewModel.showSnackbar(message: "\(product.name) added to cart.") // Optional success message
        } catch {
            print("❌ CartViewModel: Failed to add/update item \(productId) - \(error)")
            // --- Rollback Optimistic Update ---
            cartItems = originalItems // Restore previous state
            cartError = "Failed to update cart for \(product.name)."
            // self.snackbarViewModel.showSnackbar(message: cartError!) // Show error
        }
        
        isUpdatingItem.remove(productId) // Mark item update as complete
    }
    
    func increaseQuantity(for product: Product) async {
        let productId = product.id
        guard !isUpdatingItem.contains(productId) else { return }
        guard let index = cartItems.firstIndex(where: { $0.product.id == productId }) else {
            print("Error: Cannot increase quantity, product \(productId) not found locally.")
            return
        }
        
        print("CartViewModel: Attempting to increase quantity for product \(productId)")
        isUpdatingItem.insert(productId)
        cartError = nil
        let originalItems = self.cartItems // Store state for rollback
        let originalItem = cartItems[index]
        let newQuantity = originalItem.quantity + 1
        
        // --- Optimistic UI Update ---
        objectWillChange.send()
        var optimisticItem = originalItem
        optimisticItem.quantity = newQuantity
        cartItems[index] = optimisticItem
        print("CartViewModel (Optimistic): Increased quantity for \(productId) to \(newQuantity)")
        // --- End Optimistic UI Update ---
        
        do {
            // --- API Call ---
            // Use updateItemQuantity to set the specific new quantity
            let updatedCartResponse = try await cartService.updateItemQuantity(productId: productId, quantity: newQuantity)
            // Sync local state with the confirmed server state
            self.cartItems = mapCartResponseToUIModel(response: updatedCartResponse)
            print("CartViewModel (Success): Quantity increased for \(productId) on server.")
        } catch {
            print("❌ CartViewModel: Failed to increase quantity for \(productId) - \(error)")
            // --- Rollback Optimistic Update ---
            cartItems = originalItems // Restore previous state
            cartError = "Failed to increase quantity for \(product.name)."
            // self.snackbarViewModel.showSnackbar(message: cartError!) // Show error
        }
        isUpdatingItem.remove(productId)
    }
    
    
    func decreaseQuantity(for product: Product) async {
        let productId = product.id
        guard !isUpdatingItem.contains(productId) else { return }
        guard let index = cartItems.firstIndex(where: { $0.product.id == productId }) else {
            print("Error: Cannot decrease quantity, product \(productId) not found locally.")
            return
        }
        
        print("CartViewModel: Attempting to decrease quantity for product \(productId)")
        isUpdatingItem.insert(productId)
        cartError = nil
        let originalItems = self.cartItems // Store state for rollback
        let originalItem = cartItems[index]
        
        if originalItem.quantity <= 1 {
            // --- Quantity is 1 or less, so REMOVE item ---
            // --- Optimistic UI Update ---
            cartItems.remove(at: index) // remove(at:) triggers objectWillChange
            print("CartViewModel (Optimistic): Removed item \(productId) (quantity was <= 1)")
            // --- End Optimistic UI Update ---
            
            do {
                // --- API Call ---
                let updatedCartResponse = try await cartService.removeItem(productId: productId)
                // Sync local state with the confirmed server state
                self.cartItems = mapCartResponseToUIModel(response: updatedCartResponse)
                print("CartViewModel (Success): Item \(productId) removed on server.")
            } catch {
                print("❌ CartViewModel: Failed to remove item \(productId) (from decrease) - \(error)")
                // --- Rollback Optimistic Update ---
                cartItems = originalItems // Restore previous state
                cartError = "Failed to remove \(product.name) from cart."
                // self.snackbarViewModel.showSnackbar(message: cartError!) // Show error
            }
            
        } else {
            // --- Quantity is > 1, so DECREASE quantity ---
            let newQuantity = originalItem.quantity - 1
            
            // --- Optimistic UI Update ---
            objectWillChange.send()
            var optimisticItem = originalItem
            optimisticItem.quantity = newQuantity
            cartItems[index] = optimisticItem
            print("CartViewModel (Optimistic): Decreased quantity for \(productId) to \(newQuantity)")
            // --- End Optimistic UI Update ---
            
            do {
                // --- API Call ---
                let updatedCartResponse = try await cartService.updateItemQuantity(productId: productId, quantity: newQuantity)
                // Sync local state with the confirmed server state
                self.cartItems = mapCartResponseToUIModel(response: updatedCartResponse)
                print("CartViewModel (Success): Quantity decreased for \(productId) on server.")
            } catch {
                print("❌ CartViewModel: Failed to decrease quantity for \(productId) - \(error)")
                // --- Rollback Optimistic Update ---
                cartItems = originalItems // Restore previous state
                cartError = "Failed to decrease quantity for \(product.name)."
                // self.snackbarViewModel.showSnackbar(message: cartError!) // Show error
            }
        }
        isUpdatingItem.remove(productId)
    }
    
    // Changed signature to use productId for easier calling
    func removeItem(productId: String) async {
        guard !isUpdatingItem.contains(productId) else { return }
        guard let index = cartItems.firstIndex(where: { $0.product.id == productId }) else {
            print("Error: Cannot remove item, product \(productId) not found locally.")
            return
        }
        
        print("CartViewModel: Attempting to remove item \(productId)")
        isUpdatingItem.insert(productId)
        cartError = nil
        let originalItems = self.cartItems // Store state for rollback
        let itemToRemove = cartItems[index] // Get name for error message
        
        // --- Optimistic UI Update ---
        cartItems.remove(at: index) // remove(at:) triggers objectWillChange
        print("CartViewModel (Optimistic): Removed item \(productId)")
        // --- End Optimistic UI Update ---
        
        do {
            // --- API Call ---
            let updatedCartResponse = try await cartService.removeItem(productId: productId)
            // Sync local state with the confirmed server state
            self.cartItems = mapCartResponseToUIModel(response: updatedCartResponse)
            print("CartViewModel (Success): Item \(productId) removed on server.")
        } catch {
            print("❌ CartViewModel: Failed to remove item \(productId) - \(error)")
            // --- Rollback Optimistic Update ---
            cartItems = originalItems // Restore previous state
            cartError = "Failed to remove \(itemToRemove.product.name) from cart."
            // self.snackbarViewModel.showSnackbar(message: cartError!) // Show error
        }
        isUpdatingItem.remove(productId)
    }
    
    func clearCart() async {
        guard !isLoading else { return } // Use main isLoading flag
        print("CartViewModel: Attempting to clear cart")
        isLoading = true // Indicate a full cart operation
        cartError = nil
        let originalItems = self.cartItems // Store state for rollback
        
        // --- Optimistic UI Update ---
        cartItems.removeAll() // removeAll triggers objectWillChange
        print("CartViewModel (Optimistic): Cleared local cart items")
        // --- End Optimistic UI Update ---
        
        do {
            // --- API Call ---
            try await cartService.clearCart() // Assuming this returns Void on success
            // Local state is already clear, nothing more to sync
            print("CartViewModel (Success): Cart cleared on server.")
        } catch {
            print("❌ CartViewModel: Failed to clear cart - \(error)")
            // --- Rollback Optimistic Update ---
            cartItems = originalItems // Restore previous state
            cartError = "Failed to clear your cart."
            // self.snackbarViewModel.showSnackbar(message: cartError!) // Show error
        }
        isLoading = false
    }
    
    
    // --- Helper ---
    // Make sure this function is implemented correctly based on CartResponse structure
    private func mapCartResponseToUIModel(response: CartResponse) -> [CartItem] {
        print("Mapping CartResponse with \(response.items.count) items.")
        return response.items.map { responseItem -> CartItem in
            let populatedProductData = responseItem.productId
            let product = Product(
                id: populatedProductData.id,
                name: populatedProductData.name,
                brand: nil,
                description: nil,
                imageUrl: populatedProductData.imageUrl,
                dosageForm: nil,
                strength: nil,
                category: nil,
                ingredients: nil,
                price: populatedProductData.price,
                stock: 100, // Needs separate logic
                prescriptionRequired: false,
                manufacturer: nil,
                expiryDate: nil,
                instructions: nil
            )
            return CartItem(
                id: populatedProductData.id,
                product: product,
                quantity: responseItem.quantity
            )
        }
    }
    
    func clearLocalCartData() {
        isLoading = false
        isUpdatingItem = []
        cartError = nil
        self.cartItems = []
        print ("Cart cleared")
    }
    
}
