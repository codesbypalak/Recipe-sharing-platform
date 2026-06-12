# Recipe-sharing-platform
=============================================================
Project Title : Recipe Sharing Collaborative Platform
=============================================================


-------------------------------------------------------------
1. PROJECT OVERVIEW & FEATURES
-------------------------------------------------------------
This project is a fully functional Recipe Sharing Web Application where users can upload, share, rate, and review recipes. 

Key Features:
- User Authentication (Register, Login, Secure Password Hashing)
- Recipe Management (Create, View, Categorize, Upload Images/Videos)
- Interactive Community (Star Ratings, Review Comments, Favorite Recipes)
- Follow System (Follow other chefs/users)
- Dynamic Admin Dashboard (View Stats, Manage Feedback)


-------------------------------------------------------------
2. TECHNOLOGY STACK
-------------------------------------------------------------
- Frontend: HTML5, CSS3 (Glassmorphism UI), JavaScript
- Backend: Python 3.8+, Flask Framework
- Database: MySQL (using XAMPP)
- Security: Werkzeug Password Hashing


-------------------------------------------------------------
3. PREREQUISITES
-------------------------------------------------------------
To run this project on your local machine, you will need:
- XAMPP (or WAMP) server installed for the MySQL Database.
- Python installed (version 3.8 or higher is recommended).


-------------------------------------------------------------
4. INSTALLATION & SETUP
-------------------------------------------------------------
Step 1: Download the Project
1. Extract the project ZIP file to your local server directory.
   Example: `C:\xampp\htdocs\Recipe-webapp`

Step 2: Database Setup
1. Open your XAMPP Control Panel.
2. Click "Start" on both Apache and MySQL.
3. Open your browser and go to: http://localhost/phpmyadmin
4. Click on "New" and create a database exactly named: recipe_sharing
5. Click "Create".
(Note: You DO NOT need to manually create the database tables! The Python script will automatically build all necessary tables upon first startup.)

Step 3: Setup Python Environment
1. Open Command Prompt (cmd) or VS Code Terminal.
2. Navigate to the project directory:
   cd c:\xampp\htdocs\Recipe-webapp
3. Create a virtual environment:
   python -m venv venv
4. Activate the environment:
   - On Windows: venv\Scripts\activate
   - On Mac/Linux: source venv/bin/activate
5. Install project dependencies:
   pip install -r requirements.txt


-------------------------------------------------------------
5. RUNNING THE APPLICATION
-------------------------------------------------------------
1. Ensure XAMPP (MySQL) is running.
2. In your terminal, start the server using:
   python app_final.py
3. Open your web browser and go to:
   http://127.0.0.1:5000/


-------------------------------------------------------------
6. EVALUATION / TESTING CREDENTIALS (FOR EXAMINERS)
-------------------------------------------------------------
To accurately evaluate the system's role-based access, please use the following credentials. 
Important: Passwords in the database are securely hashed, demonstrating real-world security practices.

A) ADMIN DASHBOARD
To test the backend administration panel, visit: http://127.0.0.1:5000/admin/login
- Admin Username: nepals
- Admin Password: nepals

B) NORMAL USER
To test normal user features (uploading recipes, writing reviews, favoriting), you can use this pre-registered account:
- Username: ariya
- Password: password123

(To create the 'ariya' user account automatically, double-click or run the `seed_ariya.py` script provided in the folder before logging in! Alternatively, you can click "Register" on the website and create a brand new test account naturally.)


-------------------------------------------------------------
7. PROJECT STRUCTURE 
-------------------------------------------------------------
- app_final.py : Main application controller handling entire routing.
- config.py    : Database configuration file.
- database.py  : Automated Database Schema & Table creation logic.
- requirements.txt: List of dependent Python libraries.
- templates/   : Frontend HTML UI blocks.
- static/      : CSS files, JavaScript, and user-uploaded media.

=============================================================
                      END OF DOCUMENT
=============================================================
