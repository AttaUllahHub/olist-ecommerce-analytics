import json
import os
from pathlib import Path
import duckdb
import numpy as np
from scipy import stats

ROOT = Path(__file__).resolve().parent.parent
os.chdir(ROOT)


def run():
    con = duckdb.connect(str(ROOT / "olist.duckdb"), read_only=True)
    df = con.execute(
        "SELECT is_late, review_score, days_vs_estimate FROM delivered_orders WHERE review_score IS NOT NULL"
    ).fetchdf()
    con.close()

    late = df.loc[df.is_late, "review_score"].to_numpy()
    on_time = df.loc[~df.is_late, "review_score"].to_numpy()

    u, p = stats.mannwhitneyu(on_time, late, alternative="two-sided")
    cles = u / (len(on_time) * len(late))

    rng = np.random.default_rng(42)
    diffs = np.empty(2000)
    for i in range(2000):
        diffs[i] = rng.choice(on_time, len(on_time)).mean() - rng.choice(late, len(late)).mean()
    ci = np.percentile(diffs, [2.5, 97.5])

    rho, rho_p = stats.spearmanr(df["days_vs_estimate"], df["review_score"])

    out = {
        "n_reviewed_orders": int(len(df)),
        "n_late": int(len(late)),
        "n_on_time": int(len(on_time)),
        "mean_score_on_time": round(float(on_time.mean()), 3),
        "mean_score_late": round(float(late.mean()), 3),
        "mean_difference": round(float(on_time.mean() - late.mean()), 3),
        "bootstrap_95ci_difference": [round(float(ci[0]), 3), round(float(ci[1]), 3)],
        "mann_whitney_u": float(u),
        "mann_whitney_p": float(p),
        "common_language_effect_size_ties_split": round(float(cles), 3),
        "spearman_rho_days_vs_estimate_and_score": round(float(rho), 3),
        "spearman_p": float(rho_p),
    }
    path = ROOT / "reports" / "results" / "stats_summary.json"
    path.write_text(json.dumps(out, indent=2))
    return out


if __name__ == "__main__":
    print(json.dumps(run(), indent=2))
