# MD to Files Parser - Practical Examples

## Example 1: Simple Python Script

### Request
```
Generate a simple Python command-line tool that converts temperature from Celsius to Fahrenheit.

Format for MD to Files Parser v5.1.3+
```

### Expected Response Format

```text
project/
├── temp_converter.py
├── requirements.txt
└── README.md
```

```python
# [file name]: temp_converter.py
#!/usr/bin/env python3
"""
Temperature converter utility.
Converts between Celsius and Fahrenheit.
"""

def celsius_to_fahrenheit(celsius: float) -> float:
    """Convert Celsius to Fahrenheit."""
    return (celsius * 9/5) + 32

def fahrenheit_to_celsius(fahrenheit: float) -> float:
    """Convert Fahrenheit to Celsius."""
    return (fahrenheit - 32) * 5/9

def main():
    """Main entry point."""
    print("Temperature Converter")
    print("-" * 40)
    
    choice = input("Convert (C)elsius to Fahrenheit or (F)ahrenheit to Celsius? [C/F]: ").upper()
    temp = float(input("Enter temperature: "))
    
    if choice == 'C':
        result = celsius_to_fahrenheit(temp)
        print(f"{temp}°C = {result:.2f}°F")
    elif choice == 'F':
        result = fahrenheit_to_celsius(temp)
        print(f"{temp}°F = {result:.2f}°C")
    else:
        print("Invalid choice")

if __name__ == "__main__":
    main()
```

```text
# [file name]: requirements.txt
# No external dependencies required for this project
```

```markdown
# [file name]: README.md
# Temperature Converter

Simple command-line tool for temperature conversion.

## Installation
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

## Usage
```bash
python3 temp_converter.py
```

Follow the prompts to convert temperatures.
```

### Processing
```bash
./MD_to_Files_v5.1.3.sh response.md ./temp_converter

# Result:
# ✓ Created: temp_converter/temp_converter.py
# ✓ Created: temp_converter/requirements.txt
# ✓ Created: temp_converter/README.md
```

---

## Example 2: Full-Stack Web Application

### Request
```
Create a simple TODO web application with Flask backend and HTML frontend.
Include user authentication and task management features.

Requirements:
- Backend: Flask with SQLite database
- Frontend: HTML/CSS with Bootstrap
- Features: Add/delete/complete tasks, user login

Format for MD to Files Parser v5.1.3+
```

### Expected Response Structure

```text
project/
├── backend/
│   ├── app.py
│   ├── models.py
│   ├── auth.py
│   ├── requirements.txt
│   └── config.py
├── frontend/
│   ├── index.html
│   ├── dashboard.html
│   └── static/
│       ├── style.css
│       └── script.js
├── docker-compose.yml
└── README.md
```

### Sample Files

```python
# [file name]: backend/app.py
from flask import Flask, render_template, request, jsonify
from models import db, User, Task
import auth

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///todo.db'
db.init_app(app)

@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    """Get all tasks for authenticated user."""
    token = request.headers.get('Authorization')
    user = auth.verify_token(token)
    tasks = Task.query.filter_by(user_id=user.id).all()
    return jsonify([t.to_dict() for t in tasks])

@app.route('/api/tasks', methods=['POST'])
def create_task():
    """Create new task."""
    data = request.json
    task = Task(title=data['title'], user_id=get_user_id())
    db.session.add(task)
    db.session.commit()
    return jsonify(task.to_dict()), 201

if __name__ == '__main__':
    app.run(debug=True)
```

```python
# [file name]: backend/models.py
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class User(db.Model):
    """User model."""
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    tasks = db.relationship('Task', backref='user', lazy=True)

class Task(db.Model):
    """Task model."""
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    completed = db.Column(db.Boolean, default=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        """Convert to dictionary."""
        return {
            'id': self.id,
            'title': self.title,
            'completed': self.completed,
            'created_at': self.created_at.isoformat()
        }
```

```html
<!-- [file name]: frontend/dashboard.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TODO Dashboard</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h1>My Tasks</h1>
        <div id="tasks" class="mt-4"></div>
        <input type="text" id="taskInput" placeholder="Add new task" class="form-control">
        <button onclick="addTask()" class="btn btn-primary mt-2">Add Task</button>
    </div>
    <script src="{{ url_for('static', filename='script.js') }}"></script>
</body>
</html>
```

```css
/* [file name]: frontend/static/style.css */
:root {
    --primary-color: #007bff;
    --secondary-color: #6c757d;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
    background-color: #f5f5f5;
}

.container {
    max-width: 800px;
    background: white;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.task-item {
    padding: 10px;
    margin: 5px 0;
    border-left: 4px solid var(--primary-color);
    background: #f9f9f9;
}

.task-item.completed {
    text-decoration: line-through;
    opacity: 0.6;
}
```

```yaml
# [file name]: docker-compose.yml
version: '3.8'

services:
  backend:
    build: ./backend
    ports:
      - "5000:5000"
    environment:
      - FLASK_ENV=development
    volumes:
      - ./backend:/app

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend
```

### Processing
```bash
./MD_to_Files_v5.1.3.sh -vbP response.md ./todo_app

# Result:
# ✓ Created: todo_app/backend/app.py
# ✓ Created: todo_app/backend/models.py
# ✓ Created: todo_app/frontend/dashboard.html
# ✓ Created: todo_app/frontend/static/style.css
# ✓ Created: todo_app/docker-compose.yml
# ✓ Created: todo_app/README.md
# ✓ Project metadata created
```

---

## Example 3: Node.js REST API

