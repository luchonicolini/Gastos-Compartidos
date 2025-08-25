//
//  EditMemberView.swift
//  ContextoGestion
//
//  Created by Luciano Nicolini on 22/04/2025.
//

//
//  EditMemberView.swift
//  ContextoGestion
//
//  Created by Luciano Nicolini on 22/04/2025.
//

import SwiftUI
import SwiftData

struct EditMemberView: View {
    let personToEdit: Person
    @State var viewModel: GroupDetailViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    // Estados principales
    @State private var editedName: String
    @State private var isFormValid: Bool = false
    
    // Estados para alertas
    @State private var showingErrorAlert = false
    @State private var alertMessage = ""
    @State private var showingSuccessAlert = false
    @State private var successMessage = ""
    
    // Estados para animaciones y UI
    @State private var isEditing = false
    @State private var hasInitialized = false
    @FocusState private var isTextFieldFocused: Bool
    
    init(person: Person, viewModel: GroupDetailViewModel) {
        self.personToEdit = person
        _viewModel = State(initialValue: viewModel)
        _editedName = State(initialValue: person.name)
        _isFormValid = State(initialValue: !person.name.isEmpty)
    }
    
    private var hasChanges: Bool {
        let trimmedName = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && trimmedName != personToEdit.name
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header con preview del miembro
                    VStack(spacing: 20) {
                        Text("Editar miembro")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.primary)
                        
                        // Preview Card del miembro
                        MemberPreviewCard(
                            name: editedName.isEmpty ? "Nombre del miembro" : editedName,
                            originalName: personToEdit.name,
                            isPlaceholder: editedName.isEmpty,
                            hasChanges: hasChanges
                        )
                    }
                    .padding(.top, 8)
                    
                    // Formulario principal
                    VStack(spacing: 24) {
                        // Campo de nombre mejorado
                        MemberNameField(
                            text: $editedName,
                            isValid: $isFormValid,
                            isFocused: $isTextFieldFocused,
                            hasChanges: hasChanges
                        )
                        
                        // Información adicional
                        infoSection
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .onChange(of: editedName) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFormValid = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    }
                }
            }
            .background(Color("AppBackground").ignoresSafeArea())
            .navigationTitle("Editar Miembro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveChanges()
                    }
                    .font(.headline)
                    .disabled(!hasChanges || !isFormValid)
                    .foregroundColor(hasChanges && isFormValid ? .blue : .secondary)
                }
            }
            .customAlert(
                isPresented: $showingErrorAlert,
                title: "Error al Actualizar",
                message: LocalizedStringKey(alertMessage)
            )
            .customAlert(
                isPresented: $showingSuccessAlert,
                title: "Éxito",
                message: LocalizedStringKey(successMessage),
                buttons: [
                    AlertButton(title: "OK", action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            dismiss()
                        }
                    })
                ]
            )
            .onTapGesture {
                isTextFieldFocused = false
            }
            .task {
                if !hasInitialized {
                    await setupInitialValuesAsync()
                }
            }
            .onAppear {
                if !hasInitialized {
                    setupInitialValuesSync()
                }
            }
        }
    }
    
    // MARK: - Setup Methods
    @MainActor
    private func setupInitialValuesAsync() async {
        guard !hasInitialized else { return }
        
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            editedName = personToEdit.name
            isFormValid = !personToEdit.name.isEmpty
            hasInitialized = true
            isEditing = true
        }
    }
    
    private func setupInitialValuesSync() {
        guard !hasInitialized else { return }
        
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.editedName = self.personToEdit.name
                self.isFormValid = !self.personToEdit.name.isEmpty
                self.hasInitialized = true
                self.isEditing = true
            }
        }
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
                
                Text("Los cambios se aplicarán globalmente")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            
            Text("Este miembro aparece en otros grupos y gastos. Al cambiar el nombre, se actualizará en toda la aplicación.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .padding(.leading, 24)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.1), lineWidth: 1)
                )
        )
        .opacity(isEditing ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.5).delay(0.2), value: isEditing)
    }
    
    // MARK: - Save Function
    @MainActor private func saveChanges() {
        let trimmedName = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            self.alertMessage = "El nombre no puede estar vacío."
            self.showingErrorAlert = true
            return
        }
        
        // Feedback háptico
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        do {
            try viewModel.updatePerson(person: personToEdit, name: trimmedName, context: modelContext)
            self.successMessage = "Nombre cambiado a '\(trimmedName)' con éxito."
            self.showingSuccessAlert = true
        } catch let error as PersonError {
            self.alertMessage = error.localizedDescription
            self.showingErrorAlert = true
        } catch {
            self.alertMessage = "Ocurrió un error inesperado al guardar los cambios."
            self.showingErrorAlert = true
        }
    }
}

