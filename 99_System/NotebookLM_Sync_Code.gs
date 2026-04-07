/*
 * NotebookLM 用 Google Apps Script（全文コピペ用正本）
 *
 * ■ 貼り付け先: ブラウザで script.google.com → 対象プロジェクト → 左の「コード.gs」
 *   このファイルの先頭から末尾まで全部コピーして コード.gs を置き換え → 保存。
 *   （Cursor の Vault にある .gs だけ直しても Google 側は変わりません。必ず Apps Script 上で保存。）
 *
 * ■ 設定は「下の var CONFIG」の中だけ。フォルダ ID はどれも
 *   Drive でそのフォルダを開いた URL の …/folders/XXXXXXXX の XXXXXXXX 部分（長い英数字1本）。
 *
 * 実行: convertMdToGoogleDocs（全体同期） / debugNotebookLmDriveConfig（IDが開けるか確認）
 * 詳細: 99_System/01_NotebookLM_GAS_同期スクリプト.md
 */

// =====================================================================
// 【ここだけ自分用に書き換える】場所: この「var CONFIG = { … };」ブロック全体が Apps Script のコード.gs にある同じ形
// =====================================================================
var CONFIG = {
  // --- 「元」= .md を読むフォルダ（Vault 内の NotebookLM 用 MD があるフォルダ）-----------
  // ・おすすめ: SYNC_FOLDER_ID にだけ、下記の取り方で ID を貼る（1行できれば他は空でも動く）
  //   手順: Drive で「12_NotebookLM_SYNC」フォルダを開く → アドレスバーが
  //   https://drive.google.com/drive/folders/ここがID?usp=sharing の「ここがID」をコピー → 下の '' の中に貼る
  SYNC_FOLDER_ID: '',

  // ・上を空 '' のままにする場合の「親ルート」方式（上級）: 親とフォルダ名の両方が必須
  SOURCE_PARENT_FOLDER_ID: 'YOUR_VAULT_PARENT_FOLDER_ID',
  // ↑ 「Obsidian Vault」など、12_NotebookLM_SYNC のひとつ上のフォルダを開いたときの /folders/ の ID
  SYNC_FOLDER_NAME: '12_NotebookLM_SYNC',
  // ↑ Google Drive に表示されているフォルダ名と一字一句同じ（大半はこの表記）

  // --- 「先」= 書き出す Google ドキュメントを置くフォルダ（NotebookLM が読む側）-----------
  // 手順: 出力用のフォルダを Drive で開き、同じく URL の /folders/ の ID だけを貼る
  OUTPUT_ROOT_FOLDER_ID: 'YOUR_NOTEBOOKLM_OUTPUT_ROOT_FOLDER_ID',

  // --- 以下は触らなくてよい ---
  PROP_KEY_PREFIX: 'nlmdoc:',
  MAX_OPEN_RETRIES: 4,
  BASE_SLEEP_MS: 250,
  BETWEEN_FILES_MS: 150,
};

// --- 同期エントリ ---

function convertMdToGoogleDocs() {
  runWithLock_(function () {
    runConvert_(null);
  });
}

function convertMdToGoogleDocsBatch(relativePathFromSyncRoot) {
  runWithLock_(function () {
    runConvert_(relativePathFromSyncRoot);
  });
}

// --- 掃除: チェックのみ ---

function notebookLmOutputDedupeCheck() {
  dedupeOutputTree_(true, null);
}

function notebookLmOutputDedupeCheckBatch(relativePathFromOutputRoot) {
  dedupeOutputTree_(true, relativePathFromOutputRoot);
}

// --- 掃除: 実行 ---

function notebookLmOutputDedupeRun() {
  runWithLock_(function () {
    dedupeOutputTree_(false, null);
  });
}

function notebookLmOutputDedupeRunBatch(relativePathFromOutputRoot) {
  runWithLock_(function () {
    dedupeOutputTree_(false, relativePathFromOutputRoot);
  });
}

// --- 共通ロック ---

function runWithLock_(fn) {
  var lock = LockService.getScriptLock();
  if (!lock.tryLock(30000)) {
    Logger.log('❌ 別実行中のためスキップ（ロック取得タイムアウト）');
    return;
  }
  try {
    fn();
    Logger.log('✅ 完了');
  } finally {
    lock.releaseLock();
  }
}

// --- 同期本体 ---

/**
 * CONFIG がプレースホルダのままなら false と分かりやすいログを出す
 * （Cursor の .gs を直しただけでは Google 上の GAS は変わらない）
 */
