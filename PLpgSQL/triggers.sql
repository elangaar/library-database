create or replace function get_borrowing_availability()
	returns trigger
	language plpgsql
as
$$
declare
	book_status_v record;
	borrowing_v record;
	booking_v record;
	order_v record;
begin
	
	-- get a status of a book in the library
	select is_borrowed,
		is_booked,
		is_ordered
	into book_status_v
	from books
	where book_id = new.book;
	
	-- when the book is ordered
	if book_status_v.is_ordered then
		select o_user,
			date_to
		into order_v
		from orders o 
		where
			o.book = new.book
			and o.date_from <= current_date 
			and o.date_to >= current_date;
			raise notice '%', book_status_v.is_ordered;
		-- when book is ordered by another reader
		if new.b_user != order_v.o_user then
			raise exception 'This book is ordered by another reader.';
		end if;
		-- when book is ordered by current reader
		raise exception 'This book is ordered by reader';
	end if;

	-- when book is borrowed and not ordered
	if book_status_v.is_borrowed and not book_status_v.is_ordered then
		select *
--			(b.rental_date + st.rental_period)::date estimated_return_date,
--			b.b_user b_user
--		into borrowing_v
		from borrowings b 
		inner join users u 
		on b.b_user = u.user_id 
		inner join subscriptions s 
		on u.user_id = s.s_user 
		inner join payment_plans pp 
		on s.payment_plan = pp.payment_plan_id 
		inner join subscription_types st 
		on pp.subscription_type = st.subscription_type_id
		where
			b.return_date is null
			and b.book = 4;
--			and b.book = new.book;
		raise notice '%', borrowing_v;
		-- when book is borrowed by another reader
		if new.b_user != borrowing_v.b_user then
			raise exception 'This book is borrowed by another reader to %', borrowing_v.estimated_return_date;
		end if;
		-- when book is borrowed by current reader
		raise exception 'The book has been borrowed by reader to %', borrowing_v.estimated_return_date;
	end if;
	
	-- when the book is booked
	if book_status_v.is_booked then
		select b_user,
			date_to
		into booking_v
		from bookings b 
		where
			b.book = new.book
			and b.date_from <= current_date 
			and b.date_to >= current_date;
		-- when book is booked by another reader
		if new.b_user != booking_v.b_user then
			raise exception 'This book is booked by another reader to %.', booking_v.date_to;
		end if;
		-- when book is booked by current reader
		raise exception 'This book is booked by reader to %', booking_v.date_to;
	end if;
	return new;
end;
$$

create or replace trigger before_borrowing_book
	before insert 
	on borrowings
	for each row 
	execute procedure get_borrowing_availability();
