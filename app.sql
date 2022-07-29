CREATE DATABASE LIBRARY

GO

USE LIBRARY

GO

--Издательство
CREATE TABLE Publication (
ID_pub int identity(1,1) Not Null primary key,
Name_pub varchar(35) Not Null,
Year_pub_base smallint Not Null
)

--Жанр
CREATE TABLE Style(
ID_style int identity(1,1) Not Null primary key,
Name_style varchar(35) Not Null
)

--Язык
CREATE TABLE Language(
ID_language int identity(1,1) Not Null primary key,
Name_lang varchar(35) Not Null
)

--Автор
CREATE TABLE Author(
ID_author int identity(1,1) Not Null primary key,
Surname_author varchar(35) Not Null,
Name_author varchar(35) Not Null,
Patronymic_author varchar(35),
Date_bd date ,
Date_dth date DEFAULT NULL,
Summa_zadolzh int DEFAULT 0

)

--Читательский билет
CREATE TABLE Library_card(
ID_library_card int identity(1,1) Not Null primary key,
Surname_reader varchar(35) Not Null,
Name_reader varchar(35) Not Null,
Patronymic_reader varchar(35) Not Null,
Phone_reader bigint Not Null
)

--Должности
CREATE TABLE Position(
ID_posit int identity(1,1) Not Null primary key,
Name_posit varchar(35) Not Null,
Salary int Not Null
)

--Cотрудники
CREATE TABLE Employee(
ID_emp int identity(1,1) Not Null primary key,
Surname_emp varchar(35) Not Null,
Name_emp varchar(35) Not Null,
Patronymic_emp varchar(35),
Phone_emp bigint Not Null,
Position int Not Null foreign key references Position(ID_posit)
)

--Книги
CREATE TABLE Books (
ID_books int identity(1,1) Not Null primary key,
Name_book varchar(50) Not Null,
Year_book_base smallint Not Null,
Publication int Not Null foreign key references Publication(ID_pub),
Style int Not Null foreign key references Style(ID_style),
Language int Not Null foreign key references Language(ID_language)
)

--Авторство
CREATE TABLE Authorship (
ID_authorship int identity(1,1) Not Null primary key,
Books int Not Null foreign key references Books(ID_books),
Author int Not Null foreign key references Author(ID_author)
)

--Взятые книги
CREATE TABLE Book_take (
ID_book_take int identity(1,1) Not Null primary key,
Books int Not Null foreign key references Books(ID_books),
Library_card int Not Null foreign key references Library_card(ID_library_card),
Date_issue date Not Null DEFAULT getdate() ,
Date_return date,
Return_book bit Not Null,
Debt bit Not Null,
Employee int Not Null foreign key references Employee(ID_emp),
Summa_zadolzh int DEFAULT 0
)
 
Приложение №2
-- Запрос 1: Вывести жанр
select Author.Surname_author + ' ' + Author.Name_author + ' ' +Author.Patronymic_author as [Автор],
Books.Name_book as [Название книги], Books.Year_book_base as [Год написания]
from Books
INNER JOIN Authorship on Books.ID_books = Authorship.Books
INNER JOIN Author on Authorship.Author = Author.ID_author
INNER JOIN Style on Books.Style = Style.ID_style
where Style.Name_style = 'Роман'

-- Запрос 2: вывод актуальной на сегодняшний день информацию о книгах в наличии 
select distinct Books.ID_books, Books.Name_book as [название книги],
Author.Surname_author + ' ' + Author.Name_author + ' ' + Author.Patronymic_author as [Автор],
Books.Year_book_base as [Год написания], Style.Name_style as [Жанр],
Language.Name_lang as [Язык издания], Publication.Name_pub [Издательство]
From Books
INNER JOIN Style on Books.Style = Style.ID_style
INNER JOIN Authorship on Books.ID_books = Authorship.Books
INNER JOIN Author ON Authorship.Author = Author.ID_author
INNER JOIN Language ON Books.Language = Language.ID_language
INNER JOIN Publication ON Books.Publication = Publication.ID_pub
INNER JOIN Book_take ON Books.ID_books = Book_take.Books
WHERE Book_take.Return_book = 'True' OR Book_take.Return_book is NULL
ORDER BY Books.Year_book_base DESC -- DESC Убыванеи; ASC Возрастание 


