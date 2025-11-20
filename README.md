# Insurance Logbook 🧾

Offline, desktop-first CRM workspace for insurance advisors.  
Built with **Flutter** + **Hive** to manage customers, leads, interactions, quotations, and birthday follow-ups in one place.

---

## 🚀 Overview

Insurance Logbook is a lightweight CRM-style application focused on day-to-day workflows of an insurance advisor:

- Keep a clean list of **customers** with contact details & DOB.
- Track **leads** across a simple pipeline (New → Interested → Follow-up → Converted).
- Log **customer notes** after calls/meetings to avoid forgetting details.
- Attach **quotations** (PDFs / images / docs) per customer.
- Get reminded about **upcoming birthdays** to call clients at the right time.
- Use a **dashboard + analytics** view to understand workload and engagement.
- Manage data from a **Settings** page, including clearing all local data.

All data is stored **locally** using Hive – no external backend required.

---

## 🧩 Core Features

### 1. Dashboard

- High-level summary of your workspace:
  - Total customers
  - Total leads
  - Converted leads / customers
  - Quick status breakdown (pipeline overview)
- Designed as a “home screen” to quickly understand current workload.

### 2. Customer Management

- Create, view, and update customers:
  - Full name  
  - NIC / Phone  
  - Address  
  - Date of birth  
  - Status tag (e.g., Prospect, Active, Follow-up)
- Navigate from a customer into:
  - **Notes** – interaction history  
  - **Quotations** – files related to policies

> Current implementation uses a `CustomerDebugScreen` for fast CRUD, which can be easily rebranded to a more user-facing “Customers” screen.

### 3. Customer Notes

- Log **interaction notes** for each customer (calls, meetings, follow-ups).
- Notes are:
  - Stored in Hive as `CustomerNote` records.
  - Sorted **newest first** for a quick recap of recent activity.
- Analytics uses these notes to compute “Top customers by engagement”.

### 4. Leads Pipeline

- Manage leads via a dedicated **Leads** page:
  - Lead name, phone, description
  - Status: `New`, `Interested`, `Follow-up Needed`, `Converted`, `Not Interested`
- View and update statuses as the lead progresses.
- Leads are used in:
  - Dashboard metrics
  - Analytics (“New leads in the last 30 days”)

### 5. Quotations

- Attach **files** (e.g., PDFs, images) per customer.
- Stored as `Quotation` records using Hive with file path + metadata.
- Can be opened using the OS default app (via `open_filex`).

### 6. Birthdays

- Dedicated **Birthdays** page:
  - Today’s birthdays
  - Upcoming this week
  - Later this month
- For each birthday:
  - Quick access to call the customer (using `tel:`).
  - Navigate to the customer to log a “Happy Birthday” note.

### 7. Analytics & Insights

- **Analytics** page consolidates key CRM signals:
  - Customers with DOB captured
  - Birthdays in the current month
  - Customers with at least one note
  - Total notes
  - New customers in the last 30 days
  - New leads in the last 30 days
  - **Top customers by notes**, showing who is most engaged
- Uses:
  - `CustomerRepository`
  - `CustomerNoteRepository`
  - `LeadRepository`

### 8. Settings

Rich **Settings** page with multiple sections:

- **Header snapshot**
  - Counts: customers, leads, notes, quotations
  - Last data clear timestamp

- **Dashboard & Visuals**
  - Toggle birthdays panel on dashboard
  - Toggle lead pipeline panel on dashboard
  - Compact layout toggle
  - Reset visual preferences

- **Behaviour & Workflow**
  - Enable in-app reminders (conceptual)
  - Daily summary banner
  - Confirm before delete
  - Auto-archive converted leads (conceptual)
  - Reset behaviour settings

- **Data & Storage**
  - Placeholder: Export data snapshot (future)
  - Placeholder: Sync with cloud (future)
  - ✅ **Clear all local data** (clears all Hive boxes via `AppDatabase`)

- **Support & About**
  - Usage tips (placeholder)
  - Send feedback (placeholder)
  - About Insurance Logbook (description text)

> Some actions show a non-destructive SnackBar (“not enabled in this demo build”), which is useful for explaining roadmap in presentations.

---

## 🏗 Architecture

The app follows a simple layered structure:

- **Domain**
  - `Customer` (Hive `typeId: 1`)
  - `CustomerNote` (Hive `typeId: 2`)
  - `Lead` (Hive `typeId: 3`)
  - `Quotation` (Hive `typeId: 4`)

- **Data / Repositories**
  - `CustomerRepository`
  - `CustomerNoteRepository`
  - `LeadRepository`
  - `QuotationRepository`

- **Infrastructure**
  - `AppDatabase` (Hive initializer)
    - Registers adapters
    - Opens boxes
    - Provides typed box accessors

- **Presentation**
  - `AppShell` (navigation rail + tabs)
  - `DashboardPage`
  - `CustomerDebugScreen`
  - `CustomerNotesPage`
  - `LeadsPage`
  - `CustomerQuotationsPage`
  - `BirthdaysPage`
  - `AnalyticsPage`
  - `SettingsPage`

Navigation is handled via a **NavigationRail** in `AppShell`, giving a desktop-style left-side menu.

---

## 🛠 Tech Stack

- **Language:** Dart  
- **Framework:** Flutter  
- **Target:** Windows desktop (Flutter Windows runner)  
- **Local Storage:** Hive (`hive` + `hive_flutter`)  
- **File opening:** `open_filex`  
- **State management:** Local widget state (no external state library)

---

## ⚙️ Getting Started

### Prerequisites

- Flutter SDK installed (desktop + Windows enabled)
- Git
- VS Code or Android Studio (optional but recommended)

### 1. Clone the repository

```bash
git clone <https://github.com/Rakimnr/Insurance_Logbook> insurance_logbook
cd insurance_logbook
