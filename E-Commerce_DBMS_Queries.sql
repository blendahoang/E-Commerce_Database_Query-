#Dataset Creation
use HW;

select * from HW.sql_import;

drop table transaction_data;
drop table product_data;
drop table customer_data;
drop table order_data;
drop table shipping_data;

create table product_data(
ItemNumber varchar(250) primary key,
Brand text, 
Description text, 
Price double);

create table customer_data(
Email varchar(250) primary key, 
PaymentMethod text, 
BillTo text,
BillingAddress text,
BillingCity text,
BillingState text,
BillingZipCode text, 
ShipTo text, 
ShippingName text, 
ShippingAddress text,
ShippingCity text, 
ShippingState text,
ShippingZipCode text);

create table order_data(
OrderNumber int primary key, 
OrderDateTime text, 
OrderStatus text);

create table shipping_data(
ShippingMethod varchar(250) primary key,
ShippingCost int);

create table transaction_data(
RecordNumber varchar(250) primary key, 
OrderNumber int, 
Color text, 
Size text, 
Qty int, 
ItemNumber varchar(250), 
EstimatedTax double, 
OrderTotal double, 
ShipTo text, 
ShippingMethod varchar(250), 
Email varchar(250),
constraint FK_1 foreign key (OrderNumber) references order_data (OrderNumber), 
constraint FK_2 foreign key (ItemNumber) references product_data (ItemNumber), 
constraint FK_3 foreign key (ShippingMethod) references shipping_data (ShippingMethod),
constraint FK_4 foreign key (Email) references customer_data (Email)); 

insert into product_data
(ItemNumber, Brand, Description, Price) 
select distinct(ItemNumber), Brand, Description, Price from HW.sql_import;

insert into customer_data 
(Email, PaymentMethod, BillTo, BillingAddress, BillingCity, BillingState, BillingZipCode, 
ShipTo, ShippingName, ShippingAddress, ShippingCity, ShippingState, ShippingZipCode)
select distinct(Email), PaymentMethod, BillTo, BillingAddress, BillingCity, BillingState, 
BillingZipCode, ShipTo, ShippingName, ShippingAddress, ShippingCity, ShippingState, 
ShippingZipCode from HW.sql_import;

insert into order_data
(OrderNumber, OrderDateTime, OrderStatus)
select distinct(OrderNumber), OrderDateTime, OrderStatus from HW.sql_import;

insert into shipping_data
(ShippingMethod, ShippingCost)
select distinct(ShippingMethod), ShippingCost from HW.sql_import;

insert into transaction_data
(RecordNumber, OrderNumber, Color, Size, Qty, ItemNumber, EstimatedTax, OrderTotal, ShipTo, 
ShippingMethod, Email)
select RecordNumber, OrderNumber, Color, Size, Qty, ItemNumber, EstimatedTax, OrderTotal, ShipTo, 
ShippingMethod, Email from HW.sql_import;

select * from transaction_data;
select * from product_data;
select * from customer_data;
select * from order_data;
select * from shipping_data;


select RecordNumber, OrderNumber, transaction_data.ItemNumber, Description, Price
	from transaction_data left outer join product_data on
    transaction_data.ItemNumber = product_data.ItemNumber
    order by Price desc;
    
select RecordNumber, OrderNumber, transaction_data.ItemNumber, Description, Price
	from transaction_data right outer join product_data on
    transaction_data.ItemNumber = product_data.ItemNumber
    order by OrderNumber desc;

#SQL and Views

select OrderStatus, count(*) from order_data
group by OrderStatus;

select ShipTo, round(avg(OrderTotal),2) as Avg_Order_Amount from transaction_data
group by ShipTo;

select OrderNumber, round(sum(OrderTotal),2) as Total_Order_Amount  from transaction_data
group by OrderNumber;

select
	count(case when PaymentMethod like '%Visa%' then 1 else null end) as Visa,
	count(case when PaymentMethod like '%Gift%' then 1 else null end) as Gift_Card,
	count(case when PaymentMethod like '%Nordstrom%' then 1 else null end) as Nordstrom_Note 
from customer_data;

update shipping_data
set ShippingCost = 8
where ShippingCost = 10;
select * from shipping_data;

update product_data
set Price = round(Price * 0.75,2)
where Brand like '%Ferm%';
select * from product_data;

select sum(case when Size = 'One Size' then 1 else 0 end) / count(size) as Ratio_OneSize_Items
from transaction_data;

select sum(OrderTotal) / count(OrderTotal) as Total_Avg_Order
from transaction_data;

select Brand, Description, Price,
case 
	when price > 500 then 'High Tier'
    when (price < 500) and (price > 100) then 'Mid Tier'
    else 'Low Tier'
end as Ranking
from product_data
order by Price desc;

select count(Email),
case 
	when email like "%gmail%" then "Gmail_User"
    when email like "%aol%" then "AOL_User"
    when email like "%hotmail%" then "Hotmail_User"
    when email like "%yahoo%" then "Yahoo_User"
    else "N/A"
    end as Email_List
	from Customer_data
    group by Email_List;

drop view SanJose_customers;
drop view Low_Tier_Items;

create view SanJose_Customers as
select email, billingaddress, shippingaddress
from customer_data
where billingcity like '%San Jose%';
select * from SanJose_Customers;

create view Low_Tier_Items as
select ItemNumber, Brand, Description, Price
from product_data
where Price < 100;
select * from Low_Tier_Items;

#Joins & Subquery 

select ShippingState, Brand, pd.ItemNumber
from customer_data as cd
inner join transaction_data as td
on cd.email = td.email
inner join product_data as pd
on pd.ItemNumber = td.ItemNumber
having ShippingState = 'CA'
order by 1 asc;

select ShippingState, OrderStatus
from customer_data as cd
inner join transaction_data as td
on cd.email = td.email
inner join order_data as od
on od.OrderNumber = td.OrderNumber
where OrderStatus = 'In Process'
order by 1 asc;

select ShipTo, td.OrderNumber, td.ItemNumber, Brand, Description 
from transaction_data td, product_data pd 
where td.ItemNumber = pd.ItemNumber
and Brand = 'BAREFOOT DREAMS'
limit 10;

select OrderNumber, PaymentMethod
from customer_data as cd
inner join transaction_data as td
on cd.email = td.email
where (PaymentMethod like 'Visa%' or PaymentMethod like 'Note%')
and BillingState in (
	select BillingState
    from customer_data
    where BillingState = 'CA'
);

select OrderDateTime, od.OrderNumber, Brand, Color
from order_data od
inner join transaction_data td on od.OrderNumber = td.OrderNumber
inner join product_data pd on td.ItemNumber = pd.ItemNumber
where month(STR_TO_DATE(`OrderDateTime`, '%m/%d/%Y')) = 2;

























