create table categories (
    id int unsigned not null auto_increment,
    title varchar(32),
    primary key (id)
);

create table articles (
    id int unsigned not null auto_increment,
    category_id int unsigned not null,
    content varchar(243) not null,
    created_at timestamp default current_timestamp,
    primary key (id),
    foreign key (category_id) references categories(id)
);

create table users (
    id int unsigned not null auto_increment,
    name varchar(34),
    primary key (id)
);

create table users_liked_articles (
    article_id int unsigned not null,
    user_id int unsigned not null,
    foreign key (article_id) references articles(id),
    foreign key (user_id) references users(id)
);

# 1. запрос на постановку лайка от юзера к новости;
insert into users_liked_articles (user_id, article_id) values (?, ?);

# 2. запрос на отмену лайка;
delete from users_liked_articles where user_id = ? and article_id = ?;

# 3. выборка пользователей, оценивших новость, желательно учесть что их могут быть тысячи и сделать возможность постраничного вывода;
select u.* from users_liked_articles l left join users u on l.user_id = u.id where l.article_id = ? limit 50 offset 0;

# 4. запрос для вывода ленты новостей;
select * from articles order by created_at desc limit 50 offset 0;

# 5. запрос на добавление поста в ленту.
insert into articles (category_id, content) values (?, ?);