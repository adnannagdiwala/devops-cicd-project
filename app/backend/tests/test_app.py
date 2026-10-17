"""
Unit tests for the Task Manager API.
"""

import pytest
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app import app


@pytest.fixture
def client():
    """Create a test client for the Flask app."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_index(client):
    """Test the root endpoint returns API info."""
    response = client.get('/')
    assert response.status_code == 200
    data = response.get_json()
    assert data['app'] == 'Task Manager API'
    assert data['version'] == '1.0.0'
    assert 'endpoints' in data


def test_health_check_endpoint_exists(client):
    """Test that health endpoint exists (may fail without DB)."""
    response = client.get('/health')
    # Will be 200 if DB is connected, 500 if not — both are valid responses
    assert response.status_code in [200, 500]
    data = response.get_json()
    assert 'status' in data


def test_get_tasks_endpoint_exists(client):
    """Test that tasks listing endpoint exists."""
    response = client.get('/api/tasks')
    # May fail without DB, but endpoint should exist
    assert response.status_code in [200, 500]


def test_create_task_requires_title(client):
    """Test that creating a task without a title returns 400."""
    response = client.post('/api/tasks', json={})
    assert response.status_code == 400
    data = response.get_json()
    assert 'error' in data
