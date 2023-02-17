
Use Northwind_DW
go


Create Function dbo.fn_Type(@PrId int)
returns nvarchar(20)
As
Begin
declare @Type nvarchar(20)
if (Select UnitPrice From northwnd.dbo.Products where ProductID=@PrId) > (select Avg(UnitPrice) from northwnd.dbo.Products)
 set @Type= 'Expensive'
else 
 set @Type= 'Cheap'
 return @Type
end


Create Procedure usp_Updates
as

truncate table northwind_dw.dbo.Dim_Products
truncate table northwind_dw.dbo.Dim_Orders
truncate table northwind_dw.dbo.Dim_Customers
truncate table northwind_dw.dbo.Dim_Employees
truncate table northwind_dw.dbo.Fact_Sales
DROP table IF EXISTS  northwind_dw.dbo.Dim_Date




insert into northwind_dw.dbo.Dim_Products
select ProductId, ProductName, UnitPrice, dbo.fn_Type(ProductID), CategoryName, CompanyName, Discontinued
from northwnd.dbo.Products P join northwnd.dbo.Categories C
on p.CategoryID=C.CategoryID
join northwnd.dbo.Suppliers S
on p.SupplierID=S.SupplierID



insert into northwind_dw.dbo.Dim_Employees
select EmployeeID, LastName, FirstName, LastName + ' ' + FirstName, Title, BirthDate, Year(GetDate())-Year(BirthDate), HireDate, Year(GetDate())-Year(HireDate), City, Country, Photo, ReportsTo
from northwnd.dbo.Employees


insert into northwind_dw.dbo.Dim_Customers
select CustomerID, CompanyName, City, Region, Country
from northwnd.dbo.Customers

insert into northwind_dw.dbo.Dim_Orders
select OrderID, ShipCity, ShipRegion, ShipCountry
from northwnd.dbo.Orders

create table northwind_dw.dbo.Dim_Date (
DateKey int,
Date date,
Year int,
Quarter int,
Month int,
Monthname nvarchar(20))


declare @Date date = '1996/01/01'
while @Date <= '1999/12/31'
		begin
Declare @DateINT int = (select convert(int, convert (nvarchar, @Date, 112 )))

insert into Dim_Date
Values (@DateINT, @Date, Year(@Date), DateName(q,@Date), Month(@Date), DateName(m, @Date))
set @Date= (select DATEADD(d,1,@Date))
		end

insert into northwind_dw.dbo.Fact_Sales 
select OrderSk,ProductSK,DateKey,convert(int, convert (nvarchar, ShippedDate, 112 )), CustomerSK, EmployeeSK, UnitPrice, Quantity, Discount
from northwnd.dbo.[Order Details] Od join northwnd.dbo.Orders O
on Od.OrderID=O.OrderID
join northwind_dw.dbo.Dim_Orders DO on DO.OrderBK=O.OrderID
join northwind_dw.dbo.Dim_Products DP on DP.ProductBK=Od.ProductID
join northwind_dw.dbo.Dim_Employees ED on ED.EmployeeBK=O.EmployeeID
join northwind_dw.dbo.Dim_Customers CD on CD.CustomerBK COLLATE database_default  = O.CustomerID
join northwind_dw.dbo.Dim_Date DD on DD.Date = O.OrderDate




Exec usp_Updates



select * from Fact_Sales
select * from Dim_Customers
select * from Dim_Employees
select * from Dim_Orders
select * from Dim_Products
select * from Dim_Date

