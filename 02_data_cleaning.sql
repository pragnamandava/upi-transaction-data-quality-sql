create table upi_transactions_staging as
select * from raw_upi_transactions;
select * from upi_transactions_staging;
#duplicate identification
select transaction_id,transaction_date,payer_upi_id,payee_upi_id,amount,transaction_status,payer_bank,payee_bank,merchant_flag,
row_number()over(partition by transaction_id,transaction_date,payer_upi_id,payee_upi_id,amount,transaction_status,payer_bank,payee_bank,merchant_flag)
from upi_transactions_staging;
# next step no duplicate removal directly 1. may delete wrong record before cleaning,formats may differ,business rules b4 deleting 

#checking transaction_id
select transaction_id,length(transaction_id)
from upi_transactions_staging;
#date
select transaction_date from upi_transactions_staging;
#valid payer upi id
select payer_upi_id 
from upi_transactions_staging
where payer_upi_id not  regexp'^[A-Za-z]+@[A-Za-z]+$'or NULL;
#valid payee upi id 
select payee_upi_id 
from upi_transactions_staging
where payee_upi_id not  regexp'^[A-Za-z]+@[A-Za-z]+$'or NULL;
#amount 
select *
from upi_transactions_staging
where amount<=0;
#transaction status
select transaction_status
from upi_transactions_staging
where transaction_status not like '%success'or NULL;
select * from upi_transactions_staging;
select payer_bank
from upi_transactions_staging;
 use upi;
 #cleaning
 create table upi_transactions_clean as with cleaning as(
select transaction_id,
case
when transaction_date regexp'^[0-9]{2}-[0-9]{2}-[0-9]{4}$' then str_to_date(transaction_date,'%d-%m-%Y')
when transaction_date regexp'^[0-9]{4}/[0-9]{2}/[0-9]{2}$' then str_to_date(transaction_date,'%Y/%m/%d')
when transaction_date regexp'^[0-9]{2}-[0-9]{4}-[0-9]{2}$' then str_to_date(transaction_date,'%d-%Y-%m')
when transaction_date regexp'^[A-Za-z]+-[0-9]{2}-[0-9]{4}$' then str_to_date(transaction_date,'%M-%d-%Y')
when transaction_date regexp'^[0-9]{2}/[0-9]{2}/[0-9]{2}$' then str_to_date(transaction_date,'%d/%m/%Y')
else null
end as cleaned_date
,
case 
when payer_upi_id is  null or payer_upi_id not regexp'^[A-Za-z]+@[A-Za-z]+$'  
then null 
else payer_upi_id
end as cleaned_payer_upi_id
,case 
when payee_upi_id is  null or payee_upi_id not regexp'^[A-Za-z]+@[A-Za-z]+$'  
then null 
else payee_upi_id
end as cleaned_payee_upi_id,
case
when amount<=0 then null 
else amount
end as cleaned_amount
,
case
when transaction_status='completed' then 'SUCCESS'
else transaction_status
end as cleaned_transaction_status
,trim(payer_bank) as cleaned_payer_bank,trim(payee_bank) as cleaned_payee_bank,
case
  when merchant_flag in ('Y','N') then merchant_flag
  else null
end as cleaned_merchant_flag
from upi_transactions_staging),
dup as( select transaction_id,cleaned_Date,cleaned_payer_upi_id,cleaned_payee_upi_id,cleaned_amount,cleaned_transaction_status,cleaned_payer_bank,cleaned_payee_bank,cleaned_merchant_flag,
row_number() over(partition by transaction_id,cleaned_Date,cleaned_payer_upi_id,cleaned_payee_upi_id,cleaned_amount,cleaned_transaction_status,cleaned_payer_bank,cleaned_payee_bank,cleaned_merchant_flag) as rn
from cleaning),
final as
( select transaction_id,cleaned_Date,cleaned_payer_upi_id,cleaned_payee_upi_id,cleaned_amount,cleaned_transaction_status,cleaned_payer_bank,cleaned_payee_bank,cleaned_merchant_flag 
from dup 
where rn=1)
select * from final;
select * from upi_transactions_clean;