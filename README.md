# Cloud E-commerce API

A simplified cloud-native e-commerce platform focusing on RESTful API Backend and Database components, deployed on AWS.

## Architecture Overview

The solution implements two main components from the requirements:
1. **RESTful API Backend**: A Flask-based API service containerized with Docker
2. **Database**: MongoDB for product data storage

### Cloud Services Used
- **AWS EC2**: For hosting the application
- **Docker**: For containerization of the API and database
- **MongoDB**: As the database service
- **GitHub Actions**: For automated deployment

## Features

- RESTful API endpoints for product management:
  - GET /products - List all products
  - POST /products - Create a new product
  - DELETE /products/{id} - Delete a product
- Docker containerization for easy deployment
- MongoDB integration for data persistence
- Automated deployment using GitHub Actions
- Zero-downtime deployments with Docker Compose

## Prerequisites

- Docker and Docker Compose
- Python 3.9+
- MongoDB (included in Docker setup)

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/BarShuv/cloud-ecommerce-api.git
   cd cloud-ecommerce-api
   ```

2. Start the application:
   ```bash
   docker-compose up -d
   ```

3. Test the API:
   ```bash
   bash test_api.sh
   ```

## API Endpoints

### Get All Products
```bash
curl http://localhost:5000/products
```

### Create a Product
```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"name":"Product Name","price":99.99,"description":"Product description"}' \
  http://localhost:5000/products
```

### Delete a Product
```bash
curl -X DELETE http://localhost:5000/products/{product_id}
```

## Deployment

### Manual Deployment
The application is deployed on AWS EC2 using Docker containers. The deployment process includes:
1. Setting up an EC2 instance
2. Installing Docker and Docker Compose
3. Cloning the repository
4. Running the application with docker-compose

### Automated Deployment
The project uses GitHub Actions for automated deployment:
1. When code is pushed to the main branch, GitHub Actions automatically:
   - Connects to the EC2 instance via SSH
   - Pulls the latest code
   - Restarts the Docker containers

To set up automated deployment:
1. Add the following secrets to your GitHub repository:
   - `EC2_SSH_KEY`: Your EC2 instance's private SSH key
   - `EC2_HOST`: Your EC2 instance's public IP address

## Future Improvements

If given more time, I would implement:
1. Authentication service integration
2. Web Front End with React/Vue.js
3. Real-time data processing for inventory updates
4. Enhanced security measures
5. Load balancing and auto-scaling
6. Monitoring and logging solutions

## License

MIT License

## Contact

For any questions or issues, please open an issue in the GitHub repository. 