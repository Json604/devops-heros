import os
os.environ['DATABASE_URL'] = 'sqlite://'

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from app.db import Base, get_db
from app.main import app

@pytest.fixture()
def client():
    engine = create_engine('sqlite://', connect_args={'check_same_thread': False}, poolclass=StaticPool)
    Base.metadata.create_all(engine)
    sessions = sessionmaker(bind=engine)
    def database():
        with sessions() as session:
            yield session
    app.dependency_overrides[get_db] = database
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()
    engine.dispose()

def test_health(client):
    assert client.get('/health').json() == {'status': 'UP'}

def test_readiness(client):
    assert client.get('/ready').json() == {'status': 'READY'}

def test_create_and_read_ticket(client):
    response = client.post('/api/tickets', json={'title': 'Lab Wi-Fi unavailable', 'category': 'NETWORK', 'requester': '24bcs10121'})
    assert response.status_code == 201
    ticket = response.json()
    assert ticket['category'] == 'NETWORK'
    assert client.get(f"/api/tickets/{ticket['id']}").json()['requester'] == '24bcs10121'
    assert len(client.get('/api/tickets').json()) == 1

def test_update_and_statistics(client):
    ticket = client.post('/api/tickets', json={'title': 'Projector repair'}).json()
    response = client.put(f"/api/tickets/{ticket['id']}", json={'status': 'RESOLVED'})
    assert response.status_code == 200
    assert response.json()['title'] == 'Projector repair'
    assert client.get('/api/tickets/stats').json() == {'total': 1, 'open': 0, 'inProgress': 0, 'resolved': 1}

def test_delete_ticket(client):
    ticket = client.post('/api/tickets', json={'title': 'Reset lab account'}).json()
    assert client.delete(f"/api/tickets/{ticket['id']}").status_code == 204
    assert client.get(f"/api/tickets/{ticket['id']}").status_code == 404

@pytest.mark.parametrize('payload', [{'title': ''}, {'title': '   '}, {'title': 'x', 'priority': 'URGENT'}, {'title': 'x', 'category': 'INVALID'}, {'title': 'x' * 201}])
def test_invalid_ticket_is_rejected(client, payload):
    assert client.post('/api/tickets', json=payload).status_code == 422

@pytest.mark.parametrize('payload', [{'title': None}, {'status': None}, {'title': '  '}])
def test_invalid_update_does_not_change_record(client, payload):
    ticket = client.post('/api/tickets', json={'title': 'Working title'}).json()
    assert client.put(f"/api/tickets/{ticket['id']}", json=payload).status_code == 422
    assert client.get(f"/api/tickets/{ticket['id']}").json()['title'] == 'Working title'

@pytest.mark.parametrize('method', ['get', 'put', 'delete'])
def test_missing_ticket(client, method):
    kwargs = {'json': {'status': 'RESOLVED'}} if method == 'put' else {}
    assert getattr(client, method)('/api/tickets/999', **kwargs).status_code == 404

def test_metrics(client):
    client.get('/health')
    response = client.get('/metrics')
    assert response.status_code == 200
    assert 'http_requests_total' in response.text
