create or replace function get_borrowing_availability()
	returns trigger
	language plpgsql
as
$$
declare
	book_status_v record;
	borrowing_v record;
	booking_v record;
	first_order_v int;
	order_v record;
begin
	-- get a status of a book in the library
	select is_borrowed,
		is_booked,
		is_ordered
	into book_status_v
	from books
	where book_id = new.book;
	
	-- when book is borrowed
	if book_status_v.is_borrowed then
		select
			return_date,
			b_user
		into borrowing_v
		from borrowings
		where
			rental_date <= current_date
			and return_date >= current_date
			and book = new.book;
		-- when book is borrowed by another reader
		if new.b_user != borrowing_v.b_user or borrowing_v.b_user is null then
			raise exception 'This book has been borrowed by another reader to %', borrowing_v.return_date;
		end if;
		-- when book is borrowed by current reader
		raise exception 'The book has been borrowed by reader to %', borrowing_v.return_date;
	end if;

	-- when the book is booked
	if book_status_v.is_booked then
		select b_user,
			date_to
		into booking_v
		from bookings
		where
			book = new.book
			and is_realized = false;
		-- when book is booked by another reader
		if new.b_user != booking_v.b_user then
			raise exception 'This book is booked by another reader to %.', booking_v.date_to;
		end if;
	end if;

	-- when the book is ordered and not borrow or booked
	if book_status_v.is_ordered then
		select order_id
		into first_order_v
		from orders
		where 
			book = new.book
			and is_realized = false
		order by date_from
		fetch first row only;
	
		select order_id,
			o_user,
			date_to
		into order_v
		from orders
		where 
			book = new.book
			and order_id = first_order_v
			and is_realized = false;
		-- when book is ordered by another reader at the beginning of the queue
		if new.b_user != order_v.o_user then
			raise exception 'This book is ordered by another reader.';
		end if;
	end if;

	return new;
end;
$$;


create or replace function get_booking_availability()
	returns trigger
	language plpgsql
as
$$
declare
	book_status_v record;
	borrowing_v record;
	booking_v record;
	first_order_v int; 
	order_v record;
begin
	-- get a status of a book in the library
	select is_borrowed,
		is_booked,
		is_ordered
	into book_status_v
	from books
	where book_id = new.book;
	
	-- when book is borrowed
	if book_status_v.is_borrowed then
		select
			return_date,
			b_user
		into borrowing_v
		from borrowings
		where
			rental_date <= current_date
			and return_date >= current_date
			and book = new.book;
		-- when book is borrowed by another reader
		if new.b_user != borrowing_v.b_user or borrowing_v.b_user is null then
			raise exception 'This book has been borrowed by another reader to %', borrowing_v.return_date;
		end if;
		-- when book is borrowed by current reader
		raise exception 'The book has been borrowed by reader to %', borrowing_v.return_date;
	end if;

	-- when the book is booked
	if book_status_v.is_booked then
		select b_user,
			date_to
		into booking_v
		from bookings
		where
			book = new.book
			and is_realized = false;
		-- when book is booked by another reader
		if new.b_user != booking_v.b_user then
			raise exception 'This book is booked by another reader to %.', booking_v.date_to;
		end if;
		-- when book is booked by current reader
		raise exception 'This book is booked by reader to %', booking_v.date_to;
	end if;

	-- when the book is ordered and not borrow or booked
	if book_status_v.is_ordered then
		select order_id
		into first_order_v
		from orders
		where 
			book = new.book
			and is_realized = false
		order by date_from
		fetch first row only;
	
		select order_id,
			o_user,
			date_to
		into order_v
		from orders
		where 
			book = new.book
			and order_id = first_order_v
			and is_realized = false;
		-- when book is ordered by another reader at the beginning of the queue
		if new.b_user != order_v.o_user then
			raise exception 'This book is ordered by another reader.';
		end if;
		-- when book is ordered by current reader at the beginning of the queue
		raise exception 'This book is ordered by reader.';
	end if;
	return new;
end;
$$;


create or replace trigger before_borrowing_book
	before insert 
	on borrowings
	for each row 
	execute procedure get_borrowing_availability();


create or replace trigger before_booking_book
	before insert 
	on bookings
	for each row 
	execute procedure get_booking_availability();


create or replace function after_borrowing_book()
	returns trigger 
	language plpgsql
as
$$
declare 
	book_id_v int;
	rental_period_v interval;
	book_status_v record;
	booking_v int;
	order_v int;
	first_order_v int;
begin
	-- get a status of a book in the library
	select is_borrowed,
		is_booked,
		is_ordered
	into book_status_v
	from books
	where book_id = new.book;

	-- get the borrowed book id
	select book_id
	into book_id_v
	from books
	where
		book_id = new.book;
	
	-- update book status fields
	update books 
	set is_borrowed = true,
		is_booked = false,
		is_ordered = false
	where
		book_id = book_id_v;
	
	-- auto completion of the return_date field in the borrowings table depending on the reader's subscription
	select rental_period 
	into rental_period_v
	from subscriptions s 
	inner join payment_plans pp
	on s.payment_plan = pp.payment_plan_id 
	inner join subscription_types st 
	on pp.subscription_type = st.subscription_type_id 
	where
		s.s_user = new.b_user;
	
	update borrowings
	set return_date = rental_date + rental_period_v
	where
		borrowing_id = new.borrowing_id;

	-- checking if the book was booked or ordered and then filling in the fields in the tables accordingly
	if book_status_v.is_booked then
		select booking_id
		into booking_v
		from bookings
		where 
			book = new.book
			and b_user = new.b_user
			and is_realized = false;
		
		update borrowings 
		set booking = booking_v
		where
			borrowing_id = new.borrowing_id;
		
		update bookings
		set date_to = current_date,
			is_realized = true
		where booking_id = booking_v;
	
	-- checking if the book was is ordered and not borrowed or booked then filling in the fields in the tables accordingly
	elsif not book_status_v.is_borrowed and not book_status_v.is_booked and book_status_v.is_ordered then
		select order_id
		into order_v
		from orders
		where
			book = new.book
			and o_user = new.b_user
			and is_realized = false;
	
		update orders
		set date_to = current_timestamp,
			is_realized = true
		where
			order_id = order_v;
	end if;
	return new;
end;
$$;


create or replace function after_booking_book()
	returns trigger 
	language plpgsql
as
$$
declare 
	book_id_v int;
begin
	-- get the booked book id
	select book_id
	into book_id_v
	from books
	where
		book_id = new.book;
	
	-- update book status fields
	update books 
	set is_borrowed = false,
		is_booked = true,
		is_ordered = false
	where
		book_id = book_id_v;
	
	-- auto completion of the return_date field in the booking table
	update bookings
	set date_to = current_date + interval '5 days'
	where
		booking_id = new.booking_id;
	
	return new;
end;
$$;


create or replace trigger after_borrowing_book
	after insert
	on borrowings
	for each row 
	execute procedure after_borrowing_book();


create or replace trigger after_booking_book
	after insert
	on bookings
	for each row 
	execute procedure after_booking_book();
