#Project Structure

mental_health_dashboard/
├── app.py
├── data/
│   └── sample_data.csv
├── models/
│   └── analysis.py
│   └── visualization.py
│   └── standardization.py
│   └── recommendations.py
├── static/
│   └── css/
│   └── js/
├── templates/
│   └── index.html
│   └── dashboard.html
│   └── login.html
│   └── register.html
│   └── profile.html
│   └── recommendations.html
├── tests/
│   └── test_analysis.py
│   └── test_visualization.py
│   └── test_recommendations.py
├── .github/
│   └── workflows/
│       └── ci.yml
└── requirements.txt

# requirements.txt

Flask
Flask-Login
Flask-SQLAlchemy
pandas
numpy
matplotlib
seaborn
plotly
scikit-learn
gunicorn
psycopg2


# app.py

from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
import pandas as pd
from models.analysis import analyze_data
from models.visualization import create_visualizations
from models.standardization import compute_phq9
from models.recommendations import get_recommendations

app = Flask(__name__)
app.config['SECRET_KEY'] = 'supersecretkey'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///users.db'
db = SQLAlchemy(app)
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(150), unique=True, nullable=False)
    password = db.Column(db.String(150), nullable=False)
    profile_data = db.Column(db.Text, nullable=True)

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        user = User.query.filter_by(username=username).first()
        if user and user.password == password:
            login_user(user)
            return redirect(url_for('dashboard'))
        else:
            flash('Login Unsuccessful. Please check username and password', 'danger')
    return render_template('login.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        new_user = User(username=username, password=password)
        db.session.add(new_user)
        db.session.commit()
        return redirect(url_for('login'))
    return render_template('register.html')

@app.route('/dashboard')
@login_required
def dashboard():
    data = pd.read_csv('data/sample_data.csv')
    analysis_results = analyze_data(data)
    visualizations = create_visualizations(data)
    phq9_scores = compute_phq9(data)
    recommendations = get_recommendations(phq9_scores.mean())  # Example of generating recommendations
    return render_template('dashboard.html', 
                           analysis_results=analysis_results, 
                           visualizations=visualizations,
                           phq9_scores=phq9_scores,
                           recommendations=recommendations)

@app.route('/profile', methods=['GET', 'POST'])
@login_required
def profile():
    if request.method == 'POST':
        profile_data = request.form['profile_data']
        current_user.profile_data = profile_data
        db.session.commit()
        flash('Profile updated successfully', 'success')
    return render_template('profile.html', profile_data=current_user.profile_data)

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True)


# models/recommendations.py
def get_recommendations(phq9_score):
    if phq9_score < 5:
        return "Your depression levels are minimal. Keep maintaining a healthy lifestyle."
    elif 5 <= phq9_score < 10:
        return "Mild depression detected. Consider seeking support from friends or family."
    elif 10 <= phq9_score < 15:
        return "Moderate depression detected. It's advisable to consult with a mental health professional."
    elif 15 <= phq9_score < 20:
        return "Moderately severe depression detected. Professional treatment is recommended."
    else:
        return "Severe depression detected. Immediate professional help is strongly recommended."


# templates/profile.html

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Profile</title>
</head>
<body>
    <h1>Profile</h1>
    <form method="POST">
        <label for="profile_data">Profile Data:</label>
        <textarea name="profile_data" id="profile_data" rows="10" cols="50">{{ profile_data }}</textarea>
        <button type="submit">Save</button>
    </form>
    <a href="/dashboard">Back to Dashboard</a>
</body>
</html>


# templates/dashboard.html

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dashboard</title>
</head>
<body>
    <h1>Dashboard</h1>
    <div>
        <h2>Analysis Results</h2>
        <pre>{{ analysis_results }}</pre>
    </div>
    <div>
        <h2>Visualizations</h2>
        <div>{{ visualizations.scatter_plot | safe }}</div>
        <div>{{ visualizations.centroids_plot | safe }}</div>
    </div>
    <div>
        <h2>PHQ-9 Scores</h2>
        <pre>{{ phq9_scores }}</pre>
    </div>
    <div>
        <h2>Recommendations</h2>
        <p>{{ recommendations }}</p>
    </div>
    <a href="/profile">Go to Profile</a>
    <a href="/logout">Logout</a>
</body>
</html>


# tests/test_recommendations.py

import unittest
from models.recommendations import get_recommendations

class TestRecommendations(unittest.TestCase):

    def test_get_recommendations(self):
        self.assertEqual(get_recommendations(3), "Your depression levels are minimal. Keep maintaining a healthy lifestyle.")
        self.assertEqual(get_recommendations(7), "Mild depression detected. Consider seeking support from friends or family.")
        self.assertEqual(get_recommendations(12), "Moderate depression detected. It's advisable to consult with a mental health professional.")
        self.assertEqual(get_recommendations(17), "Moderately severe depression detected. Professional treatment is recommended.")
        self.assertEqual(get_recommendations(22), "Severe depression detected. Immediate professional help is strongly recommended.")

if __name__ == '__main__':
    unittest.main()


# newrelic.ini

[newrelic]
license_key = YOUR_NEW_RELIC_LICENSE_KEY
app_name = Mental Health Dashboard
monitor_mode = true
log_level = info


# Update the application to include New Relic monitoring

import newrelic.agent
newrelic.agent.initialize('newrelic.ini')

# Existing imports and code

if __name__ == '__main__':
    app.run(debug=True)


# github/workflows/ci.yml
# Finalized GitHub Actions CI Configuration. Ensure the CI pipeline runs tests and checks the code on every commit

name: CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.x

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt

    - name: Run tests
      run: |
        python -m unittest discover tests
