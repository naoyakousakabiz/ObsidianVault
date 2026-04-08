# 面談通知自動化システム 設計書

**ファイル:** `50_AI自動化/40_施策実装/01_GAS_面談カレンダー_マネージャー招待とSlack通知.md`
**位置づけ:** **施策実装**（1ファイル＝1施策）。全体方針は `20_設計/Ringwell_CS_AI自動化設計.md`。業務整理・フレームは `10_業務整理/10_業務改善とAI導入_コンサル納品フレーム_RINGBELL用.md`。フォルダの意味は `02_フォルダ設計.md`。汎用テンプレ正本は `04_AI/02_AI導入コンサルテンプレートフォルダ/`。

**Google Apps Script / 作成日：2026年4月8日**

---

## 1. このシステムが解決すること

Googleカレンダーに「面談」予定が登録されたとき、これまでは手動で行っていた以下の2つの作業を完全に自動化します。

| やること | 自動化前 | 自動化後 |
|---------|---------|---------|
| マネージャーへの共有 | 毎回手動でゲスト追加 | 自動でゲスト追加 |
| 自分への通知 | カレンダーを都度確認 | Slack DMに自動通知 |

**漏れ・遅れ・二度手間をゼロにする**、それがこのシステムの目的です。

---

## 2. システム構成

```
Googleカレンダーに「面談」予定が登録される
        ↓
GAS が15分おきに自動実行
        ↓
        ├─ マネージャーをゲストに追加（カレンダー招待通知が届く）
        └─ 自分のSlack DMに通知が届く
```

### 基本設定値

| 項目 | 値 |
|------|----|
| 対象カレンダー | support_2@ringbell-marriage.com |
| 監視キーワード | 「面談」を含む予定タイトル |
| 監視範囲 | 実行時点から60日先まで |
| マネージャー | masumoto@ringbell-marriage.com |
| 通知先 | 担当者個人Slack DM |
| 実行間隔 | 15分おき |

---

## 3. 設計方針と意図

### 3-1. 設定の一元管理
変更が発生しやすいメールアドレス・キーワード・日数をすべて `CONFIG` オブジェクトに集約しています。将来的に担当者が変わったり、監視期間を変更したい場合でも、**CONFIGを変えるだけでよく、ロジックに一切触れる必要がない**設計です。

### 3-2. 二重実行の防止（LockService）
GASのトリガーは稀に複数が同時に走ることがあります。`LockService` でスクリプトロックを取得し、同一処理の並走を完全にブロックしています。

### 3-3. 重複通知の防止（冪等性）
「同じ面談に何度通知しても、Slackには1回しか届かない」という設計です。通知済みの記録を `PropertiesService` に保存し、次回実行時にチェックします。値にはタイムスタンプを使用することで、後述のクリーンアップも機能します。

### 3-4. 過去イベントの完全除外
APIの仕様上、取得結果に開始済みイベントが含まれる場合があります。`event.getStartTime() < now` の比較で明示的に除外し、**不要なゲスト追加や通知の誤発火を防止**しています。

### 3-5. ストレージ汚染の防止
通知済みフラグは蓄積し続けると `PropertiesService` の容量上限（500KB）に達します。`cleanupOldNotifyKeys()` を月1回実行し、90日以上経過したキーを自動削除します。

### 3-6. エラーの透明性
`catch` ブロックでログ出力後、意図的に再スローしています。これにより GAS の実行ログに「失敗」として記録され、**異常の見落としを防ぎます**。`finally` で確実にロックを解放する構造も合わせて担保しています。

---

## 4. 処理フロー

```
トリガー起動（15分おき）
  ↓
ロック取得（二重実行防止）
  ↓
カレンダーから today ～ +60日のイベントを取得
  ↓
各イベントをチェック：
  ① 開始時刻が過去 → スキップ
  ② タイトルに「面談」なし → スキップ
  ③ マネージャーが未追加 → addGuest()
  ④ Slack未通知 → notifySlack() → フラグ保存
  ↓
ロック解放
```

---

## 5. 関数一覧

| 関数名 | 役割 | 実行タイミング |
|-------|------|-------------|
| `addGuestsToNewEvents()` | メイン処理 | 15分おき（トリガー） |
| `notifySlack(title, startTime)` | Slack Webhook へ通知送信 | メイン処理内から呼び出し |
| `formatDate(date)` | 日付を日本時間でフォーマット | 通知文生成時 |
| `cleanupOldNotifyKeys()` | 古い通知フラグを削除 | 月1回（トリガー） |

---

## 6. ソースコード

