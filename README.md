BetterSpent is an expense tracking application built with Flutter. It focuses on providing a simple and efficient experience for managing personal finances, with features like smart expense entry, budget management, and insightful summaries.

## Features

*   **Smart Expense Entry**: Utilize natural language to quickly add expenses. The app's smart input mode parses text like "coffee 5.50" to automatically categorize and log your spending.
*   **Comprehensive Dashboard**: The home screen provides an at-a-glance overview of your financial health, including your current balance, income, monthly budget, and daily spending limits.
*   **Detailed Expense Management**: View a complete list of your expenses, grouped by date. Easily edit, and delete expenses.
*   **Insightful Summaries**: Analyze your spending habits with weekly and monthly summaries, including total spending, daily averages, and breakdowns by category.
*   **Budget & Income Tracking**: Set a monthly budget and track your income to stay on top of your financial goals.
*   **Customizable Settings**: Tailor the app to your needs by changing the currency, toggling smart input, managing notifications, and more.
*   **Dark Mode UI**: A clean and modern user interface designed for a comfortable viewing experience.

## Technology Stack

*   **Framework**: Flutter
*   **Language**: Dart
*   **Routing**: `go_router` for declarative navigation.
*   **Architecture**: Feature-first project structure, separating UI, models, and core logic.

## Project Structure

The project is structured to promote separation of concerns and scalability. Key directories under `lib/` include:

```
lib/
├── core/               # Shared code: routing, constants, utils, base widgets
├── features/           # Application features (e.g., home, expenses, summary)
│   ├── expenses/
│   ├── home/
│   ├── onboarding/
│   ├── settings/
│   └── summary/
├── models/             # Data models (e.g., ExpenseModel)
└── main.dart           # Main application entry point
```

-   **`core`**: Contains foundational elements like the app router (`app_router.dart`), constants for colors and text styles, and reusable widgets (`PrimaryButton`, `CustomTextField`).
-   **`features`**: Each sub-directory represents a major feature of the app, containing its own presentation layer (screens and widgets).

  
## Getting Started

To run this project locally, follow these steps:

1.  **Prerequisites**
    *   Ensure you have the [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
    *   An editor like VS Code with the Flutter extension or Android Studio.

2.  **Clone the Repository**
    ```bash
    git clone https://github.com/htetyeemon/BetterSpent.git
    cd BetterSpent
    ```

3.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

4.  **Run the Application**
    ```bash
    flutter run
