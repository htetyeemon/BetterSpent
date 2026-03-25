class HelpContent {
  static const Map<String, String> content = {
    'How to use BetterSpent': '''
 How to Use BetterSpent

1. View Your Budget Overview
When you open the app, the Home Screen shows:
• Current balance
• Monthly remaining budget
• Daily spending limit
• Latest income added

2. Add an Expense (Fast Way – AI Input)
If AI input is enabled:
Type your expense naturally
Example: Lunch 120 baht
The app automatically detects:
• Amount
• Category
• Note

3. Add an Expense (Manual Way)
• Enter amount
• Select category
• Add note (optional)
• Save

4. Edit or Delete an Expense
• Go to the Expenses tab
• Select an expense
• Edit details or delete it

5. View Summary
In the Summary tab, you can see:
• Weekly spending total
• Monthly overview
• Category breakdown

6. Manage Settings
• Enable/Disable AI input
• Change currency
• Turn budget alerts on/off
''',

    'Offline vs online mode': '''
🌐 Offline vs Online Mode

🟢 Online Mode
• AI expense input available
• Free-text parsing works
• Best experience

🔴 Offline Mode
• AI disabled
• Manual entry still works
• Data is never lost

When internet returns, AI becomes available again.
''',

    'Privacy policy': '''
Privacy Policy

We respect your privacy and collect only what is needed to run BetterSpent.

What we collect
• Account info (email) for sign-in and account recovery.
• Expense data you enter (amount, category, date, note).
• App settings (currency, AI input preferences).

How we use it
• To save, sync, and display your expenses.
• To personalize your budget summaries and insights.
• To improve app reliability and performance.
• If AI input is enabled, your text is sent to a third-party model to parse expenses.

What we do not collect
• No payment card data.
• No government ID numbers.
• No precise location tracking.

Authentication
• Sign-in is handled by Firebase Authentication.
• We do not store passwords locally or log them.

Data storage
• Data is stored securely in Firebase services tied to your account.
• We use Firebase Authentication, Cloud Firestore, and Cloud Functions.
• You can delete your account and data from Settings.

Contact
If you have questions about privacy, contact the app owner.
''',

    'About this app': '''
About This App

App Name: BetterSpent
Version: 1.0.0
Category: Finance
''',
  };
}
