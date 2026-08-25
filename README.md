# NeoRider Flutter App

NeoRider connects an Android phone to the NeoRider ESP32 helmet over Bluetooth Low Energy (BLE), forwards synchronized helmet and chest IMU readings to the FastAPI backend, and displays the backend's runtime safety state.

## Requirements

- Flutter SDK compatible with Dart `^3.11.4`
- Android Studio / Android SDK
- Android phone with Bluetooth
- ESP32 NeoRider hardware

## Setup

From the repository root:

```sh
flutter pub get
```

## Run Main Application

The main application entry point is `lib/main.dart`:

```sh
flutter run --dart-define=NEORIDER_API_BASE_URL=http://YOUR_PC_IP:8002
```

## Run BLE Test

```sh
flutter run -t lib/ble_test_main.dart --dart-define=NEORIDER_API_BASE_URL=http://YOUR_PC_IP:8002
```

## Run with Deployed Backend

```sh
flutter run -t lib/ble_test_main.dart --dart-define=NEORIDER_API_BASE_URL=https://YOUR_BACKEND_URL
```

The main application can use the deployed URL with the same `--dart-define` option.

## BLE Device

Device name: `NeoRider-Helmet`

## BLE Characteristics

- Helmet notify: `6e400003-b5a3-f393-e0a9-e50e24dcca9e`
- Chest notify: `6e400004-b5a3-f393-e0a9-e50e24dcca9e`
- Control write: `6e400005-b5a3-f393-e0a9-e50e24dcca9e`

Packets are 20 bytes, little-endian, and include IMU values plus a sequence number. Helmet and chest packets are matched by sequence before forwarding.

## Live Data Pipeline

Helmet IMU + Chest IMU -> ESP32 -> BLE -> Flutter -> synchronized packet pair -> FastAPI `POST /sensor/live` -> ML prediction -> `final_state` -> UI / actuator command

## Safety States

The backend runtime states are:

- `SAFE`
- `RISK`
- `ACCIDENT_PENDING`
- `ACCIDENT_CONFIRMED`
- `UNKNOWN`

`ACCIDENT_CONFIRMED` is the backend-confirmed accident state used to activate physical vibration/buzzer feedback. `RISK` and `ACCIDENT_PENDING` remain warning/information states and do not activate accident feedback.

## Backend Configuration

The app reads `NEORIDER_API_BASE_URL` at compile time through `String.fromEnvironment` in `lib/config/api_config.dart`. Supply it with `--dart-define` whenever running or building the app. The value should contain the scheme and host (and port when needed), without the `/sensor/live` path.

No developer-specific LAN address or deployed production URL is stored in the source. If the define is omitted, requests fail with a configuration message instead of silently targeting a machine-specific address.

## Troubleshooting

- Bluetooth must be enabled.
- Required Android Bluetooth permissions must be granted.
- Phone and laptop must be on the same network when using a local FastAPI IP.
- `127.0.0.1` from the phone points to the phone, not the laptop.
- Use the laptop's LAN IPv4 address for local testing.
- Ensure FastAPI listens on an interface reachable from the phone, such as `0.0.0.0`.
- A deployed backend removes the same-Wi-Fi requirement.
- If the helmet is not found, confirm it advertises as `NeoRider-Helmet` and is not connected to another device.

## Verification

```sh
flutter analyze
```
