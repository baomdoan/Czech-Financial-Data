SELECT count(type) total_card, type
FROM new_card
GROUP BY type
ORDER BY total_card DESC;
/* Most common card type in each of district and how many are from each 
card related to disp via disp_id, and account_id to new account and district_id to new district */

SELECT district.district_id dcode, card.type
FROM new_account acct
INNER JOIN new_disp disp
ON acct.account_id = disp.account_id
INNER JOIN new_card card
ON disp.disp_id = card.disp_id
INNER JOIN new_district district
ON acct.district_id = district.district_id;

/* Update the tables by changing the Czech languages into English*/

UPDATE new_account
SET frequency = 'Monthly Issued'
WHERE frequency = 'POPLATEK MESICNE';

UPDATE new_trans
SET transaction_type = (CASE WHEN transaction_type = 'PRIJEM' THEN 'Credit'
					    WHEN transaction_type = 'VYDAJ' THEN 'Withdrawal'
                        END),
operation = (CASE WHEN operation = 'VYBER KRATOU' THEN 'Credit Card Withdrawal'
					  WHEN operation = 'VKLAD' THEN 'Credit In Cash'
                      WHEN operation = 'PREVOD Z UCTU' THEN 'Collection From Another Bank'
                      WHEN operation = 'VYBER' THEN 'Cash Withdrawal'
                      ELSE 'Remittance To Another Bank'
                      END),
 k_symbol = (CASE WHEN k_symbol = 'POJISTNE' THEN 'Isurance Payment'
					 WHEN k_symbol = 'SLUZBY' THEN 'Payment For Statement'
                     WHEN k_symbol = 'UROK' THEN 'Interest Credited'
                     WHEN k_symbol = 'SANKC.UROK' THEN 'Sanction Interest if Negative Balannce'
                     WHEN k_symbol = 'SIPO' THEN 'Household'
                     WHEN k_symbol = 'DUCHOD' THEN 'Old-Age Pension'
                     WHEN k_symbol = 'UVER' THEN 'Loan Payment'
                     ELSE 'NULL'
                     END)
WHERE transaction_type in ('PRIJEM','VYDAJ') AND
operation in ('VYBER KRATOU','VKALD','PREVOD Z UCTU','VYBER','PREVOD NA UCET') AND
k_symbol in ('POJISTNE','SLUZBY','UROK','SANKC.UROK','SIPO','DUCHOD','UVER');

UPDATE new_trans
SET transaction_type = 'Cash Withdrawal'
WHERE transaction_type = 'VYBER';

UPDATE new_trans
SET operation = 'Remittance To Another Bank'
WHERE operation = 'PREVOD NA UCET';

/* build client and # of transaction
client to district to account and to transaction */

SELECT count(tran_id), client_id
FROM new_account acnt
INNER JOIN new_district dist
ON acnt.district_id = dist.district_id
INNER JOIN new_trans trans
ON acnt.account_id = trans.account_id
INNER JOIN new_client clnt
ON dist.district_id = clnt.district_id
GROUP BY client_id;

/* 'junior' card and avg amount of transaction
card to dist to account to trans */

SELECT AVG(amount) avg_transaction, card.type type_of_card
FROM new_account acnt
INNER JOIN new_disp disp
ON acnt.account_id = disp.account_id
INNER JOIN new_trans trans
ON acnt.account_id = trans.account_id
INNER JOIN new_card card
ON disp.disp_id = card.disp_id
WHERE card.type = 'junior'
GROUP BY type_of_card;

/* client average amount of transaction have been made after jan 1st 1995 
client to district to account then to trans */

SELECT AVG(trans.amount) average_transaction, clnt.client_id client_id, trans.date transaction_date
FROM new_account acnt
INNER JOIN new_district dist
ON acnt.district_id = dist.district_id
INNER JOIN new_trans trans
ON acnt.account_id = trans.account_id
INNER JOIN new_client clnt
ON dist.district_id = clnt.district_id
WHERE trans.date > 950101
GROUP BY client_id;

/* min and max transaction amount for each client*/

SELECT min(trans.amount), max(trans.amount), client_id
FROM new_account acnt
INNER JOIN new_district dist
ON acnt.district_id = dist.district_id
INNER JOIN new_trans trans
ON acnt.account_id = trans.account_id
INNER JOIN new_client clnt
ON dist.district_id = clnt.district_id
GROUP BY client_id;

SELECT AVG(new_trans.amount), max(new_trans.amount), new_trans.account_id
FROM new_trans
GROUP BY new_trans.account_id;

SELECT AVG(new_trans.amount), max(new_trans.amount), new_trans.account_id acc_id
FROM new_trans
WHERE new_trans.account_id = 1
GROUP BY new_trans.account_id;

SELECT AVG(new_trans.amount), max(new_trans.amount)
FROM new_trans;
/* Sum of transaction amount and only customers whose amount is above certain threshold.
amount and account_id fields from new_trans.
*/
SELECT SUM(new_trans.amount) total_amount, new_trans.account_id
FROM new_trans
GROUP BY new_trans.account_id
HAVING SUM(new_trans.amount) > 500000;

SELECT SUM(new_trans.amount) total_amount, new_trans.account_id
FROM new_trans
GROUP BY new_trans.account_id
HAVING total_amount > 500000;

SELECT SUM(new_trans.amount) total_amount, new_trans.account_id
FROM new_trans
WHERE new_trans.amount >500000
GROUP BY new_trans.account_id;

/*describe behaviour of ppl that have problem with paying their loans
Thought process: loans problem >> salary, area of living?, the amount of balance? Late payment?
*/

SELECT accnt.account_id,trxn.date, trxn.balance,
       loan.monthly_payments,loan.loan_status,
       MAX(CASE WHEN trxn.balance>0 THEN trxn.balance END) max_positive,
       MAX(CASE WHEN trxn.balance<0 THEN trxn.balance END) max_negative,
       COUNT(CASE WHEN trxn.balance<0 THEN trxn.balance END) total_negative
FROM new_order od
INNER JOIN new_account accnt
ON od.account_id = accnt.account_id
INNER JOIN new_loan loan
ON accnt.account_id = loan.account_id
INNER JOIN new_trans trxn
ON accnt.account_id = trxn.account_id
WHERE loan.loan_status='In Debt' OR loan.loan_status='Ongoing'
	  OR loan.loan_status='Loan Not Paid'
GROUP BY trxn.account_id
ORDER BY trxn.account_id;


SELECT *
FROM new_order od
INNER JOIN new_account accnt
ON od.account_id = accnt.account_id
INNER JOIN new_loan loan
ON accnt.account_id = loan.account_id
INNER JOIN new_trans trxn
ON accnt.account_id = trxn.account_id;

SELECT *
FROM new_loan;

SELECT *
FROM new_trans;
