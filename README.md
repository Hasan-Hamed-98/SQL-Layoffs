# 🌍 World Layoffs Data Analysis (SQL Project)

## 📌 Overview

This project analyzes global layoffs data from 2020 to 2023 using SQL.
It demonstrates a complete data analytics workflow, including:

* Data cleaning and preprocessing
* Handling missing and inconsistent data
* Exploratory data analysis (EDA)
* Extracting business insights

---

## 🧰 Tools & Skills Used

* SQL (MySQL)
* Data Cleaning Techniques
* Window Functions (`ROW_NUMBER`, `DENSE_RANK`)
* Common Table Expressions (CTEs)
* Aggregations & Grouping
* Date transformations

---

## 📂 Dataset

The dataset contains information about layoffs across companies worldwide, including:

* Company name
* Industry
* Location & country
* Total employees laid off
* Percentage laid off
* Date
* Funding stage

---

## 🧹 Data Cleaning Process

Key steps performed:

1. Created a staging table to preserve raw data
2. Removed duplicate records using `ROW_NUMBER()`
3. Standardized data:

   * Trimmed company names
   * Unified industry values (e.g., Crypto variations)
   * Fixed country inconsistencies
4. Converted date column from string to DATE format
5. Handled missing values:

   * Filled missing industries using self-joins
6. Removed irrelevant records (null layoffs data)

---

## 📊 Exploratory Data Analysis

Key analyses performed:

* Companies with the highest layoffs
* Industries most affected by layoffs
* Countries with the highest layoffs
* Monthly and cumulative layoff trends
* Top companies by layoffs per year using ranking

---

## 🔍 Key Insights

* Tech companies had the highest layoffs, especially in 2022–2023
* Consumer and retail industries were heavily impacted
* The United States led in total layoffs globally
* Layoffs peaked between late 2022 and early 2023

---

## 📈 Example Queries

### Top Companies by Total Layoffs

```sql
SELECT company, SUM(total_laid_off) AS total
FROM layoffs_staging2
GROUP BY company
ORDER BY total DESC;
```

### Rolling Layoff Trend

```sql
WITH monthly AS (
    SELECT DATE_FORMAT(date, '%Y-%m') AS month,
           SUM(total_laid_off) AS total
    FROM layoffs_staging2
    GROUP BY month
)
SELECT month,
       total,
       SUM(total) OVER (ORDER BY month) AS rolling_total
FROM monthly;
```

---

## 🚀 Future Improvements

* Add dashboards using Tableau or Power BI
* Perform year-over-year trend analysis
* Analyze layoffs by funding stage
* Build predictive models for layoff trends

---

## 👤 Author

**Hasan Hamed**

---

## ⭐ Project Value

This project demonstrates real-world SQL skills required for data analyst roles, including data cleaning, transformation, and analytical thinking.
