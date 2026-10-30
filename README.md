# GreenLeaf — Native Flutter Smooth Navigation (Android demo)

This version is **native Flutter**, not a WebView wrapper. The dashboard, Campaigns, Inbox, Contacts, More and Billing views are Flutter widgets. The sample data and interactions are taken from your uploaded `GreenLeaf_Clean_Campaigns_Smooth_Navigation.html`, kept under `reference/` for comparison. Scrolling, filtering, chat preview, tab switching and billing tabs run in Flutter itself.

**Important:** This is a **UI/demo only** app. It does not communicate with the live GreenLeaf backend or WhatsApp API, send messages, create campaigns, process payment, or authenticate. The UI is a native adaptation of the supplied reference, not a pixel-perfect reproduction of every CSS effect. No performance benchmarks have been run on a Galaxy S25 yet.

## How to build `app-debug.apk` in GitHub

1. Extract this ZIP on Windows. Open the extracted folder.
2. Open your GitHub repo `https://github.com/Lasar456/greenleaf` and choose **Code → Add file → Upload files**.
3. Upload **`lib/`**, **`branding/`**, and **`pubspec.yaml`** to the repo root, replacing previous versions. The `reference/` folder is optional. **Do not upload the ZIP itself.**
4. Your workflow must be saved at **`.github/workflows/main.yml`**. Windows often hides folders whose names start with a dot. If that folder is hidden, use GitHub **Add file → Create new file**, type `.github/workflows/main.yml` in the path box, and paste the contents of `main.yml` from this ZIP. Alternatively upload the full extracted folder with Git/GitHub Desktop.
5. Commit to `main` and open the **Actions** tab.
6. Open **Build GreenLeaf Native Smooth APK**, not `blank.yml` or `Initial CI workflow`.
7. When the workflow is green, open the run and download the **GreenLeaf-Native-Smooth-S25-APK** artifact from the **Artifacts** section.
8. Extract the artifact ZIP. It contains **`app-debug.apk`**. Copy that file to your Galaxy S25 and install it.

The workflow runs `flutter create . --platforms=android`, `flutter pub get`, and `flutter build apk --debug`, then verifies the APK and uploads it as an artifact. Java 17 and Flutter stable are installed inside the GitHub runner, so you do not need Flutter installed locally.

## Project layout

- `pubspec.yaml`: Flutter project dependencies (Flutter SDK only; no third-party packages)
- `lib/main.dart`: all native screens, sample state and interactions
- `branding/ic_launcher_*.png`: small generated GreenLeaf app icons for Android densities
- `.github/workflows/main.yml`: workflow compiling the APK in GitHub
- `reference/GreenLeaf_Clean_Campaigns_Smooth_Navigation.html`: the uploaded source HTML for design comparison

## Why this should feel faster than the WebView versions

- No HTML, browser engine, page reloads or CSS blur are used at runtime.
- Tabs use Flutter's `IndexedStack`, keeping their state alive and swapping instantly.
- Lists and text fields are native Flutter widgets; the app has no network calls.
- UI effects are lightweight gradients and short transitions, rather than expensive browser blur effects.
- Android Back takes you from Billing to More, or another tab to Home; conversations use the native navigation stack.

If you see a **red** GitHub workflow, open the failed step and share the compiler log; do not assume the APK was generated.
