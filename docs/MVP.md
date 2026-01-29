# Rentbot — MVP specification

## 1. Goal
Telegram-bot for rent payment tracking:
- who paid / who did not
- reminders about upcoming due date and overdue
- user reports payment, admin confirms with one button
- shows payment requisites

## 2. Roles and access

### USER (tenant)
Can:
- view requisites
- view own status for current period (paid / unpaid / pending)
- see days until due date
- press "I paid" (creates a payment request)

Cannot:
- see other tenants
- confirm/deny payments
- edit settings

### ADMIN
Can:
- view all tenants status
- approve/deny payment requests
- manage tenants (add/link/disable)
- edit rent settings (amount, due date rules)
- edit requisites

## 3. Commands and UI

### USER commands/buttons
- /start
  - shows main menu
- [Requisites]
  - shows payment details (text/link)
- [My status]
  - shows: current period, due date, amount, status (PAID / UNPAID / PENDING)
- [Days until payment]
  - shows number of days until due date (or overdue days)
- [I paid]
  - creates PaymentRequest (PENDING) if not already exists for current period
  - notifies admin with buttons: ✅ Approve / ❌ Reject

### ADMIN commands/buttons
- /admin
  - shows admin menu
- [Status for all]
  - list of tenants with statuses for current period:
    ✅ paid (paidAt)
    🟡 pending (request createdAt)
    ❌ unpaid (days until/overdue)
- [Pending requests]
  - list PENDING payment requests with buttons:
    ✅ Approve / ❌ Reject
- [Tenants]
  - add tenant
  - link tenant to telegramUserId
  - enable/disable tenant
- [Rent settings]
  - amount
  - due date rule
- [Requisites]
  - update requisites text

## 4. Period rules (choose one)

### Option A (fixed day of month)
- Period = calendar month (e.g. "2026-01")
- Due date = fixed day (e.g. 5th day of each month)
- If today > due date and no payment -> overdue

### Option B (nextDueDate rolling)
- Store nextDueDate in config
- After payment is APPROVED: nextDueDate = nextDueDate + 1 month

MVP decision: A

## 5. Status rules
For a tenant and period:
- PAID: there exists Payment for the period
- PENDING: there exists PaymentRequest with status PENDING for the period and no Payment
- UNPAID: no Payment and no PENDING request

"I paid" button rules:
- if already PAID -> show "Already paid"
- if already PENDING -> show "Already pending"
- else -> create PENDING request

Admin decision rules:
- Approve:
  - create Payment
  - mark request APPROVED
- Reject:
  - mark request REJECTED (optional comment)

## 6. Reminders (scheduler)
Daily job at 09:00 (server timezone):

For each active tenant:
- if PAID -> do nothing
- if UNPAID:
  - if today = dueDate - N -> reminder #1
  - if today = dueDate -> reminder "today is due date"
  - if today > dueDate -> overdue reminder (rule: daily OR every 3 days)

Admin digest:
- once per day send list of unpaid + overdue days

MVP reminder settings:
- N = 3
- Overdue reminder frequency = every 3 days

## 7. Non-goals (out of MVP)
- automatic payments / acquiring / bank integration
- file storage for receipts
- web admin panel

## 8. Done criteria (MVP)
- 1 admin + up to 15 tenants can use the bot
- user can check status and report payment
- admin can approve/reject and see full status list
- reminders are sent
- all DB tables created by Flyway from empty database
