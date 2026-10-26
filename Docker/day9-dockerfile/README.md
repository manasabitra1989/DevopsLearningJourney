# Day 02 / Day 9: Dockerfile Deep Dive

Production-ready Docker packaging for a Node.js HTTP API demonstrating least-privilege runtime security, layer caching optimization, and entrypoint argument handling.

---

## 1. Dockerfile Instruction Breakdown

* **`FROM node:20-alpine`**: Selects a minimal, secure base image to reduce image size and attack surface.
* **`WORKDIR /app`**: Establishes the execution directory inside the container image.
* **`ARG APP_VERSION=1.0`**: Declares a build-time argument (not persisted in runtime).
* **`ENV PORT=3000 APP_ENV=dev APP_VERSION=$APP_VERSION`**: Sets default runtime environment variables.
* **`COPY package*.json ./`**: Copies only dependency manifests first to leverage Docker layer caching.
* **`RUN npm install --omit=dev`**: Installs production dependencies; cached unless package manifests change.
* **`COPY . .`**: Copies application code after dependency resolution.
* **`EXPOSE 3000`**: Documents port 3000 as the intended listener.
* **`USER node`**: Switches container process execution from root to unprivileged user `node`.
* **`CMD ["node", "server.js"]`**: Uses exec form to execute node directly without an intermediate shell.

---

## 2. Key Architectural Concepts

### CMD vs. ENTRYPOINT
* `ENTRYPOINT` defines the fixed executable process to run (`echo`).
* `CMD` supplies default arguments to that executable (`World`).
* Appending arguments at `docker run` replaces `CMD` while preserving `ENTRYPOINT`, allowing `docker run greeter:local DevOps` to produce `Hello DevOps`.

### COPY vs. ADD
* `COPY` is the standard for local-to-container copying.
* `ADD` supports automatic tar archive extraction and remote URLs, which adds unnecessary complexity for plain file transfers.

### ARG vs. ENV
* `ARG` is only accessible during image build time.
* `ENV` persists in the generated image and runtime container. Neither should ever store secrets.

---

## 3. Reflection Answers

1. **Which step was reused after changing only `server.js`?**
   * The `RUN npm install --omit=dev` step showed `CACHED` because `package*.json` was untouched.
2. **What happens if `package.json` changes?**
   * It invalidates the cache at `COPY package*.json ./`, requiring dependencies to reinstall.
3. **How does build-time vs. runtime configuration differ?**
   * Build-time (`ARG`) is baked into image compilation; runtime (`ENV`, `-e`) dynamically configures behavior per environment without rebuilding.
4. **What would you change before shipping to production?**
   * Pin the base image with a sha256 digest (`node:20-alpine@sha256:...`).
   * Introduce multi-stage builds.
   * Add a `HEALTHCHECK` directive.
   * Use `npm ci --omit=dev` with a committed `package-lock.json`.

---

## 4. Evidence of Completion

| Requirement | Screenshot Path |
| :--- | :--- |
| Healthcheck & Base Greeting | `evidence/health-check.png` |
| Runtime Environment Override | `evidence/env-override.png` |
| Build Layer Cache Hit (`CACHED`) | `evidence/cache-hit.png` |
| ENTRYPOINT vs CMD Experiment | `evidence/entrypoint-test.png` |
