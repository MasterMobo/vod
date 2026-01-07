# VOD - Video On Demand Streaming Platform

A DIY Netflix-style video streaming application built to explore modern backend technologies, cloud infrastructure, and full-stack development. This project serves as a learning platform for Spring Boot, Next.js, AWS services, and video streaming architecture.

## 🎯 Project Purpose

This project is designed to:
- **Learn modern backend development** with Spring Boot and Java
- **Explore cloud infrastructure** using AWS services (RDS, S3, CloudFront, EC2/Elastic Beanstalk)
- **Build a production-like video streaming platform** with authentication, user profiles, and video delivery
- **Understand video streaming architecture** including HTTP range requests, CDN distribution, and scalable storage

## ✨ Features

### Core Features (MVP)
- **Video Browsing**
  - Browse videos by category
  - Search functionality
  - Paginated video listings
  - Video details pages with metadata

- **Video Playback**
  - Stream videos with seeking support (HTTP Range requests)
  - Responsive video player
  - Continue watching functionality (tracks last watched position)

- **User Authentication**
  - User registration and login
  - JWT-based authentication
  - Role-based access control (User, Admin)
  - Secure password hashing

- **Personalization**
  - "My List" - save videos to watch later
  - Viewing history and progress tracking
  - User profiles

- **Admin Features**
  - Upload videos with metadata
  - Manage video catalog
  - Admin dashboard

### Technical Features
- RESTful API architecture
- Cloud-native deployment on AWS
- CDN-accelerated video delivery via CloudFront
- Scalable database architecture with PostgreSQL
- Docker containerization
- API security with rate limiting and validation

## 🏗️ Architecture

### System Architecture Diagram

```mermaid
graph TB
    subgraph "Client Layer"
        WEB[Next.js Web App<br/>Port 3000]
        MOBILE[Mobile App<br/>Future]
    end

    subgraph "AWS Cloud"
        subgraph "CDN & Storage"
            CF[CloudFront CDN<br/>Video Delivery]
            S3[S3 Bucket<br/>Video Files & Thumbnails]
        end

        subgraph "Application Layer"
            EB[Elastic Beanstalk / EC2<br/>Spring Boot API<br/>Port 8080]
        end

        subgraph "Database Layer"
            RDS[(RDS PostgreSQL<br/>User Data & Metadata)]
        end

        subgraph "AWS Services"
            COGNITO[AWS Cognito<br/>Optional Auth]
            CLOUDWATCH[CloudWatch<br/>Logging & Metrics]
            SECRETS[Secrets Manager<br/>Credentials]
        end
    end

    subgraph "Local Development"
        LOCAL_DB[(Local PostgreSQL<br/>Docker)]
        LOCAL_STORAGE[Local File System<br/>Video Storage]
    end

    WEB -->|HTTPS| CF
    WEB -->|REST API| EB
    MOBILE -.->|Future| EB

    CF -->|Cache Miss| S3
    EB -->|Read/Write| RDS
    EB -->|Generate Pre-signed URLs| S3
    EB -->|Store Secrets| SECRETS
    EB -->|Logs & Metrics| CLOUDWATCH

    EB -.->|Dev Mode| LOCAL_DB
    EB -.->|Dev Mode| LOCAL_STORAGE

    style WEB fill:#61dafb
    style EB fill:#6db33f
    style RDS fill:#336791
    style S3 fill:#ff9900
    style CF fill:#ff9900
```

### Component Architecture

```mermaid
graph LR
    subgraph "Frontend - Next.js"
        A[Pages & Routes] --> B[API Client]
        B --> C[State Management]
        C --> D[UI Components]
    end

    subgraph "Backend - Spring Boot"
        E[Controllers] --> F[Services]
        F --> G[Repositories]
        G --> H[(Database)]
        F --> I[Security Layer]
        F --> J[File Storage]
    end

    subgraph "AWS Infrastructure"
        K[S3 Storage] --> L[CloudFront CDN]
        M[RDS Database] --> N[Backup & Replication]
    end

    B -->|HTTP/REST| E
    E -->|JWT Auth| I
    J -->|Upload/Download| K
    G -->|SQL Queries| M
    L -->|Video Streams| D

    style A fill:#61dafb
    style E fill:#6db33f
    style K fill:#ff9900
    style M fill:#336791
```

### Data Flow - Video Streaming

```mermaid
sequenceDiagram
    participant User
    participant NextJS as Next.js Frontend
    participant API as Spring Boot API
    participant DB as PostgreSQL
    participant S3 as AWS S3
    participant CF as CloudFront CDN

    User->>NextJS: Browse Videos
    NextJS->>API: GET /api/videos
    API->>DB: Query video metadata
    DB-->>API: Return video list
    API-->>NextJS: JSON response
    NextJS-->>User: Display video grid

    User->>NextJS: Click Play Video
    NextJS->>API: GET /api/videos/{id}
    API->>DB: Get video metadata
    DB-->>API: Video details + S3 key
    API-->>NextJS: Video metadata + CloudFront URL
    NextJS->>CF: Request video stream
    CF->>S3: Fetch if not cached
    S3-->>CF: Video file chunks
    CF-->>NextJS: Stream video (Range requests)
    NextJS-->>User: Play video in player

    User->>NextJS: Add to Watchlist
    NextJS->>API: POST /api/watchlist/{id} (with JWT)
    API->>API: Validate JWT token
    API->>DB: Insert watchlist item
    DB-->>API: Success
    API-->>NextJS: Confirmation
    NextJS-->>User: Update UI
```

## 🛠️ Tech Stack

