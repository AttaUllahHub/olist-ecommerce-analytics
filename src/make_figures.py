import os
from pathlib import Path
import duckdb
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
os.chdir(ROOT)
RES = ROOT / "reports" / "results"
FIG = ROOT / "reports" / "figures"
FIG.mkdir(parents=True, exist_ok=True)

INK, MUTED, BLUE, RED, LIGHT = "#222222", "#6b6b6b", "#3b6ea5", "#c0392b", "#d9d9d9"
SOURCE = "Source: Olist Brazilian E-Commerce Public Dataset (delivered orders)"

plt.rcParams.update({
    "font.family": "DejaVu Sans",
    "axes.spines.top": False,
    "axes.spines.right": False,
    "axes.edgecolor": LIGHT,
    "axes.labelcolor": MUTED,
    "xtick.color": MUTED,
    "ytick.color": MUTED,
    "text.color": INK,
    "figure.facecolor": "white",
    "axes.facecolor": "white",
})


def finish(fig, ax, title, subtitle=None, name="fig", source=SOURCE):
    fig.text(0.06, 0.95, title, fontsize=14, fontweight="bold", ha="left", va="top")
    if subtitle:
        fig.text(0.06, 0.885, subtitle, fontsize=10, color=MUTED, ha="left", va="top")
    fig.text(0.06, 0.02, source, fontsize=8, color=MUTED, ha="left")
    fig.savefig(FIG / f"{name}.png", dpi=160)
    plt.close(fig)


def monthly_revenue():
    d = pd.read_csv(RES / "10_monthly_revenue.csv")
    fig, ax = plt.subplots(figsize=(10, 5.6))
    fig.subplots_adjust(top=0.78, bottom=0.14, left=0.09, right=0.96)
    x = range(len(d))
    ax.plot(x, d["revenue"] / 1e3, color=BLUE, lw=2.2)
    ax.plot(x, d["revenue_3m_avg"] / 1e3, color=MUTED, lw=1.2, ls="--", label="3-month average")
    peak = d["revenue"].idxmax()
    ax.annotate("Black Friday\nNov 2017", (peak, d.loc[peak, "revenue"] / 1e3), xytext=(peak - 3.2, 930),
                fontsize=9, color=INK, arrowprops=dict(arrowstyle="-", color=MUTED))
    ax.set_xticks(list(x)[::2])
    ax.set_xticklabels(d["month"][::2], rotation=0, fontsize=8)
    ax.set_ylabel("Revenue (R$ thousands)")
    ax.set_ylim(0, 1100)
    ax.legend(frameon=False, fontsize=9, loc="upper left")
    ax.yaxis.grid(True, color="#eeeeee")
    ax.set_axisbelow(True)
    first, last = d.iloc[0], d.iloc[-1]
    finish(fig, ax, "Revenue climbed through 2017, then levelled off near R\\$0.9M a month in 2018",
           "Item revenue of delivered orders by month, January 2017 (R\\$112K) to August 2018 (R\\$839K)", "01_monthly_revenue")


def categories():
    d = pd.read_csv(RES / "11_category_performance.csv").head(10).iloc[::-1]
    fig, ax = plt.subplots(figsize=(10, 5.6))
    fig.subplots_adjust(top=0.78, bottom=0.12, left=0.22, right=0.94)
    ax.barh(d["category"].str.replace("_", " "), d["revenue"] / 1e3, color=BLUE, height=0.65)
    for y, (v, s) in enumerate(zip(d["revenue"] / 1e3, d["revenue_share_pct"])):
        ax.text(v + 12, y, f"R${v:,.0f}K  ({s:.1f}%)", va="center", fontsize=9, color=INK)
    ax.set_xlim(0, 1650)
    ax.set_xlabel("Revenue (R$ thousands)")
    top10 = pd.read_csv(RES / "11_category_performance.csv").head(10)["revenue_share_pct"].sum()
    finish(fig, ax, f"Ten categories out of 71 generate {top10:.0f}% of revenue",
           "Top 10 product categories by item revenue", "02_top_categories")


def retention():
    d = pd.read_csv(RES / "12b_cohort_retention.csv")
    d = d[d["month_index"] > 0]
    agg = d.groupby("month_index").apply(lambda g: 100 * g["active_customers"].sum() / g["cohort_customers"].sum(), include_groups=False)
    fig, ax = plt.subplots(figsize=(10, 5.6))
    fig.subplots_adjust(top=0.78, bottom=0.14, left=0.09, right=0.96)
    ax.bar(agg.index.astype(str), agg.values, color=BLUE, width=0.6)
    for i, v in zip(agg.index.astype(str), agg.values):
        ax.text(i, v + 0.015, f"{v:.2f}%", ha="center", fontsize=9)
    ax.set_ylim(0, 1.0)
    ax.yaxis.set_major_formatter(mtick.PercentFormatter(decimals=1))
    ax.set_xlabel("Months after first purchase")
    ax.set_ylabel("Customers who bought again")
    one_time = pd.read_csv(RES / "12a_repeat_purchase.csv").set_index("orders_placed").loc["1", "customers_pct"]
    finish(fig, ax, f"{one_time:.0f}% of customers never come back, and each month brings back under 1%",
           "Share of each first-purchase cohort (Jan 2017 to Feb 2018) that ordered again, by month", "03_retention")


