To create the `app.py` file directly inside your `app` directory on your Linux/WSL terminal, choose whichever method you find easiest:

---

### Option 1: Use `cat` (Easiest & Fastest — Prevents Indentation Errors)

Run this entire block directly in your terminal. It will overwrite `app.py` with properly indented code:

```bash
cat << 'EOF' > app.py
import os
import time
import redis
import psycopg2
from flask import Flask

app = Flask(__name__)

def get_redis():
    return redis.Redis(
        host=os.getenv("REDIS_HOST", "redis"),
        port=6379,
        decode_responses=True
    )

def get_db():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "db"),
        dbname=os.environ["POSTGRES_DB"],
        user=os.environ["POSTGRES_USER"],
        password=os.environ["POSTGRES_PASSWORD"],
        connect_timeout=3
    )

@app.route("/")
def index():
    hits = get_redis().incr("hits")
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "CREATE TABLE IF NOT EXISTS visits ("
                "id serial PRIMARY KEY, ts timestamptz DEFAULT now())"
            )
            cur.execute("INSERT INTO visits DEFAULT VALUES")
            cur.execute("SELECT count(*) FROM visits")
            total = cur.fetchone()[0]
    return f"Redis hits: {hits} | Postgres visits: {total}\n"

@app.route("/health")
def health():
    return "ok\n"

if __name__ == "__main__":
    for attempt in range(20):
        try:
            with get_db() as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT 1")
                    break
        except Exception:
            if attempt == 19:
                raise
            time.sleep(2)
    app.run(host="0.0.0.0", port=5000)
EOF

```

---

### Option 2: Using `nano` (Beginner-Friendly Editor)

1. Open the file in `nano`:
```bash
nano app.py

```


2. Paste the Python code into the editor.


3. Press **`Ctrl + O`**, then **`Enter`** to save.
4. Press **`Ctrl + X`** to exit.

---

### Option 3: Using `vi` / `vim` with Paste Mode

If you prefer `vi`, enable `paste` mode first so it doesn't strip or scramble the indentation:

1. Open the file:
```bash
vi app.py

```


2. Clear any existing broken content by pressing `Esc`, typing `:%d`, and pressing `Enter`.
3. Type `:set paste` and hit `Enter` (this ensures clean indentation when pasting).
4. Press `i` to enter Insert mode.
5. Paste the code into your terminal.


6. Press `Esc`, then type `:wq` and press `Enter` to save and exit.

---

### Verify It

Confirm the indentation looks correct by displaying the file with line numbers:

```bash
nl -ba app.py

```
