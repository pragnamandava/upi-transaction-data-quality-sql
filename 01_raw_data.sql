CREATE TABLE raw_upi_transactions (
    transaction_id VARCHAR(30),
    transaction_date VARCHAR(20),
    payer_upi_id VARCHAR(50),
    payee_upi_id VARCHAR(50),
    amount DECIMAL(10,2),
    transaction_status VARCHAR(20),
    payer_bank VARCHAR(50),
    payee_bank VARCHAR(50),
    merchant_flag CHAR(1)   -- Y or N
);
INSERT INTO raw_upi_transactions VALUES
-- Valid transactions
('TXN1001', '15-08-2023', 'ravi@okhdfcbank', 'amazon@apl', 2500.00, 'SUCCESS', 'HDFC', 'APBL', 'Y'),
('TXN1002', '2023/08/16', 'sita@ybl', 'flipkart@ibl', 1800.50, 'SUCCESS', 'ICICI', 'ICICI', 'Y'),

-- Duplicate transaction
('TXN1002', '2023/08/16', 'sita@ybl', 'flipkart@ibl', 1800.50, 'SUCCESS', 'ICICI', 'ICICI', 'Y'),

-- Invalid date formats
('TXN1003', '16-2023-08', 'manoj@oksbi', 'swiggy@ibl', 950.00, 'SUCCESS', 'SBI', 'ICICI', 'Y'),
('TXN1004', 'Aug-17-2023', 'anu@paytm', 'zomato@paytm', 620.00, 'SUCCESS', 'PAYTM', 'PAYTM', 'Y'),

-- Invalid UPI IDs
('TXN1005', '18-08-2023', 'rajesh123', 'uber@apl', 430.00, 'SUCCESS', 'AXIS', 'APBL', 'Y'),
('TXN1006', '2023/08/19', NULL, 'ola@okaxis', 720.00, 'SUCCESS', 'AXIS', 'AXIS', 'Y'),

-- Negative / zero amount
('TXN1007', '20-08-2023', 'priya@ybl', 'netflix@apl', -299.00, 'SUCCESS', 'ICICI', 'APBL', 'Y'),
('TXN1008', '2023/08/21', 'kiran@oksbi', 'spotify@ibl', 0.00, 'SUCCESS', 'SBI', 'ICICI', 'Y'),

-- Invalid transaction status
('TXN1009', '22-08-2023', 'rahul@paytm', 'bigbasket@apl', 1250.00, 'COMPLETED', 'PAYTM', 'APBL', 'Y'),
('TXN1010', '2023/08/23', 'neha@ybl', 'ajio@ibl', 3100.00, 'IN_PROGRESS', 'ICICI', 'ICICI', 'Y'),

-- Multiple issues in one row
('TXN1011', '23/08/23', 'xyz', 'unknown', -450.00, 'UNKNOWN', 'SBI', 'HDFC', 'N'),

-- Valid P2P transaction
('TXN1012', '24-08-2023', 'arjun@okhdfcbank', 'meena@ybl', 5000.00, 'SUCCESS', 'HDFC', 'ICICI', 'N'),

-- Another duplicate
('TXN1012', '24-08-2023', 'arjun@okhdfcbank', 'meena@ybl', 5000.00, 'SUCCESS', 'HDFC', 'ICICI', 'N');