# Большая таблица под нагрузкой, поэтому тяжёлые запросы типа select * from users в неё кидать нельзя
# limit, offset тоже не сильно подходит, т.к. на больших значениях offset серверу придётся перебирать всю таблицу с начала, это оверхед
# Один из вариантов - пройтись по таблице курсором, тогда клиент не будет генерить блокировок, и сервер не будет фетчить результаты огромных выборок в память
# Здесь используется немного костыльная функция для получения текста после разделителя.
# В процедуре get_domains бежим курсором по всем записям, для каждой выделяем домен из адреса, и складываем во временную таблицу

# Как вариант, можно использовать такой запрос:
# select * from users u left join (select id from users limit N offset M) as uids on u.id = uids.id,
# перебирать записи с помощью limit,offset, и средствами ЯП (например php), парсить строки, выделяя домены и собирая их в массив
# это будет быстрее и легче, чем перебор записей запросом select * from users limit N offset M, но всё равно, курсор на больших таблицах выглядит оптимальнее

create function str_split(str varchar(255), delimiter varchar(1), position int) returns varchar(255)
begin
    return replace(
      substring(
        substring_index(str, delimiter, position),
        length(substring_index(str, delimiter, position -1)) + 1
      ),
      delimiter,
      ''
    );
end;

create procedure get_domains()
begin
  declare done int default 0;
  declare i int default 1;
  declare single_email varchar(45);
  declare emails varchar(255);
  declare cur cursor for select email from users;
  declare continue handler for sqlstate '02000' set done = 1;

  create temporary table domains (domain varchar(45) not null, cnt int default 0, primary key (domain));

  open cur;

  cursor_loop: loop
    fetch cur into emails;

    if done = 1 then
      leave cursor_loop;
    end if;

    # i - счётчик email-адресов в одном поле, перечисленных через запятую
    set i = 1;
    parse_emails_loop: loop
      set single_email = str_split(emails, ',', i);

      if single_email = '' then
        leave parse_emails_loop;
      end if;

      insert into domains (domain, cnt) values (split_str(single_email, '@', 2), 1) on duplicate key update cnt = cnt+1;
      set i = i + 1;
    end loop parse_emails_loop;

  end loop cursor_loop;
  close cur;
  select * from domains;
  drop temporary table domains;
end;

call get_domains();
