WITH paid_orders as (select Orders.ID as order_id,
    Orders.USER_ID	as customer_id,
    Orders.ORDER_DATE AS order_placed_at,
        Orders.STATUS AS order_status,
    p.total_amount_paid,
    p.payment_finalized_date,
    C.FIRST_NAME    as customer_first_name,
        C.LAST_NAME as customer_last_name
FROM raw.jaffle_shop.orders as Orders
left join (select ORDERID as order_id, max(CREATED) as payment_finalized_date, sum(AMOUNT) / 100.0 as total_amount_paid
        from raw.stripe.payment
        where STATUS <> 'fail'
        group by 1) p ON orders.ID = p.order_id
left join raw.jaffle_shop.customers C on orders.USER_ID = C.ID ),

customer_orders 
as (select C.ID as customer_id
    , min(ORDER_DATE) as first_order_date
    , max(ORDER_DATE) as most_recent_order_date
    , count(ORDERS.ID) AS number_of_orders
from raw.jaffle_shop.customers C 
left join raw.jaffle_shop.orders as Orders
on orders.USER_ID = C.ID 
group by 1)

select
p.*,
ROW_NUMBER() OVER (ORDER BY p.order_id) as transaction_seq,
ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY p.order_id) as customer_sales_seq,
CASE WHEN c.first_order_date = p.order_placed_at
THEN 'new'
ELSE 'return' END as nvsr,
x.clv_bad as customer_lifetime_value,
c.first_order_date as fdos
FROM paid_orders p
left join customer_orders as c USING (customer_id)
LEFT OUTER JOIN 
(
        select
        p.order_id,
        sum(t2.total_amount_paid) as clv_bad
    from paid_orders p
    left join paid_orders t2 on p.customer_id = t2.customer_id and p.order_id >= t2.order_id
    group by 1
    order by p.order_id
) x on x.order_id = p.order_id
ORDER BY order_id

----------------------
with 
    paid_orders as (
        select orders.id as order_id,
            orders.user_id as customer_id,
            orders.order_date as order_placed_at,
            orders.status as order_status,
            p.total_amount_paid,
            p.payment_finalized_date,
            c.first_name as customer_first_name,
            c.last_name as customer_last_name
        from {{ source('jaffle_shop', 'orders') }} as orders
        left join (
            select 
                orderid as order_id,
                max(created) as payment_finalized_date,
                sum(amount) / 100.0 as total_amount_paid
            from {{ source('stripe', 'payment') }} as payments
            where status <> 'fail'
            group by 1
        ) p on orders.id = p.order_id
        left join {{ source('jaffle_shop', 'customers') }} as c on orders.user_id = c.id ),

    customer_orders as (
        select 
            c.id as customer_id
            , min(order_date) as first_order_date
            , max(order_date) as most_recent_order_date
            , count(orders.id) as number_of_orders
        from {{ source('jaffle_shop', 'customers') }}  c 
        left join {{ source('jaffle_shop', 'orders') }}  as orders on orders.user_id = c.id 
        group by 1
    )         

    select
        p.*,
        row_number() over (order by p.order_id) as transaction_seq,
        row_number() over (partition by customer_id order by p.order_id) as customer_sales_seq,
        case when c.first_order_date = p.order_placed_at
        then 'new'
        else 'return' end as nvsr,
        x.clv_bad as customer_lifetime_value,
        c.first_order_date as fdos
    from paid_orders p
    left join customer_orders as c using (customer_id)
    left outer join 
    (
        select
            p.order_id,
            sum(t2.total_amount_paid) as clv_bad
        from paid_orders p
        left join paid_orders t2 on p.customer_id = t2.customer_id and p.order_id >= t2.order_id
        group by 1
        order by p.order_id
    ) x on x.order_id = p.order_id
    order by order_id
    ----------------------------------
    with 

-- Import CTEs

customers as (

  select * from {{ source('jaffle_shop', 'customers') }}

),

orders as (

  select * from {{ source('jaffle_shop', 'orders') }}

),

payments as (

  select * from {{ source('stripe', 'payment') }}

),

-- Logical CTEs
-- Final CTE
-- Simple Select Statment


paid_orders as (
    select orders.id as order_id,
        orders.user_id as customer_id,
        orders.order_date as order_placed_at,
        orders.status as order_status,
        p.total_amount_paid,
        p.payment_finalized_date,
        c.first_name as customer_first_name,
        c.last_name as customer_last_name
    from orders
    left join (
        select 
            orderid as order_id,
            max(created) as payment_finalized_date,
            sum(amount) / 100.0 as total_amount_paid
        from payments
        where status <> 'fail'
        group by 1
    ) p on orders.id = p.order_id
    left join customers as c on orders.user_id = c.id ),

customer_orders as (
    select 
        c.id as customer_id
        , min(order_date) as first_order_date
        , max(order_date) as most_recent_order_date
        , count(orders.id) as number_of_orders
    from customers as c 
    left join orders on orders.user_id = c.id 
    group by 1
)

select
    p.*,
    row_number() over (order by p.order_id) as transaction_seq,
    row_number() over (partition by customer_id order by p.order_id) as customer_sales_seq,
    case when c.first_order_date = p.order_placed_at
    then 'new'
    else 'return' end as nvsr,
    x.clv_bad as customer_lifetime_value,
    c.first_order_date as fdos
from paid_orders p
left join customer_orders as c using (customer_id)
left outer join 
(
    select
        p.order_id,
        sum(t2.total_amount_paid) as clv_bad
    from paid_orders p
    left join paid_orders t2 on p.customer_id = t2.customer_id and p.order_id >= t2.order_id
    group by 1
    order by p.order_id
) x on x.order_id = p.order_id
order by order_id

--------------------
with

-- Import CTEs

customers as (

  select * from {{ ref('stg_jaffle_shop__customers') }}

),

orders as (

  select * from {{ ref('stg_jaffle_shop__orders') }}

),

payments as (

  select * from {{ ref('stg_stripe__payments') }}

),

-- Logical CTEs

completed_payments as (

  select 
    order_id,
    max(payment_created_at) as payment_finalized_date,
    sum(payment_amount) as total_amount_paid
  from payments
  where payment_status <> 'fail'
  group by 1

),

paid_orders as (

  select 
    orders.order_id,
    orders.customer_id,
    orders.order_placed_at,
    orders.order_status,

    completed_payments.total_amount_paid,
    completed_payments.payment_finalized_date,

    customers.customer_first_name,
    customers.customer_last_name
  from orders
  left join completed_payments on orders.order_id = completed_payments.order_id
  left join customers on orders.customer_id = customers.customer_id

),

-- Final CTE

final as (

  select
    order_id,
    customer_id,
    order_placed_at,
    order_status,
    total_amount_paid,
    payment_finalized_date,
    customer_first_name,
    customer_last_name,

    -- sales transaction sequence
    row_number() over (order by order_id) as transaction_seq,

    -- customer sales sequence
    row_number() over (partition by customer_id order by order_id) as customer_sales_seq,

    -- new vs returning customer
    case  
      when (
      rank() over (
      partition by customer_id
      order by order_placed_at, order_id
      ) = 1
    ) then 'new'
    else 'return' end as nvsr,

    -- customer lifetime value
    sum(total_amount_paid) over (
      partition by customer_id
      order by order_placed_at
      ) as customer_lifetime_value,

    -- first day of sale
    first_value(order_placed_at) over (
      partition by customer_id
      order by order_placed_at
      ) as fdos

    from paid_orders
		
)

-- Simple Select Statement

select * from final
order by order_id
