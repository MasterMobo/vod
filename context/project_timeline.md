## Week 1 – Spring Boot API + Local Video Streaming

**Goal: Local backend that can serve JSON + video bytes.**

- **Day 1–2: Project setup & core models**
  - Create Spring Boot project (Java 17+, Spring Web, Spring Data JPA, Spring Security).
  - Set up PostgreSQL (Docker is fine).
  - Define entities: `User`, `Video`, `WatchlistItem`; create JPA repositories.
  - Implement simple REST:
    - `GET /api/videos` (list, with pagination).
    - `GET /api/videos/{id}` (details).

- **Day 3–4: Auth & watchlist**
  - Add Spring Security + JWT:
    - `POST /api/auth/register`, `POST /api/auth/login`.
    - Protect `/api/watchlist/**`, `/api/admin/**`; keep `/api/videos/**` public.
  - Implement:
    - `GET /api/watchlist` (current user).
    - `POST /api/watchlist/{videoId}`, `DELETE /api/watchlist/{videoId}`.

- **Day 5–7: Local video streaming**
  - Store video files locally (e.g. `videos/` folder), DB holds file path.
  - Implement `GET /api/videos/{id}/stream` in Spring:
    - Support `Range` header → return `206 Partial Content`.
    - Content type `video/mp4`.
  - Test with a basic HTML page or Postman + browser `<video>` tag.

---

## Week 2 – Minimal Next.js Client + AWS Basics + First Deployment

**Goal: Simple UI talking to your backend, then move backend to AWS.**

- **Day 8–9: Minimal Next.js frontend**
  - Create Next.js app (App Router, TypeScript).
  - Pages:
    - `/` – fetch `GET /api/videos` and render list.
    - `/video/[id]` – fetch details + `<video>` using backend stream URL.
    - `/login` & `/register` – call Spring auth endpoints.
  - For auth, start simple: store JWT in memory or localStorage; protect “My List” page client-side.

- **Day 10–11: AWS account + RDS + S3**
  - Create AWS account (if not already).
  - Create **RDS PostgreSQL** instance, migrate schema/data from local.
  - Create **S3 bucket** for storing video files and thumbnails.
  - Update backend:
    - Video metadata points to S3 object keys or pre-signed URLs (for now you can still stream from backend and have it read from S3).

- **Day 12–14: Deploy backend**
  - Package Spring Boot as Docker image.
  - Deploy options (pick one):
    - **Elastic Beanstalk** (simpler) – deploy the Dockerized Spring app, connect to RDS.
    - Or **EC2** instance with Docker Compose (manual but good learning).
  - Configure security groups, environment variables for DB credentials.
  - Verify: public URL for API works from your local machine and Next.js frontend.

---

## Week 3 – Cloud-native Storage/Delivery + Better Architecture

**Goal: Use AWS properly for media, refine backend design.**

- **Day 15–17: S3 + CloudFront for video**
  - Put raw video files in S3.
  - Configure **CloudFront** in front of S3.
  - Decide on approach:
    - Easiest: video `<source src="https://your-cloudfront/.../video.mp4" />` directly from CloudFront.
    - Or: generate **pre-signed S3 URLs** from Spring for authorized users; Next.js uses those URLs in `<video>`.
  - Update `Video` entity to store CloudFront URL or S3 key.

- **Day 18–19: Admin upload flow**
  - Backend:
    - `POST /api/admin/videos/presign-upload` → returns pre-signed S3 URL.
    - `POST /api/admin/videos` → save metadata (title, description, S3 key, etc.).
  - (Optional) Simple admin page in Next.js to:
    - Request pre-signed URL.
    - Upload file directly to S3 from browser.
    - Submit metadata to backend.

- **Day 20–21: Backend quality & robustness**
  - Add validation (Bean Validation annotations).
  - Add global exception handler.
  - Introduce DTOs instead of exposing entities directly.
  - Basic logging + error monitoring (at least Spring logs piped to CloudWatch).

---

## Week 4 – Hardening, Auth, and “Product” Features

**Goal: Make it feel like a real (small) product, and deepen backend/AWS skills.**

- **Day 22–23: Auth & security improvements**
  - Refine Spring Security:
    - Roles: `ROLE_USER`, `ROLE_ADMIN`.
    - Method-level security (`@PreAuthorize`) for admin endpoints.
  - Consider token refresh or shorter-lived access tokens.
  - Add simple rate limiting (e.g. filter + in-memory, or explore AWS API Gateway).

- **Day 24–25: User features**
  - “Continue watching”:
    - Table `ViewingProgress` (userId, videoId, lastPosition, updatedAt).
    - Endpoint `PUT /api/videos/{id}/progress`.
  - “My List” improvements:
    - Pagination/sorting, “featured” videos.

- **Day 26–27: Performance & observability**
  - Add caching for `GET /api/videos` (Spring Cache + Redis, or in-memory for now).
  - Add basic metrics:
    - Request counts, latency (Micrometer + CloudWatch).
  - Improve DB indexes (on `video_id`, `user_id`, etc.).

- **Day 28: Review & polish**
  - Cleanup config, environment variables, secrets handling (SSM Parameter Store or Secrets Manager).
  - Write README with architecture overview and deployment steps.
  - Make a short checklist/demo script (login → browse → play → add to list → continue watching).

---