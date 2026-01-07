## Overall setup (once)

- [x] **Update system packages**
  - [x] Run `sudo apt update && sudo apt upgrade -y`
- [x] **Install Git**
  - [x] Run `sudo apt install -y git`
- [x] **Create project folder**
  - [x] Run `mkdir -p ~/programming/vod && cd ~/programming/vod`
- [x] **Install Java 17 JDK**
  - [x] Run `sudo apt install -y openjdk-17-jdk`
  - [x] Verify with `java -version` shows 17.x
- [x] **Install Maven**
  - [x] Run `sudo apt install -y maven`
  - [x] Verify with `mvn -v`
- [x] **Install Node.js (via nvm)**
  - [x] Install nvm (from nvm docs)
  - [x] Run `nvm install --lts`
  - [x] Verify with `node -v`
- [x] **Install Docker**
  - [x] Run `sudo apt install -y docker.io`
  - [x] Add user to docker group: `sudo usermod -aG docker $USER` (then re-login)
  - [x] Verify with `docker run hello-world`

---

## Week 1 – Spring Boot API + Local Video Streaming

### Week 1 setup

- [x] **Start local Postgres in Docker**
  - [x] Run `docker run --name vod-postgres -e POSTGRES_PASSWORD=vodpass -e POSTGRES_USER=voduser -e POSTGRES_DB=voddb -p 5432:5432 -d postgres:16`
  - [x] Optionally install client: `sudo apt install -y postgresql-client`
  - [x] Verify `psql -h localhost -U voduser -d voddb` connects
- [x] **Generate Spring Boot project (`vod-backend`)**
  - [x] Use Spring Initializr (web or curl) to create project with:
    - Spring Web
    - Spring Data JPA
    - Spring Security
    - Validation
    - PostgreSQL Driver
  - [x] Extract/open project in Cursor
- [x] **Run the app once**
  - [x] From backend folder run `./mvnw spring-boot:run` or `mvn spring-boot:run`
  - [x] Confirm app starts on port 8080 without errors

### Day 1–2: Project setup & core models

- [x] **Configure Postgres connection in `application.yml`**
  - [x] Set `spring.datasource.url=jdbc:postgresql://localhost:5432/voddb`
  - [x] Set `spring.datasource.username=voduser`
  - [x] Set `spring.datasource.password=vodpass`
  - [x] Set `spring.jpa.hibernate.ddl-auto=update` (dev only)
  - [x] Restart app and confirm DB connection is OK
- [ ] **Create JPA entities**
  - [ ] Create `User` entity (`id`, `email`, `passwordHash`, `role`, timestamps)
  - [x] Create `Video` entity (`id`, `title`, `description`, `duration`, `thumbnailUrl`, `videoPath`, `createdAt`)
  - [ ] Create `WatchlistItem` entity (`id`, `user`, `video`, `createdAt`)
- [ ] **Create JPA repositories**
  - [ ] `UserRepository` extends `JpaRepository`
  - [x] `VideoRepository` extends `JpaRepository`
  - [ ] `WatchlistRepository` extends `JpaRepository`
- [ ] **Seed initial video data**
  - [x] Add `CommandLineRunner` or SQL script to insert a few sample videos
- [x] **Create basic video REST endpoints**
  - [x] Create `VideoController`
  - [x] Implement `GET /api/videos` (paginated list)
  - [ ] Implement `GET /api/videos/{id}` (details)
  - [x] Test with `curl http://localhost:8080/api/videos`

### Day 3–4: Auth & watchlist

- [ ] **Set up password encoding**
  - [ ] Add `BCryptPasswordEncoder` bean
- [ ] **Create auth DTOs**
  - [ ] `RegisterRequest`
  - [ ] `LoginRequest`
  - [ ] `AuthResponse` (includes JWT)
- [ ] **Implement auth service**
  - [ ] `register`: create user, hash password, save
  - [ ] `login`: validate credentials, generate JWT
- [ ] **Configure JWT handling**
  - [ ] Define JWT secret in config
  - [ ] Implement JWT utility for generate/validate token
  - [ ] Implement JWT filter:
    - [ ] Read `Authorization: Bearer <token>` header
    - [ ] Validate token and set authentication
- [ ] **Configure Spring Security rules**
  - [ ] Define `SecurityFilterChain`
  - [ ] Permit `/api/auth/**` and `/api/videos/**`
  - [ ] Require auth for `/api/watchlist/**` and `/api/admin/**`
  - [ ] Disable CSRF for stateless JWT API
- [ ] **Create auth endpoints**
  - [ ] `POST /api/auth/register` → returns message or token
  - [ ] `POST /api/auth/login` → returns JWT
  - [ ] Test register/login flow via curl/Postman
