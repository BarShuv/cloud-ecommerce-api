# Cloud E-commerce API

A simplified cloud-native e-commerce platform focusing on a RESTful API backend and database components, deployed on AWS using infrastructure as code.

## Architecture Overview

The solution consists of the following components:

1. **RESTful API Backend**
   - Flask-based REST API
   - Containerized with Docker
   - Deployed on AWS EC2
   - Implements basic CRUD operations for products

2. **Database**
   - Currently using in-memory storage
   - Ready for future upgrade to MongoDB

## Tools & Services Used

- **Flask**: Lightweight Python web framework for the API
- **Docker**: Containerization for consistent deployment
- **Terraform**: Infrastructure as Code for AWS resource provisioning
- **AWS EC2**: Compute service for hosting the API
- **AWS Security Groups**: Network security for the EC2 instance

## Prerequisites

- AWS Account with configured credentials
- Terraform installed
- Docker installed (for local testing)
- Python 3.11+

## Setup Instructions

### Local Development

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Create a virtual environment and install dependencies:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. Run the Flask application:
   ```bash
   python app.py
   ```

### Docker Deployment

1. Build the Docker image:
   ```bash
   cd backend
   docker build -t ecommerce-api .
   ```

2. Run the container:
   ```bash
   docker run -p 5000:5000 ecommerce-api
   ```

### AWS Deployment

1. Configure AWS credentials:
   ```bash
   aws configure
   ```

2. Initialize Terraform:
   ```bash
   cd terraform
   terraform init
   ```

3. Apply the Terraform configuration:
   ```bash
   terraform apply
   ```

4. SSH into the EC2 instance and deploy the Docker container:
   ```bash
   ssh ubuntu@<EC2_PUBLIC_IP>
   docker run -d -p 5000:5000 ecommerce-api
   ```

## API Endpoints

- `GET /products`: Retrieve all products
- `POST /products`: Create a new product
- `DELETE /products/{id}`: Delete a product by ID

Example POST request:
```bash
curl -X POST -H "Content-Type: application/json" -d '{"name":"New Product","price":99.99,"description":"A new product"}' http://localhost:5000/products
```

## Future Improvements

1. **Database Integration**
   - Implement MongoDB for persistent storage
   - Add database migration scripts

2. **Authentication**
   - Add JWT-based authentication
   - Integrate with AWS Cognito

3. **Monitoring & Logging**
   - Implement CloudWatch integration
   - Add structured logging

4. **CI/CD Pipeline**
   - Set up GitHub Actions for automated testing and deployment
   - Implement blue-green deployment strategy

## Security Considerations

- The current setup uses basic security groups
- In production, consider:
  - Restricting SSH access to specific IP ranges
  - Implementing HTTPS
  - Adding rate limiting
  - Setting up AWS WAF

## License

MIT 