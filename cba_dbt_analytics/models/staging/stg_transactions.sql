with source as (
    select * from {{ source('raw', 'transactions') }}
),

cleaned as (
    select
        transaction_id,
        account_id,
        transaction_date::date                          as transaction_date,
        date_trunc('month', transaction_date)::date     as transaction_month,
        extract(dow from transaction_date)::int         as day_of_week,
        extract(hour from transaction_date)::int        as hour_of_day,
        abs(amount)                                     as amount,
        transaction_type,
        upper(trim(merchant_name))                      as merchant_name,
        upper(trim(merchant_category))                  as merchant_category,
        upper(trim(merchant_state))                     as merchant_state,
        upper(trim(channel))                            as channel,
        upper(trim(status))                             as status,
        balance_after,
        loaded_at
    from source
    where
        transaction_id is not null
        and amount > 0
        and status != 'DECLINED'
)

select * from cleaned
