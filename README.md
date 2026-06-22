# Online Student Attendance Application (Face Recognition-Based)

A digital attendance system that replaces manual roll-call with secure, multi-layer verification — combining a faculty-generated session code, location-based geofencing, and face recognition — to eliminate proxy attendance in academic institutions.

## Overview

Manual attendance marking in classrooms is time-consuming and prone to proxy attendance. This application solves that with a three-layer verification process: faculty generate a time-bound session code restricted to a specific location, and students must be physically present within that location and pass face recognition before their attendance is accepted. Admins, faculty, and students each get role-specific access to manage and track attendance.

## Features

- **Multi-Role Authentication** — separate login and access levels for Admin, Faculty, and Student
- **Faculty-Generated Session Code** — faculty select a subject and division to generate a unique 4-digit code for that session
- **Geofenced Code Validation** — the code only works within a location radius defined by the faculty, preventing remote proxy marking
- **Face Recognition Verification** — students must pass a face recognition check before attendance is accepted, even with a valid code
- **Real-Time Attendance Percentage** — attendance percentage is calculated and updated instantly
- **Attendance History Reports** — students can view their attendance history and track their percentage over time

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter |
| Face Recognition / Backend Logic | Python |
| Database | MySQL |
| IDE | Android Studio |

## Getting Started

### Prerequisites
- Flutter SDK installed
- Android Studio (with an emulator or a physical device for testing)
- Python environment for the face recognition module
- MySQL server running locally or remotely

### Setup
1. Clone the repository
   ```bash
   git clone https://github.com/PatelVishakha-07/<repo-name>.git
   ```
2. Open the Flutter project in Android Studio and run:
   ```bash
   flutter pub get
   ```
3. Set up the MySQL database using the provided schema/scripts and update the database connection details in the project configuration
4. Set up the Python face recognition module and install its dependencies:
   ```bash
   pip install -r requirements.txt
   ```
5. Run the Flutter app:
   ```bash
   flutter run
   ```

## How It Works

1. **Admin** sets up faculty, students, subjects, and divisions
2. **Faculty** selects a subject and division, then generates a unique 4-digit session code, valid only within a defined location radius
3. **Students** enter the code (only accepted within the faculty's set location) and complete **face recognition verification**
4. Attendance is marked only after both checks pass, and the **attendance percentage updates in real time**
5. **Students** can log in to view their attendance history and current percentage

## Author

**Vishakha Patel**
[LinkedIn](https://www.linkedin.com/in/patelvishakha-tech)

