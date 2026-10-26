Here is the complete, chronologically organized step-by-step record of everything performed for the Day 10 assignment to include in your `README.md`:

---

### Step 1: Project Setup and Source Code Creation

Created a dedicated directory `day10-multistage` and defined the lightweight Go HTTP service:

* **Directory:** `mkdir -p day10-multistage && cd day10-multistage`


* **Module Definition (`go.mod`)**:


```text
module demo
go 1.22

```


* **Application Logic (`main.go`)**:
Configured two endpoints—root (`/`) responding with `"Hello from a multi-stage build!"` and health check (`/health`) returning `"ok"` on port 8080:


```go
package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "Hello from a multi-stage build!")
	})

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, "ok")
	})

	http.ListenAndServe(":8080", nil)
}

```



---

### Step 2: Defining the Single-Stage Build

Created **`Dockerfile.single`** which copies all source files and compiles inside the base Go SDK image:

```dockerfile
FROM golang:1.22
WORKDIR /src
COPY . .
RUN go build -o /app/server
EXPOSE 8080
CMD ["/app/server"]

```

Note: This intentionally bundles the compiler, build cache, and full toolchain into the runtime image.

---

### Step 3: Defining the Multi-Stage Build with Non-Root Security

Created **`Dockerfile`** utilizing a two-stage approach:

1. **Builder Stage:** Uses `golang:1.22-alpine` to compile a statically linked binary without debug overhead (`CGO_ENABLED=0`, `-ldflags="-s -w"`).


2. **Runtime Stage:** Employs minimal `alpine:3.20`, creates a non-root user/group (`app`), copies only the compiled binary with ownership flags (`--chown=app:app`), and switches the execution context using `USER app`.



```dockerfile
# Stage 1: Build static binary
FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY go.mod ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /out/server

# Stage 2: Minimal runtime image
FROM alpine:3.20
RUN addgroup -S app && adduser -S -G app app
WORKDIR /app
COPY --from=builder --chown=app:app /out/server /app/server
USER app
EXPOSE 8080
CMD ["/app/server"]

```

---

### Step 4: Building the Images & Measuring Sizes

Executed the build commands for both images:

```bash
docker build -f Dockerfile.single -t demo:single .
docker build -f Dockerfile -t demo:multi .

```

Inspected local image footprint via `docker images demo`:

* **`demo:single`:** Disk Usage: `1.31 GB` (~1,341.44 MB) | Content Size: `319 MB`
* **`demo:multi`:** Disk Usage: `19 MB` | Content Size: `5.73 MB`

#### Mathematical Size Reduction



$$\text{Disk Reduction (\%)} = \left(\frac{1341.44\text{ MB} - 19\text{ MB}}{1341.44\text{ MB}}\right) \times 100 = \mathbf{98.58\%}$$

$$\text{Content Size Reduction (\%)} = \left(\frac{319\text{ MB} - 5.73\text{ MB}}{319\text{ MB}}\right) \times 100 = \mathbf{98.20\%}$$

---

### Step 5: Container Execution & Health Verification

Started the multi-stage container mapping host port 8080 to container port 8080:

```bash
docker run -d --name demo -p 8080:8080 demo:multi

```

Validated both endpoints via curl:

```bash
curl http://localhost:8080/
# Output: Hello from a multi-stage build!

curl http://localhost:8080/health
# Output: ok

```

---

### Step 6: Security Verification (Least Privilege)

Inspected the running container process identity to confirm it was not operating as root (`uid=0`):

```bash
docker exec demo id
# Output: uid=100(app) gid=100(app) groups=100(app)

```

Validated: The container adheres to least privilege by running under unprivileged user `app`.

---

### Step 7: Verifying Stage Isolation & Builder Target

Confirmed independent build stage execution by compiling only up to the builder stage:

```bash
docker build --target builder -t demo:build -f Dockerfile .

```

Validated: Successfully produced an intermediary build target without compiling or running the Alpine runtime layer.

---

### Step 8: Container Cleanup

Removed the active testing container:

```bash
docker rm -f demo

```
