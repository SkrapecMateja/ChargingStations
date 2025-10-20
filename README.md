# ⚡️ ChargingStations

An iOS app built for the **Trifork Tech Interview** challenge.  
The app helps electric vehicle (EV) drivers find **nearby charging stations** in Switzerland and displays their **real-time availability**.

---

## 🚀 Overview

The **ChargingStations** app is a native Swift iOS application built using **SwiftUI**, **Combine**, and **MVVM**.  

It retrieves charging station data from the **Swiss Confederation open data portal**, updates availability in real time, and supports **offline usage** through local persistence.

---

## 🧩 Features

### ✅ Implemented “MUST” Requirements
- **List of nearby charging stations (1 km radius)**  
  Displays stations around the user's current location.  
  Sorted by **maximum charging power (descending)**.  

- **Real-time availability updates**  
  The list automatically refreshes periodically (every 30 seconds).  
  Displays a **“Last updated”** timestamp in the UI.

- **Offline access**  
  When offline, the last fetched list of nearby stations is loaded from cache.  
  The map view is not cached.

---

### ⚙️ Additional “SHOULD” Features
- **Map centered on current location**  
  Shows nearby charging stations with visual markers.

- **Availability-based icons**  
  Charging stations have distinct colors/icons depending on their availability.

- **Automatic refresh & location updates**  
  The app listens for network changes, location updates, and app foreground/background transitions.

---

## 🏗️ Architecture

The project follows the **MVVM** architecture pattern with **Combine**-based reactive bindings.

| Layer | Responsibility |
|--------|----------------|
| **View (SwiftUI)** | Displays map, station list, and status UI. |
| **ViewModel** | Binds model data to views, handles sorting, filtering, and state management. |
| **Model / Repository** | Defines domain entities and manages persistence and API data. |
| **Networking** | Fetches charging station data and handles API errors gracefully. |
| **Location & Reachability** | Observes the user’s location and network state. |

Key types include:
- `StationsProvider` — orchestrates updates, persistence, and reactive streams.  
- `StationRepository` — handles caching and storage.  
- `StationFetching` —  fetches stations from API.  
- `ReachabilityMonitoring` — Combine wrapper for network reachability.  
- `LocationManagerType` — publishes user location updates.

---

## 💾 Persistence

- The app caches the **last fetched stations** in local storage.
    - Stations are stored in a file in applications directory.
    - NOTE: If there would be more stations than just the 1 km radius required to show, I would store them using CoreData instead.
- On relaunch without network connectivity, cached stations are displayed.
- The **last update timestamp** is stored alongside cached data just to UserDefaults.

---

🧪 Unit Testing
The project includes a lightweight unit testing setup using XCTest and Combine test publishers.
A few initial tests are implemented to verify the core logic and reactive data flow (e.g., location updates, station fetching, and network availability handling).

✅ Current Tests
Mock-driven architecture:
Core services (StationClientMock, LocationManagerMock, NetworkAvailabilityMock) simulate real-world behaviors and responses using Combine publishers.
StationsProvider tests:
 - Validate automatic updates, offline fallback, and correct station publishing behavior.
Mock-based isolation:
- Each component is tested independently from networking, ensuring deterministic, fast tests.
Future improvements: I would add more unit test in a similar way to cover StationsProvider further and view models


## 🌐 Data Source

Open data provided by the **Swiss Confederation**:  
🔗 https://github.com/SFOE/ichtankestrom_Documentation  
🔗 https://opendata.swiss/de/dataset/ladestationen-fuer-elektroautos  

For validation, use:  
🔗 https://map.geo.admin.ch/?lang=en&topic=energie&bgLayer=ch.swisstopo.pixelkarte-grau&layers=ch.bfe.ladestellen-elektromobilitaet  

---

## 🧭 How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/<your-username>/ChargingStations.git
   cd ChargingStations
2. open ChargingStations.xcodeproj
3. Build on a simulator:
    - There is a gpx file that can mock Trifork's office location. Check if it's assigned in the target: 
        1. Open Chargins Stations -> Edit Scheme -> Run -> Options
        2. For defaultLocation choose 'gpxZurich'
4. To run on a device, you will have to 'Trust the developer':
    - Open Settings app after app instalation
    - General -> VPN & Device Managment -> Developer App: mateja.skrapec15@gmail.com
    - Allow install
