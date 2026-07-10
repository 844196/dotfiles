#!/usr/bin/env python3
"""sessions.csv を event 数で均等割りして batches/batch-NN.txt を生成する。

抽出フェーズで各サブエージェント 1 体が 1 バッチを担当する。バッチ間の
負荷 (= 読む event の総数) を揃えるため、LPT (Longest Processing Time first)
greedy でビンパッキングする。生ログの重い少数セッションが 1 バッチに偏らない
ようにするのが狙い。

使い方:
    python3 build-batches.py <opinions_dir> [num_batches]

前提: <opinions_dir>/sessions.csv が存在すること (SKILL.md のコマンドで生成)。
CSV ヘッダ: ctx_session_id,events,msgs,cwd
出力: <opinions_dir>/batches/batch-01.txt .. batch-NN.txt (1 行 1 session id)
"""
import sys, csv, os


def main():
    if len(sys.argv) < 2:
        print("usage: build-batches.py <opinions_dir> [num_batches]", file=sys.stderr)
        sys.exit(2)
    out = sys.argv[1]
    n = int(sys.argv[2]) if len(sys.argv) > 2 else 16

    rows = []
    with open(os.path.join(out, "sessions.csv")) as f:
        for x in csv.DictReader(f):
            rows.append((x["ctx_session_id"], int(x["events"]), int(x["msgs"])))

    if not rows:
        print("sessions.csv is empty", file=sys.stderr)
        sys.exit(1)

    # セッション数が少ないときはバッチ数を丸める (空バッチを作らない)
    n = max(1, min(n, len(rows)))

    # LPT: event 数の多い順に、その時点で最も軽いビンへ入れる
    rows.sort(key=lambda t: t[1], reverse=True)
    bins = [[] for _ in range(n)]
    load = [0] * n
    for sid, ev, ms in rows:
        i = load.index(min(load))
        bins[i].append((sid, ev, ms))
        load[i] += ev

    os.makedirs(os.path.join(out, "batches"), exist_ok=True)
    for i, b in enumerate(bins, 1):
        p = os.path.join(out, "batches", f"batch-{i:02d}.txt")
        with open(p, "w") as f:
            for sid, ev, ms in b:
                f.write(f"{sid}\n")
        print(
            f"batch-{i:02d}: {len(b)} sessions, "
            f"{sum(x[1] for x in b)} events, {sum(x[2] for x in b)} msgs"
        )
    print("total sessions:", sum(len(b) for b in bins))


if __name__ == "__main__":
    main()