function assertDriveConfigReady_() {
  var syncId = String(CONFIG.SYNC_FOLDER_ID || '').trim();
  var parentId = String(CONFIG.SOURCE_PARENT_FOLDER_ID || '').trim();
  var outId = String(CONFIG.OUTPUT_ROOT_FOLDER_ID || '').trim();

  if (!syncId && (!parentId || parentId.indexOf('YOUR_') === 0)) {
    Logger.log(
      '❌ CONFIG 未設定: Google Apps Script のエディタで「このプロジェクトのコード.gs」を開き、CONFIG を書き換えて保存してください。\n' +
        '  【簡単】SYNC_FOLDER_ID に、12_NotebookLM_SYNC フォルダをブラウザで開いたときの URL の …/folders/ の後ろの ID だけ貼る（SOURCE_PARENT は未使用になります）。\n' +
        '  【代替】SYNC_FOLDER_ID を空のままにするなら、SOURCE_PARENT_FOLDER_ID に Vault フォルダ（その中に 12_NotebookLM_SYNC があるフォルダ）の ID を貼る。'
    );
    return false;
  }
  if (!outId || outId.indexOf('YOUR_') === 0) {
    Logger.log(
      '❌ OUTPUT_ROOT_FOLDER_ID がプレースホルダのままです。NotebookLM 用 Doc を置くフォルダの /folders/ ID を CONFIG に貼ってください。'
    );
    return false;
  }
  return true;
}

function runConvert_(relativePathFromSyncRoot) {
  if (!assertDriveConfigReady_()) {
    return;
  }

  var props = PropertiesService.getScriptProperties();
  var syncFolder = getSyncFolder_();
  if (!syncFolder) {
    return;
  }

  var outputRoot;
  try {
    outputRoot = getFolderByIdOrThrow_(CONFIG.OUTPUT_ROOT_FOLDER_ID, 'OUTPUT_ROOT_FOLDER_ID');
  } catch (eOut) {
    Logger.log('❌ 出力ルート取得失敗: ' + eOut);
    return;
  }

  var start = resolveMirroredStart_(syncFolder, outputRoot, relativePathFromSyncRoot);
  if (!start) {
    return;
  }

  processFolder_(start.source, start.output, props);
}

/**
 * 手動実行用: 入力・出力フォルダIDが開けるかログに出す
 */
function debugNotebookLmDriveConfig() {
  var directId = String(CONFIG.SYNC_FOLDER_ID || '').trim();
  if (directId) {
    try {
      var sf = getFolderByIdOrThrow_(directId, 'SYNC_FOLDER_ID');
      Logger.log('OK SYNC_FOLDER_ID → ' + sf.getName() + ' (' + sf.getId() + ')');
    } catch (e1) {
      Logger.log('NG SYNC_FOLDER_ID: ' + e1);
    }
  } else {
    try {
      var par = getFolderByIdOrThrow_(CONFIG.SOURCE_PARENT_FOLDER_ID, 'SOURCE_PARENT_FOLDER_ID');
      Logger.log('OK SOURCE_PARENT_FOLDER_ID → ' + par.getName() + ' (' + par.getId() + ')');
    } catch (e2) {
      Logger.log('NG SOURCE_PARENT_FOLDER_ID: ' + e2);
    }
  }
  try {
    var out = getFolderByIdOrThrow_(CONFIG.OUTPUT_ROOT_FOLDER_ID, 'OUTPUT_ROOT_FOLDER_ID');
    Logger.log('OK OUTPUT_ROOT_FOLDER_ID → ' + out.getName() + ' (' + out.getId() + ')');
  } catch (e3) {
    Logger.log('NG OUTPUT_ROOT_FOLDER_ID: ' + e3);
  }
}

/**
 * @param {string} id
 * @param {string} label CONFIG キー名（ログ用）
 * @return {Folder}
 */
function getFolderByIdOrThrow_(id, label) {
  var raw = String(id || '').trim();
  if (!raw || raw.indexOf('YOUR_') === 0) {
    throw new Error(label + ' が未設定です（プレースホルダのまま）');
  }
  return DriveApp.getFolderById(raw);
}

