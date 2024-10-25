# backend/main.py
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles

app = FastAPI()

# Serve static files
app.mount("/static", StaticFiles(directory="static"), name="static")

# Home route
@app.get("/", response_class=HTMLResponse)
async def read_root():
    with open("static/index.html", "r") as f:
        return f.read()

# Dynamic routes for different dashboard pages; all pages served from the `pages` directory
@app.get("/pages/{page_name}", response_class=HTMLResponse)
async def get_page(page_name: str):
    try:
        with open(f"static/pages/{page_name}.html", "r") as f:
            return f.read()
    except FileNotFoundError:
        return HTMLResponse(content="Page not found", status_code=404)