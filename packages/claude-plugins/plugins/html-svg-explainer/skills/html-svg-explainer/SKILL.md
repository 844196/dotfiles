---
name: html-svg-explainer
description: Explain a topic by writing a single self-contained HTML+SVG page (diagrams drawn as hand-coded inline SVG, not ASCII art or an external diagramming tool), then open it in the browser. Use this whenever the user explicitly asks for an HTML page, an SVG diagram, a "one-pager", or says something like "explain this visually" / "図で説明して" / "HTMLで" / "svgで" / "ascii artじゃなくて" / "ペライチにして". This is especially valuable — and worth proposing even if the user only asks to "explain" or "summarize" — when the subject matter has timeline structure, sequencing, before/after relationships, or correspondence/pairing between two or more things (e.g. two data series being compared frame-by-frame, a sequence of events, a state machine, a pipeline of steps). Don't use this for quick verbal explanations or when the user wants plain prose/markdown.
---

# HTML+SVG Explainer

## なぜこの形式か

テキストや ASCII art で時系列・対応関係・前後関係を説明しようとすると、等幅フォントや端末幅に依存してすぐレイアウトが崩れ、要素間の対応が視覚的に追いにくくなる。HTML+SVG なら座標を明示的に指定できるので、「AとBが同じ時刻で対応している」「この矢印はここからここへの変換を表す」といった空間的関係を正確に、かつリッチに (色・太さ・破線・矢印の向き) 表現できる。

説明対象に次のような構造があるときは、たとえユーザーが「説明して」「まとめて」としか言っていなくても、このスキルを積極的に提案する価値がある:

- 時系列 (何が起きた順に並ぶか)
- 対応関係・ペアリング (AのこれとBのこれが対応する、比較される)
- 前後関係・因果 (この状態からこの状態に変化した)
- 分岐・パターン比較 (複数の仮説/シナリオを並べて見せる)

逆に、対象が単なる箇条書きで済む情報 (単純なリスト、単一の数値、はい/いいえの結論) なら、わざわざ HTML+SVG にする意味は薄い。素直にテキストで答える。

## 進め方

1. **説明したい内容の構造を先に決める。** 何が縦軸・横軸になるか、何と何を対応づけるかを自分の中で整理してから SVG の座標を組み立てる。行き当たりばったりで rect を置き始めると、後から要素がぶつかったり文字が重なったりする。
2. **`assets/template.html` を土台にする。** ゼロから HTML を書く必要はない。テンプレートには CSS (見出し、callout、凡例、テーブル) と SVG の矢印マーカー定義が用意済みなので、中身の `<h1>`/`<p>`/`<svg>` 要素を書き換えていく。
3. **保存先を決める。**
   - プロジェクトに scratchpad 的な置き場所の規約がある場合 (例: `.844196/` のような gitignore された個人ディレクトリ、`docs/`配下の調査メモディレクトリなど) はそれに従う。
   - 特に規約がなければ、作業中のトピックに関連するディレクトリ、それも無ければカレントディレクトリに `<説明が付く名前>.html` として置く。
   - ファイル新規作成の際にプロジェクト固有の手順 (例: 空ファイルを touch してから Read → Write する、等) があればそれに従う。
4. **書き終えたら `chroma` でブラウザに開く。**
   ```bash
   chroma "file://$(realpath path/to/diagram.html)"
   ```
   `chroma` が使えない環境 (このユーザー固有のツールなので、無ければ普通に) では、ファイルパスを伝えてユーザーに自分で開いてもらう。
5. **チャットにも要点を書く。** HTML ファイルは補助教材であって代替物ではない。何を図示したか、結論は何かをチャット上でも簡潔に説明する。ページを開かせて終わりにしない。

## SVG を組み立てるときのコツ

- **座標は手計算でよい。** 過去の実例でも、ライブラリ (D3.js など) を使わず `<rect>`/`<circle>`/`<line>`/`<text>`/`<polyline>` の座標を直接書き下ろす方式で十分な品質になっている。要素数が多くない一枚絵なら、この方が却って自由度が高く速い。
- **`viewBox` を使う。** `<svg width="900" height="240" viewBox="0 0 900 240">` のようにしておくと、後で全体のサイズ調整がしやすい。
- **色は「意味」に固定して一貫させる。** 例えば「片方の系列は青系、もう片方は赤系」「確定した事実は緑、未検証の仮説は赤/黄」のように、ページ全体で同じ色が同じ意味を持つようにする。都度その場の思いつきで色を変えない。テンプレートの callout (`.info`/`.warn`/`.ok`) と合わせて統一すると分かりやすい。
- **対応関係は矢印で結ぶ。** 2つの要素が対応する/しないを示したいときは、位置を揃えて並べるだけでなく `<line marker-end="url(#arrow)">` で明示的に結ぶと格段に伝わりやすくなる。正しい対応は緑、ズレ/警告は赤、など矢印の色も意味に合わせる。テンプレートに緑/赤の矢印マーカー定義がある。
- **ラベルは要素の中か直下に置く。** `text-anchor="middle"` で図形の中心にラベルを置くのが基本。長い注釈は図の外の `<figcaption>` に逃がして SVG 内は短いラベルだけにする方が読みやすい。
- **凡例を忘れない。** 色や線種に意味を持たせたら、テンプレートの `.legend` ブロックで凡例を必ず添える。作った本人には自明でも、見る側には自明ではない。
- **要素がぶつかったら座標を計算し直す。** テキストが重なったり矢印が図形を突き抜けたりしていないか、書いた後に座標を目で追って確認する。
- **SVG は後に描いた要素が前の要素を覆い隠す。** 特に「見出しラベルの右に長い注釈テキストを続けて置き、その下 (同じ縦範囲) に矩形を描く」パターンでは、矩形がラベルの続きを隠して文字が途中で切れる事故が起きやすい。ラベル行と図形の行は縦方向に十分離す (ラベルの `y` と、その下の図形の `y` の間に最低でも文字の高さ+余白分の差を空ける) か、ラベルの右端が図形の `x` 開始位置を超えないよう文字数を見積もっておく。

## 参考実装

`references/example-frame-pairing.html` に、実際に高評価だった実例 (2つの時系列データの対応関係のズレを図示したもの) を収録している。テーブルとSVGを併用した構成、複数シナリオの比較、色分けのルールなど、具体的な組み立て方を見たいときに参照する。
