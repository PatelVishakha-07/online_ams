# Online Student Attendance Application (Face Recognition-Based)

A digital attendance system that replaces manual roll-call with secure, automated attendance marking using facial recognition — built for academic institutions with multi-role access for admins, faculty, and students.

## Overview

Manual attendance marking in classrooms is time-consuming and prone to proxy attendance. This application solves that by using facial recognition to verify a student's identity before marking them present, while giving faculty and admins the tools to manage subjects, divisions, and attendance records efficiently.

## Features

- **Multi-Role Authentication** — separate login and access levels for Admin, Faculty, and Student
- **Face Recognition-Based Marking** — attendance is marked only after verifying the student's face, preventing proxy attendance
- **Subject & Division-Wise Attendance** — faculty can mark attendance for specific subjects and divisions
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
2. **Faculty** selects a subject and division, then initiates attendance marking
3. Each student's identity is verified using **face recognition** before attendance is marked
4. Attendance is recorded and the **attendance percentage updates in real time**
5. **Students** can log in to view their attendance history and current percentage

## Author

**Vishakha Patel**
[LinkedIn](https://www.linkedin.com/in/patelvishakha-tech)
