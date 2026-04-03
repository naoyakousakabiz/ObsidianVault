# Workout Log (for AI analysis)

このファイルは、目標大会までの到達可能性をAIと検討するための「マルチスポーツ共通ログ」です。  
**スイム/ラン/バイク/筋トレを同一スキーマで蓄積**し、比較・時系列分析・種目横断分析ができる形にします。

## Source of truth

- 大会目標・レース戦略の正本は `12_NotebookLM_Sync/05_Athlete/10_Triathlon.md`
- このファイルは「日々/週次の実績ログ」と「課題に対する意思決定ログ」を集約する

## Index

- [Quick view](#quick-view)
- [Weekly decision log](#weekly-decision-log-append-only)
- [Session log](#session-log)
  - [Swim](#swim)
  - [Run](#run)
  - [Bike](#bike)
  - [Strength](#strength)
- [Appendix](#appendix)

## Quick view

### 次回Run（最優先3つ）

- **強度**: Z2固定（目安 `HR <= 145`。`HR > 145` が2分続いたら即ペースダウン）
- **ピッチ**: `162-167 spm`（全編で上げ続けない。**5分ごとに30秒だけ**合わせる）
- **フォーム**: 「静かに着地」「足は真下」（上下動を小さく）

**やり方（迷ったらこれ）**

- **時計表示**: HR（心拍）＋Cadence（ピッチ）を同一画面
- **確認頻度**: 10分ごと＋「息が上がった瞬間」
- **ピッチ調整のコツ**: ピッチを上げる時は **ストライドを少し短く**（跳ねない/前に伸ばしすぎない）
- **ピッチを合わせる手段**:
  - **メトロノーム**: 165bpmで鳴らして足を合わせる（イヤホンが一番ラク）
  - **音声キュー/アラート**: 5分ごとに「ピッチ上げ」を時計アラートに設定（できる範囲でOK）
  - **代替**: 曲のBPMを165前後にして足を合わせる（音楽でも可）

### 次回Swim（最優先3つ）

- **Z2死守**：目標ペース **2:45〜3:00/100m**、**HRは140bpm以下**（盛れば即ダウン）。特に**前半400m**ははっきり抑えて後半のフォーム崩れを防ぐ
- **技術**：（**2026-04-04**：左呼吸は一旦オフ。利き側で可）**肺に溜め→最後のストロークで6〜7割吐く**／**グライド長め・滑る**／**腕はゆっくり大きく（肩に圧をかけない）**／**ハの字からまっすぐ入水〜30°意識**／**「ハチーっ」で待つ**／体は自然に傾ける
- **安全**：**真下〜腰付近だけ**しっかりかく。肩甲骨は**引く**イメージ。肩に違和感→力みを抜くか中断

**やり方（迷ったらこれ）**

- **目的**: 「効率は良いが速すぎる」状態から、アイアンマン向け **楽に長く泳ぐ** フェーズへ寄せる（目標・課題の正本は `10_Triathlon.md`）
- **ペース**: 本命は **2:45〜3:00/100m**。2:18慣れで「遅すぎて泳ぎにくい」なら、最初の本だけ **2:35〜2:45** から入り、HRが **`<= 140` に収まる範囲**で徐々に遅側へ寄せる
- **確認頻度**: 壁ターンのたび、または **100mごと** にペース＋（取れるなら）HR。前半400mだけ別メンタルで「cap合否」を見る
- **左右呼吸**: いきなり全編が辛ければ、**ウォームアップ〜最初の800mだけ** から定着させる。**04-04 は左なしで 2km**（他キュー優先）→ 左は別セッションで再開でよい

### 運用ルール（短縮版）

- 目標の正本: `12_NotebookLM_Sync/05_Athlete/10_Triathlon.md`
- 日々追記: `Session log` に追加（各セッションは `id` を必ず付与）
- 週次見直し: `Weekly decision log` は **3点だけ**（先週の結論 / 次週の打ち手3つ / 判定指標）

## Session log

### Swim

#### 2026-03-27 21:24 Pool

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

#### 2026-04-10 Swim（フォーム気づきログ・距離・時刻は未計測／要追記）

```yaml
id: "2026-04-10-swim-form-notes"
date: 2026-04-10
start_time: ""                    # Garmin 等と突き合わせて追記
sport: swim
discipline: pool_swim
session_name: "プール（フォーム意識メモ）"

duration: { total: "" }
distance_m: null
hr: { avg_bpm: null }
load: { training_load: null }

notes_objective: |
  【今回意識したこと（効いた感覚）】
  - 入水：ハの字くらいから入れてまっすぐ入れる
  - 呼吸：肺に空気を溜め、最後のストロークで6〜7割吐く
  - 腕：ゆっくり・できる限り大きく（肩に圧がかからない範囲）
  - グライド：長く、滑る感覚
  - 体：自然に傾ける（ロール）

  【次回意識（苦しくならない／効率寄り）】
  - 力の入れ方：真下〜腰あたりのストロークゾーンだけ
  - 肩甲骨：プッシュ〜リカバリー周りでグッと引くイメージ
  - 入水：約30°で滑り込ませる（ガイド §5 整合）
  - 待ち：「ハチーっ」＝何もしない時間を増やす（長距離リズム）

environment: {}
equipment: []
set_structure: []

sport_specific:
  swim:
    avg_pace_per_100m: null
    notes_form: "参考：25m 16ストローク前後が出る日あり（別セッション時の体感）"
  run: {}
  bike: {}
  strength: {}
```

### Run

#### 2026-03-21 15:53 Treadmill

```yaml
id: "2026-03-21-run-1553"
date: 2026-03-21
start_time: "15:53"
sport: run
discipline: treadmill_run
session_name: "トレッドミル"

duration:
  total: "1:59:28"
  moving: "1:58:47"
  elapsed: "2:03:42"
distance_m: 20030
hr:
  avg_bpm: 153
  max_bpm: 178
  zones_time:
    z1: "0:24"      # 103-122
    z2: "25:00"     # 123-143
    z3: "1:04:09"   # 144-163
    z4: "29:30"     # 164-184
    z5: "0:00"      # >184
load:
  training_load: 128
  training_effect:
    aerobic: 3.8
    anaerobic: 0.4
energy:
  calories_total: 1356
  calories_active: null
  calories_resting: null

environment: {}
equipment: []
set_structure: []
notes_objective: "トレッドミル設定8.0km/hで実施。Garmin推定は20.03km/5:58/km（トレッドミル表示と乖離の可能性あり）。ラン1:58:48、ウォーク0:32、休憩0:08。"

sport_specific:
  swim: {}
  run:
    avg_pace_per_km: "5:58"
    best_pace_per_km: "4:12"
    avg_speed_kmh: 10.1
    max_speed_kmh: 14.3
    treadmill_speed_setting_kmh: 8.0
    cadence_spm: 157
    stride_length_m: 1.08
    vertical_ratio_pct: 8.8
    vertical_osc_cm: 9.5
    ground_contact_time_ms: 291
    avg_power_w: 320
    max_power_w: 487
    power_zones_time:
      z1_260_315: "15:36"
      z2_316_355: "1:41:02"
      z3_356_394: "1:00"
      z4_395_451: "0:05"
      z5_ge451: "0:04"
  bike: {}
  strength: {}
```

### Bike

### Strength

## Weekly decision log (append only)

### Week 2026-03-17..2026-03-23

```yaml
week: "2026-03-17..2026-03-23"
linked_workout_ids:
  - "2026-03-21-run-1553"

run_next_session_focus:
  top_3_priorities:
    - "Z2固定（HR<=145）。超えたらすぐペースを落とす"
    - "ピッチ162-167spm（5分ごとに30秒だけ意識）"
    - "フォームは『静かに着地』『足は真下』"

  how_to_monitor:
    definitions:
      hr: "心拍数（bpm）"
      cadence: "ピッチ（spm）"
    watch_setup: "ラン中はHRとピッチを同一画面で表示"
    check_timing:
      - "10分ごとにチラ見（15分ごとは遅い）"
      - "息が上がった瞬間にも確認"
    correction_rules:
      - "HR>145が2分続いたら: 10-15秒/km落とす"
      - "ピッチ<160なら: 30秒だけ『小刻み』で戻す"
      - "跳ねる/接地が重いなら: ストライドを少し短くして真下着地"

  next_run_playbook:
    duration_min: 90
    plan:
      - "0-30分: かなり抑えめ（会話できる強度）"
      - "30-75分: 同じ呼吸・同じリズムを維持"
      - "75-90分: フォーム維持（崩さない）"
    success_criteria:
      - "Z2が70%以上"
      - "平均ピッチ162以上"
      - "接地時間が291msより改善（目安285ms未満）"
      - "後半30分で失速しない"
```

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

# Swim: next session focus (memo / history)
swim_next_session_focus:
  goal: "2kmを『余裕』で泳ぐ土台作り（イーブン・呼吸・肩負担低減・グライド）"
  worked_last_session:
    - "入水：ハの字→まっすぐ"
    - "呼吸：溜め→最後のストロークで6〜7割吐く"
    - "腕：ゆっくり大きく（肩に圧をかけない）"
    - "グライド長く・滑る"
    - "体を自然に傾ける"
  priorities:
    - "主に苦しくならない強度域で：真下〜腰だけ力を入れる"
    - "肩甲骨でプッシュ（グッと引く）"
    - "入水は約30°で滑り込む（30_Swim_Guide.md §5）"
    - "「ハチーっ」で何もしない時間を増やす（伸び優先）"
    - "3ストローク1呼吸（左右）— 別日に。04-04 は左オフで 2km（吐き・グライド・入水・ハチー優先）"
    - "前半400mを明確に抑える／キックは強くでなく止めない"
  checks:
    - "25mストローク数が後半で暴れていないか"
    - "3どり1が辛ければウォームアップ帯のみから"
    - "肩の違和感→即フォーム優先・ペース一段落とす"
  cue_words:
    - "溜めて、最後に吐く"
    - "滑る、ハチー"
    - "30°入水、肩甲骨を引く"
```

## Appendix

### Minimal session template（普段はこれでOK）

```yaml
id: ""               # YYYY-MM-DD-sport-HHMM（例: 2026-03-27-swim-2124）
date: ""             # YYYY-MM-DD
start_time: ""       # HH:MM
sport: ""            # swim | run | bike | strength
discipline: ""       # pool_swim / road_run / treadmill_run / indoor_bike / gym_strength など
session_name: ""

duration: { total: "" }
distance_m: null
hr: { avg_bpm: null }
load: { training_load: null }
notes_objective: ""
```

### Full session schema（必要なときだけ埋める）

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
environment: {}
equipment: []
set_structure: []
notes_objective: ""

# Sport-specific metrics
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
