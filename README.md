![MySQL](https://img.shields.io/badge/SQL-MySQL-blue)


# UPI Transaction Data Quality & Cleaning Using SQL

## Project Overview
This project is based on a simulated UPI transaction dataset that contains common real-world data quality problems such as invalid formats, duplicates, missing values, and business rule violations.

The goal of the project is to clean and standardize raw transaction data using SQL and to clearly separate valid records from rejected ones in an auditable way.

---

## Business Context
In digital payment systems like UPI, even small data quality issues can cause:
- Incorrect financial reports
- Reconciliation mismatches
- Compliance and audit problems
- Incorrect analytical insights

This project focuses on how a data analyst would approach raw transactional data before using it for reporting or analysis.

---

## Dataset Details
**Source Table:** `raw_upi_transactions`

| Column | Description |
|------|------------|
| transaction_id | Transaction reference number |
| transaction_date | Date in multiple raw formats |
| payer_upi_id | Sender UPI ID |
| payee_upi_id | Receiver UPI ID |
| amount | Transaction amount |
| transaction_status | Status of the transaction |
| payer_bank | Payer bank name |
| payee_bank | Payee bank name |
| merchant_flag | Merchant indicator (Y/N) |

---

## Data Quality Issues Identified
- Inconsistent and invalid date formats
- Invalid or missing payer and payee UPI IDs
- Zero and negative transaction amounts
- Unsupported transaction status values
- Duplicate transactions
- Invalid merchant flag values
- Records containing multiple issues at the same time

---

## Tools Used
- MySQL
- Common Table Expressions (CTEs)
- Window functions (`ROW_NUMBER`)
- Regular expressions for validation
- SQL-based data cleaning logic

---

## Data Processing Steps

### Step 1: Raw Data Ingestion
Raw UPI transaction data was loaded into a staging table without any modification.

### Step 2: Data Profiling
Initial checks were performed to identify duplicates, invalid formats, null values, and rule violations.
No records were deleted at this stage.

### Step 3: Data Cleaning
- Standardized multiple date formats
- Validated UPI ID patterns using regex
- Replaced invalid transaction amounts with NULL
- Normalized transaction status values
- Trimmed and standardized bank names

### Step 4: Deduplication
Duplicates were identified using `ROW_NUMBER()` over business-relevant columns.
Only the first valid occurrence was retained.

### Step 5: Clean Data Output
Validated and deduplicated records were stored in `upi_transactions_clean`.

### Step 6: Rejection Handling
Invalid records were stored in a `rejection_table` along with detailed rejection reasons.
Multiple rejection reasons were captured for a single record where applicable.

---

## Output Tables

### Clean Table
**`upi_transactions_clean`**  
Contains only valid, analytics-ready UPI transactions.

### Rejection Table
**`rejection_table`**  
Contains rejected records with reasons such as:
- invalid_date
- invalid_payer_upi_id
- invalid_payee_upi_id
- invalid_amount
- invalid_merchant_flag
- duplicate
## Sample Rejection Logic
```sql
concat_ws(',',
  if(cleaned_date is null,'invalid_date',null),
  if(payer_upi_id is null or payer_upi_id not regexp '^[A-Za-z]+@[A-Za-z]+$','invalid_payer_upi_id',null),
  if(payee_upi_id is null or payee_upi_id not regexp '^[A-Za-z]+@[A-Za-z]+$','invalid_payee_upi_id',null),
  if(amount <= 0,'invalid_amount',null),
  if(rn > 1,'duplicate',null)
  )
```

## Key Takeaways

- Importance of staging tables in real data pipelines  
- Validating data before deletion or transformation  
- Handling multiple data quality issues in a single record  
- Using window functions for controlled deduplication  
- Maintaining rejection tables for audit and traceability  

---

## Possible Improvements

- Add reference tables for bank validation  
- Automate quality checks using stored procedures  
- Build dashboards on top of cleaned data  
- Extend logic to support incremental data loads  

---

## Use Case

This project reflects real-world fintech data challenges and demonstrates SQL skills related to data cleaning, validation, ETL fundamentals, and analytics readiness.