// MARK: - Member Preview Card
struct MemberPreviewCard: View {
    let name: String
    let originalName: String
    let isPlaceholder: Bool
    let hasChanges: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: hasChanges ?
                            [Color.green.opacity(0.6), Color.blue.opacity(0.8)] :
                            [Color.blue.opacity(0.6), Color.purple.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                Text(String(name.prefix(2).uppercased()))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                if hasChanges {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .background(Color.white)
                                .clipShape(Circle())
                                .font(.system(size: 20))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(width: 80, height: 80)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: hasChanges)
            
            // Nombres
            VStack(spacing: 8) {
                if hasChanges {
                    VStack(spacing: 4) {
                        Text("Nombre anterior")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Text(originalName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .strikethrough()
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    
                    Image(systemName: "arrow.down")
                        .foregroundColor(.blue)
                        .font(.system(size: 16, weight: .medium))
                        .transition(.scale.combined(with: .opacity))
                }
                
                VStack(spacing: 4) {
                    Text(hasChanges ? "Nuevo nombre" : "Nombre actual")
                        .font(.caption)
                        .foregroundColor(hasChanges ? .green : .secondary)
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    Text(name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(isPlaceholder ? .secondary : .primary)
                        .opacity(isPlaceholder ? 0.6 : 1.0)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: hasChanges)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            hasChanges ? Color.green.opacity(0.3) : Color.clear,
                            lineWidth: 2
                        )
                )
        )
        .scaleEffect(hasChanges ? 1.02 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: hasChanges)
    }
}

// MARK: - Member Name Field
struct MemberNameField: View {
    @Binding var text: String
    @Binding var isValid: Bool
    @FocusState.Binding var isFocused: Bool
    let hasChanges: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(hasChanges ? .green : .blue)
                    .font(.system(size: 16, weight: .medium))
                
                Text("Nombre del miembro")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if hasChanges {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            TextField("Ingresa el nombre", text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 18, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    isFocused ?
                                    (hasChanges ? Color.green.opacity(0.5) : Color.blue.opacity(0.5)) :
                                    (hasChanges ? Color.green.opacity(0.3) : Color.gray.opacity(0.2)),
                                    lineWidth: isFocused ? 2 : 1
                                )
                        )
                )
                .focused($isFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
            
            // Contador de caracteres
            if !text.isEmpty {
                HStack {
                    if hasChanges {
                        Text("¡Nombre actualizado!")
                            .font(.caption2)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    Text("\(text.count) caracteres")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .padding(.horizontal, 4)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: hasChanges)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Group.self, Person.self, Expense.self, configurations: config)
    
    let samplePerson = Person(name: "Nombre Original Para Editar")
    let sampleGroup = Group(name: "Grupo de Prueba para ViewModel")
    sampleGroup.members = [samplePerson]
    
    container.mainContext.insert(samplePerson)
    container.mainContext.insert(sampleGroup)
    
    let previewViewModel = GroupDetailViewModel()
    MainActor.assumeIsolated { previewViewModel.setGroup(sampleGroup) }
    
    return EditMemberView(person: samplePerson, viewModel: previewViewModel)
        .modelContainer(container)
}
