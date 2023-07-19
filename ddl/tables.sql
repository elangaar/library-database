drop table if exists books;
drop table if exists languages;
drop table if exists publishers;
drop table if exists authors;
drop table if exists books_authors;
drop table if exists nationalities;
drop table if exists book_categories;
drop table if exists book_subcategories;
drop table if exists books_book_subcategories;
drop table if exists bookings;
drop table if exists borrowings;
drop table if exists orders;
drop table if exists users;
drop table if exists subscriptions;
drop table if exists payment_plans;
drop table if exists subscription_types;


create table books (
	book_id int generated always as identity,
	title varchar(100) not null,
	isbn varchar(17) not null,
	release_date date not null,
	num_pages smallint not null,
	is_borrowed bool default false,
	is_booked bool default false,
	is_ordered bool default false,
	language int not null,
	publisher int not null,
	primary key (book_id)
);

create table languages (
	language_id int generated always as identity,
	name varchar(30) not null,
	primary key (language_id)
);

create table publishers (
	publisher_id int generated always as identity,
	name varchar(50) not null,
	primary key (publisher_id)
);

create table authors (
	author_id int generated always as identity,
	first_name varchar(30) not null,
	last_name varchar(30) not null,
	nationality int not null,
	primary key (author_id)
);

create table books_authors (
	book int,
	author int,
	primary key (book, author)
);

create table nationalities (
	nationality_id int generated always as identity,
	name varchar(30) not null,
	primary key (nationality_id)
);

create table book_categories (
	book_category_id int generated always as identity,
	name varchar(50) not null,
	primary key (book_category_id)
);

create table book_subcategories (
	book_subcategory_id int generated always as identity,
	name varchar(50) not null,
	category int not null,
	primary key (book_subcategory_id)
);

create table books_book_subcategories (
	book_subcategory int,
	book int,
	primary key (book_subcategory, book)
);

create table bookings (
	booking_id int generated always as identity,
	date_from date not null,
	date_to date not null,
	book int not null,
	user_ int not null,
	primary key (booking_id)
);

create table borrowings (
	borrowing_id int generated always as identity,
	rental_date date not null,
	return_date date not null,
	b_user int not null,
	book int,
	booking int,
	b_order int,
	primary key (borrowing_id)
);

create table orders (
	order_id int generated always as identity,
	date_from date not null,
	date_to date not null,
	book int not null,
	o_user int not null,
	primary key (order_id)
);

create table users (
	user_id int generated always as identity,
	first_name varchar(30) not null,
	last_name varchar(30) not null,
	email varchar(30) not null,
	phone varchar(20) not null,
	kind varchar(20) not null,
	primary key (user_id)
);

create table subscriptions (
	subscription_id int generated always as identity,
	date_from date not null,
	date_to date,
	s_user int not null,
	payment_plan int not null,
	primary key (subscription_id)
);

create table payment_plans (
	payment_plan_id int generated always as identity,
	pp_period interval not null,
	amount numeric(15,2) not null,
	subscription_type int not null,
	primary key (payment_plan_id)
);

create table subscription_types (
	subscription_type_id int generated always as identity,
	name varchar(30) not null,
	num_books smallint not null,
	rental_period interval not null,
	primary key (subscription_type_id)
);














