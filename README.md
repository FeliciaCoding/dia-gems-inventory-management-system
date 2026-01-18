# Diamond, Gemstone, Jewelry Inventory Management System

A Streamlit application for managing diamond and jewelry inventory with PostgreSQL database.

## Prerequisites
- Docker Desktop
- Git

## Quick Start

Clone and run:
```bash
git clone <your-repo-url>
cd project-p_wu_liao_makovskyi
docker compose up --build --watch
```

Access at: http://localhost:8501

## File Structure (the graph is generated with a help of ChatGPT)
```
project-p_wu_liao_makovskyi/
├── diagram/                         # ER diagrams and documentation
│   ├── er_schema.png
│   ├── er_schema.uxf
│   ├── er_to_relational.md
│   └── er_to_relational.pdf
├── queries/                         # Example queries and procedure calls
│   └── project-queries.sql
├── report/                          # Project reports and documentation
├── Slides/                          # Presentation materials
├── specs/                           # Requirements specifications
├── sql/diamonds/                    # Database schema and data
│   ├── 1-project-schema.sql
│   ├── 2-project-insert-dummy-data.sql
│   ├── 3-project-views.sql
│   ├── 4-project-triggers.sql
│   └── 5-project-procedure.sql
├── src/                             # Application source code
│   ├── diamonds_ui/                # Streamlit UI components
│   └── streamlit_utils/            # Utility functions
├── docker-compose.yml               # Container orchestration
├── Dockerfile                       # Application container
├── pyproject.toml                   # Python dependencies
└── README.md                        # Project overview
```

## Development Commands

Start application with live reload:
```bash
docker compose up --build --watch
```

Stop application:
```bash
docker compose down
```

Recreate database (removes all data):
```bash
docker compose down -v
docker compose up --build
```

Connect to database:
```bash
docker compose exec postgresql psql -U diamonds -d diamonds
```

View logs:
```bash
docker compose logs -f diamonds-ui
docker compose logs -f postgresql
```

## Local Development (without Docker)

Install dependencies:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
uv venv
uv sync
```

Start database only:
```bash
docker compose up postgresql
```

Configure connection:
```bash
cat > .streamlit/secrets.toml <<EOF
[connections.postgresql]
type = "db.StreamlitPsycopgConnection"
host = "localhost"
port = 5432
user = "diamonds"
password = "diamonds"
dbname = "diamonds"
EOF
```

Run application:
```bash
streamlit run src/diamonds_ui/app.py
```

## Tech Stack
- Frontend: Streamlit
- Database: PostgreSQL 18
- Python: 3.13
- Package Manager: uv
- Container: Docker

## Troubleshooting

Port 5432 conflict:
```bash
sudo service postgresql stop
```

Schema updates not applying:
```bash
docker compose down -v
docker compose up --build
```

