drop view if exists books_v;
drop view if exists authors_v;
drop view if exists bookings_v;
drop view if exists orders_v;
drop view if exists borrowings_v;
drop view if exists users_v;
drop view if exists subscriptions_v;


alter table books 
	drop constraint if exists books_languages_fkey;
alter table books
	drop constraint if exists books_publishers_fkey;
alter table book_subcategories 
	drop constraint if exists book_subcategories_book_categories_fkey;
alter table books_book_subcategories 
	drop constraint if exists books_book_subcategories_book_subcategories_fkey;
alter table if exists books_book_subcategories
	drop constraint if exists books_book_subcategories_books_fkey;
alter table authors 
	drop constraint if exists authors_nationalities_fkey;
alter table books_authors
	drop constraint if exists books_authors_authors_fkey;
alter table books_authors
	drop constraint if exists books_authors_books_fkey;
alter table bookings 
	drop constraint if exists bookings_books_fkey;
alter table bookings
	drop constraint if exists bookings_users_fkey;
alter table orders
	drop constraint if exists orders_books_fkey;
alter table orders
	drop constraint if exists orders_users_fkey;
alter table borrowings 
	drop constraint if exists borrowings_books_fkey;
alter table borrowings 
	drop constraint if exists borrowings_bookings_fkey;
alter table borrowings
	drop constraint if exists borrowings_users_fkey;
alter table borrowings 
	drop constraint if exists borrowings_orders_fkey;
alter table subscriptions 
	drop constraint if exists subscriptions_users_fkey;
alter table subscriptions
	drop constraint if exists subscriptions_payment_plans_fkey;
alter table payment_plans
	drop constraint if exists payment_plans_subscription_types_fkey;


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
	is_borrowed bool not null default false,
	is_booked bool not null default false,
	is_ordered bool not null default false,
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
	b_user int not null,
	is_realized bool not null default false,
	primary key (booking_id)
);

create table borrowings (
	borrowing_id int generated always as identity,
	rental_date date not null default now(),
	return_date date,
	b_user int not null,
	book int not null,
	booking int,
	b_order int,
	primary key (borrowing_id)
);

create table orders (
	order_id int generated always as identity,
	date_from timestamp not null,
	date_to timestamp,
	book int not null,
	o_user int not null,
	is_realized bool not null default false,
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














