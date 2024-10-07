# FastAPI + Docker Project Template

This repository provides a template for a FastAPI project with Docker, Docker Compose, and a development container configuration.
It encourages the developer to use the same Docker container for both develop their application and deploy it, ensuring reproducibility and mitigating unintended errors due to environment discrepancies.

## Features

- FastAPI project template under Poetry for dependency management.
  - Development-related dependencies are isolated in its own group.
- Docker container: Multi-stage build docker container to host the project.
  - `BUILD_MODE` build argument to toggle between deployment and development mode.
  - Serve the application with Uvicorn for hot-reloading when running the container in development mode
and Gunicorn with Uvicorn worker in production mode for multi-threading capabilities.
  - **Non-root** approach:
    - The container runs under a non-root user called `fastapi`.
    - This user has the full ownership over the application files, preventing security and permission issues when mounting the container as a volume in the host and/or when running CI/CD pipelines.
- Development environment:
  - Leverage Docker Compose and GNU Make to build and manage the development environment.
  - The container working directory is mounting to the project folder so any file updated is reflected in the container and vice-versa.
  - Map the exposed port 8000 to the host to enable access to the API.
  - Define the `BUILD_MODE` argument via an environment variable defined in the .env file.
  - GNU Make orchestrates container-related operations.

## Getting Started

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [GNU/Make](https://www.gnu.org/software/make/)

### Using this template

To create a repository using this template, follow these steps:
1. Click on the `Use this template` button.
2. Fill out the repository details asked by GitHub.
3. Clone your repository.
4. Update the [LICENSE](LICENSE.md) file accordingly with your details.
5. Happy hacking!

### Usage
#### Build mode
By default, the project is configured to build the Docker image in deployment mode.
To change this, copy the `.env.example` file to a new `.env` file and set up the `BUILD_MODE` environment variable accordingly.

#### Working with the project
GNU Make is the recommended option to handle the most-common operations. The current `Makefile` defines the following ones:

Usage: make [target]

| target              | Description                                                                                                              |
|---------------------|--------------------------------------------------------------------------------------------------------------------------|
| **help**            | Display this help message (Default target)                                                                             |
| **build**           | Build the Docker images for the services after ensuring services are down                                               |
| **build-no-cache**  | Build the Docker images for the services bypassing the Docker cache                                                     |
| **up**              | Start the services from the images already built in the background                                                      |
| **up-build**        | Build the Docker images and start the services in the background                                                        |
| **stop**            | Stop the services keeping containers, networks, and volumes                                                             |
| **down**            | Stop the services and remove containers, networks, and volumes created by `up`                                         |
| **logs**            | Follow logs for the services                                                                                             |
| **shell**           | Login into the app container to perform the rest of operations not configured in the Makefile, such as dependency management.|
| **test**            | Run linters then the unit test suite. Ensure `BUILD_MODE=development` is set in the .env file; otherwise, this won't work|
| **pytest**          | Run the unit test suite only. Ensure `BUILD_MODE=development` is set in the .env file; otherwise, this won't work      |
| **lint**            | Run all linters                                                                                                        |
| **pylint**          | Run pylint                                                                                                              |
| **black**           | Run black                                                                                                               |
| **isort**           | Run isort                                                                                                               |


Note that since `help` is the default target, you can run just `make` to check the help screen whenever you need.

## Acknowledgements
- [FastAPI](https://fastapi.tiangolo.com/)
- [Poetry](https://python-poetry.org/)
- [Docker](https://www.docker.com/)
- [GNU/Make](https://www.gnu.org/software/make/)

## Contributing
Contributions are welcomed! Feel free to file an issue or a pull request to suggest enhancements or contribute new features.