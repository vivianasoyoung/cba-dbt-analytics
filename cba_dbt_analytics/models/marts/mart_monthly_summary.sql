with monthly as (
    select * from {{ ref('int_customer_monthly_spend') }}
),

summary as (
    select
        transaction_month,
        count(distinct account_id)      as active_accounts,
        count(distinct customer_id)     as active_customers,
        sum(transaction_count)          as total_transactions,
        sum(total_spend)                as total_spend,
        avg(avg_spend)                  as avg_transaction_value
    from monthly
    group by 1
)

select * from summary
order by transaction_month desc
