with monthly as (
    select * from {{ ref('int_customer_monthly_spend') }}
),

customer_summary as (
    select
        account_id,
        customer_id,
        account_type,
        sum(total_spend)                as lifetime_spend,
        avg(total_spend)                as avg_monthly_spend,
        count(distinct transaction_month) as active_months,
        max(total_spend)                as best_month_spend,
        count(distinct merchant_category) as categories_used
    from monthly
    group by 1, 2, 3
),

segmented as (
    select
        *,
        case
            when avg_monthly_spend >= 5000 then 'Premium'
            when avg_monthly_spend >= 2000 then 'High Value'
            when avg_monthly_spend >= 500  then 'Regular'
            else 'Low Activity'
        end as customer_segment
    from customer_summary
)

select * from segmented
