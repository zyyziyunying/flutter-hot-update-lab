# react_like_runtime_poc

This app is the active in-repo proof of concept for the React-like runtime route.

## What It Proves

- a fixed Flutter host can evaluate a local JS bundle
- JS can expose the PoC bundle globals and metadata contract
- JS can commit a native render tree to Flutter
- Flutter can render `View`, `Text`, and `Button` as native widgets
- button presses can dispatch back into JS and trigger `useState` rerender
- switching between bundle A and bundle B changes both UI and behavior

## Rebuild Bundles

```sh
cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc/js
npm install
npm run build
```

## Run

```sh
cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc
flutter run -d macos
```

## Verify

```sh
cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc
flutter analyze
flutter test
flutter build macos --profile
```
