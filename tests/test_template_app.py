import pytest
from fastapi import status
from fastapi.testclient import TestClient

from app.app import app

class TestTemplateApp:
    """
    Template test.
    """
    @pytest.fixture
    def client(self) -> TestClient:
        """
        FastAPI client.
        """
        return TestClient(app=app)

    def test(
            self,
            client: TestClient,
        ):
        """
        Test template .
        """
        response = client.get("/")
        assert response.status_code == status.HTTP_200_OK
        assert response.json() == {"message": "Hello World"}