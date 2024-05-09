
use p_226;
create table Custemer_Data(
customer_id varchar(50),
customer_unique_id varchar(50),
customer_zip_code_prefix int,
customer_city varchar(50),
customer_state varchar(5));

Load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers_dataset.csv"
into table custemer_data 
fields terminated by ','
Optionally enclosed by '"'
Lines terminated by '\n'
ignore 1 rows;

create table Pruduct_Data(
product_id Varchar(50),
product_category_name Varchar(50),
product_name_lenght int,
product_description_lenght int ,
product_photos_qty int,
product_weight_g int,
product_length_cm int, 
product_height_cm int,
product_width_cm int);

Load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_dataset.csv"
into table pruduct_data
fields terminated by ','
Optionally enclosed by '"'
Lines terminated by '\n'
ignore 1 rows;

create table Order_item_data(
order_id varchar(50),
order_item_id int,
product_id varchar(50),
seller_id Varchar(70),
shipping_limit_date timestamp,
price decimal(7,2),
freight_value decimal(5,2));


Load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv"
into table order_item_data
fields terminated by ','
Optionally enclosed by '"'
Lines terminated by '\n'
ignore 1 rows;

create table Order_payment(
order_id Varchar(60),
payment_sequential int,
payment_type Varchar(15),
payment_installments int,
payment_value decimal(7,2));

Load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_payments_dataset.csv"
into table order_payment
fields terminated by ','
Optionally enclosed by '"'
Lines terminated by '\n'
ignore 1 rows;

create table Order_reviews(
review_id varchar(60),
order_id varchar(60),
review_score int);

Load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_reviews_dataset.csv"
into table order_reviews
fields terminated by ','
Optionally enclosed by '"'
Lines terminated by '\n'
ignore 1 rows;

create table seller(
seller_id varchar(60),
seller_zip_code_prefix int,
seller_city varchar(50),
seller_state varchar(5));

Load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_sellers_dataset.csv"
into table seller
fields terminated by ','
Optionally enclosed by '"'
Lines terminated by '\n'
ignore 1 rows;

create table product_category(
product_category_name varchar(80),
product_category_name_english varchar(80));

Load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_category_name_translation.csv"
into table product_category
fields terminated by ','
Optionally enclosed by '"'
Lines terminated by '\n'
ignore 1 rows;

create table Orders(
order_id Varchar(50),
customer_id varchar(50),
order_status varchar(15),
order_purchase_timestamp timestamp,
order_approved_at timestamp,
order_delivered_carrier_date timestamp,
order_delivered_customer_date timestamp,
order_estimated_delivery_date date);

Load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv"
into table orders
fields terminated by ','
Optionally enclosed by '"'
Lines terminated by '\n'
ignore 1 rows

(order_id,customer_id,order_status,order_purchase_timestamp,@order_approved_at,@order_delivered_carrier_date,@order_delivered_customer_date,order_estimated_delivery_date)
SET order_approved_at = NULLIF(@order_approved_at, ''),
order_delivered_carrier_date = NULLIF(@order_delivered_carrier_date, ''),
order_delivered_customer_date=nullif(@order_delivered_customer_date,'');


create table olist_geolocation_dataset(
geolocation_zip_code_prefix int, 
geolocation_lat decimal(12,8), 
geolocation_lng decimal(12,8),
geolocation_city varchar(50),
geolocation_state varchar(20));

Load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_geolocation_dataset.csv"
into table olist_geolocation_dataset
fields terminated by ','
Optionally enclosed by '"'
Lines terminated by '\n'
ignore 1 rows;
 
 
 
 use  p_226;
select sum(payment_value) from order_payment;


    set sql_safe_updates=0;
    
    
alter table orders  add column weekdays_weekends varchar(10);

update orders set weekdays_weekends =
    case
        when dayofweek(order_purchase_timestamp) in (1, 7) then 'weekend'
        else 'weekday'
    end;
    
    
-- kpi1 --

create view kpi1 as
select o.weekdays_weekends, round(sum(p.payment_value),2) as Total_payment from orders o
inner join order_payment p
on o.order_id = p.order_id
group by o.weekdays_weekends;

select * from kpi1;

-- kpi2 --

create view kpi2 as
select p.payment_type, count(r.order_id) as No_of_orders from order_reviews r
left join order_payment p
on r.order_id = p.order_id
where r.review_score =5
group by p.payment_type;

select * from kpi2;

-- kpi3 --


select count(*) from orders;
alter table  orders modify order_delivered_customer_date datetime null;
alter table  orders add column shipping_days int;
update  orders set shipping_days = datediff(order_delivered_customer_date,order_purchase_timestamp);
select * from orders;
desc orders;



create view kpi3 as
select p.product_category_name, round(avg(o.shipping_days)) as avg_shipping_days from orders o
inner join order_item_data i
on o.order_id = i.order_id
inner join pruduct_data p on i.product_id = p.product_id
where p.product_category_name = "pet_shop";
    
select * from kpi3;


-- kpi4 ---

create view kpi4 as
select c.customer_city, avg(i.price) as avg_item_price , avg(p.payment_value) as  avg_payment_value from orders o
inner join custemer_data c on o.customer_id = c.customer_id
inner join order_item_data i on o.order_id = i.order_id
inner join order_payment p on o.order_id = p.order_id
where c.customer_city = "sao paulo"
group by c.customer_city;


select * from kpi4;


-- kpi5 --

create view kpi5 as
select r.review_score ,avg(o.shipping_days), count(o.order_id) from orders o 
inner join order_reviews r
on o.order_id = r.order_id
group by r.review_score
order by review_score;

select * from kpi5;

# ALL KPIs 
select * from kpi1;
select * from kpi2;
select * from kpi3;
select * from kpi4;
select * from kpi5;