```javascript
const CONFIG = {
  CALENDAR_ID: 'support_2@ringbell-marriage.com',
  MANAGER_EMAIL: 'masumoto@ringbell-marriage.com',   // ゲスト追加（通知あり）
  KEYWORD: '面談',
  MAIL_SUBJECT_PREFIX: '【面談予約】',               // Slack通知プレフィックス
  LOOKAHEAD_DAYS: 60,
  LOCK_TIMEOUT_MS: 20000,
  NOTIFY_RETENTION_DAYS: 90,                         // 通知キー保持期間（日）
  SLACK_WEBHOOK_URL: 'https://hooks.slack.com/services/XXX/YYY/ZZZ'
};

function addGuestsToNewEvents() {
  const lock = LockService.getScriptLock();
  if (!lock.tryLock(CONFIG.LOCK_TIMEOUT_MS)) return;

  try {
    const now = new Date();
    const future = new Date(
      now.getTime() + 1000 * 60 * 60 * 24 * CONFIG.LOOKAHEAD_DAYS
    );

    const calendar = CalendarApp.getCalendarById(CONFIG.CALENDAR_ID);
    const events = calendar.getEvents(now, future);
    const props = PropertiesService.getScriptProperties();

    events.forEach(event => {
      // 過去イベントの完全除外
      if (event.getStartTime() < now) return;

      const title = event.getTitle() || '';
      if (!title.includes(CONFIG.KEYWORD)) return;

      const guests = event.getGuestList().map(g => g.getEmail().toLowerCase());

      // マネージャー：ゲスト追加（通知あり）
      if (!guests.includes(CONFIG.MANAGER_EMAIL.toLowerCase())) {
        event.addGuest(CONFIG.MANAGER_EMAIL);
        console.log(`Manager added: ${title}`);
      }

      // 自分：Slack DM通知（重複防止）
      const notifyKey = `NOTIFIED_${event.getId()}`;
      if (!props.getProperty(notifyKey)) {
        notifySlack(title, event.getStartTime());
        props.setProperty(notifyKey, String(Date.now())); // タイムスタンプ保存
        console.log(`Slack notified: ${title}`);
      }
    });

  } catch (e) {
    console.error('Error:', e);
    // トリガーにエラーを伝播させ、GAS実行ログに失敗として記録するため再スロー
    throw e;
  } finally {
    lock.releaseLock();
  }
}

// Slack DM通知
function notifySlack(title, startTime) {
  const payload = {
    text: `${CONFIG.MAIL_SUBJECT_PREFIX}${title}\n日時：${formatDate(startTime)}\nカレンダー：${CONFIG.CALENDAR_ID}`
  };
  UrlFetchApp.fetch(CONFIG.SLACK_WEBHOOK_URL, {
    method: 'POST',
    contentType: 'application/json',
    payload: JSON.stringify(payload)
  });
}

// 日付フォーマット（日本時間）
function formatDate(date) {
  return Utilities.formatDate(date, 'Asia/Tokyo', 'yyyy/MM/dd HH:mm');
}

// 古い通知キーを削除（月1回トリガー推奨）
function cleanupOldNotifyKeys() {
  const props = PropertiesService.getScriptProperties();
  const all = props.getProperties();
  const cutoff = Date.now() - 1000 * 60 * 60 * 24 * CONFIG.NOTIFY_RETENTION_DAYS;

  Object.entries(all)
    .filter(([key]) => key.startsWith('NOTIFIED_'))
    .forEach(([key, value]) => {
      const timestamp = Number(value);
      // 旧形式（数値変換不可）も安全に削除対象とする
      if (!timestamp || timestamp < cutoff) {
        props.deleteProperty(key);
        console.log(`Cleaned up key: ${key}`);
      }
    });
}
```

---

## 7. トリガー設定

| 関数 | 種別 | 間隔 |
|-----|------|------|
| `addGuestsToNewEvents` | 時間主導型 | 15分おき |
| `cleanupOldNotifyKeys` | 時間主導型 | 月1回 |

---

## 8. 注意事項・既知のリスク

| リスク | 内容 | 対策 |
|-------|------|------|
| Webhook URLの漏洩 | URLが第三者に渡ると誰でも自分のDMに送信可能 | GitHubなどに公開しない。漏洩時はSlack側でURLを再生成 |
| マネージャーの再招待 | 招待辞退後にイベントが編集されると再追加される場合がある | 現状は許容範囲。問題があればゲストの承認状態チェックを追加 |
| タイトル後付け変更 | 「面談」を後からタイトルに追加した場合も通知対象になる | 仕様として許容。意図しない場合は手動でフラグを削除 |

---

## 9. 今後の拡張・横展開の可能性

本設計は拡張性を意識しており、以下のような発展が低コストで実現できます。

**通知内容の強化**
Slack の Block Kit を使えば、ボタン付きのリッチな通知（例：「カレンダーを開く」リンク付き）に変更可能です。`notifySlack()` 関数のみ改修すればよく、他に影響しません。

**複数キーワードへの対応**
`KEYWORD` を文字列から配列に変更し、`keywords.some(kw => title.includes(kw))` とするだけで「面談・商談・打合せ」など複数条件に対応できます。

**複数カレンダーへの横展開**
`CALENDAR_ID` を配列化し、ループ処理にすることで複数カレンダーを一つのスクリプトで監視できます。

**通知チャンネルの切り替え**
`notifySlack()` のインターフェースを維持したまま中身をメール・Teams・LINE通知などに差し替えることが可能です。CONFIGの `SLACK_WEBHOOK_URL` を変えるだけで通知先チャンネルの変更もできます。

**実行ログの永続化**
現状は `console.log` のみですが、Googleスプレッドシートへの書き込みを追加することで、誰にいつ通知が飛んだかを台帳として記録できます。

---

*本設計書は実装と同時に作成されたものです。コードと設計書の内容は常に一致した状態で管理してください。*