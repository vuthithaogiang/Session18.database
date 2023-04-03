use master

if exists (select * from sys.databases where name='Session18')
drop database Session18

create database Session18

use Session18

-- 2: create table

create table Account (
 account_code int identity primary key,
 account_firstName varchar(50) not null,
 account_midleName varchar (50) not null,
 account_lastName varchar (50) not null,
 account_address varchar(50),
 account_dateOfBirth date
)



create table Directory (
  account_code int foreign key references Account(account_code),
  phone varchar(10) not null,
  primary key (account_code, phone)
)


--3: insert data

insert into Account values
('An', 'Nguyen',  ' Van' , '111 Nguyen Trai, Thanh Xuan, Ha Noi', '1987-11-18'), 
('Giang', 'Thao', 'Vu', 'Vinh Phuc', '2000-04-05'),
('Minh', 'Truong', 'Vu', 'Ha Noi', '1999-01-06')

insert into Account values 

('Yen', 'Thu', 'Nguyen' ,'Ha Noi', '2009-12-12'),
('Binh', 'An', 'Vu', 'Ha Noi', '2009-12-12')

update Account 
set account_firstName  = 'An' ,
    account_midleName = 'Van',
	account_lastName = 'Nguyen'
where account_code = 1

insert into Directory values 
(1, '987654321'), (1, '09873452') , (1, '09832323'), ( 1, '09434343'),
(2, '123456789')

insert into Directory values (1, '234567890')

insert into Directory values (3, '345678901'), (4, '456789012'), (5, '567890123')


select * from Directory
select * from Account

--4: liệt kê danh sach những người có trong danh bạ
select a.account_code,
       a.account_lastName + ' ' + a.account_midleName  + ' ' + a.account_firstName 
	   as FullName,
	   a.account_address,
	   a.account_dateOfBirth
from Account as a
inner join Directory as d on d.account_code = a.account_code


-- liệt kê danh sách số điện thoại có trong danh bạ

select d.phone as PhoneNumber
from Directory as d

--5: liệt kê danh sách người trong danh bạ theo thứ tự alphabet

select  a.account_code,
       a.account_lastName + ' ' + a.account_midleName  + ' ' + a.account_firstName 
	   as FullName,
	   a.account_address,
	   a.account_dateOfBirth
from Account as a
inner join Directory as d on d.account_code = a.account_code
order by a.account_firstName, account_midleName, a.account_lastName

-- liệt kê các sdt cua nguoi có ten la Nguyen Van An

select d.phone
from Directory as d
inner join Account as a on a.account_code = d.account_code 
where a.account_firstName like 'An' and a.account_midleName like 'Van' 
and  a.account_lastName like 'Nguyen'

-- Liet ke những người có ngày sinh là 12/12/2009
select * from Account
where account_dateOfBirth in ('2009-12-12')


--6: tìm số lượng điện thoại của mỗi người trong danh bạ
select d.account_code ,
       count (*) as NumberOfPhone
from Directory as d
group by account_code

-- tìm số người trong danh bạ sinh vào tháng 12
select a.*
from Account as a
inner join Directory as d on d.account_code = a.account_code
where MONTH(a.account_dateOfBirth) = '12'

--hiển thị toàn bộ thông tin về người, của từng số điện thoại

select d.* ,
         a.account_lastName + ' ' + a.account_midleName  + ' ' + a.account_firstName 
	   as FullName,
	   a.account_address as Address,
	   a.account_dateOfBirth as DateOfBirth
from Directory as d
inner join Account as a on a.account_code = d.account_code

-- hiển thị toàn bộ thông tin về người, của số đt 123456789

select d.* ,
         a.account_lastName + ' ' + a.account_midleName  + ' ' + a.account_firstName 
	   as FullName,
	   a.account_address as Address,
	   a.account_dateOfBirth as DateOfBirth
from Directory as d
inner join Account as a on a.account_code = d.account_code
where d.phone like '123456789'

