# minimal_hot_update_demo

This app is the first in-repo experiment for a fixed Flutter host plus a local replaceable payload.

## What It Proves

- the host page stays fixed
- a local payload file can be replaced
- the payload can change both visible UI and button behavior

## Run

```sh
cd /Users/zyyziyunying/flutter-hot-update-lab/demo/minimal_hot_update_demo
flutter run -d macos
```

## Verify

```sh
cd /Users/zyyziyunying/flutter-hot-update-lab/demo/minimal_hot_update_demo
flutter analyze
flutter test
```

## Demo Flow

- Launch the app.
- Use `Payload A` and `Payload B` to overwrite the local payload file.
- Click `Reload Current Payload` to re-read the file.
- Watch both the title and button behavior change.
- The current local payload file path is displayed in the UI for manual inspection or editing.
