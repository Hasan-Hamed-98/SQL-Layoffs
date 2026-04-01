# 🧹 Data Cleaning Explanation

## 📌 Overview

Raw datasets often contain inconsistencies, duplicates, and missing values that can lead to misleading analysis.
This project applies a structured data cleaning pipeline to ensure accuracy and reliability before performing analysis.

---

## 🔁 Step 1: Creating a Staging Table

A staging table (`layoffs_staging`) was created to preserve the original dataset.

**Why this matters:**

* Prevents accidental modification of raw data
* Allows safe experimentation and debugging
* Follows best practices used in real-world data workflows

---

## 🧹 Step 2: Removing Duplicates

Duplicates were identified using a window function:

* `ROW_NUMBER()` partitioned by all relevant columns
* Rows with `row_num > 1` were removed

**Why this matters:**

* Duplicate records inflate metrics (e.g., total layoffs)
* Ensures each record represents a unique event

---

## 🧼 Step 3: Standardizing Data

### 3.1 Trimming Text Fields

* Removed leading/trailing spaces in company names using `TRIM()`

**Reason:**
Prevents duplicate entries caused by inconsistent formatting.

---

### 3.2 Normalizing Industry Values

* Unified variations like:

  * "Crypto"
  * "Crypto Currency"
  * "CryptoCurrency"

**Reason:**
Different labels for the same category distort aggregation results.

---

### 3.3 Fixing Country Inconsistencies

* Standardized values such as:

  * "United States" vs "United States."

**Reason:**
Ensures accurate grouping and country-level analysis.

---

### 3.4 Converting Date Format

* Converted `date` from string to `DATE` type using `STR_TO_DATE()`

**Reason:**

* Enables time-based analysis (monthly, yearly trends)
* Improves query performance and consistency

---

## ⚠️ Step 4: Handling Missing Values

### 4.1 Identifying Missing Data

* Checked for `NULL` and blank values in key columns:

  * `industry`
  * `total_laid_off`
  * `percentage_laid_off`

---

### 4.2 Filling Missing Industry Values

* Used a self-join to populate missing industries based on other records of the same company and location

**Reason:**

* Maintains data completeness without introducing assumptions
* Uses existing data instead of external guesses

---

### 4.3 Limitations

* Some fields (e.g., layoffs count) could not be inferred reliably
* These were left as NULL or removed if unusable

---

## 🗑️ Step 5: Removing Irrelevant Records

* Deleted rows where both:

  * `total_laid_off` is NULL
  * `percentage_laid_off` is NULL

**Reason:**

* These records provide no analytical value
* Removing them improves dataset quality

---

## 🧱 Step 6: Final Cleanup

* Dropped helper column (`row_num`) after deduplication

**Reason:**

* Keeps the final dataset clean and production-ready

---

## ✅ Final Result

The cleaned dataset:

* Contains no duplicates
* Has consistent categorical values
* Uses proper data types
* Minimizes missing or unusable data

This ensures reliable and accurate exploratory data analysis.

---

## 💡 Key Takeaway

Data cleaning is a critical step in any data analytics project.
Well-cleaned data leads to:

* More accurate insights
* Better decision-making
* Increased trust in results