function getSyncFolder_() {
  var directId = String(CONFIG.SYNC_FOLDER_ID || '').trim();
  if (directId) {
    try {
      return getFolderByIdOrThrow_(directId, 'SYNC_FOLDER_ID');
    } catch (e) {
      Logger.log('❌ SYNC_FOLDER_ID で開けません: ' + e);
      return null;
    }
  }

  try {
    var parent = getFolderByIdOrThrow_(CONFIG.SOURCE_PARENT_FOLDER_ID, 'SOURCE_PARENT_FOLDER_ID');
  } catch (e2) {
    Logger.log(
      '❌ SOURCE_PARENT_FOLDER_ID で親フォルダを開けません: ' +
        e2 +
        ' … URLは /folders/ のIDか、実行アカウントに編集権があるか確認。SYNC_FOLDER_ID 直指定も可。'
    );
    return null;
  }

  var it = parent.getFoldersByName(CONFIG.SYNC_FOLDER_NAME);
  if (!it.hasNext()) {
    Logger.log('❌ Syncフォルダなし: ' + CONFIG.SYNC_FOLDER_NAME + '（親内のフォルダ名を確認）');
    return null;
  }
  return it.next();
}

/**
 * @return {{source:Folder,output:Folder}|null}
 */
function resolveMirroredStart_(syncFolder, outputRoot, rel) {
  var path = rel && String(rel).trim();
  if (!path) {
    return { source: syncFolder, output: outputRoot };
  }
  var parts = path.split('/').map(function (s) {
    return s.trim();
  }).filter(Boolean);
  var srcCur = syncFolder;
  var outCur = outputRoot;
  var i;
  for (i = 0; i < parts.length; i++) {
    var it = srcCur.getFoldersByName(parts[i]);
    if (!it.hasNext()) {
      Logger.log('❌ バッチ対象フォルダなし（入力側）: ' + parts.slice(0, i + 1).join('/'));
      return null;
    }
    srcCur = it.next();
    outCur = getOrCreateFolder_(outCur, parts[i]);
  }
  return { source: srcCur, output: outCur };
}

/**
 * @return {Folder|null}
 */
function resolveOutputOnlyStart_(outputRoot, rel) {
  var path = rel && String(rel).trim();
  if (!path) {
    return outputRoot;
  }
  var parts = path.split('/').map(function (s) {
    return s.trim();
  }).filter(Boolean);
  var cur = outputRoot;
  var i;
  for (i = 0; i < parts.length; i++) {
    var it = cur.getFoldersByName(parts[i]);
    if (!it.hasNext()) {
      Logger.log('❌ 掃除バッチのフォルダなし（出力側）: ' + parts.slice(0, i + 1).join('/'));
      return null;
    }
    cur = it.next();
  }
  return cur;
}

function processFolder_(sourceFolder, outputFolder, props) {
  var files = sourceFolder.getFiles();
  while (files.hasNext()) {
    var file = files.next();
    var name = file.getName();
    if (!/\.md$/i.test(name)) {
      continue;
    }

    var mdId = file.getId();
    var docName = name.replace(/\.md$/i, '');
    var content = file.getBlob().getDataAsString('UTF-8');

    syncOne_(mdId, docName, content, outputFolder, props);
    Utilities.sleep(CONFIG.BETWEEN_FILES_MS);
  }

  var subFolders = sourceFolder.getFolders();
  while (subFolders.hasNext()) {
    var sub = subFolders.next();
    var outSub = getOrCreateFolder_(outputFolder, sub.getName());
    processFolder_(sub, outSub, props);
  }
}

function propKeyForMd_(mdId) {
  return CONFIG.PROP_KEY_PREFIX + mdId;
}

function syncOne_(mdId, docName, mdText, outputFolder, props) {
  var key = propKeyForMd_(mdId);
  var preferredId = props.getProperty(key);

  var canonical = enforceSingleCanonicalDoc_(outputFolder, docName, preferredId);
  if (canonical) {
    props.setProperty(key, canonical.getId());
  } else {
    props.deleteProperty(key);
  }

  if (!canonical) {
    var newId = createDocWithContent_(docName, mdText, outputFolder);
    props.setProperty(key, newId);
    enforceSingleCanonicalDoc_(outputFolder, docName, newId);
    Logger.log('🆕 作成: ' + docName);
    return;
  }

  var result = updateDocWithRetry_(canonical, docName, mdText);
  if (result === 'unchanged') {
    Logger.log('⏩ 変更なし: ' + docName);
    return;
  }
  if (result === 'updated') {
    props.setProperty(key, canonical.getId());
    enforceSingleCanonicalDoc_(outputFolder, docName, canonical.getId());
    Logger.log('🔄 更新: ' + docName);
    return;
  }
  if (result && result.recreate) {
    Logger.log('♻️ 再作成: ' + docName + ' （理由: ' + result.reason + '）');
    try {
      canonical.setTrashed(true);
    } catch (e1) {
      Logger.log('⚠️ 旧Docゴミ箱失敗: ' + e1);
    }
    var id2 = createDocWithContent_(docName, mdText, outputFolder);
    props.setProperty(key, id2);
    enforceSingleCanonicalDoc_(outputFolder, docName, id2);
    Logger.log('🆕 作成(差替): ' + docName);
  }
}