### Request
```
Generate a RESTful API using Express.js for a product catalog with:
- Product CRUD operations
- Authentication with JWT
- Error handling
- Request validation

Format for MD to Files Parser v5.1.3+
```

### Expected Structure

```text
project/
├── src/
│   ├── server.js
│   ├── routes/
│   │   └── products.js
│   ├── middleware/
│   │   ├── auth.js
│   │   └── validation.js
│   ├── models/
│   │   └── Product.js
│   └── config/
│       └── database.js
├── tests/
│   └── products.test.js
├── .env.example
├── package.json
├── README.md
└── .gitignore
```

### Sample Code

```javascript
// [file name]: src/server.js
const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const productRoutes = require('./routes/products');
const { errorHandler } = require('./middleware/auth');

dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/products', productRoutes);

// Error handling
app.use(errorHandler);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

module.exports = app;
```

```javascript
// [file name]: src/routes/products.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const validate = require('../middleware/validation');
const Product = require('../models/Product');

// Get all products
router.get('/', async (req, res) => {
    try {
        const products = await Product.find();
        res.json(products);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Create product
router.post('/', auth.verifyToken, validate.createProduct, async (req, res) => {
    try {
        const product = new Product(req.body);
        await product.save();
        res.status(201).json(product);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Update product
router.put('/:id', auth.verifyToken, async (req, res) => {
    try {
        const product = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.json(product);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Delete product
router.delete('/:id', auth.verifyToken, async (req, res) => {
    try {
        await Product.findByIdAndDelete(req.params.id);
        res.json({ message: 'Product deleted' });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

module.exports = router;
```

```json
// [file name]: package.json
{
  "name": "product-catalog-api",
  "version": "1.0.0",
  "description": "REST API for product catalog",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^7.0.0",
    "dotenv": "^16.0.3",
    "jsonwebtoken": "^9.0.0",
    "cors": "^2.8.5",
    "joi": "^17.9.1"
  },
  "devDependencies": {
    "nodemon": "^2.0.20",
    "jest": "^29.5.0"
  }
}
```

### Processing
```bash
./MD_to_Files_v5.1.3.sh -vbP response.md ./product_api

cd product_api
npm install
npm start
```

---

## Example 4: Multi-Language Microservices

### Request
```
Design a microservices architecture with:
- Python FastAPI backend service
- Node.js API gateway
- Docker Compose for orchestration
- Database migrations

Format for MD to Files Parser v5.1.3+
```

### Resulting Tree

```text
project/
├── services/
│   ├── api-gateway/
│   │   ├── src/
│   │   │   └── index.js
│   │   └── package.json
│   └── backend/
│       ├── app/
│       │   ├── main.py
│       │   └── models.py
│       └── requirements.txt
├── docker-compose.yml
├── .env.example
├── Makefile
└── README.md
```

---

## Example 5: Real-World Validation

### ✅ GOOD Response

```markdown
# Shopping Cart API

```text
project/
├── src/
│   ├── app.py
│   ├── models.py
│   └── routes.py
├── requirements.txt
└── README.md
```

```python
# [file name]: src/app.py
from flask import Flask
app = Flask(__name__)

if __name__ == '__main__':
    app.run()
```

```text
# [file name]: requirements.txt
Flask==2.0.0
```

```markdown
# [file name]: README.md
# Shopping Cart API

Setup:
pip install -r requirements.txt
```
```

**Why it works:**
- ✓ Tree in code block
- ✓ Each file marked correctly
- ✓ Language identifiers present
- ✓ Complete code with imports

### ❌ BAD Response

```markdown
Here's the shopping cart API:

project/
├── app.py
└── requirements.txt

```python
# Implementation
def create_app():
    pass

# requirements: Flask==2.0.0
```

**Why it fails:**
- ✗ Tree NOT in code block
- ✗ No [file name]: markers
- ✗ Incomplete code
- ✗ No language identifier on tree
- ✗ Code fragmented across response

---

## Workflow Comparison

### Manual Approach (Old)
```
1. Read LLM response (15 min)
2. Copy each code block (20 min)
3. Create directory structure (10 min)
4. Create files and paste code (30 min)
5. Fix errors and adjust paths (15 min)
TOTAL: ~90 minutes
Error rate: High
```

### Automated Approach (New)
```
1. Add prompt suffix (1 min)
2. Get formatted response (5 min)
3. Run MD to Files script (10 sec)
TOTAL: ~6 minutes
Error rate: Near zero
```

**Time saved: ~84 minutes per project!**

---

## Performance Metrics

| Metric | Manual | Automated |
|--------|--------|-----------|
| Time per project | 90+ min | ~6 min |
| Files per minute | 1-2 | 50-100 |
| Error rate | 5-15% | <1% |
| Reproducibility | No | Yes |
| Scalability | Limited | Unlimited |

---

## Testing Your Own Response

```bash
#!/bin/bash
response_file="$1"

echo "Testing response format..."

# 1. Check structure
[ -f "$response_file" ] || { echo "File not found"; exit 1; }

# 2. Check tree
grep -q "^project/" "$response_file" && \
    echo "✓ Tree found" || \
    echo "✗ Missing tree"

# 3. Check markers
markers=$(grep -c "\[file name\]:" "$response_file" || echo "0")
echo "✓ Found $markers file markers"

# 4. Try parse
./MD_to_Files_v5.1.3.sh -d "$response_file" /tmp/test_parse > /dev/null 2>&1
[ $? -eq 0 ] && echo "✓ Valid format" || echo "✗ Parse failed"

echo "Test complete"
```

---

*Version 1.0 | 2025-10-30 | Compatible with MD to Files v5.1.3+*

