import os
import sqlite3
from datetime import datetime, timedelta, timezone
from functools import wraps

from flask import Flask, request, jsonify, g
from flask_cors import CORS
import jwt
from werkzeug.security import generate_password_hash, check_password_hash

# ✅ 환경변수에서 읽고, 없으면 개발용 기본값 사용
SECRET_KEY = os.getenv("SECRET_KEY", "dev-secret-change-me")
JWT_SECRET = os.getenv("JWT_SECRET", "dev-jwt-change-me")

DB_PATH = os.path.join(os.path.dirname(__file__), 'grinmind.db')
TOKEN_EXPIRE_HOURS = 24 * 7

app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": "*"}})


def get_db():
  if 'db' not in g:
    g.db = sqlite3.connect(DB_PATH, detect_types=sqlite3.PARSE_DECLTYPES)
    g.db.row_factory = sqlite3.Row
  return g.db

@app.teardown_appcontext
def close_db(exc):
  db = g.pop('db', None)
  if db is not None:
    db.close()

def init_db():
  conn = sqlite3.connect(DB_PATH)
  c = conn.cursor()
  c.execute("""
  CREATE TABLE IF NOT EXISTS users(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )""")
  c.execute("""
  CREATE TABLE IF NOT EXISTS actions(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL
  )""")
  c.execute("""
  CREATE TABLE IF NOT EXISTS action_logs(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    action_id INTEGER NOT NULL,
    delta INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )""")
  defaults = [('텀블러 사용',), ('분리수거 철저',), ('대중교통 이용',),
              ('일회용품 줄이기',), ('에너지 절약',), ('채식 식사 선택',), ('재사용·수리하기',)]
  c.executemany("INSERT OR IGNORE INTO actions(name) VALUES(?)", defaults)
  conn.commit()
  conn.close()

init_db()

def create_token(user_id, email):
  payload = {
    'sub': user_id,
    'email': email,
    'exp': datetime.now(timezone.utc) + timedelta(hours=TOKEN_EXPIRE_HOURS)
  }
  return jwt.encode(payload, SECRET_KEY, algorithm='HS256')

def get_current_user_id():
  auth = request.headers.get('Authorization', '')
  if not auth.startswith('Bearer '):
    return None
  token = auth.split(' ', 1)[1]
  try:
    data = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
    return data.get('sub')
  except Exception:
    return None

def login_required(f):
  @wraps(f)
  def wrapper(*args, **kwargs):
    uid = get_current_user_id()
    if not uid:
      return jsonify({'error': 'unauthorized'}), 401
    g.user_id = uid
    return f(*args, **kwargs)
  return wrapper

KST = timezone(timedelta(hours=9))

def monday_00(dt):
  return (dt - timedelta(days=dt.weekday())).replace(hour=0, minute=0, second=0, microsecond=0)

def week_ranges_for_today(now=None):
  now = now.astimezone(KST) if now else datetime.now(KST)
  this_mon = monday_00(now)
  last_mon = this_mon - timedelta(days=7)
  last_sun_2359 = this_mon - timedelta(seconds=1)
  if now.weekday() == 0:
    lb_start, lb_end = last_mon, last_sun_2359
    period_label = 'last_week'
  else:
    lb_start, lb_end = this_mon, now
    period_label = 'this_week'
  me_start, me_end = this_mon, now
  return (lb_start, lb_end, period_label, me_start, me_end)

@app.post('/api/signup')
def signup():
  data = request.get_json() or {}
  email = (data.get('email') or '').strip().lower()
  password = data.get('password') or ''
  if not email or not password:
    return jsonify({'error':'email and password required'}), 400
  try:
    db = get_db()
    db.execute("INSERT INTO users(email, password_hash) VALUES(?,?)",
               (email, generate_password_hash(password)))
    db.commit()
    return jsonify({'ok': True})
  except sqlite3.IntegrityError:
    return jsonify({'error':'email exists'}), 409

@app.post('/api/login')
def login():
  data = request.get_json() or {}
  email = (data.get('email') or '').strip().lower()
  password = data.get('password') or ''
  db = get_db()
  row = db.execute("SELECT id, password_hash FROM users WHERE email=?", (email,)).fetchone()
  if not row or not check_password_hash(row['password_hash'], password):
    return jsonify({'error':'invalid credentials'}), 401
  token = create_token(row['id'], email)
  return jsonify({'token': token})

@app.get('/api/actions')
@login_required
def list_actions():
  _, _, _, me_start, me_end = week_ranges_for_today()
  db = get_db()
  rows = db.execute("""
    SELECT a.id, a.name,
           IFNULL(SUM(CASE WHEN l.created_at BETWEEN ? AND ? THEN l.delta END),0) AS count
    FROM actions a
    LEFT JOIN action_logs l ON l.action_id=a.id AND l.user_id=?
    GROUP BY a.id, a.name
    ORDER BY a.id ASC
  """, (me_start, me_end, g.user_id)).fetchall()
  items = [{'id': r['id'], 'name': r['name'], 'count': int(r['count'] or 0)} for r in rows]
  return jsonify({'items': items})

@app.post('/api/actions/<int:action_id>/add')
@login_required
def add_action(action_id):
  data = request.get_json() or {}
  delta = int(data.get('delta') or 0)
  if delta not in (-1, 1):
    return jsonify({'error':'delta must be -1 or 1'}), 400
  db = get_db()
  ex = db.execute("SELECT 1 FROM actions WHERE id=?", (action_id,)).fetchone()
  if not ex:
    return jsonify({'error':'action not found'}), 404
  db.execute(
    "INSERT INTO action_logs(user_id, action_id, delta, created_at) VALUES(?,?,?,CURRENT_TIMESTAMP)",
    (g.user_id, action_id, delta)
  )
  db.commit()
  return jsonify({'ok': True})

@app.get('/api/leaderboard')
@login_required
def leaderboard():
  lb_start, lb_end, period_label, me_start, me_end = week_ranges_for_today()
  db = get_db()
  rows = db.execute("""
    SELECT u.id AS user_id, u.email, IFNULL(SUM(l.delta),0) AS total
    FROM users u
    LEFT JOIN action_logs l
      ON l.user_id=u.id AND l.created_at BETWEEN ? AND ?
    GROUP BY u.id, u.email
    ORDER BY total DESC, u.id ASC
  """, (lb_start, lb_end)).fetchall()
  items = [{'email': r['email'], 'total': int(r['total'] or 0)} for r in rows]

  my_email = db.execute("SELECT email FROM users WHERE id=?", (g.user_id,)).fetchone()['email']
  my_rank = None
  for i, r in enumerate(items, start=1):
    if r['email'] == my_email:
      my_rank = i
      break

  r = db.execute("""
    SELECT IFNULL(SUM(delta),0) AS total
    FROM action_logs
    WHERE user_id=? AND created_at BETWEEN ? AND ?
  """, (g.user_id, me_start, me_end)).fetchone()
  my_total = int(r['total'] or 0)

  return jsonify({
    'period': period_label,
    'range': {'start': lb_start.isoformat(), 'end': lb_end.isoformat()},
    'items': items,
    'me': {'rank': my_rank, 'total': my_total}
  })

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=5000, debug=True)
