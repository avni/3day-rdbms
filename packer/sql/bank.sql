use threedayrdbms;

create table bank_customers (
       customer_id	    int not null primary key auto_increment,
       customer_name	    varchar(100) not null,
       -- defaults in MySQL must be constant, except for timestamp
       date_joined timestamp not null default current_timestamp
);

create table bank_accounts (
       account_id		int not null auto_increment,
       -- normally we put a REFERENCES constraint with the column def
       -- but MySQL ignores those, so it is at the end of the statement
       customer_id  int not null,
       account_type enum('checking','savings') not null,
       balance	    			       decimal(20,2) not null default 0,
       primary key (account_id),
       foreign key (customer_id) references bank_customers(customer_id)
);

-- note that we need to say how much precision we want, unlike in 
-- Oracle. A simple "numeric" will result in 3.75 being rounded up
-- to 4 upon insertion.

insert into bank_customers (customer_id, customer_name, date_joined)
VALUES 
(1, "Joe Hedge Fund", "2006-12-24"),
(2, "Susie Average", "1997-03-14");

-- note standard YYYY-MM-DD format above

insert into bank_accounts (customer_id, account_type, balance)
VALUES
(1, 'checking', 200000000),
(1, 'savings', 175000000),
(2, 'checking', 4000),
(2, 'savings', 30000);