function fileIsDirectChild_(file, folder) {
  var parents = file.getParents();
  while (parents.hasNext()) {
    if (parents.next().getId() === folder.getId()) {
      return true;
    }
  }
  return false;
}

function listNativeDocsByName_(folder, docName) {
  var out = [];
  var allInFolder = listAllNativeDocsInFolder_(folder);
  var i;
  for (i = 0; i < allInFolder.length; i++) {
    if (resolveDuplicateFileName_(allInFolder[i]) === docName) {
      out.push(allInFolder[i]);
    }
  }
  return out;
}

function listAllNativeDocsInFolder_(folder) {
  var out = [];
  var it = folder.getFiles();
  while (it.hasNext()) {
    var f = it.next();
    if (f.isTrashed()) {
      continue;
    }
    if (f.getMimeType() !== MimeType.GOOGLE_DOCS) {
      continue;
    }
    if (!fileIsDirectChild_(f, folder)) {
      continue;
    }
    out.push(f);
  }
  return out;
}

function resolveDuplicateFileName_(file) {
  return file.getName();
}

function enforceSingleCanonicalDoc_(folder, docName, preferredId) {
  var all = listNativeDocsByName_(folder, docName);
  var canonical = null;
  var i;

  if (preferredId) {
    for (i = 0; i < all.length; i++) {
      if (all[i].getId() === preferredId) {
        canonical = all[i];
        break;
      }
    }
  }

  if (!canonical && all.length > 0) {
    sortFilesByLastUpdatedDesc_(all);
    canonical = all[0];
  }

  for (i = 0; i < all.length; i++) {
    if (canonical && all[i].getId() === canonical.getId()) {
      continue;
    }
    try {
      all[i].setTrashed(true);
    } catch (e) {
      Logger.log('dedupe trash fail: ' + all[i].getId() + ' ' + e);
    }
  }

  return canonical || null;
}

function sortFilesByLastUpdatedDesc_(files) {
  files.sort(function (a, b) {
    return b.getLastUpdated().getTime() - a.getLastUpdated().getTime();
  });
}

// --- 出力ツリー掃除 ---

function dedupeOutputTree_(dryRun, relativePathFromOutputRoot) {
  var outputRoot;
  try {
    outputRoot = getFolderByIdOrThrow_(CONFIG.OUTPUT_ROOT_FOLDER_ID, 'OUTPUT_ROOT_FOLDER_ID');
  } catch (e) {
    Logger.log('❌ 出力ルート取得失敗(dedupe): ' + e);
    return;
  }
  var start = resolveOutputOnlyStart_(outputRoot, relativePathFromOutputRoot);
  if (!start) {
    return;
  }

  var stats = {
    dryRun: dryRun,
    scannedFolders: 0,
    duplicateGroups: 0,
    filesRemovedOrWouldRemove: 0,
    filesKeptPerGroup: 0,
  };

  walkDedupeOutput_(start, dryRun, stats);
  Logger.log('dedupe summary: ' + JSON.stringify(stats));
}

function walkDedupeOutput_(folder, dryRun, stats) {
  stats.scannedFolders++;
  dedupeOneOutputFolder_(folder, dryRun, stats);

  var subs = folder.getFolders();
  while (subs.hasNext()) {
    walkDedupeOutput_(subs.next(), dryRun, stats);
  }
}

function dedupeOneOutputFolder_(folder, dryRun, stats) {
  var map = {};
  var files = listAllNativeDocsInFolder_(folder);
  var i;
  for (i = 0; i < files.length; i++) {
    var n = resolveDuplicateFileName_(files[i]);
    if (!map[n]) {
      map[n] = [];
    }
    map[n].push(files[i]);
  }

  var name;
  for (name in map) {
    if (!Object.prototype.hasOwnProperty.call(map, name)) {
      continue;
    }
    var arr = map[name];
    if (arr.length < 2) {
      continue;
    }

    sortFilesByLastUpdatedDesc_(arr);
    var keep = arr[0];
    var remove = arr.slice(1);
    stats.duplicateGroups++;
    stats.filesKeptPerGroup += 1;
    stats.filesRemovedOrWouldRemove += remove.length;

    var removeIds = remove.map(function (f) {
      return f.getId();
    });
    var mode = dryRun ? '[DRY] ' : '';
    Logger.log(
      mode +
        '同名 Doc: ' +
        name +
        ' | 保持(latest): ' +
        keep.getId() +
        ' @ ' +
        keep.getLastUpdated() +
        ' | 削除' +
        (dryRun ? '予定' : '') +
        ': ' +
        removeIds.join(', ')
    );

    if (dryRun) {
      continue;
    }

    for (i = 0; i < remove.length; i++) {
      try {
        remove[i].setTrashed(true);
      } catch (e) {
        Logger.log('dedupe run trash fail: ' + remove[i].getId() + ' ' + e);
      }
    }
    remapScriptPropsToKeptDoc_(keep.getId(), removeIds);
  }
}

