# AI-Powered Malnutrition Monitoring App (Mobile)

This repository contains the Flutter mobile application for my graduation project. The app is designed to help United Nations workers and nutrition officers monitor child malnutrition in low-income areas.

The application uses a hybrid architecture. It connects directly to Firebase (Auth and Firestore) for user management and data storage. For heavy AI operations (object detection and LLM generation), it communicates with a separate Python backend server via a secure Cloudflare Tunnel connection.

### Key Features
* Role-Based Access: Dedicated interfaces for Field Workers, Nutrition Officers, and Camp Managers.
* Child Management: Register children and automatically calculate risk levels based on MUAC, weight, and edema data.
* Stock Tracking: Monitor RUTF (Ready-to-Use Therapeutic Food) inventory and distributions in real-time.
* Barcode Scanning: Scan RUTF packages using the device camera to log meal intakes.
* AI Integration: Sends captured food photos and child health data to the Python backend to receive food detection results and nutrition advice.

### Architecture and Connection
The app communicates with the backend server over HTTPS using a Cloudflare Tunnel. This allows the mobile application to securely access the FastAPI server running on a local machine (Apple M3 Silicon), enabling high-performance AI inference without needing a cloud GPU instance.

### Tech Stack
* Framework: Flutter (Dart)
* Database: Google Firebase (Firestore)
* Authentication: Firebase Auth
* Connectivity: Cloudflare Tunnel (for Backend API)
* Visualization: fl_chart and syncfusion_flutter_gauges