-- Запрос 3: Вывод всей информации о читателях с задолжностями, отсортировывает сначала тех, у кого наибольшая задолжность 
select Books.Name_book as [Название книги], Author.Surname_author + ' ' + Author.Name_author + ' ' + Author.Patronymic_author as [Автор], 
Library_card.Surname_reader + ' ' + Library_card .Name_reader as [Читатель], Library_card.Phone_reader [Контактный номер],
Book_take.Date_return as [Дата возврата]

From Books 
INNER JOIN Book_take ON Books.ID_books = Book_take.Books
INNER JOIN Library_card ON Book_take.Library_card = Library_card.ID_library_card
INNER JOIN Authorship ON Books.ID_books = Authorship.Books
INNER JOIN Author ON Authorship.Author = Author.ID_author
WHERE Book_take.Return_book = 'False' AND Book_take.Date_return < GETDATE()
ORDER BY Book_take.Date_return ASC

--Запрос 4: вывод всех зарегистрированных в библиотеке читателей, которые еще не брали на руки издания
Select Library_card.ID_library_card as [ID Читательского билета], Library_card.Surname_reader + ' ' + Library_card.Name_reader [Читатель]
From Library_card
Where ID_library_card not in (Select Book_take.Library_card from Book_take)

--Запрос 5: Ввыод ВСЮ сумму задолжности у читателя
select Library_card.Surname_reader + ' ' + Library_card.Name_reader as [Читатель], Sum(Book_take.Summa_zadolzh) as [Сумма долга читателя]
From Books
INNER JOIN Book_take on Books.ID_books = Book_take.Books
INNER JOIN Library_card ON Book_take.Library_card = Library_card.ID_library_card
INNER JOIN Authorship ON Books.ID_books = Authorship.Books
INNER JOIN Author ON Authorship.Author = Author.ID_author
WHERE Book_take.Return_book = 'False' AND Book_take.Date_return < GETDATE()
group BY Library_card.Surname_reader + ' ' + Library_card.Name_reader 
Приложение №3
--заполнение таблицы Publication
select * from  Publication 

insert into Publication values('Эксмо',1991) 
insert into Publication values('АСТ ',1989) 
insert into Publication values('МИФ',2005) 
insert into Publication values('Просвещение ',1930) 
insert into Publication values('Азбука-аттикус',2008) 
insert into Publication values('Альпина Паблишер',1998) 

--Заполнение таблицы Style
select * from  Style
insert into Style values('Фантастика')
insert into Style values('Научная-фантастика ')
insert into Style values('Приключения')
insert into Style values('Роман')
insert into Style values('Научный')
insert into Style values('Фольклор')
insert into Style values('Справочник')
insert into Style values('Поэзия')
insert into Style values('Детская ')
insert into Style values('Деловая')
insert into Style values('Учебная')
insert into Style values('Саморазвитие')
insert into Style values('Зарубежная')
insert into Style values('Техническая')

--Заполнение таблицы Language
select * from  Language
insert into Language values('Английский')
insert into Language values('Русский')

