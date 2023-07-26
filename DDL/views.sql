drop view if exists books_v;
drop view if exists authors_v;
drop view if exists bookings_v;
drop view if exists orders_v;
drop view if exists borrowings_v;
drop view if exists users_v;
drop view if exists subscriptions_v;


create or replace view books_v as
select
	b.title,
	b.isbn,
	b.release_date,
	b.num_pages,
	bc.name category,
	bs.name subcategory,
	l.name language,
	p.name publisher,
	a.first_name || ' ' || a.last_name author
from books b
left join books_book_subcategories bbs on b.book_id = bbs.book
inner join book_subcategories bs on bbs.book_subcategory = bs.book_subcategory_id
inner join book_categories bc on bs.category = bc.book_category_id
left join languages l on b.language = l.language_id
left join publishers p on b.publisher = p.publisher_id
inner join books_authors ba on b.book_id = ba.book
inner join authors a on ba.author = a.author_id
order by b.release_date;

create or replace view authors_v as
select
	a.first_name,
	a.last_name,
	n.name nationality
from authors a
inner join nationalities n 
on a.nationality = n.nationality_id
order by last_name;

create or replace view bookings_v as
select
	b.title,
	b.isbn,
	date_from,
	date_to,
	u.first_name || ' ' || u.last_name user
from bookings bo
inner join books b on bo.book = b.book_id 
inner join users u on bo.b_user = u.user_id
order by date_from;

create or replace view orders_v as
select
	b.title,
	b.isbn,
	date_from,
	date_to,
	u.first_name || ' ' || u.last_name user
from orders o
inner join books b on o.book = b.book_id 
inner join users u on o.o_user = u.user_id
order by date_from;

create or replace view borrowings_v as
select
	b.title,
	b.isbn,
	br.rental_date,
	br.return_date,
	u.first_name || ' ' || u.last_name user,
	br.booking,
	br.b_order
from borrowings br
left join books b on br.book = b.book_id 
left join bookings bo on br.booking = bo.booking_id
left join orders o on br.b_order = o.order_id
inner join users u on br.b_user = u.user_id
order by rental_date;

create or replace view users_v as
select
	u.first_name,
	u.last_name,
	u.email,
	u.phone,
	u.kind kind_of_user,
	st.name subscription_type,
	s.date_from subscription_from,
	s.date_to subscription_to
from users u
left join subscriptions s on u.user_id = s.s_user
inner join payment_plans pp on s.payment_plan = pp.payment_plan_id
inner join subscription_types st on pp.subscription_type = st.subscription_type_id;

create or replace view subscriptions_v as
select
	u.first_name || ' ' || u.last_name user,
	s.date_from,
	s.date_to,
	pp.pp_period payment_plan_period,
	pp.amount,
	st.name subscription_type_name,
	st.num_books num_books_at_time,
	st.rental_period
from subscriptions s 
inner join users u on s.s_user = u.user_id
inner join payment_plans pp on s.payment_plan = pp.payment_plan_id
inner join subscription_types st on pp.subscription_type = st.subscription_type_id
order by u.last_name, u.first_name;

