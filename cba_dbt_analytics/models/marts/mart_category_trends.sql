with monthly as (
    select * from {{ ref('int_customer_monthly_spend') }}
),

trends as (
    select
        transaction_month,
        merchant_category,
        sum(transaction_count)          as total_transactions,
        sum(total_spend)                as total_spend,
        avg(avg_spend)                  as avg_transaction_value,
        count(distinct account_id)      as unique_customers,
        sum(total_spend) / nullif(count(distinct account_id), 0) as spend_per_customer
    from monthly
    group by 1, 2
)

select * from trends
order by transaction_month desc, total_spend desc