--Заполнение таблицы Author
select * from  Author
INSERT INTO Author (Surname_author, Name_author, Patronymic_author, Date_bd, Date_dth) VALUES ('Булгаков', 'Михаил', 'Афанасьевич', '1-10-1889', '1-01-1940')
insert into Author (Surname_author, Name_author, Patronymic_author, Date_bd, Date_dth) values ('Булгаков','Михаил','Афанасьевич','23-08-1891','15-06-1940')
insert into Author (Surname_author, Name_author, Patronymic_author, Date_bd, Date_dth) values ('Чехов','Анатолий ','Павлович','16-09-1860','02-02-1904')
insert into Author (Surname_author, Name_author, Patronymic_author, Date_bd, Date_dth) values ('Пушкин','Александр','Сергеевич','11-11-1799','13-04-1837')
insert into Author (Surname_author, Name_author, Patronymic_author, Date_bd, Date_dth) values ('Лермонтов','Михаил','Юрьевич','14-05-1814','17-05-1841')
insert into Author (Surname_author, Name_author, Patronymic_author, Date_bd, Date_dth) values ('Маяковсский ','Владимир','Владимирович','04-06-1893','18-09-1930')
insert into Author (Surname_author, Name_author, Patronymic_author, Date_bd, Date_dth) values ('Достоевский','Федор','Михайлович','17-04-1821','19-01-1881')
insert into Author (Surname_author, Name_author, Patronymic_author, Date_bd, Date_dth) values ('Фет','Афанасий','Афанасьевич','21-07-1820','26-04-1892')
insert into Author (Surname_author, Name_author, Patronymic_author, Date_bd, Date_dth) values ('Бродский','Иосиф','Александрович','30-04-1940','02-07-1996')
insert into Author (Surname_author, Name_author, Patronymic_author, Date_bd) values ('Лукьяненко','Сергей','Васильевич','10-10-1968')
-- SET IDENTITY_INSERT to ON.  
SET IDENTITY_INSERT dbo.Author off;  --Использовал св-во ON
GO  
insert into Author (ID_author, Surname_author, Name_author, Patronymic_author, Date_bd) values (21,'Дашкова','Полина','Викторовна','11-11-1960') 
GO
insert into Author (Surname_author, Name_author, Patronymic_author, Date_bd) values ('Пелевин','Виктор','Олегович','16-11-1962')
insert into Author (Surname_author, Name_author, Patronymic_author, Date_bd, Date_dth) values ('Ильф','Илья ','Арнольдович','15-10-1897','18-03-1937')
insert into Author (Surname_author, Name_author,Patronymic_author, Date_bd) values ('Каненман','Дэниел','Джордж','10-12-1934')
insert into Author (Surname_author, Name_author, Patronymic_author, Date_bd) values ('Коэльо','Пауло','Пуэрто','17-07-1947')
insert into Author (Surname_author, Name_author, Patronymic_author, Date_bd, Date_dth) values ('Толкин','Джон','Рональд','03-03-1892','07-08-1973')
insert into Author (Surname_author, Name_author, Patronymic_author, Date_bd, Date_dth) values ('Дойл','Артур','Конан','26-09-1959','29-07-1930')
insert into Author (Surname_author, Name_author, Patronymic_author, Date_bd, Date_dth) values ('Хэмингуэй','Эрнест','Джош','23-10-1899','24-08-1961')
insert into Author (Surname_author, Name_author, Patronymic_author, Date_bd, Date_dth) values ('Маркес','Гарсима','Габриэль','16-11-1927','10-12-2014')

UPDATE Author SET Date_bd = '17-09-1860' WHERE ID_author = 3
--Удаление строчки с ИД 18
DELETE
FROM Author
WHERE ID_author = 18

DELETE
FROM Author
WHERE ID_author = 2

DELETE
FROM Author
WHERE ID_author = 21

--Заполение таблицы Library_card
select * from Library_card 
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Иванов', 'Петр', 'Иванович', 79109998887766)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Игнатова ','Софья',' Дмитриевна',79107778123)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Гаврилов ','Артём ','Николаевич',79107778124)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Воронова','Софья','Александровна',79107778125)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Минаева','Анастасия','Тимофеевна',79107778126)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Токарев','Дмитрий','Макарович',79107778127)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Попов','Денис','Даниилович',79107778128)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Карпов','Михаил','Никитич',79107778129)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Егоров','Владимир','Львович',79107778130)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Ильин','Тихон','Иванович',79107778131)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Жукова','Анна','Александровна',79107778132)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Макаров','Алексей','Ильич',79107778133)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Чернов','Никита','Владиславович',79107778134)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Виноградова','Кристина','Фёдоровна',79107778135)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Котова','Дарья','Георгиевна',79107778136)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Кузнецова','Мирослава','Данииловна',79107778137)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Бородин','Арсений','Артёмович',79107778138)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Кулешов','Иван','Русланович',79107778139)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Верещагин','Даниил','Игоревич',79107778140)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Захарова','Елизавета','Алексеевна',79107778141)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Афанасьева','Кристина','Артемьевна',79107778142)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Смирнова','Марьяна','Ильинична',79107778143)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Морозова','Анна','Вячеславовна',79107778144)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Степанов','Александр','Арсентьевич',79107778145)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Мартынов','Михаил','Григорьевич',79107778146)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Столярова','Милана','Владимировна',79107778147)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Тихонов','Макар','Мирославович',79107778148)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Смирнова','Софья','Данииловна',79107778149)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Нечаев','Даниэль','Тихонович',79107778150)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Кузнецов','Григорий','Фёдорович',79107778151)
insert into Library_card (Surname_reader, Name_reader, Patronymic_reader, Phone_reader) values ('Егорова','Ева','Данииловна',79107778152)

DELETE
FROM Library_card
WHERE ID_Library_card = 1

