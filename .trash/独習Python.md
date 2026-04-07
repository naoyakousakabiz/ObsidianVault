---
title: 独習Python
author: 山田 祥寛
type: book
kindle-bookId: '7934'
kindle-title: 独習Python
kindle-author: 山田 祥寛
kindle-highlightsCount: 86
kindle-asin: B087JDXCX9
kindle-lastAnnotatedDate: Invalid date
kindle-bookImageUrl: 'https://m.media-amazon.com/images/I/81CYRSlmChL._SX1024.jpg'
---

# 独習Python

Author: 山田 祥寛

---

## Highlights

（3）isclose関数 — location: [2097](kindle://book?action=open&asin=B087JDXCX9&location=2097) ^ref-28131

---
同一性と同値性 — location: [2110](kindle://book?action=open&asin=B087JDXCX9&location=2110) ^ref-10587

---
イミュータブル型の同一性 — location: [2130](kindle://book?action=open&asin=B087JDXCX9&location=2130) ^ref-48334

---
これは、文字列がイミュータブルであるがための挙動です。イミュータブルであれば、あとから値が変化することはないはずなので、Pythonではメモリを節約するために同じ値（オブジェクト）を再利用しているのです。 — location: [2137](kindle://book?action=open&asin=B087JDXCX9&location=2137) ^ref-64719

---
あくまで、このような挙動もある、とだけ理解しておき、==、is演算子は同値性／同一性いずれを判定するかによって使い分けるようにしてください。 — location: [2141](kindle://book?action=open&asin=B087JDXCX9&location=2141) ^ref-55316

---
None値の比較はis演算子 — location: [2142](kindle://book?action=open&asin=B087JDXCX9&location=2142) ^ref-21153

---
Pythonでは比較演算子の連結を認めており、上のような例であれば、そもそも、 50 <= x <= 100 のように表すべき — location: [2241](kindle://book?action=open&asin=B087JDXCX9&location=2241) ^ref-7978

---
複雑な式を書く場合には、できるだけ丸カッコを利用して、演算子の優先順位を明確にしておくことをお勧めし — location: [2287](kindle://book?action=open&asin=B087JDXCX9&location=2287) ^ref-2177

---
丸カッコはうるさくならない範囲で、積極的に利用すべき — location: [2293](kindle://book?action=open&asin=B087JDXCX9&location=2293) ^ref-2645

---
異なる演算子の処理順序を決めるのが優先順位であるとすれば、同じ優先順位の演算子を処理する順序を決めるのが結合則 — location: [2294](kindle://book?action=open&asin=B087JDXCX9&location=2294) ^ref-24820

---
● 順次（ 順接）：記述された順に処理を実行 ● 選択：条件によって処理を分岐 ● 反復：特定の処理を繰り返し実行 — location: [2339](kindle://book?action=open&asin=B087JDXCX9&location=2339) ^ref-22792

---
順次／選択／反復を組み合わせながらプログラムを組み立てていく手法のことを 構造化プログラミング と — location: [2343](kindle://book?action=open&asin=B087JDXCX9&location=2343) ^ref-55353

---
複合文は、より具体的には1つ以上の 節（clause）から構成されます。節は、さらに ヘッダー（header）と スイート（suite）とに分類される、という作りです（図4.1）。 — location: [2374](kindle://book?action=open&asin=B087JDXCX9&location=2374) ^ref-27023

---
ヘッダーの一般的な文法規則は、以下の通りです（図4.2）。 ● 1つの複合文でヘッダーのインデント（字下げ）位置はそろっていること ● ヘッダーを識別するキーワード（ここではif）で始まり、コロン（:）で終わること — location: [2383](kindle://book?action=open&asin=B087JDXCX9&location=2383) ^ref-32704

---
インデントは原則、 半角空白4個分 で表すのが — location: [2396](kindle://book?action=open&asin=B087JDXCX9&location=2396) ^ref-18547

---
Pythonは、ヘッダーの直後にブロックを期待しているので、この場合は「IndentationError: expected an indented block」のようなエラーとなります。 開発中などの理由で空のブロックを用意したい場合には、以下のようにpass命令を利用してください。 — location: [2415](kindle://book?action=open&asin=B087JDXCX9&location=2415) ^ref-43929

---
passは「なにもしない」を表す命令 — location: [2419](kindle://book?action=open&asin=B087JDXCX9&location=2419) ^ref-8023

---
elifブロックを利用する場合には、条件式を範囲の狭いものから順に記述するようにしてください。 — location: [2459](kindle://book?action=open&asin=B087JDXCX9&location=2459) ^ref-28267

---
同じ階層のヘッダー／ブロックは、それぞれインデント位置をそろえる — location: [2500](kindle://book?action=open&asin=B087JDXCX9&location=2500) ^ref-25096

---
条件式は丸カッコでくくることもできますが、単純な式では、これまで見てきたようにカッコなしで表すのが一般的です。 — location: [2512](kindle://book?action=open&asin=B087JDXCX9&location=2512) ^ref-16469

---
ただし、論理演算子を伴う複雑な条件式を表す場合など、論理演算子の単位で条件式を改行したいことがあります（そのほうが条件式を一望しやすいからです）。 そのような状況では、条件式全体を丸カッコでくくってください。カッコ内ではキーワードの区切りで自由に改行／インデントできるからです。 — location: [2513](kindle://book?action=open&asin=B087JDXCX9&location=2513) ^ref-48984

---
リストが空であることを判定するならば、「list == [ ]」ではなく「not list」のようにすれば十分 — location: [2528](kindle://book?action=open&asin=B087JDXCX9&location=2528) ^ref-50902

---
（3）条件式からはできるだけ否定を取り除く — location: [2532](kindle://book?action=open&asin=B087JDXCX9&location=2532) ^ref-20626

---
繰り返し処理を記述する際には、まずループが正しく終了できるのか、条件式を確認してから実行するようにしましょ — location: [2588](kindle://book?action=open&asin=B087JDXCX9&location=2588) ^ref-51440

---
たとえば以下は、文字列をfor命令で処理する例です。この場合、for命令は文字列を1文字単位に分割します。 — location: [2610](kindle://book?action=open&asin=B087JDXCX9&location=2610) ^ref-21415

---
range関数のさまざまな表現 — location: [2633](kindle://book?action=open&asin=B087JDXCX9&location=2633) ^ref-58156

---
実際に生成された値を確認するならば、list関数でリストに変換してしまいましょう。これで生成された値をひと目で確認できます。 — location: [2650](kindle://book?action=open&asin=B087JDXCX9&location=2650) ^ref-44568

---
内包表記（comprehension）とは、既存のリストから新たなリストを生成する際に簡単に書ける表現方法 — location: [2663](kindle://book?action=open&asin=B087JDXCX9&location=2663) ^ref-31880

---
一方、アプリがどんなに正しくても未然に防げない問題があります。これをエラーと区別して、 例外（exception）と呼び — location: [2808](kindle://book?action=open&asin=B087JDXCX9&location=2808) ^ref-19331

---
例外処理とは、あらかじめ発生する かもしれない エラーを想定しておき、実行を継続できるよう処理する、または、安全に終了させるための処理のこと — location: [2831](kindle://book?action=open&asin=B087JDXCX9&location=2831) ^ref-35067

---
except節は空にもできますが、それは避けてください。except節を空にするということは、発生した例外を無視する（＝握りつぶす）ことであり、バグなどの問題特定を困難にします。最低でも、サンプルのように例外情報を出力し、例外の発生を確認できるようにしておきます。 — location: [2849](kindle://book?action=open&asin=B087JDXCX9&location=2849) ^ref-32841

---
例外情報には、例外変数exを介してアクセスできます（名前に決まりはありませんが、e、exとするのが一般的です）。 — location: [2851](kindle://book?action=open&asin=B087JDXCX9&location=2851) ^ref-47061

---
Pythonインタプリター（本体）に組み込まれている関数／型を 組み込み関数／ 組み込み型（総称して 組み込みライブラリ）と言い、特別な準備なしで呼び出せます。 一方、Builtinでない型／関数は、 モジュール という枠で束ねられて、提供されています。 — location: [2956](kindle://book?action=open&asin=B087JDXCX9&location=2956) ^ref-18189

---
「値, ...」のように値を列挙するだけの引数を 位置引数、「名前=値, ...」形式の引数を キーワード引数 と呼び — location: [2979](kindle://book?action=open&asin=B087JDXCX9&location=2979) ^ref-61311

---
概念的な解説で「難しい！」と思ってしまった人は、具体的なコードに即して考えてみましょう。 msg = 'こんにちは' このコードを読み解くと、 'こんにちは'という文字列リテラルによって、str型（クラス）のインスタンス（オブジェクト）を生成し、変数msgに代入する — location: [2992](kindle://book?action=open&asin=B087JDXCX9&location=2992) ^ref-55028

---
型名を関数のように呼び出すことで、インスタンスを作成します（インスタンスを生成するための仕組みということで、従来の関数と区別して コンストラクター と呼ぶこともあります）。 たとえば、5.3.1項で触れるdatetime.date型（日付）であれば、以下のようにインスタンス化できます。 today = datetime.date(2020, 11, 10) これで2020/11/10を表すdatetime.date型のインスタンスを生成したことになります。 実は、str型も同じように生成できます。 msg = str('こんにちは') 3.1.2項でstr関数、int関数と説明しましたが、正確にはstr型、int型をインスタンス化していたわけです。 — location: [3004](kindle://book?action=open&asin=B087JDXCX9&location=3004) ^ref-51894

---
リテラルが用意されている型は、リテラルで作成されたインスタンスをまた、str('いろは')のようにインスタンス化するのは冗長ですし、なにより無駄な処理なので、リテラルを優先して利用するべき — location: [3015](kindle://book?action=open&asin=B087JDXCX9&location=3015) ^ref-19930

---
型は専用の関数を持っています。これを型に属さない関数と区別して メソッド — location: [3019](kindle://book?action=open&asin=B087JDXCX9&location=3019) ^ref-48321

---
構文 メソッドの呼び出し インスタンス.メソッド(引数, ...) — location: [3024](kindle://book?action=open&asin=B087JDXCX9&location=3024) ^ref-36955

---
型は、それ自体がさまざまな情報を保存しています。たとえば、先ほど軽く触れたdatetime.date型（日付）は、年／月／日のような情報（変数）を持っています。このように、型に属する変数を、普通の変数と区別して 属性（ アトリビュート）と呼びます。 — location: [3037](kindle://book?action=open&asin=B087JDXCX9&location=3037) ^ref-48424

---
構文 属性へのアクセス インスタンス.属性 — location: [3042](kindle://book?action=open&asin=B087JDXCX9&location=3042) ^ref-13139

---
型の中でも、複数の値を束ねるための仕組みを持つものを総称して、 コレクション、 コンテナー などと呼びます。 — location: [3794](kindle://book?action=open&asin=B087JDXCX9&location=3794) ^ref-40234

---
います。 — location: [3797](kindle://book?action=open&asin=B087JDXCX9&location=3797) ^ref-10227

---
言語によっては、配列などと呼ばれる仕組み — location: [3799](kindle://book?action=open&asin=B087JDXCX9&location=3799) ^ref-65073

---
シーケンス型 とは、配下の要素が順序付けられたデータ構造です。「順序がある」とは、インデックス値によって個々の要素にアクセスできる、と言い換えてもよいでしょう。 — location: [3806](kindle://book?action=open&asin=B087JDXCX9&location=3806) ^ref-30062

---
popメソッドは、戻り値として削除した値を返すので、（削除するというよりも）値を取り出している、といったほうがより的確なイメージかもしれません。 — location: [3897](kindle://book?action=open&asin=B087JDXCX9&location=3897) ^ref-54917

---
同一の要素が複数あった場合にも、removeメソッドが削除するのは最初の1つです。 ❶ であれば、後方の「田中」は削除 されない 点に注目です。 — location: [3929](kindle://book?action=open&asin=B087JDXCX9&location=3929) ^ref-60178

---
配下のリスト（[1, 2, 3]、[4, 5, 6]、[7, 8, 9]）は、それぞれ参照をコピーしただけなので、コピー先data2への変更はそのままコピー元dataにも影響してしまうわけです。 これを避けるには、copyモジュールのdeepcopy関数を利用してください。 — location: [4022](kindle://book?action=open&asin=B087JDXCX9&location=4022) ^ref-44539

---
確かに、今度は互いの変更が双方に影響 しない（＝配下のリストも新規に生成されている）ことが確認できます。このようなコピーのことを ディープコピー（深いコピー）と呼びます。 — location: [4029](kindle://book?action=open&asin=B087JDXCX9&location=4029) ^ref-61912

---
「*」による連結は、あくまで参照のコピーでしかないわけです。値そのものをコピーしているわけではない点に注意してください。 — location: [4046](kindle://book?action=open&asin=B087JDXCX9&location=4046) ^ref-503

---
似たメソッドにappendメソッドもありますが、こちらは意味が異なります。指定されたリストの要素ではなく、リストそのものが1つの要素として追加されてしまいます。 — location: [4056](kindle://book?action=open&asin=B087JDXCX9&location=4056) ^ref-1830

---
reverseメソッドとreversed関数は、以下の点で異なります。 ● reserveメソッドが現在のリストに影響を及ぼすのに対して、reversed関数は逆順に並べ替えた結果を戻り値として返す ● reversed関数の戻り値はリストではなく、イテレーター（11.4節） よって、 ❷ でもreversed関数によって得られた結果をlist関数（コンストラクター）でリストに変換したうえで表示しています。 — location: [4066](kindle://book?action=open&asin=B087JDXCX9&location=4066) ^ref-20703

---
insort関数は挿入値xと同じ値がリスト内に存在した場合、それらの要素の最後に新規の要素を挿入します。もしも最初（左側）に挿入したい場合は、insort_left関数を利用してください。 — location: [4140](kindle://book?action=open&asin=B087JDXCX9&location=4140) ^ref-52021

---
zip関数を利用することで、複数のリストを束ねて処理することも可能 — location: [4156](kindle://book?action=open&asin=B087JDXCX9&location=4156) ^ref-23741

---
もしも最も要素数の多いリストに合わせて処理するならば、itertoolsモジュールのzip_longest関数を利用してください。 — location: [4163](kindle://book?action=open&asin=B087JDXCX9&location=4163) ^ref-9731

---
なお、map関数の戻り値は、（リストではなく）mapオブジェクトです。インデックスによるアクセスやforループでの処理は可能ですが、そのままprint関数に渡しても型名だけしか表示されません（＝中身を確認できません）。そこで、 ❷ ではmapオブジェクトをlist関数に渡して、リストに変換したものを表示しています。 — location: [4202](kindle://book?action=open&asin=B087JDXCX9&location=4202) ^ref-26303

---
引数 initializer は、最初にresultに渡す値を表します。省略された場合には、リストの先頭要素が渡されます。よって、 ❶ は以下のように書いてもほぼ同じ意味です。 — location: [4265](kindle://book?action=open&asin=B087JDXCX9&location=4265) ^ref-63543

---
キュー（Queue）は、先入れ先出し（FIFO：First In First Out）と呼ばれるデータ構造です（図6.7）。最初に入った要素から順に処理する（取り出す）流れが、窓口などでサービスを待つ様子にも似ていることから、 待ち行列 とも呼ばれます。 — location: [4279](kindle://book?action=open&asin=B087JDXCX9&location=4279) ^ref-58133

---
辞書（ dict）は、一意のキーと値のペアで管理されるデータ構造です。言語によっては、 ハッシュ、 連想配列 と呼ぶ場合もあります。 — location: [4480](kindle://book?action=open&asin=B087JDXCX9&location=4480) ^ref-6139

---
リスト／タプルと異なり、個々の要素に対して、（インデックスではなく）キーという意味ある情報でアクセスできる点が、辞書の特徴です（ — location: [4483](kindle://book?action=open&asin=B087JDXCX9&location=4483) ^ref-39697

---
ある項目（キー）と内容とが対になっているという意味で、「辞書」と呼ばれるわけです。 — location: [4485](kindle://book?action=open&asin=B087JDXCX9&location=4485) ^ref-51186

---
辞書（dict）は、内部的に ハッシュ表（ ハッシュテーブル）と呼ばれるリストを持ち — location: [4515](kindle://book?action=open&asin=B087JDXCX9&location=4515) ^ref-64798

---
要素を保存する際に、キーからハッシュ値を求めることで、ハッシュ表のどこに値（オブジェクト）を保存するかを決定します。 — location: [4518](kindle://book?action=open&asin=B087JDXCX9&location=4518) ^ref-47304

---
キーはハッシュ可能であること 以上のような性質から、辞書（dict）のキーは、ハッシュ値を算出可能な型でなければなりません。このような性質を hashable（ ハッシュ可能）と呼びます。 — location: [4528](kindle://book?action=open&asin=B087JDXCX9&location=4528) ^ref-263

---
つまり、list、set、dictなどの型はunhashable（ハッシュ不可）で、辞書のキーとして利用することはできません。 最初のうちは、str型をキーとして利用することが多いはずですが、まずは ● 辞書のキーは文字列に限定されないこと ● とはいえ、すべての型をキーとして利用できるわけではないこと を押さえておくとよいでしょう。 — location: [4534](kindle://book?action=open&asin=B087JDXCX9&location=4534) ^ref-44465

---
正規表現（Regular Expression）とは「あいまいな文字列パターンを表現するための記法」です。大ざっぱに「ワイルドカードをもっと高度にしたもの」と言っていいかもしれません。 — location: [4711](kindle://book?action=open&asin=B087JDXCX9&location=4711) ^ref-31656

---
しかし、正規表現を利用すれば、正規表現パターンと比較対象の文字列を指定するだけで、あとは両者が合致するかどうかを正規表現エンジンが判定してくれるのです。 — location: [4726](kindle://book?action=open&asin=B087JDXCX9&location=4726) ^ref-11119

---
単にマッチするかどうかの判定だけではありません。正規表現を利用すれば、たとえば、掲示板への投稿記事から有害なHTMLタグだけを取り除いたり、任意の文書からメールアドレスだけを取り出したり、といったこともできます。 — location: [4727](kindle://book?action=open&asin=B087JDXCX9&location=4727) ^ref-21143

---
正規表現とは、非定型のテキスト、HTMLなど、散文的な（ということは、コンピューターにとって再利用するのが難しい）データを、ある定型的な形で抽出し、データとしての洗練度を — location: [4730](kindle://book?action=open&asin=B087JDXCX9&location=4730) ^ref-7589

---
させる──いわば、人間のためのデータと、システムのためのデータをつなぐ橋渡し的な役割を果たす存在とも言えます。 — location: [4731](kindle://book?action=open&asin=B087JDXCX9&location=4731) ^ref-21342

---
正規表現パターンには、その性質上、「\」文字が多く含まれます。文字列リテラルでのエスケープシーケンスとの衝突を防ぐために、raw文字列（r'...'）で表すのが安全でしょう（「\\」のようにエスケープしてもかまいませんが、冗長です！）。 — location: [4769](kindle://book?action=open&asin=B087JDXCX9&location=4769) ^ref-40336

---
compile関数は、戻り値として正規表現（Pattern）オブジェクトを返すので、そのsearchメソッドで検索を実行し — location: [4771](kindle://book?action=open&asin=B087JDXCX9&location=4771) ^ref-45935

---
groupメソッドは、引数を省略、または0に指定した場合にマッチした文字列全体を、1以上の値を指定した場合にはサブマッチ文字列を、それぞれ返します（図7.2）。 — location: [4784](kindle://book?action=open&asin=B087JDXCX9&location=4784) ^ref-52873

---
search／matchメソッドで得られる結果は、いずれも最初にマッチした文字列1つだけです。もしもマッチした文字列すべてを取得したいならば、findall／finditerメソッドを利用してください。 — location: [4803](kindle://book?action=open&asin=B087JDXCX9&location=4803) ^ref-38927

---
同じく「*?」「{n,}?」「??」などの最短一致表現も可能 — location: [4934](kindle://book?action=open&asin=B087JDXCX9&location=4934) ^ref-22954

---
名前付きキャプチャグループ — location: [4935](kindle://book?action=open&asin=B087JDXCX9&location=4935) ^ref-49804

---
変数は、利用にあたって特別な準備もいらず、ごく手軽に値を出し入れできます。反面、その保存先はメモリなので、プログラムが終了すると値もそのまま消えてしまいます。 しかし、より実践的なアプリでは、プログラムが終了した後も残しておけるデータの保存先が欲しくなります。そのような保存先の中でも準備がいらず、比較的手軽に利用できるのがファイルです。 — location: [5090](kindle://book?action=open&asin=B087JDXCX9&location=5090) ^ref-41735

---
ファイルのように、複数のコードから利用する可能性があるものは、使い終わった後はきちんと閉じなければなりません。さもないと、Pythonがファイルを占有してしまい、他のコードからファイルを開けなくなってしまう可能性があるからです。 — location: [5156](kindle://book?action=open&asin=B087JDXCX9&location=5156) ^ref-2534

---
そこでPythonでは、自動クローズの仕組みとしてwith命令を提供しています。 — location: [5161](kindle://book?action=open&asin=B087JDXCX9&location=5161) ^ref-14437

---
実際のアプリではwith命令を優先して利用することをお勧めします。 — location: [5174](kindle://book?action=open&asin=B087JDXCX9&location=5174) ^ref-19982

---
シーク位置を変更する これまでは、オープンモード既定のシーク位置でファイルを操作してきましたが、seekメソッドを利用することで、明示的にシーク位置を変更することもできます。たとえば、リスト7.19は3文字目からファイルの読み込みを開始する例です。 — location: [5242](kindle://book?action=open&asin=B087JDXCX9&location=5242) ^ref-37508

---
バイナリデータを読み書きするならば、open関数でrb、wbのように、読み書きを表すオープンモードに「b」（バイナリモード）を追加するだけです。 — location: [5255](kindle://book?action=open&asin=B087JDXCX9&location=5255) ^ref-61869

---
readメソッドは、読み取るべきデータが残っていない場合に、空のbytesオブジェクトを返します。ここでは、その性質を利用して、シーク位置がファイル終端に達したところで（＝ファイルをすべて読み切ったところで）ループを脱出しているわけです。 — location: [5263](kindle://book?action=open&asin=B087JDXCX9&location=5263) ^ref-49982

---
csvモジュールの利用がお勧めです。 — location: [5301](kindle://book?action=open&asin=B087JDXCX9&location=5301) ^ref-30689

---
ファイルの情報が必要なことがあらかじめわかっているならば、scandir関数を利用したほうが効率的 — location: [5423](kindle://book?action=open&asin=B087JDXCX9&location=5423) ^ref-56502

---
makedirs関数は、このように、 パスの途中に存在しないフォルダーが挟まっていた場合は、これを再帰的に作成 してくれるわけです（ちなみに、mkdir関数でも/subが存在する状態でsub/gsubフォルダーを作成することは問題ありません）。 — location: [5506](kindle://book?action=open&asin=B087JDXCX9&location=5506) ^ref-23046

---

---

## Notes
