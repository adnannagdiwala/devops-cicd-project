"""
Task Manager Backend API
A simple Flask REST API for managing tasks, connected to MySQL.
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
import mysql.connector
import os
import time

app = Flask(__name__)
CORS(app)

# Database configuration from environment variables
DB_CONFIG = {
    'host': os.environ.get('DB_HOST', 'localhost'),
    'port': int(os.environ.get('DB_PORT', 3306)),
    'user': os.environ.get('DB_USER', 'root'),
    'password': os.environ.get('DB_PASSWORD', 'rootpassword'),
    'database': os.environ.get('DB_NAME', 'taskmanager'),
}


def get_db_connection():
    """Create and return a database connection."""
    return mysql.connector.connect(**DB_CONFIG)


def init_db():
    """Initialize the database and create tables if they don't exist."""
    max_retries = 10
    for attempt in range(max_retries):
        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS tasks (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    title VARCHAR(255) NOT NULL,
                    description TEXT,
                    status ENUM('pending', 'in_progress', 'completed') DEFAULT 'pending',
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
                )
            ''')
            conn.commit()
            cursor.close()
            conn.close()
            print("✅ Database initialized successfully!")
            return
        except mysql.connector.Error as err:
            print(f"⏳ Waiting for database... attempt {attempt + 1}/{max_retries} ({err})")
            time.sleep(5)
    print("❌ Failed to connect to database after retries.")


# ─── Health Check ────────────────────────────────────────────────

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint for Kubernetes probes."""
    try:
        conn = get_db_connection()
        conn.close()
        return jsonify({'status': 'healthy', 'database': 'connected'}), 200
    except Exception as e:
        return jsonify({'status': 'unhealthy', 'database': str(e)}), 500


# ─── API Endpoints ───────────────────────────────────────────────

@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    """Get all tasks."""
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute('SELECT * FROM tasks ORDER BY created_at DESC')
    tasks = cursor.fetchall()
    cursor.close()
    conn.close()
    # Convert datetime objects to strings for JSON serialization
    for task in tasks:
        task['created_at'] = task['created_at'].isoformat() if task['created_at'] else None
        task['updated_at'] = task['updated_at'].isoformat() if task['updated_at'] else None
    return jsonify(tasks), 200


@app.route('/api/tasks', methods=['POST'])
def create_task():
    """Create a new task."""
    data = request.get_json()
    if not data or 'title' not in data:
        return jsonify({'error': 'Title is required'}), 400

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        'INSERT INTO tasks (title, description, status) VALUES (%s, %s, %s)',
        (data['title'], data.get('description', ''), data.get('status', 'pending'))
    )
    conn.commit()
    task_id = cursor.lastrowid
    cursor.close()
    conn.close()
    return jsonify({'id': task_id, 'message': 'Task created successfully'}), 201


@app.route('/api/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    """Update an existing task."""
    data = request.get_json()
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        'UPDATE tasks SET title=%s, description=%s, status=%s WHERE id=%s',
        (data.get('title'), data.get('description'), data.get('status'), task_id)
    )
    conn.commit()
    affected = cursor.rowcount
    cursor.close()
    conn.close()
    if affected == 0:
        return jsonify({'error': 'Task not found'}), 404
    return jsonify({'message': 'Task updated successfully'}), 200


@app.route('/api/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    """Delete a task."""
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('DELETE FROM tasks WHERE id=%s', (task_id,))
    conn.commit()
    affected = cursor.rowcount
    cursor.close()
    conn.close()
    if affected == 0:
        return jsonify({'error': 'Task not found'}), 404
    return jsonify({'message': 'Task deleted successfully'}), 200


# ─── App Info ────────────────────────────────────────────────────

@app.route('/', methods=['GET'])
def index():
    """Root endpoint — basic API info."""
    return jsonify({
        'app': 'Task Manager API',
        'version': '1.0.0',
        'endpoints': {
            'GET /health': 'Health check',
            'GET /api/tasks': 'List all tasks',
            'POST /api/tasks': 'Create a task',
            'PUT /api/tasks/<id>': 'Update a task',
            'DELETE /api/tasks/<id>': 'Delete a task',
        }
    })


if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5000, debug=False)