def lateness():
    d = pd.read_csv(RES / "14b_lateness_buckets.csv")
    d["label"] = d["bucket"].str.replace(r"^\d\.\s", "", regex=True)
    fig, ax = plt.subplots(figsize=(10, 5.6))
    fig.subplots_adjust(top=0.78, bottom=0.2, left=0.09, right=0.96)
    colors = [BLUE, BLUE, BLUE, RED, RED, RED]
    ax.bar(d["label"], d["avg_review_score"], color=colors, width=0.62)
    for i, (v, o) in enumerate(zip(d["avg_review_score"], d["one_star_pct"])):
        ax.text(i, v + 0.07, f"{v:.2f}", ha="center", fontsize=11, fontweight="bold")
        ax.text(i, 0.12, f"{o:.0f}% one-star", ha="center", fontsize=8.5, color="white")
    ax.set_ylim(0, 5)
    ax.set_ylabel("Average review score (1 to 5)")
    plt.setp(ax.get_xticklabels(), fontsize=9)
    finish(fig, ax, "Reviews fall from 4.3 stars to 1.7 as delivery slips past the estimate",
           "Average review score by delivery date versus the estimate shown at checkout (95,824 reviewed orders)", "04_lateness_vs_reviews")


def late_by_state():
    d = pd.read_csv(RES / "14c_delivery_by_state.csv").sort_values("late_pct")
    fig, ax = plt.subplots(figsize=(10, 6.4))
    fig.subplots_adjust(top=0.82, bottom=0.13, left=0.09, right=0.94)
    colors = [RED if v >= 12 else BLUE for v in d["late_pct"]]
    ax.barh(d["state"], d["late_pct"], color=colors, height=0.68)
    for y, v in enumerate(d["late_pct"]):
        ax.text(v + 0.3, y, f"{v:.1f}%", va="center", fontsize=8.5)
    ax.set_xlabel("Orders delivered after the estimated date")
    ax.xaxis.set_major_formatter(mtick.PercentFormatter())
    finish(fig, ax, "Orders to AL, MA and SE arrive late 3 to 5 times as often as to SP",
           "Late delivery rate by customer state, states with 300+ delivered orders (red = 12% or higher)", "05_late_by_state",
           source=SOURCE + "  |  AL Alagoas, MA Maranhão, SE Sergipe, SP São Paulo")


def sellers():
    d = pd.read_csv(RES / "15a_seller_concentration.csv")
    fig, ax = plt.subplots(figsize=(10, 5.6))
    fig.subplots_adjust(top=0.78, bottom=0.14, left=0.09, right=0.96)
    colors = [RED] + [BLUE] * 9
    ax.bar(d["decile"].astype(str), d["revenue_share_pct"], color=colors, width=0.62)
    for i, v in zip(d["decile"].astype(str), d["revenue_share_pct"]):
        ax.text(i, v + 1, f"{v:.1f}%", ha="center", fontsize=9)
    ax.set_xlabel("Seller decile (1 = top 10% of sellers by revenue)")
    ax.set_ylabel("Share of marketplace revenue")
    ax.yaxis.set_major_formatter(mtick.PercentFormatter())
    ax.set_ylim(0, 78)
    top = d.loc[0, "revenue_share_pct"]
    finish(fig, ax, f"The top 10% of sellers earn {top:.0f}% of marketplace revenue",
           f"Revenue share by seller decile ({int(d['sellers'].sum()):,} sellers with delivered orders)", "06_seller_concentration")


def linkedin_card():
    d = pd.read_csv(RES / "14b_lateness_buckets.csv")
    d["label"] = d["bucket"].str.replace(r"^\d\.\s", "", regex=True).str.replace(" days", "d").str.replace("On the estimated day", "On the day")
    fig = plt.figure(figsize=(7.5, 3.92))
    ax = fig.add_axes([0.07, 0.2, 0.9, 0.5])
    colors = [BLUE, BLUE, BLUE, RED, RED, RED]
    ax.bar(d["label"], d["avg_review_score"], color=colors, width=0.62)
    for i, v in enumerate(d["avg_review_score"]):
        ax.text(i, v + 0.1, f"{v:.1f}", ha="center", fontsize=10, fontweight="bold")
    ax.set_ylim(0, 5.3)
    ax.set_yticks([])
    ax.spines["left"].set_visible(False)
    plt.setp(ax.get_xticklabels(), fontsize=7.5)
    fig.text(0.07, 0.93, "Reviews fall from 4.3 stars to 1.7 as delivery slips past the promise", fontsize=12.5, fontweight="bold", va="top")
    fig.text(0.07, 0.84, "Average review score by delivery date vs. the promised date  |  96K orders, Olist Brazilian e-commerce", fontsize=7.5, color=MUTED, va="top")
    fig.text(0.07, 0.04, "Analysis: SQL (DuckDB) + Python  |  github.com/AttaUllahHub/olist-ecommerce-analytics", fontsize=7, color=MUTED)
    fig.savefig(FIG / "linkedin_card.png", dpi=160)
    plt.close(fig)


if __name__ == "__main__":
    for fn in [monthly_revenue, categories, retention, lateness, late_by_state, sellers, linkedin_card]:
        fn()
    print(sorted(p.name for p in FIG.glob("*.png")))
