#rejection table
CREATE TABLE `rejection_table` (
  `transaction_id` varchar(30) DEFAULT NULL,
  `transaction_date` varchar(20) DEFAULT NULL,
  `payer_upi_id` varchar(50) DEFAULT NULL,
  `payee_upi_id` varchar(50) DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `transaction_status` varchar(20) DEFAULT NULL,
  `payer_bank` varchar(50) DEFAULT NULL,
  `payee_bank` varchar(50) DEFAULT NULL,
  `merchant_flag` char(1) DEFAULT NULL,
  `rejection_reason` varchar(60)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
insert into rejection_table (transaction_id,transaction_date,payer_upi_id,payee_upi_id,amount,transaction_status,payer_bank,payee_bank,merchant_flag,rejection_reason)
with date as(select *,
case
when transaction_date regexp'^[0-9]{2}-[0-9]{2}-[0-9]{4}$' then str_to_date(transaction_date,'%d-%m-%Y')
when transaction_date regexp'^[0-9]{4}/[0-9]{2}/[0-9]{2}$' then str_to_date(transaction_date,'%Y/%m/%d')
when transaction_date regexp'^[0-9]{2}-[0-9]{4}-[0-9]{2}$' then str_to_date(transaction_date,'%d-%Y-%m')
when transaction_date regexp'^[A-Za-z]+-[0-9]{2}-[0-9]{4}$' then str_to_date(transaction_date,'%M-%d-%Y')
when transaction_date regexp'^[0-9]{2}/[0-9]{2}/[0-9]{2}$' then str_to_date(transaction_date,'%d/%m/%Y')
else null
end as cleaned_date
from upi_transactions_staging), 
dedup as( select *,row_number() over(partition by transaction_id,transaction_date,payer_upi_id,payee_upi_id,amount,transaction_status,payer_bank,payee_bank,merchant_flag) as rn
from date),rr as(select transaction_id,transaction_date,payer_upi_id,payee_upi_id,amount,transaction_status,payer_bank,payee_bank,merchant_flag,
concat_ws(',',
if(cleaned_date is null ,'invalid_date',null),
if(payer_upi_id is null or payer_upi_id not regexp'^[A-Za-z]+@[A-Za-z]+$' ,'invalid_payer_upi_id',null), 
if(payee_upi_id is null or payee_upi_id not regexp'^[A-Za-z]+@[A-Za-z]+$' , 'invalid_payee_upi_id',null), 

if( amount<=0 ,'invalid_amount',null),
 if(merchant_flag not in('Y','N') ,'invalid_merchant_flag',null),

if( rn>1 , 'duplicate',null) 
)
as rejection_reason from dedup)
select transaction_id,transaction_date,payer_upi_id,payee_upi_id,amount,transaction_status,payer_bank,payee_bank,merchant_flag,rejection_reason from rr
where rejection_reason  is not null and rejection_reason <> '';
select * from rejection_table;