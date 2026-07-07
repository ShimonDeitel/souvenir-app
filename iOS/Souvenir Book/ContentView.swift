import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: Entry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.itemName).font(Theme.headlineFont)
                            Text(entry.tripTag).font(Theme.bodyFont).foregroundColor(.secondary)
                            HStack {
                                Text("\(entry.price, specifier: \"%.1f\") $")
                                Spacer()
                                Text("\(entry.quantity, specifier: \"%.1f\")")
                            }
                            .font(.caption)
                            .foregroundColor(Theme.accent)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Theme.card)
                        .contentShape(Rectangle())
                        .onTapGesture { editingEntry = entry }
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Souvenir Book")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if store.canAddMore || purchases.isPro {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryFormView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) var dismiss
    @State private var itemName: String
    @State private var tripTag: String
    @State private var priceText: String
    @State private var quantityText: String
    @State private var notes: String
    @FocusState private var focusedField: Field?
    private let originalID: UUID
    private let onSave: (Entry) -> Void

    enum Field { case f1, f2, n1, n2, notes }

    init(entry: Entry?, onSave: @escaping (Entry) -> Void) {
        _itemName = State(initialValue: entry?.itemName ?? "")
        _tripTag = State(initialValue: entry?.tripTag ?? "")
        _priceText = State(initialValue: entry != nil ? String(entry!.price) : "")
        _quantityText = State(initialValue: entry != nil ? String(entry!.quantity) : "")
        _notes = State(initialValue: entry?.notes ?? "")
        originalID = entry?.id ?? UUID()
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("itemName") {
                    TextField("itemName", text: $itemName)
                        .focused($focusedField, equals: .f1)
                        .accessibilityIdentifier("field_itemName")
                }
                Section("tripTag") {
                    TextField("tripTag", text: $tripTag)
                        .focused($focusedField, equals: .f2)
                        .accessibilityIdentifier("field_tripTag")
                }
                Section("Details") {
                    TextField("price", text: $priceText)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .n1)
                        .accessibilityIdentifier("field_price")
                    TextField("quantity", text: $quantityText)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .n2)
                        .accessibilityIdentifier("field_quantity")
                    TextField("Notes", text: $notes)
                        .focused($focusedField, equals: .notes)
                        .accessibilityIdentifier("field_notes")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(originalID == UUID() ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("formCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = Entry(
                            id: originalID,
                            itemName: itemName,
                            tripTag: tripTag,
                            price: Double(priceText) ?? 0,
                            quantity: Double(quantityText) ?? 0,
                            notes: notes
                        )
                        onSave(entry)
                        dismiss()
                    }
                    .accessibilityIdentifier("formSaveButton")
                    .disabled(itemName.isEmpty)
                }
            }
        }
    }
}
