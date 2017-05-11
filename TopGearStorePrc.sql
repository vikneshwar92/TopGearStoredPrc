select * from INFORMATION_SCHEMA.TABLES

--Creating Customers,Products,Orders,OrderDetails table

Create table Customers(CustomerID numeric(5) not null constraint pk_CustomerID primary key,
                       FirstName varchar(14),LastName varchar(13),
					   Address1 varchar(100),Address2 varchar(100),
					   City varchar(15),State varchar(15),Country varchar(15),
					   Phone varchar(13) not null,Email varchar(100))

Create table Products(ProductID numeric(5) not null constraint pk_ProductID primary key,
                      UnitPrice numeric(5) not null,ProductName varchar(20) not null,
					  ProductDescription varchar(100),AvailableColors varchar(10),
					  Size varchar(15),Color varchar(10),Discount numeric(5),Ranking numeric(5))

Create table OrderDetails(OrderDetailsID numeric(5) NOT NULL constraint pk_OrderDetailsID primary key,
                          OrderID numeric(5) not null,
						  ProductID numeric(5) NOT NULL constraint fk_ProductID foreign key references Products(ProductID),
						  Quantity numeric(5),UnitPrice numeric(5),Discount numeric(5),Size numeric(5),Color VARCHAR(15),
						  RequiredDate DateTime,OrderedDate DateTime,ShippedDate DateTime,Total numeric(5))

Create table Orders(OrderID numeric(5) NOT NULL Constraint pk_OrderID primary key,
                    CustomerID numeric(5) NOT NULL constraint fk_CustomerID foreign key references 
					Customers(CustomerID),OrderDetailsID numeric(5) NOT NULL constraint OrderDetailsID foreign key
					references OrderDetails(OrderDetailsID),
					Quantity varchar(100),RequiredDate DateTime,OrderedDate DateTime,ShippedDate DateTime)

alter table OrderDetails add constraint fk_OrderID foreign key (OrderID) references Orders(OrderID)
alter table OrderDetails drop constraint fk_OrderID
alter table OrderDetails drop column OrderID
Select * from Customers
Select * from Products
Select * from OrderDetails
Select * from Orders

--Creating Stored Procedure for sp_Products_sav
Create Procedure sp_Products_sav @ProductID numeric(5),@UnitPrice numeric(5),@ProductName varchar(20),
@ProductDescription varchar(100),@AvailableColors varchar(10),@Size varchar(15),@Color Varchar(10),
@Discount numeric(5),@Ranking numeric(5)
As
Begin
Insert into Products values (@ProductID,@UnitPrice,@ProductName,@ProductDescription,@AvailableColors,@Size,
@Color,@Discount,@Ranking)
End

--Creating Stored Procedure for sp_HandleCustomerData
Create Procedure sp_HandleCustomerData @Action Varchar(10), @CustomerID numeric(5)=100,
@FirstName varchar(14)=null,@LastName varchar(13)=null,@Address1 Varchar(100)=null,
@Address2 varchar(100)=null,@City varchar(15)=null,@State varchar(15)=null,@Country varchar(15)=null,
@Phone varchar(13)=1234567890,@Email varchar(100)=null
As
Begin
DECLARE @CustomerData varchar(20) = 'CustomerData'; 
Begin tran @CustomerData
if(@Action='I')
insert into Customers values (@CustomerID,@FirstName,@LastName,@Address1,@Address2,@City,
@State,@Country,@Phone,@Email)
if(@Action='D')
Delete from Customers WHERE CustomerID NOT IN( SELECT DISTINCT CUSTOMERID FROM Orders)
if(@Action='U')
update Customers set Address2=@Address2 where CustomerID=@CustomerID
commit tran @CustomerData
End

--Creating Stored Procedure for sp_Orders_sav
create procedure sp_Orders_sav @OrderID numeric(5),@CustomerID numeric(5),@OrderDetailsID numeric(5),
@Quantity varchar(100),@RequiredDate DateTime,@OrderedDate DateTime,@ShippedDate DateTime
As
Begin
DECLARE @OrderData varchar(20) = 'OrderData'; 
Begin tran @OrderData
Insert into Orders values (@OrderID,@CustomerID,@OrderDetailsID,@Quantity,@RequiredDate,
@OrderedDate,@ShippedDate)
commit tran @OrderData
End

--Creating Stored Procedure for sp_OrdersDetails_sav
Create Procedure sp_OrdersDetails_sav @OrderDetailsID numeric(5),@ProductID numeric(5),
@Quantity numeric(5),@UnitPrice numeric(5),@Discount numeric(5),@Size numeric(5),@Color VARCHAR(15),
@RequiredDate DateTime,@OrderedDate DateTime,@ShippedDate DateTime,@Total numeric(5)
As
Begin 
Declare @OrdersDetailsData Varchar(20)= 'OrdersDetailsData' 
Begin tran @OrdersDetailsData
Insert into OrderDetails values (@OrderDetailsID,@ProductID,@Quantity,@UnitPrice,@Discount,@Size,
@Color,@RequiredDate,@OrderedDate,@ShippedDate,@Total)
Commit tran @OrdersDetailsData
End

--Creating Stored Procedure for sp_OrdersDetails_get
Create Procedure sp_OrdersDetails_get @CustomerID numeric(5)
As
Begin
SELECT * FROM OrderDetails WHERE OrderDetailsID in 
(select OrderDetailsID from Orders where CustomerID= @CustomerID)
End

