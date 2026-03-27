# Workout Log (for AI analysis)

このファイルは、目標大会までの到達可能性をAIと検討するための「マルチスポーツ共通ログ」です。  
**スイム/ラン/バイク/筋トレを同一スキーマで蓄積**し、比較・時系列分析・種目横断分析ができる形にします。

## Source of truth

- 大会目標・レース戦略の正本は `12_NotebookLM_Sync/05_Athlete/10_Triathlon.md`
- このファイルは「日々/週次の実績ログ」と「課題に対する意思決定ログ」を集約する

## Session schema (append only)

```yaml
id: ""                       # 例: 2026-03-27-swim-2124
date: ""                     # YYYY-MM-DD
start_time: ""               # HH:MM
sport: ""                    # swim | run | bike | strength
discipline: ""               # pool_swim / road_run / indoor_bike / gym_strength など
session_name: ""

# Common metrics (種目横断で比較する軸)
duration:
  total: ""                  # HH:MM:SS or MM:SS
  moving: null
  elapsed: null
distance_m: null             # strengthはnullでOK
hr:
  avg_bpm: null
  max_bpm: null
  zones_time:
    z1: null
    z2: null
    z3: null
    z4: null
    z5: null
load:
  training_load: null
  training_effect:
    aerobic: null
    anaerobic: null
energy:
  calories_total: null
  calories_active: null
  calories_resting: null

# Objective context (主観ではなく事実)
environment: {}              # 例: { location: "pool", temperature_c: null }
equipment: []                # 使った道具
set_structure: []            # メニューを配列で
notes_objective: ""          # 事実のみ

# Sport-specific metrics
sport_specific:
  swim: {}                   # swim時のみ値を入れる
  run: {}                    # run時のみ値を入れる
  bike: {}                   # bike時のみ値を入れる
  strength: {}               # strength時のみ値を入れる
```

## Session log

### 2026-03-27 21:24 Swim / Pool

```yaml
id: "2026-03-27-swim-2124"
date: 2026-03-27
start_time: "21:24"
sport: swim
discipline: pool_swim
session_name: "プールスイム"

duration:
  total: "47:18"
  moving: "46:38"
  elapsed: "48:12"
distance_m: 2025
hr:
  avg_bpm: 137
  max_bpm: 153
  zones_time:
    z1: "5:37"
    z2: "28:39"
    z3: "12:47"
    z4: "0:00"
    z5: "0:00"
load:
  training_load: 50
  training_effect:
    aerobic: 2.7
    anaerobic: 0.0
energy:
  calories_total: 509
  calories_active: 437
  calories_resting: 72

environment: {}
equipment: []
set_structure: []
notes_objective: "2,025mのセッション。自己ベスト更新。"

sport_specific:
  swim:
    avg_pace_per_100m: "2:18"
    best_pace_per_100m: "0:55"
    avg_speed_kmh: 2.6
    max_speed_kmh: 6.5
    strokes:
      total: 959
      avg_per_lap: 11.8
      avg_spm: 21
    swolf_avg: 46
    pool_length_m: null
    stroke_style: null
  run: {}
  bike: {}
  strength: {}
```

## Weekly decision log (append only)

### Week 2026-03-23..2026-03-29

```yaml
week: "2026-03-23..2026-03-29"
linked_workout_ids:
  - "2026-03-27-swim-2124"

risk_register:
  - key: ows_panic
    status: high
    evidence: "OWS本番経験が浅く、最優先リスクとして継続管理"
    next_action:
      - "OWSでの呼吸・視認・集団接触を含む実地練習を段階導入"
      - "伊東OWS(6/28)を本番前検証レースとして活用"
  - key: bike_unknown
    status: medium_high
    evidence: "バイクの実測データ不足（目標ペースは暫定）"
    next_action:
      - "荒川試走データ取得後にOD/ミドル/IMのバイク目標を更新"
      - "90km相当のZ2走でHRドリフトと巡航維持性を確認"
  - key: heat_adaptation
    status: medium
    evidence: "暑熱期に向けた対策が必要"
    next_action:
      - "6月から暑熱順化プロトコルを開始"
      - "発汗量と補給量の実測をログ化"

discipline_issues:
  swim:
    - issue: "片側呼吸依存"
      action: "左右呼吸の比率を段階的に引き上げる"
    - issue: "ペース先行でフォーム崩れ"
      action: "序盤抑制でフォーム優先、後半ビルド"
    - issue: "ストローク効率"
      action: "ストローク数とSWOLFを継続モニタリング"
  run:
    - issue: "強度過多"
      action: "Z2主体へ再配分"
    - issue: "ピッチ不足"
      action: "目標ピッチへ段階移行（フォーム維持優先）"
    - issue: "上下動/接地効率"
      action: "真下接地と体幹安定をドリルで補強"
  bike:
    - issue: "基準値未確立"
      action: "実走データ取得まで心拍上限管理で運用"
  strength:
    - issue: "継続性"
      action: "S&C週2を固定運用（体幹・股関節優先）"

global_habits:
  sleep_target_h: 7
  nutrition:
    protein_g_per_kg: 2.0
```

## Sport-specific template (copy & fill)

```yaml
sport_specific:
  swim:
    avg_pace_per_100m: null
    best_pace_per_100m: null
    avg_speed_kmh: null
    max_speed_kmh: null
    strokes: { total: null, avg_per_lap: null, avg_spm: null }
    swolf_avg: null
    pool_length_m: null
    stroke_style: null
  run:
    avg_pace_per_km: null
    best_pace_per_km: null
    cadence_spm: null
    stride_length_m: null
    elevation_gain_m: null
    ground_contact_time_ms: null
  bike:
    avg_speed_kmh: null
    max_speed_kmh: null
    avg_power_w: null
    normalized_power_w: null
    ftp_w: null
    cadence_rpm: null
    elevation_gain_m: null
  strength:
    focus_area: []            # 例: ["lower", "core"]
    volume:
      sets: null
      reps: null
      total_weight_kg: null
    exercises: []             # 例: [{name: "Squat", sets: 5, reps: 5, weight_kg: 80}]
```
