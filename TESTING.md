# SavePesa - Testing Guide

## How to Test New Features

### 1. Run the App
```bash
flutter run
```

### 2. Test Notifications
1. Login/Register
2. Look for notification bell icon (top right) with badge
3. Add a transaction → notification appears
4. Create a savings goal → notification appears
5. Tap bell icon → opens notifications page
6. Tap "Mark all read" to clear badge

### 3. Test Quick Actions (FAB)
1. Tap the floating + button (bottom right)
2. Select "Add Transaction"
   - Fill form
   - Toggle Income/Expense
   - Select category
   - Submit → notification created
3. Select "Create Savings Goal"
   - Enter name and target
   - Submit → notification created
4. Select "View Insights"
   - See analytics page with stats

### 4. Test Homepage Features
1. **Pull to refresh** - swipe down on homepage
2. **Balance trend** - shows % change if you have transactions
3. **Motivational message** - changes based on goals
4. **Goals preview** - horizontal scroll to see active goals
5. **Category chips** - tap to filter transactions by category
6. **Time filters** - tap All/Week/Month to filter transactions
7. **User avatar** - shows your initial

### 5. Test Insights Page
- View total transactions
- See average income/expense
- Check savings rate
- View top spending category
- Read financial tips

## Expected Behavior
- ✅ Notifications badge updates in real-time
- ✅ All buttons are functional
- ✅ Filters work correctly
- ✅ Forms validate input
- ✅ UI is responsive and smooth

## Known Limitations
- Data is not persistent (resets on app restart)
- No backend integration
- Simple password hashing (not production-ready)
