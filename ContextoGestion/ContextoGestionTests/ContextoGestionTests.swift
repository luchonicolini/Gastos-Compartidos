import SwiftData
import XCTest
@testable import ContextoGestion

final class ContextoGestionTests: XCTestCase {
    @MainActor
    func testEmptyGroupHasNoBalancesOrSettlements() throws {
        let fixture = try Fixture(names: [])
        fixture.viewModel.setGroup(fixture.group)
        XCTAssertTrue(fixture.viewModel.memberBalances.isEmpty)
        XCTAssertTrue(fixture.viewModel.suggestFormattedSettlements().isEmpty)
    }

    @MainActor
    func testMembersWithoutExpensesHaveZeroBalances() throws {
        let fixture = try Fixture(names: ["Ana", "Bruno"])
        fixture.viewModel.setGroup(fixture.group)
        XCTAssertEqual(fixture.viewModel.memberBalances.count, 2)
        XCTAssertTrue(fixture.viewModel.memberBalances.allSatisfy { $0.balance == 0 })
        XCTAssertTrue(fixture.viewModel.suggestFormattedSettlements().isEmpty)
    }

    @MainActor
    func testEqualSplitCreditsPayerAndDebitsParticipants() throws {
        let fixture = try Fixture(names: ["Ana", "Bruno", "Carla"])
        fixture.addExpense(amount: 120)
        fixture.viewModel.setGroup(fixture.group)
        XCTAssertEqual(try fixture.balance(at: 0), 80, accuracy: 0.001)
        XCTAssertEqual(try fixture.balance(at: 1), -40, accuracy: 0.001)
        XCTAssertEqual(try fixture.balance(at: 2), -40, accuracy: 0.001)
        XCTAssertEqual(fixture.totalBalance, 0, accuracy: 0.001)
    }

    @MainActor
    func testCustomSplitsPreserveExpectedBalances() throws {
        let cases: [(SplitType, Double, Double)] = [
            (.byAmount, 25, 75), (.byPercentage, 25, 75), (.byShares, 1, 3)
        ]
        for (splitType, firstShare, secondShare) in cases {
            let fixture = try Fixture(names: ["Ana", "Bruno"])
            fixture.addExpense(amount: 100, splitType: splitType, details: [
                fixture.members[0].id: firstShare,
                fixture.members[1].id: secondShare
            ])
            fixture.viewModel.setGroup(fixture.group)
            XCTAssertEqual(try fixture.balance(at: 0), 75, accuracy: 0.001)
            XCTAssertEqual(try fixture.balance(at: 1), -75, accuracy: 0.001)
            XCTAssertEqual(fixture.totalBalance, 0, accuracy: 0.001)
        }
    }

    @MainActor
    func testUnevenSplitConservesTotalAfterRounding() throws {
        let fixture = try Fixture(names: ["Ana", "Bruno", "Carla"])
        fixture.addExpense(amount: 10)
        fixture.viewModel.setGroup(fixture.group)
        // The first participant receives the remainder: 3.34 + 3.33 + 3.33.
        XCTAssertEqual(try fixture.balance(at: 0), 6.66, accuracy: 0.001)
        XCTAssertEqual(try fixture.balance(at: 1), -3.33, accuracy: 0.001)
        XCTAssertEqual(try fixture.balance(at: 2), -3.33, accuracy: 0.001)
        XCTAssertEqual(fixture.totalBalance, 0, accuracy: 0.001)
    }

    @MainActor
    func testSettlementUsesMemberIDsEvenWhenNamesMatch() throws {
        let fixture = try Fixture(names: ["Alex", "Alex"])
        fixture.addExpense(amount: 100)
        fixture.viewModel.setGroup(fixture.group)
        let payments = fixture.viewModel.suggestFormattedSettlements()
        XCTAssertEqual(payments.count, 1)
        let payment = try XCTUnwrap(payments.first)
        XCTAssertEqual(payment.payerId, fixture.members[1].id)
        XCTAssertEqual(payment.payeeId, fixture.members[0].id)
        XCTAssertEqual(payment.amount, 50, accuracy: 0.001)
    }

    @MainActor
    func testRecordedPartialPaymentReducesOutstandingDebt() throws {
        let fixture = try Fixture(names: ["Ana", "Bruno"])
        fixture.addExpense(amount: 100)
        fixture.addPayment(amount: 20, payerIndex: 1, payeeIndex: 0)
        fixture.viewModel.setGroup(fixture.group)
        XCTAssertEqual(try fixture.balance(at: 0), 30, accuracy: 0.001)
        XCTAssertEqual(try fixture.balance(at: 1), -30, accuracy: 0.001)
        let suggestion = try XCTUnwrap(fixture.viewModel.suggestFormattedSettlements().first)
        XCTAssertEqual(suggestion.amount, 30, accuracy: 0.001)
        XCTAssertEqual(fixture.totalBalance, 0, accuracy: 0.001)
    }

    @MainActor
    func testRecordedFullPaymentClearsOutstandingSettlements() throws {
        let fixture = try Fixture(names: ["Ana", "Bruno"])
        fixture.addExpense(amount: 100)
        fixture.addPayment(amount: 50, payerIndex: 1, payeeIndex: 0)
        fixture.viewModel.setGroup(fixture.group)
        XCTAssertEqual(try fixture.balance(at: 0), 0, accuracy: 0.001)
        XCTAssertEqual(try fixture.balance(at: 1), 0, accuracy: 0.001)
        XCTAssertTrue(fixture.viewModel.suggestFormattedSettlements().isEmpty)
    }
}

@MainActor
private final class Fixture {
    let container: ModelContainer
    let group: Group
    let members: [Person]
    let viewModel = GroupDetailViewModel()

    init(names: [String]) throws {
        let schema = Schema([Group.self, Person.self, Expense.self, SettlementPayment.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        group = Group(name: "Test group")
        members = names.map { Person(name: $0) }
        container.mainContext.insert(group)
        for member in members {
            container.mainContext.insert(member)
        }
        group.members = members
    }

    func addExpense(amount: Double, splitType: SplitType = .equally,
                    details: [UUID: Double]? = nil) {
        let expense = Expense(description: "Shared expense", amount: amount,
                              payer: members.first, participants: members,
                              splitType: splitType, splitDetails: details)
        container.mainContext.insert(expense)
        group.expenses = [expense]
    }

    func addPayment(amount: Double, payerIndex: Int, payeeIndex: Int) {
        let payer = members[payerIndex]
        let payee = members[payeeIndex]
        let payment = SettlementPayment(payerId: payer.id, payeeId: payee.id,
                                        amount: amount, group: nil,
                                        payerName: payer.name, payeeName: payee.name)
        container.mainContext.insert(payment)
        group.settlementPayments = [payment]
    }

    func balance(at index: Int) throws -> Double {
        try XCTUnwrap(viewModel.memberBalances.first { $0.id == members[index].id }).balance
    }

    var totalBalance: Double {
        viewModel.memberBalances.reduce(0) { $0 + $1.balance }
    }
}
