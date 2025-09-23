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
  defaults = [('지역 농산물 시장을 이용하며, 현지 음식(로컬 푸드)을 먹는다',), ('유기농 식품을 구입한다',), ('식품의 라벨에서 환경에 해로운 성분을 확인하고 소비한다',), ('고도로 가공된 식품(소시지 등)의 소비를 피한다',), ('주변의 녹지를 찾는다',), ('올바른 재활용 방법에 대해 스스로 공부한다',), ('자연, 동물 및 환경 보호의 중요성에 대해 가족 및 친구와 함께 이야기한다',), ('친구 및 가족과 지속 가능한 행동 변화에 대한 아이디어를 공유한다',), ('생태 발자국을 최소화하기 위한 계획을 세워본다',), ('도움이 필요한 사람들에게 헌 옷이나 가정 용품을 기부한다',), ('에너지, 빈곤 및 기후 사이의 상호 작용을 공부한다',), ('플라스틱 용기 대신 샴푸 바, 비누 바를 구입한다',), ('집을 청소할 때 천연 세제를 사용한다',), ('플라스틱 칫솔을 대나무 칫솔로 바꾸고, 이를 닦는 동안 수도꼭지를 잠근다',), ('집에서 소비하는 에너지를 알아 둔다',), ('기후 변화가 경제에 영향을 미칠 것이라는 사실을 사람들에게 이야기한다',), ('공정무역 제품을 구매한다',), ('탄소 발자국이 낮은 회사의 제품을 구입한다',), ('가전 제품을 바꿀 때 기존의 제품은 기부한다',), ('현지에서 생산된 제품을 구매한다',), ('주변 사람들과 전기 제품을 공유한다',), ('환경 변화가 지역사회에 어떤 영향을 미치는지에 대해 논의한다',), ('새 제품 대신 중고품을 구입한다',), ('재사용 또는 재활용 재료로 만든 옷을 구입한다',), ('제로웨이스트 매장에서 음식을 구입한다',), ('유기농 면과 친환경 재료를 구입한다',), ('생태 관광에 참여한다',), ('냉장고와 에어컨을 올바르게 폐기하는 방법에 대해 알아본다',), ('기후에 대한 미신을 없애고, 사람들괴 사실과 허구를 구분하는 것이 중요함을 이야기한다',), ('지속 가능한 출처의 생선이나 해산물을 구입한다',), ('나무를 심는다',), ('벼룩시장을 조직하거나 참여한다',), ('정부가 재생 에너지 생산에 보조금을 지급 정책에 알아본다',), ('기업의 사회적 책임을 주장한다',), ('정부에 공원이나 숲과 같은 더 많은 녹지 공간을 확보하도록 요구한다',), ('지역사회에서 일회용 플라스틱 사용을 없애도록 노력한다',), ('재생지를 구입한다',), ('선거에서 환경과 기후변화 관련 공약을 제시하는 후보를 지지한다',), ('종이타월이나 핸드드라이어 대신 개인 손수건을 사용한다',)]
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

  # 월요일이 아닐 경우 리더보드를 반환하지 않습니다.
  if period_label != 'last_week':
    return jsonify({'error': 'Leaderboard is only available on Monday.'}), 404

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