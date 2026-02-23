---
trigger: model_decision
---

# SplitLocal Application Domain Rules

> **IMPORTANT**: Keep updating this rule file as you gain more understanding of the project!

## Core Concepts

### Groups

- **Regular Groups**: Normal expense-sharing groups with multiple members
  - `isFriendGroup: false`
  - Has its own `currency` setting chosen at creation time
  - Expenses within the group use the **group's currency**

- **Friend Groups (Individual Expenses)**: Hidden groups for 1:1 friend expenses
  - `isFriendGroup: true`
  - Name is always "Individual Expenses" (not displayed to user)
  - Contains exactly 2 members: device owner + friend
  - **Currency Rule**: When adding expenses, use **Account Default** (preferredCurrency), NOT the friend group's stored currency (which may be stale from creation time)

### Currency Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│ Account Default (preferredCurrencyProvider)                │
│   ├── When: New group creation                             │
│   ├── When: Friend group expense (isFriendGroup: true)     │
│   └── When: Expense with no group context                  │
├─────────────────────────────────────────────────────────────┤
│ Group Currency (group.currency)                             │
│   └── When: Expense in regular group (isFriendGroup: false)│
├─────────────────────────────────────────────────────────────┤
│ Dashboard Currency (dashboardCurrencyProvider)              │
│   └── Used ONLY for view filtering in Friends/Groups screens│
│   └── Does NOT affect expense creation or defaults          │
└─────────────────────────────────────────────────────────────┘
```

### Currency Provider Separation

| Provider                    | Purpose                                | Persistence    |
| --------------------------- | -------------------------------------- | -------------- |
| `preferredCurrencyProvider` | Global default for new groups/expenses | Yes (stored)   |
| `dashboardCurrencyProvider` | View/filter currency in top bar        | No (session)   |
| `group.currency`            | Group's configured currency            | Yes (in group) |

## Key Relationships

### Friend → Group Mapping

```
Friend (User) ──→ friendGroupProvider(friendId) ──→ Group (isFriendGroup: true)
```

- One friend = one hidden friend group with 2 members
- Friend groups are created lazily when first expense is added

### Expense Creation Flow

```
1. User navigates to Add Expense
2. Form initialized with:
   - If regular group: Use group.currency
   - If friend group (isFriendGroup): Use preferredCurrency ← IMPORTANT!
   - If no group: Use preferredCurrency
3. User can still change currency in the form
4. Expense saved with the selected currency
```

### Multi-Currency Handling

Groups can have transactions in multiple currencies. When displaying totals:

| Context                        | Provider                                   | Display             |
| ------------------------------ | ------------------------------------------ | ------------------- |
| Groups list                    | `groupTotalSpendByCurrencyProvider`        | "₹500 +1 more"      |
| Groups list                    | `groupNetBalancesByCurrencyProvider`       | "₹200 +1 more"      |
| Friend details (shared groups) | `groupBalanceWithFriendByCurrencyProvider` | "₹300 +1 more"      |
| Friends list                   | `allFriendBalancesByCurrencyProvider`      | "₹400 +1 more"      |
| Admin Debt View (Settle Up)    | Per-currency debt calculation              | "₹500" per currency |
| Settle Up Screen               | Per-currency debt calculation              | "₹300" per currency |

**Never sum amounts across currencies.** Always display per-currency or use abbreviated format.

## Common Pitfalls

1. **Friend Group Currency**: Never use `group.currency` for `isFriendGroup: true` groups in expense forms. Always use `preferredCurrencyProvider`.

2. **Mixed Currency Totals**: Don't sum ₹500 + $50 = 550. Use currency-aware providers that return `Map<String, double>`.

3. **Dashboard vs Preferred Currency**: Dashboard currency is for view filtering only. Never use it to set defaults for new expenses or groups.

4. **Group Currency vs Transaction Currency**: Transactions can have their own currency (`transaction.currency`) that differs from `group.currency`. Always check for transaction-level currency first.

## File Locations

| Feature               | Location                                                         |
| --------------------- | ---------------------------------------------------------------- |
| Group model           | `lib/features/groups/models/group.dart`                          |
| Friend group provider | `lib/features/friends/providers/friend_group_provider.dart`      |
| Add expense form      | `lib/features/expenses/providers/add_expense_form_provider.dart` |
| Preferred currency    | `lib/shared/providers/preferred_currency_provider.dart`          |
| Multi-currency widget | `lib/shared/widgets/multi_currency_amount_text.dart`             |
| Debt calculation      | `lib/services/debt_calculator_service.dart`                      |

---

_Last updated: 2026-02-09_
