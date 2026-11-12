# FoldFlow on Firebase – setup guide

Two projects share one Firebase project:

| Project | Who uses it | Login |
|---|---|---|
| `foldflow-web` (Angular) | Staff and owner, at the counter | Email + password |
| `foldflow-app` (Flutter) | Customers | None (anonymous behind the scenes) |

Neither can open the other's side: the rules only let signed-in staff touch
orders, payments and settings, and the app only ever reads one tracking card at
a time.

## 1. Create the Firebase project (once)

1. console.firebase.google.com → **Add project**.
2. **Build → Firestore Database → Create database** (production mode, pick the
   region closest to the shop).
3. **Build → Authentication → Sign-in method**: enable **Email/Password** and
   **Anonymous**.
4. **Project settings → Your apps**: add a **Web app** (copy the config) and an
   **Android app** (package name `com.foldflow.foldflow`).

## 2. Deploy the security rules

From `foldflow-web/` (edit `.firebaserc` first: put your project ID):

```bash
npm install -g firebase-tools
firebase login
firebase deploy --only firestore:rules
```

## 3. Create the staff accounts

For each person (the owner/manager and any counter staff):

1. **Authentication → Users → Add user** (email + password). Copy the **User UID**.
2. **Firestore → Start collection** `staff` → Document ID = that **UID** → field
   `role` (string) = `owner` or `staff`.

Only `owner` can change the price per kilo. An account without a `staff/{uid}`
document is signed straight back out of the dashboard.

## 4. Web dashboard

```bash
cd foldflow-web
npm install
npm install firebase          # the Firebase SDK (replaces Supabase)
# paste your Web app config into src/environments/environment.ts
npm start                     # http://localhost:4200
```

Sign in as the owner → **Settings** → set the price per kilo. (Until set, 60 is
used.) Deploy later with `ng build` then `firebase deploy --only hosting`.

## 5. Mobile app

```bash
cd foldflow-app
flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure         # same Firebase project; overwrites lib/firebase_options.dart
flutter run
```

## 6. Try the whole flow

| Step | Where | What you should see |
|---|---|---|
| Book a drop-off | App | Confirmation with `REQ-XXXXXX` |
| | Web → Reservations | Card appears by itself with a badge in the sidebar |
| Confirm | Web | App's reservation changes to *Confirmed* |
| Check in → enter weight → Save | Web | Digital ticket `ORD-1001`, total from the rate |
| Track My Laundry → `ORD-1001` | App | Progress bar at *Received* |
| Change status in Active Orders | Web | App's bar moves live |
| Ready for Pickup → Claim Order → record payment → Complete claim | Web | App shows *Claimed* |
| Daily Reports | Web | Income, completed count, laundry still in shop |

## Data layout (Firestore)

- `orders/{ORD-1001}` – full order (staff only): customer, contact, weightKg,
  pricePerKg, totalAmount, status, paymentStatus/Method, paidAt, claimedAt,
  reservationId. Subcollection `history` is the audit trail.
- `tracking/{ORD-1001}` – what the customer app reads: status, weight, total,
  payment state, a short name ("Maria S.") and masked phone ("•••• 4567").
- `reservations/{REQ-XXXXXX}` – booking requests from the app (or added by
  staff): name, contact, dropOffDate (YYYY-MM-DD), dropOffTime, status
  (`pending | confirmed | checked_in | cancelled`), orderId.
- `settings/pricing` – `pricePerKg`. `counters/orders` – next Order ID number.
- `staff/{uid}` – who may use the dashboard.
- Status codes everywhere: `received, washing, drying, ready_for_pickup, claimed`
  (shown on the web as Pending, Washing, Drying / Folding, Ready for Pickup,
  Claimed / Complete).

## Good to know

- **Not compiled here.** My workspace could not reach npm or Flutter, so none of
  this has been built or run. Expect a small compile fix or two on first build;
  send me the error text and I will fix it.
- Order IDs are sequential, so someone could try `ORD-1002`. They would only see
  a short name, a masked phone, status and total, never the full record. If you
  want even that hidden, tell me and I will switch tracking to a random code.
- The dashboard loads the latest 1000 orders; reports cover those.
- Bookings from the app need internet; offline it shows an error after 15 s.
- Anonymous customers are per install: reinstalling the app forgets that
  phone's earlier reservation list (orders can still be tracked by ID).
- The old Supabase project can simply be deleted; nothing reads it anymore.