--Заполнение таблицы Position
select * from Position
insert into Position values ('Исполнительный директор',45000)
insert into Position values ('Заместитель директора',30000)
insert into Position values ('Главный библиотекарь',28000)
insert into Position values ('Главный библиограф', 26500)
insert into Position values ('Библиотекарь-руководитель',22000)
insert into Position values ('Методист',15650)
insert into Position values ('Секретарь ',18000)
insert into Position values ('Бухгалтер',25000)
insert into Position values ('Руководитель отдела комплектования',20125)
insert into Position values ('Специалист по компьютерам',22000)
insert into Position values ('Библиотекарь-руководитель подразделения',25000)
insert into Position values ('Смотритель читального зала',12580)
insert into Position values ( 'Смотритель журнальных подшивок',10000)
insert into Position values ('Хранитель книжных архивов',10000)
insert into Position values ('Каталогизатор',8500)
insert into Position values ('Охраник',16320)

--Заполнение таблицы Employee
select * from Employee
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Белкина', 'Ульяна', 'Лукинична', 79086345512, 1)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Карасева', 'Елизавета', 'Михайловна', 79086345513, 2)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Симонов', 'Тихон', 'Адамович', 79086345514, 3)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Кожевников', 'Артём', 'Дмитриевич', 79086345515, 4)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Иванов', 'Александр', 'Максимович', 79086345516, 5)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Павлов', 'Роберт', 'Русланович', 79086345517, 5)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Антипова', 'Малика', 'Дмитриевна', 79086345518, 5)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Прокофьева', 'Александра', 'Максимовна', 79086345519, 6)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Новикова', 'Мария', 'Стефановна', 79086345520, 6)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Бородина', 'Надежда', 'Павловна', 79086345521, 6)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Калашникова', 'Майя', 'Александровна', 79086345522, 7)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Леонов', 'Александр', 'Дмитриевич', 79086345523, 8)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Овчинников', 'Никита', 'Фёдорович', 79086345524, 9)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Степанова', 'Амелия', 'Кирилловна', 79086345525, 10)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Столяров', 'Арсений', 'Родионович', 79086345526, 11)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Богданов', 'Константин', 'Максимович', 79086345527, 12)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Белякова', 'Вероника', 'Адамовна', 79086345528, 12)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Иванова', 'Алиса', 'Александровна', 79086345529, 13)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Родионов', 'Ярослав', 'Тимурович', 79086345530, 14)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Зотов', 'Гордей', 'Владимирович', 79086345531, 15)
insert into Employee (Surname_emp, Name_emp, Patronymic_emp, Phone_emp, Position) values ('Власова', 'Ульяна', 'Арсентьевна', 79086345532, 16)