### Frontend
- **Framework**: Next.js 14+ (App Router)
- **Language**: TypeScript
- **Styling**: CSS Modules / Tailwind CSS (optional)
- **State Management**: React Context / Zustand (optional)

### Backend
- **Framework**: Spring Boot 3.x
- **Language**: Java 17+
- **Security**: Spring Security + JWT
- **Database**: PostgreSQL (via Spring Data JPA)
- **Build Tool**: Maven
- **Validation**: Bean Validation

### Infrastructure & DevOps
- **Cloud Provider**: AWS
  - **Compute**: Elastic Beanstalk / EC2
  - **Database**: RDS PostgreSQL
  - **Storage**: S3
  - **CDN**: CloudFront
  - **Monitoring**: CloudWatch
  - **Secrets**: AWS Secrets Manager / SSM Parameter Store
- **Containerization**: Docker
- **Version Control**: Git

### Development Tools
- **IDE**: VS Code / Cursor
- **Database**: Docker (local PostgreSQL)
- **API Testing**: Postman / curl
- **Package Management**: npm / pnpm

## 📁 Project Structure

```
vod/
├── backend/                 # Spring Boot application
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── com/vod/
│   │   │   │       ├── controller/    # REST controllers
│   │   │   │       ├── service/       # Business logic
│   │   │   │       ├── repository/    # Data access
│   │   │   │       ├── entity/        # JPA entities
│   │   │   │       ├── dto/           # Data transfer objects
│   │   │   │       ├── security/      # Security config & JWT
│   │   │   │       └── config/        # Configuration classes
│   │   │   └── resources/
│   │   │       └── application.yml    # App configuration
│   │   └── test/                      # Unit & integration tests
│   ├── Dockerfile
│   └── pom.xml                        # Maven dependencies
│
├── frontend/               # Next.js application
│   ├── app/                # App Router pages
│   ├── components/         # React components
│   ├── lib/                # Utilities & API client
│   └── public/             # Static assets
│
├── context/                # Project documentation
│   ├── project_timeline.md
│   └── project_checklist.md
│
└── README.md               # This file
```

## 🚀 Quick Start

### Prerequisites
- Java 17+ JDK
- Maven 3.8+
- Node.js 20+ LTS
- Docker (for local PostgreSQL)
- AWS Account (for cloud deployment)

### Local Development Setup

1. **Start PostgreSQL** (Docker):
   ```bash
   docker run --name vod-postgres \
     -e POSTGRES_PASSWORD=vodpass \
     -e POSTGRES_USER=voduser \
     -e POSTGRES_DB=voddb \
     -p 5432:5432 -d postgres:16
   ```

2. **Backend Setup**:
   ```bash
   cd backend
   ./mvnw spring-boot:run
   ```
   Backend runs on `http://localhost:8080`

3. **Frontend Setup**:
   ```bash
   cd frontend
   npm install
   npm run dev
   ```
   Frontend runs on `http://localhost:3000`

### Detailed Setup Instructions
See `context/project_checklist.md` for a complete step-by-step checklist covering all 4 weeks of development.

## 📚 Learning Resources

### Spring Boot
- [Spring Boot Official Documentation](https://spring.io/projects/spring-boot)
- [Spring Security Reference](https://docs.spring.io/spring-security/reference/)

### Next.js
- [Next.js Documentation](https://nextjs.org/docs)
- [Next.js App Router Guide](https://nextjs.org/docs/app)

### AWS
- [AWS Documentation](https://docs.aws.amazon.com/)
- [AWS Free Tier](https://aws.amazon.com/free/)

### Video Streaming
- [HTTP Range Requests (MDN)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Range_requests)
- [Video Streaming Best Practices](https://www.nginx.com/blog/video-streaming-for-remote-learning-with-nginx/)

## 🗺️ Development Roadmap

This project follows a **4-week structured learning path**:

- **Week 1**: Spring Boot API + Local Video Streaming
- **Week 2**: Next.js Frontend + AWS Basics + First Deployment
- **Week 3**: Cloud-native Storage/Delivery + Better Architecture
- **Week 4**: Hardening, Auth, and Product Features

See `context/project_timeline.md` for detailed weekly breakdowns.

## 🔒 Security Considerations

- **Authentication**: JWT tokens with secure expiration
- **Password Security**: BCrypt hashing
- **API Security**: Rate limiting, input validation
- **AWS Security**: IAM roles, security groups, encrypted storage
- **Secrets Management**: AWS Secrets Manager / SSM Parameter Store
- **HTTPS**: CloudFront SSL/TLS certificates

## 📝 API Endpoints

### Public Endpoints
- `GET /api/videos` - List videos (paginated)
- `GET /api/videos/{id}` - Get video details
- `GET /api/videos/{id}/stream` - Stream video file
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login

### Protected Endpoints (Require JWT)
- `GET /api/watchlist` - Get user's watchlist
- `POST /api/watchlist/{videoId}` - Add to watchlist
- `DELETE /api/watchlist/{videoId}` - Remove from watchlist
- `PUT /api/videos/{id}/progress` - Update viewing progress
- `GET /api/videos/continue-watching` - Get continue watching list

### Admin Endpoints (Require Admin Role)
- `POST /api/admin/videos/presign-upload` - Get pre-signed S3 upload URL
- `POST /api/admin/videos` - Create video metadata
- `GET /api/admin/videos` - List all videos (admin view)
- `DELETE /api/admin/videos/{id}` - Delete video

## 🤝 Contributing

This is a personal learning project. Feel free to fork and adapt for your own learning journey!

## 📄 License

This project is for educational purposes.

---

**Built with ❤️ for learning modern backend development and cloud infrastructure**
# vod