- [ ] **Implement watchlist endpoints**
  - [ ] `GET /api/watchlist` (current user’s list)
  - [ ] `POST /api/watchlist/{videoId}` (add)
  - [ ] `DELETE /api/watchlist/{videoId}` (remove)
  - [ ] Use authenticated principal (from JWT) to resolve `User`
  - [ ] Test watchlist flow with JWT in `Authorization` header

### Day 5–7: Local video streaming

- [ ] **Prepare local video files**
  - [ ] Create local `videos/` folder
  - [ ] Place at least one small `.mp4` file in `videos/`
  - [ ] Update a `Video.videoPath` to point to real file path
- [ ] **Implement streaming endpoint**
  - [ ] Create streaming controller method `GET /api/videos/{id}/stream`
  - [ ] Load `Video` by `id` to get `videoPath`
  - [ ] Read `Range` header from request
  - [ ] Implement full file response (`200 OK`) when no range
  - [ ] Implement partial response (`206 Partial Content`) when range present
  - [ ] Set headers: `Content-Range`, `Content-Length`, `Accept-Ranges: bytes`, `Content-Type: video/mp4`
  - [ ] Ensure endpoint is public or testable in Security config
- [ ] **Test streaming with HTML page**
  - [ ] Create simple `index.html` with `<video>` tag pointing to `/api/videos/1/stream`
  - [ ] Open in browser and verify video plays
  - [ ] Verify seeking works (check backend logs for range requests)

---

## Week 2 – Minimal Next.js Client + AWS Basics + First Deployment

### Week 2 setup

- [ ] **Create Next.js app (`vod-frontend`)**
  - [ ] From `~/programming/vod`, run `npx create-next-app@latest vod-frontend`
  - [ ] Choose App Router and TypeScript
  - [ ] Run `npm run dev` (or `pnpm dev`) and verify `http://localhost:3000`
- [ ] **Configure AWS CLI**
  - [ ] Install: `sudo apt install -y awscli`
  - [ ] Run `aws configure` with access key, secret, and default region

### Day 8–9: Minimal Next.js frontend

- [ ] **Home page**
  - [ ] Implement `/` page
  - [ ] Fetch `GET http://localhost:8080/api/videos`
  - [ ] Render list of videos (title + thumbnail)
- [ ] **Video detail page**
  - [ ] Implement `/video/[id]` route
  - [ ] Fetch `GET http://localhost:8080/api/videos/{id}`
  - [ ] Render title, description
  - [ ] Render `<video>` tag with `src` pointing to `/api/videos/{id}/stream`
- [ ] **Auth pages**
  - [ ] Implement `/register` page with form
  - [ ] Call `POST http://localhost:8080/api/auth/register`
  - [ ] Implement `/login` page with form
  - [ ] Call `POST http://localhost:8080/api/auth/login`
  - [ ] On success, store JWT (e.g. in localStorage) for now
- [ ] **My List page**
  - [ ] Implement `/my-list` page
  - [ ] Read JWT from client storage
  - [ ] Call `GET http://localhost:8080/api/watchlist` with `Authorization` header
  - [ ] Render list of watchlist videos

### Day 10–11: AWS account + RDS + S3

- [ ] **Create RDS PostgreSQL instance**
  - [ ] In AWS console, create RDS PostgreSQL
  - [ ] Set DB name, user, password (e.g. `voddb`, `voduser`, `vodpass`)
  - [ ] Configure security group to allow connections (from your IP and later from app)
  - [ ] Test connection from local machine with `psql` using RDS endpoint
- [ ] **Point backend to RDS**
  - [ ] Update `spring.datasource.url` to RDS endpoint
  - [ ] Update username/password to RDS credentials
  - [ ] Run app and verify schema/data on RDS
- [ ] **Create S3 bucket for media**
  - [ ] Create S3 bucket (e.g. `vod-videos-<yourname>`)
  - [ ] Upload at least one test video and thumbnail
  - [ ] Note object keys and URLs

### Day 12–14: Deploy backend

- [ ] **Dockerize Spring Boot app**
  - [ ] Create `Dockerfile` for backend
  - [ ] Build image: `docker build -t vod-backend:latest .`
  - [ ] Test locally: `docker run -p 8080:8080 --env-file .env vod-backend:latest`
- [ ] **Choose deployment target**
  - [ ] Decide: Elastic Beanstalk or EC2 + Docker
- [ ] **Deploy to AWS**
  - [ ] If Elastic Beanstalk:
    - [ ] Create EB application & environment
    - [ ] Deploy Docker app
    - [ ] Configure env vars (DB URL, user, password, JWT secret)
  - [ ] If EC2 + Docker:
    - [ ] Launch EC2 instance
    - [ ] Install Docker on EC2
    - [ ] Build/pull image and run with env vars