--Заполнение таблицы Books 
select * from Books 
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Мастер и маргарита', 1928, 1, 5, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Записки Юного врача', 1925, 1, 12, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Повести', 1910, 1, 7, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Дама с собачкой ', 1899, 2, 4, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Палата номер 6', 1892, 2, 1, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Пари', 1889, 2, 1, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Капитанская дочка', 1836, 2, 4, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Пиковая дама', 1834, 3, 5, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Евгений Онегин ', 1833, 3, 9, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Полтава', 1828, 4, 9, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Золотая рыбка ', 1830, 4, 10, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Герой нашего времени ', 1840, 4, 5, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Демон', 1839, 1, 5, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Мцыри', 1840, 5, 5, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Парус', 1841, 5, 7, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Бородино', 1837, 5, 9, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Флейта-позвоночник', 1915, 5, 3, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Преступление и наказание ', 1866, 5, 5, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Братья Карамазовы', 1879, 6, 5, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Бесы', 1872, 6, 9, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Игрок', 1866, 6, 12, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Бобок', 1873, 3, 10, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Воспоминания', 1983, 3, 7, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Меньше единицы', 1986, 3, 2, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Discovery', 1999, 3, 14, 2)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('So Forth', 1996, 4, 14, 2)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Ночной дозор', 1998, 4, 3, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Дневной дозор', 2000, 4, 3, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Сумеречный дозор', 2004, 4, 3, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Геном', 1999, 2, 3, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Черновик', 2006, 2, 3, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Чистовик', 2007, 2, 3, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Кваzи', 2017, 2, 3, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Лёгкие шаги безумия', 2007, 2, 2, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Generation П', 1999, 6, 2, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Чапаев и пустота', 1996, 6, 2, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Смотритель ', 2015, 6, 2, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Yellow Arrow', 1996, 1, 14, 2)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Двенадцать стульев', 1928, 1, 4, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Золтой телёнок', 1931, 1, 4, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Одоноэтажная Америка', 1937, 1, 4, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('American Road Trip', 1937, 1, 4, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Думай медленно, решай быстро', 2011, 1, 13, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Thinking, Fast and Slow', 2011, 1, 14, 2)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Алхимик', 1988, 3, 5, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Властелин колец', 1987, 3, 5, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Контики ', 1956, 4, 4, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Старик и море ', 1952, 5, 10, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('По ком звонит колокол', 1940, 6, 5, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('Иметь и не иметь', 1937, 3, 5, 1)
insert into Books (Name_book, Year_book_base, Publication, Style, Language) values ('100 лет одиночества', 1990, 1, 5, 1)

 --Заполнение таблицы Authorship 
select * from Authorship 
insert into Authorship values (1, 1)
insert into Authorship values (2, 1)
insert into Authorship values (3, 3)
insert into Authorship values (4, 3)
insert into Authorship values (5, 3)
insert into Authorship values (6, 3)
insert into Authorship values (7, 4)
insert into Authorship values (8, 4)
insert into Authorship values (9, 4)
insert into Authorship values (10, 4)
insert into Authorship values (11, 4)
insert into Authorship values (12, 8)
insert into Authorship values (13, 8)
insert into Authorship values (14, 8)
insert into Authorship values (15, 8)
insert into Authorship values (16, 8)
insert into Authorship values (17, 9)
insert into Authorship values (18, 10)
insert into Authorship values (19, 10)
insert into Authorship values (20, 10)
insert into Authorship values (21, 10)
insert into Authorship values (22, 10)
insert into Authorship values (23, 11)
insert into Authorship values (24, 12)
insert into Authorship values (25, 12)
insert into Authorship values (53, 12)
insert into Authorship values (54, 20)
insert into Authorship values (55, 20)
insert into Authorship values (56, 20)
insert into Authorship values (30, 20)
insert into Authorship values (31, 20)
insert into Authorship values (32, 20)
insert into Authorship values (33, 20)
insert into Authorship values (34, 21)
insert into Authorship values (35, 22)
insert into Authorship values (36, 22)
insert into Authorship values (37, 22)
insert into Authorship values (38, 22)
insert into Authorship values (39, 13)
insert into Authorship values (40, 13)
insert into Authorship values (41, 13)
insert into Authorship values (42, 13)
insert into Authorship values (43, 13)
insert into Authorship values (44, 23)
insert into Authorship values (45, 24)
insert into Authorship values (46, 14)
insert into Authorship values (47, 15)
insert into Authorship values (48, 16)
insert into Authorship values (49, 16)
insert into Authorship values (57, 16)
insert into Authorship values (51, 17)

 --Удаление всех строк таблицы Authorship
TRUNCATE TABLE Authorship

--Заполнение таблциы Book_take
select * from Book_take
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(5,5,'2021-11-01', '2021-11-15', 0, 1, 11)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(55,15,'2021-11-02', '2021-11-16', 1, 1, 2)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(16,25,'2021-11-03', '2021-11-17', 0, 1, 7)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(19,5,'2021-11-04', '2021-11-18', 0, 1, 5)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(44,14,'2021-11-06', '2021-11-20', 1, 1, 21)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(13,21,'2021-11-07', '2021-11-21', 0, 1, 12)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(37,12,'2021-11-08', '2021-11-22', 1, 1, 7)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(42,9,'2021-11-09', '2021-11-23', 1, 1, 19)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(17,17,'2021-11-10', '2021-11-24', 0, 1, 6)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(31,3,'2021-11-11', '2021-11-25', 0, 1, 2)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(33,17,'2021-11-12', '2021-11-26', 1, 0, 6)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(24,20,'2021-11-13', '2021-11-27', 0, 0, 8)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(57,2,'2021-11-15', '2021-11-29', 1, 0, 16)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(49,9,'2021-11-16', '2021-11-30', 0, 0, 1)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(13,12,'2021-11-17', '2021-12-01', 1, 0, 18)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(53,6,'2021-11-18', '2021-12-02', 1, 0, 14)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(49,3,'2021-11-20', '2021-12-04', 1, 0, 4)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(18,4,'2021-11-21', '2021-12-05', 1, 0, 14)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(22,27,'2021-11-23', '2021-12-07', 1, 0, 2)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(35,7,'2021-11-25', '2021-12-09', 1, 0, 9)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(37,12,'2021-11-26', '2021-12-10', 0, 0, 2)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(22,27,'2021-11-27', '2021-12-11', 1, 0, 21)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(56,29,'2021-11-28', '2021-12-12', 0, 0, 14)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(41,23,'2021-11-29', '2021-12-13', 0, 0, 16)
insert into Book_take (Books, Library_card, Date_issue, Date_return, Return_book, debt, Employee) values(48,26,'2021-11-30', '2021-12-14', 0, 0, 10)