function remapScriptPropsToKeptDoc_(keptId, trashedIds) {
  if (!trashedIds || !trashedIds.length) {
    return;
  }
  var trashSet = {};
  var i;
  for (i = 0; i < trashedIds.length; i++) {
    trashSet[String(trashedIds[i])] = true;
  }

  var props = PropertiesService.getScriptProperties();
  var all = props.getProperties();
  var prefix = CONFIG.PROP_KEY_PREFIX;

  var key;
  for (key in all) {
    if (!Object.prototype.hasOwnProperty.call(all, key)) {
      continue;
    }
    if (key.indexOf(prefix) !== 0) {
      continue;
    }
    var v = all[key];
    if (trashSet[v]) {
      props.setProperty(key, keptId);
    }
  }
}

function updateDocWithRetry_(docFile, logicalName, mdText) {
  var newText = normalize_(mdText);
  var attempt;

  for (attempt = 1; attempt <= CONFIG.MAX_OPEN_RETRIES; attempt++) {
    try {
      var doc = DocumentApp.openById(docFile.getId());
      var body = doc.getBody();
      var oldText = normalize_(body.getText());
      if (oldText === newText) {
        doc.saveAndClose();
        return 'unchanged';
      }
      body.clear();
      writeMarkdown_(body, mdText);
      doc.saveAndClose();
      return 'updated';
    } catch (e) {
      var msg = String(e);
      Logger.log('⚠️ open/update失敗 ' + logicalName + ' attempt=' + attempt + ' err=' + msg);
      if (attempt === CONFIG.MAX_OPEN_RETRIES) {
        return { recreate: true, reason: msg };
      }
      Utilities.sleep(CONFIG.BASE_SLEEP_MS * Math.pow(2, attempt - 1));
    }
  }
  return { recreate: true, reason: 'max retries' };
}

function createDocWithContent_(name, md, folder) {
  var doc = DocumentApp.create(name);
  var body = doc.getBody();
  writeMarkdown_(body, md);
  doc.saveAndClose();
  var file = DriveApp.getFileById(doc.getId());
  file.moveTo(folder);
  return file.getId();
}

function getOrCreateFolder_(parent, name) {
  var folders = parent.getFoldersByName(name);
  return folders.hasNext() ? folders.next() : parent.createFolder(name);
}

function writeMarkdown_(body, md) {
  var lines = md.split('\n');
  var inCode = false;

  lines.forEach(function (line) {
    if (line.indexOf('```') === 0) {
      inCode = !inCode;
      return;
    }
    if (inCode) {
      body.appendParagraph(line).setFontFamily('Courier New');
      return;
    }
    if (line.indexOf('### ') === 0) {
      body.appendParagraph(line.slice(4)).setHeading(DocumentApp.ParagraphHeading.HEADING3);
      return;
    }
    if (line.indexOf('## ') === 0) {
      body.appendParagraph(line.slice(3)).setHeading(DocumentApp.ParagraphHeading.HEADING2);
      return;
    }
    if (line.indexOf('# ') === 0) {
      body.appendParagraph(line.slice(2)).setHeading(DocumentApp.ParagraphHeading.HEADING1);
      return;
    }
    if (/^[-*] /.test(line)) {
      body.appendListItem(line.replace(/^[-*] /, ''));
      return;
    }
    if (/^---+$/.test(line)) {
      body.appendParagraph('────────────');
      return;
    }
    if (line.trim() === '') {
      body.appendParagraph('');
      return;
    }
    var text = line
      .replace(/\*\*(.*?)\*\*/g, '$1')
      .replace(/\*(.*?)\*/g, '$1')
      .replace(/`(.*?)`/g, '$1');
    body.appendParagraph(text);
  });
}

function normalize_(text) {
  return text
    .replace(/\r\n/g, '\n')
    .replace(/\s+$/gm, '')
    .trim();
}
