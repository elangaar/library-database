-- FOREIGN KEY CONSTRAINTS

alter table books
	add constraint books_languages_fkey
	foreign key ("language")
	references languages (language_id)
	on delete set null;
	
alter table books
	add constraint books_publishers_fkey
	foreign key (publisher)
	references publishers (publisher_id)
	on delete set null;

alter table book_subcategories 
	add constraint book_subcategories_book_categories_fkey
	foreign key (category)
	references book_categories (book_category_id)
	on delete cascade;

alter table books_book_subcategories 
	add constraint books_book_subcategories_book_subcategories_fkey
	foreign key (book_subcategory)
	references book_subcategories (book_subcategory_id)
	on delete cascade;

alter table books_book_subcategories
	add constraint books_book_subcategories_books_fkey
	foreign key (book)
	references books (book_id)
	on delete restrict;

alter table authors 
	add constraint authors_nationalities_fkey
	foreign key (nationality)
	references nationalities (nationality_id)
	on delete set null;

alter table books_authors
	add constraint books_authors_authors_fkey
	foreign key (author)
	references authors (author_id)
	on delete cascade;

alter table books_authors
	add constraint books_authors_books_fkey
	foreign key (book)
	references books (book_id)
	on delete restrict;

alter table bookings 
	add constraint bookings_books_fkey
	foreign key (book)
	references books (book_id)
	on delete cascade;

alter table bookings
	add constraint bookings_users_fkey
	foreign key (b_user)
	references users (user_id)
	on delete cascade;

alter table orders
	add constraint orders_books_fkey
	foreign key (book)
	references books (book_id)
	on delete cascade;

alter table orders
	add constraint orders_users_fkey
	foreign key (o_user)
	references users (user_id)
	on delete cascade;

alter table borrowings 
	add constraint borrowings_books_fkey
	foreign key (book)
	references books (book_id)
	on delete cascade;

alter table borrowings 
	add constraint borrowings_bookings_fkey
	foreign key (booking)
	references bookings (booking_id)
	on delete cascade;

alter table borrowings
	add constraint borrowings_users_fkey
	foreign key (b_user)
	references users (user_id)
	on delete cascade;

alter table borrowings 
	add constraint borrowings_orders_fkey 
	foreign key (b_order)
	references orders (order_id)
	on delete cascade;

alter table subscriptions 
	add constraint subscriptions_users_fkey
	foreign key (s_user)
	references users (user_id)
	on delete cascade;

alter table subscriptions
	add constraint subscriptions_payment_plans_fkey
	foreign key (payment_plan)
	references payment_plans (payment_plan_id)
	on delete cascade;

alter table payment_plans
	add constraint payment_plans_subscription_types_fkey
	foreign key (subscription_type)
	references subscription_types (subscription_type_id)
	on delete cascade;


-- CHECK CONSTRAINTS

alter table borrowings
	add constraint borrowings_source_check
	check (
		(book is null and booking is null and b_order is not null)
		or (book is null and booking is not null and b_order is null)
		or (book is not null and booking is null and b_order is null)
	);