- [ ] **Configure security groups**
  - [ ] Allow inbound HTTP to app (80/8080)
  - [ ] Allow app SG to connect to RDS SG
- [ ] **Verify deployment**
  - [ ] Call `GET http://<backend-url>/api/videos` from local machine
  - [ ] Update Next.js to use deployed backend base URL

---

## Week 3 – Cloud-native Storage/Delivery + Better Architecture

### Day 15–17: S3 + CloudFront for video

- [ ] **Configure CloudFront distribution**
  - [ ] Create CloudFront distribution with S3 bucket as origin
  - [ ] Note CloudFront domain (e.g. `d123abc.cloudfront.net`)
- [ ] **Update `Video` model for S3/CloudFront**
  - [ ] Add field for S3 key or CloudFront URL (e.g. `videoUrl`)
  - [ ] Migrate existing test data to include URL/key
- [ ] **Choose access model**
  - [ ] Option A (public): use CloudFront URLs directly in `<video src="...">`
  - [ ] Option B (secure): generate pre-signed S3 URLs from backend
  - [ ] Implement endpoint for pre-signed URL if using secure model

### Day 18–19: Admin upload flow

- [ ] **Backend admin endpoints**
  - [ ] `POST /api/admin/videos/presign-upload` (returns pre-signed URL + key)
  - [ ] `POST /api/admin/videos` (stores title, description, key, etc.)
- [ ] **Optional Next.js admin page**
  - [ ] Create `/admin/upload` page
  - [ ] Request pre-signed upload URL from backend
  - [ ] Upload file to S3 via pre-signed URL
  - [ ] Submit metadata to backend to create `Video` record

### Day 20–21: Backend quality & robustness

- [ ] **Validation**
  - [ ] Add Bean Validation annotations to request DTOs (`@NotBlank`, `@Email`, etc.)
- [ ] **DTOs everywhere**
  - [ ] Ensure controllers expose DTOs, not JPA entities directly
- [ ] **Global exception handling**
  - [ ] Create `@ControllerAdvice` with exception handlers
  - [ ] Return consistent error response format
- [ ] **Logging & monitoring**
  - [ ] Configure structured logs
  - [ ] Ensure EB/EC2 logs appear in CloudWatch (platform integration or agent)

---

## Week 4 – Hardening, Auth, and “Product” Features

### Day 22–23: Auth & security improvements

- [ ] **Roles**
  - [ ] Add roles `ROLE_USER` and `ROLE_ADMIN`
  - [ ] Assign roles on registration or via admin tools
- [ ] **Method-level security**
  - [ ] Enable `@PreAuthorize`
  - [ ] Protect admin endpoints with role checks
- [ ] **Token improvements**
  - [ ] Configure shorter-lived access tokens
  - [ ] Optionally implement refresh token endpoints/flow
- [ ] **Basic rate limiting**
  - [ ] Implement simple in-memory rate limiting filter/interceptor
  - [ ] Optionally explore AWS API Gateway throttling

### Day 24–25: User features

- [ ] **Continue watching**
  - [ ] Create `ViewingProgress` entity (`userId`, `videoId`, `lastPosition`, `updatedAt`)
  - [ ] Implement `PUT /api/videos/{id}/progress` to update position
  - [ ] Implement `GET /api/videos/continue-watching` to list items with progress
- [ ] **My List improvements**
  - [ ] Add pagination to `GET /api/watchlist`
  - [ ] Add sorting (e.g. by `createdAt` or popularity)

### Day 26–27: Performance & observability

- [ ] **Caching**
  - [ ] Add Spring Cache (in-memory or Redis)
  - [ ] Cache `GET /api/videos` responses for short periods
- [ ] **Indexes**
  - [ ] Add DB indexes on frequently queried columns (`user_id`, `video_id`, etc.)
- [ ] **Metrics**
  - [ ] Add Micrometer integration
  - [ ] Export metrics to CloudWatch or Prometheus
  - [ ] Track request counts and latency per endpoint

### Day 28: Review & polish

- [ ] **Clean configuration & secrets**
  - [ ] Move secrets to AWS SSM Parameter Store or Secrets Manager
  - [ ] Ensure no secrets are committed to Git
- [ ] **Documentation**
  - [ ] Update README with architecture overview
  - [ ] Document local setup steps
  - [ ] Document AWS deployment steps
- [ ] **Demo script**
  - [ ] Write a short “demo flow” (register → login → browse → play → add to list → continue watching)
  - [ ] Do a full run-through to verify everything works end-to-end