--Execute procedure sp_Products_sav
Exec sp_Products_sav 10000,1000,'Shoes','A pair of shoes','Black',10,'Black',10,3
Exec sp_Products_sav 20000,600,'Trousers','Mens Wear','Grey',30,'Grey',10,4
Exec sp_Products_sav 30000,1000,'Shirts','Mens Wear','White',42,'White',20,4
Exec sp_Products_sav 34000,800,'Belt','Tightening trip','Black',null,'Black',null,4
Exec sp_Products_sav 35000,600,'Wallet','For Keeping money','Brown',null,'Brown',null,5
Exec sp_Products_sav 36000,4000,'Travel Bag','Bag for Luggage','GreenBlack',null,'GreenBlack',30,5
Exec sp_Products_sav 37000,1200,'BedSheet','Bed Spread','Brown',20,'Brown',5,4
Exec sp_Products_sav 38000,300,'Pillow Cover','Covering the pillow','Orange',null,'Orange',null,4
Exec sp_Products_sav 39000,250,'Pull over','Pull Over','Black',null,'Black',null,5
Exec sp_Products_sav 40000,100,'Gloves','A pair of gloves','Yellow',10,'Yellow',null,5


select * from Customers

Select * from Customers  where CustomerID= (Select C.CustomerID from Customers as C left join Orders as O on
C.CustomerID=O.CustomerID group by c.CustomerID having COUNT(OrderID)=0)

SELECT * FROM Customers WHERE CustomerID NOT IN (SELECT DISTINCT CUSTOMERID FROM Orders)

--Execute procedure sp_HandleCustomerData
exec sp_HandleCustomerData 'I',1001,'Ram',' ','Indira Nagar','GachiBowli','Hyderabad',
'Telangana','India','7894512365','ram.kulkarni@gmail.com'

exec sp_HandleCustomerData 'I',1002,'Punnet','Kalra','Anjan Nagar','GachiBowli','Hyderabad',
'Telangana','India','9874562314','punnet.kalra@gmail.com'

exec sp_HandleCustomerData 'I',1003,'Lekha','Jovitha','Gandhi Nagar','T-nagar','Chennai',
'TamilNadu','India','9840152363','lekha.jovitha@gmail.com'

exec sp_HandleCustomerData 'I',1004,'Sriram','Krishnagiri','Amman koil Street','Kodampakkam','Chennai',
'TamilNadu','India','9840123456','sriram.krishnagiri@gmail.com'

exec sp_HandleCustomerData 'I',1005,'Ram','Deshpande','Vinay nagar','Gachibowli','Hyderabad',
'Telangana','India','8956231412','ram.deshpande@gmail.com'

exec sp_HandleCustomerData 'D'

exec sp_HandleCustomerData 'U', 1001, @Address2='mehdipatnam'

--Execute procedure sp_Orders_sav
Exec sp_Orders_sav 11101,1001,51000,1,'2017-05-11','2017-05-11','2017-05-11'
Exec sp_Orders_sav 11102,1001,52000,2,'2017-05-11','2017-05-11','2017-05-11'
Exec sp_Orders_sav 11103,1001,53000,4,'2017-05-11','2017-05-11','2017-05-11'
Exec sp_Orders_sav 11104,1002,54000,1,'2017-05-15','2017-05-08','2017-05-10'
Exec sp_Orders_sav 11105,1002,55000,1,'2017-05-15','2017-05-08','2017-05-11'
Exec sp_Orders_sav 11106,1002,56000,1,'2017-05-17','2017-05-09','2017-05-11'
Exec sp_Orders_sav 11107,1003,57000,1,'2017-05-18','2017-05-10','2017-05-12'
Exec sp_Orders_sav 11108,1003,58000,2,'2017-05-14','2017-05-07','2017-05-09'
Exec sp_Orders_sav 11109,1004,59000,1,'2017-05-13','2017-05-06','2017-05-08'
Exec sp_Orders_sav 11110,1004,60000,1,'2017-05-12','2017-05-07','2017-05-08'

--Execute procedure sp_OrdersDetails_sav
Exec sp_OrdersDetails_sav 51000,10000,1,1000,10,10,'Black','2017-05-11','2017-05-11','2017-05-11',900
Exec sp_OrdersDetails_sav 52000,20000,2,600,10,30,'Grey','2017-05-11','2017-05-11','2017-05-11',1080
Exec sp_OrdersDetails_sav 53000,30000,4,1000,20,42,'White','2017-05-11','2017-05-11','2017-05-11',3200
Exec sp_OrdersDetails_sav 54000,34000,1,800,null,null,'Black','2017-05-15','2017-05-08','2017-05-10',800
Exec sp_OrdersDetails_sav 55000,35000,1,600,null,null,'Brown','2017-05-15','2017-05-08','2017-05-11',600
Exec sp_OrdersDetails_sav 56000,36000,1,4000,30,null,'GreenBlack','2017-05-17','2017-05-09','2017-05-11',2800
Exec sp_OrdersDetails_sav 57000,37000,1,1200,5,20,'Brown','2017-05-18','2017-05-10','2017-05-12',1140
Exec sp_OrdersDetails_sav 58000,38000,2,300,null,null,'Orange','2017-05-14','2017-05-07','2017-05-09',600
Exec sp_OrdersDetails_sav 59000,39000,1,250,null,null,'Black','2017-05-13','2017-05-06','2017-05-08',250
Exec sp_OrdersDetails_sav 60000,40000,1,100,null,10,'Yellow','2017-05-12','2017-05-07','2017-05-08',100

--Execute procedure sp_OrdersDetails_get
Exec sp_OrdersDetails_get 1002