--7: viết câu lệnh thay đổi trừơng ngày sinh là trước ngày hiện tại
select account_dateOfBirth ,
        DATENAME (year, account_dateOfBirth) as CurrentYear,
        DATENAME (month, account_dateOfBirth) as CurrentMonth,
        DATENAME (day, account_dateOfBirth) as CurrentDay,
		DATEADD(day, -01, account_dateOfBirth) as AddOneDay
      
from Account 

update Account
set account_dateOfBirth = DATEADD(day, -01, account_dateOfBirth)

select * from Account

-- viết câu lệnh thêm trường: ngày bắt đầu liên lạc: dateStart

alter table Directory
add dateStart date default null

select * from Directory

--8: đặt chỉ mục cho cột Họ và tên
create nonclustered index IX_Name
on Account (account_firstName, account_midleName, account_lastName)

-- đặt chỉ mục cho cột số điện thoại
create unique nonclustered index IX_PhoneNumber
on Directory(phone)

-- View_Phone: hiển thị thông tin gồm tên, sđt
create view View_Phone
as
select 
        a.account_lastName + ' ' + a.account_midleName  + ' ' + a.account_firstName 
	   as FullName,
	   d.phone as PhoneNumber
from Directory as d
inner join Account as a on a.account_code = d.account_code


select * from View_Phone
 
--View_DateOfBirth: hiển thị những người có sinh nhật trong tháng hiện tại: 
-- họ tên, ngày sinh, số điện thoại
create view View_DateOfBirth
as
select 
    a.account_lastName + ' ' + a.account_midleName  + ' ' + a.account_firstName 
	   as FullName,
	   a.account_dateOfBirth as DateOfBirth,
	   d.phone as PhoneNumber
from Account as a
inner join Directory as d on d.account_code = a.account_code

where month(CURRENT_TIMESTAMP) = month(a.account_dateOfBirth)


select * from View_DateOfBirth
-- SP_Insert_Directory: thêm một người mới vào danh bạ
create procedure SP_Insert_Directory (
   @id int,
   @firstName varchar(50),
   @midleName varchar(50),
   @lastName varchar(50),
   @address varchar(50),
   @dateOfBirth date,
   @phone varchar(10)
)
as 
begin
   if ( @phone not in ( select Directory.phone from Directory)
   and @id not in (select Account.account_code  from Account) )
   begin
      set identity_insert Account on;
	  insert into Account ( account_code, account_firstName,
	       account_midleName, account_lastName, account_address,
		   account_dateOfBirth)
       
     values (@id, @firstName, @midleName, @lastName, @address, @dateOfBirth);

	 set identity_insert Account off;
	  
	  insert into Directory (account_code, phone) values (@id, @phone);
	  print 'Inserted complete!'
   end
   else
   begin
      print 'Account or Phone number already have!';
	  rollback transaction;
   end
end

-- test 
exec SP_Insert_Directory 1, 'Nguyen', 'Van', 'Hoa', 'Ha Noi', '1999-09-09',
'11111111111'

exec SP_Insert_Directory 11, 'Nguyen', 'Van', 'Hoa', 'Ha Noi', '1999-09-09',
'123456789'
 -- ok
exec SP_Insert_Directory 11, 'Nguyen', 'Van', 'Hoa', 'Ha Noi', '1999-09-09',
'11111111111'

select * from Directory

-- SP_Search_Directory: tìm thông tin liên hệ của người theo tên (gần đúng)

create procedure SP_Search_Directory ( @name varchar(40))
as
begin
   select d.phone as PhoneNumber,
          d.dateStart ,
		  a.account_lastName + ' ' + a.account_midleName  + ' ' + a.account_firstName 
	         as FullName
		  
   from Directory as d
   inner join Account as a on a.account_code = d.account_code
   where PATINDEX(@name, a.account_firstName) not in (0) 
       or  PATINDEX(@name, a.account_midleName) not in (0) 
	   or  PATINDEX(@name, a.account_lastName) not in (0) 

end

exec SP_Search_Directory @name = 'nguyen'