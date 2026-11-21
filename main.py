from src import make_figures, run_analysis, stats_tests

if __name__ == "__main__":
    run_analysis.main(show=False)
    stats_tests.run()
    make_figures.monthly_revenue()
    make_figures.categories()
    make_figures.retention()
    make_figures.lateness()
    make_figures.late_by_state()
    make_figures.sellers()
    make_figures.linkedin_card()
    print("Done. Results in reports/results, charts in reports/figures.")
