-- V4__Insert_sample_data.sql
-- Insert sample policy holders
INSERT INTO POLICYHOLDERS (POLICYHOLDER_CODE, FIRST_NAME, LAST_NAME, EMAIL, PHONE, ADDRESS, DATE_OF_BIRTH)
VALUES 
    ('PH001', 'John', 'Doe', 'john.doe@email.com', '555-0101', '123 Main St', '1980-01-15'),
    ('PH002', 'Jane', 'Smith', 'jane.smith@email.com', '555-0102', '456 Oak Ave', '1985-03-22'),
    ('PH003', 'Bob', 'Johnson', 'bob.j@email.com', '555-0103', '789 Pine Rd', '1975-11-08');

-- Insert sample policies
INSERT INTO POLICIES (POLICY_NUMBER, POLICYHOLDER_ID, PRODUCT_ID, PREMIUM_AMOUNT, COVERAGE_AMOUNT, START_DATE, END_DATE)
VALUES 
    ('POL-2024-001', 1, 1, 150.00, 100000.00, '2024-01-01', '2025-01-01'),
    ('POL-2024-002', 2, 2, 200.00, 150000.00, '2024-02-01', '2025-02-01'),
    ('POL-2024-003', 3, 1, 175.00, 125000.00, '2024-03-01', '2025-03-01');