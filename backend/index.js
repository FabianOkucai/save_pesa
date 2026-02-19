const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();
const db = require('./database');

const app = express();
const PORT = process.env.PORT || 5000;
const JWT_SECRET = process.env.JWT_SECRET;

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Middleware to verify JWT
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) return res.status(401).json({ error: 'Access denied' });

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ error: 'Invalid token' });
        req.user = user;
        next();
    });
};

// --- Auth Routes ---

app.post('/api/register', async (req, res) => {
    const { phone, name, password } = req.body;
    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const query = `INSERT INTO users (phone, name, password) VALUES (?, ?, ?)`;
        db.run(query, [phone, name, hashedPassword], function (err) {
            if (err) {
                if (err.message.includes('UNIQUE constraint failed')) {
                    return res.status(400).json({ error: 'Phone number already registered' });
                }
                return res.status(500).json({ error: err.message });
            }
            res.status(201).json({ message: 'User registered successfully', userId: this.lastID });
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/login', (req, res) => {
    const { phone, password } = req.body;
    const query = `SELECT * FROM users WHERE phone = ?`;
    db.get(query, [phone], async (err, user) => {
        if (err) return res.status(500).json({ error: err.message });
        if (!user) return res.status(400).json({ error: 'User not found' });

        const validPassword = await bcrypt.compare(password, user.password);
        if (!validPassword) return res.status(400).json({ error: 'Invalid password' });

        const token = jwt.sign({ id: user.id, phone: user.phone, name: user.name }, JWT_SECRET, { expiresIn: '7d' });
        res.json({ token, user: { id: user.id, phone: user.phone, name: user.name } });
    });
});

// --- Transaction Routes ---

app.get('/api/transactions', authenticateToken, (req, res) => {
    const query = `SELECT * FROM transactions WHERE user_id = ? ORDER BY date DESC`;
    db.all(query, [req.user.id], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

app.post('/api/transactions/sync', authenticateToken, (req, res) => {
    const { transactions } = req.body;
    if (!Array.isArray(transactions)) return res.status(400).json({ error: 'Invalid data format' });

    const stmt = db.prepare(`REPLACE INTO transactions (id, user_id, title, amount, date, category, note, mpesa_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`);

    db.serialize(() => {
        transactions.forEach(tx => {
            stmt.run([tx.id, req.user.id, tx.title, tx.amount, tx.date, tx.category, tx.note, tx.mpesa_id]);
        });
        stmt.finalize((err) => {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ message: 'Sync successful' });
        });
    });
});

// --- Goal Routes ---

app.get('/api/goals', authenticateToken, (req, res) => {
    const query = `SELECT * FROM goals WHERE user_id = ?`;
    db.all(query, [req.user.id], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

app.post('/api/goals/sync', authenticateToken, (req, res) => {
    const { goals } = req.body;
    if (!Array.isArray(goals)) return res.status(400).json({ error: 'Invalid data format' });

    const stmt = db.prepare(`REPLACE INTO goals (id, user_id, name, target, saved, icon_code, color_hex, deadline) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`);

    db.serialize(() => {
        goals.forEach(goal => {
            stmt.run([goal.id, req.user.id, goal.name, goal.target, goal.saved, goal.icon_code, goal.color_hex, goal.deadline]);
        });
        stmt.finalize((err) => {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ message: 'Sync successful' });
        });
    });
});

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
