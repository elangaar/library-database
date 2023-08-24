create or replace procedure return_book(book_id_p int, user_id_p int)
language plpgsql
as $$
declare 
	book_id_v int;
begin
	select book
	into book_id_v
	from borrowings
	where book = book_id_p
		and b_user = user_id_p
		and rental_date < current_date
		and return_date > current_date;
	
	if not found then
		raise exception 'book with id % is not currently borrowed by reader %', book_id_p, user_id_p;
	end if;
	update books 
	set is_borrowed = false 
	where book_id = book_id_v;
end;
$$

call return_book(3, 2);
