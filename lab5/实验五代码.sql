--1．创建一个PROFILE文件pTester，设置锁定用户的登录失败次数为3次，会话的总计连接时间60分钟，口令可用天数30天。
--2．创建一个新用户Tester，密码为Tester123，缺省表空间是tabspace_????。在tabspace_????表空间中可以使用50M空间，指定环境资源文件为pTester。
--3．将角色RESOURCE指派给用户Tester。
--4．用EXP和IMP工具将之前创建的major_????表导入到Tester用户下。
--5．利用PL/SQL语言，以major_????表为例，编写一个存储过程实现针对单张表的逻辑数据导出功能，要求将给定表的数据转换成SQL语言的Insert语句，表的结构转换成SQL语言的Create Table语句，并保存在文件中。该过程以要导出的表名和保存SQL语句的文件名为参数。

--1．创建一个PROFILE文件pTester，设置锁定用户的登录失败次数为3次，
--   会话的总计连接时间60分钟，口令可用天数30天。
drop profile Ptester;
create profile Ptester limit FAILED_LOGIN_ATTEMPTS 3
connect_time 60
password_lock_time 30;

--2．创建一个新用户Tester，密码为Tester123，缺省表空间是tabspace_????。
--  在tabspace_????表空间中可以使用50M空间，指定环境资源文件为pTester。
create user U_Tester
identified by Tester123
default tablespace tabSpace_W125
quota 50M on tabSpace_W125
profile Ptester;

--3．将角色RESOURCE指派给用户Tester。
grant resource to U_Tester;
grant create session, dba to U_Tester;

--4．用EXP和IMP工具将之前创建的major_????表导入到Tester用户下。
--exp why/281612 file=major.dmp tables=T_major_W125
--imp U_Tester/Tester123 file=major.dmp full=y ignore=y

--将导出的内容放到dir下的指定文件中
create directory dir as '/home/oracle/';
grant read, write on directory dir to why;

--5．利用PL/SQL语言，以major_????表为例，
--  编写一个存储过程实现针对单张表的逻辑数据导出功能，
--  要求将给定表的数据转换成SQL语言的Insert语句，
--  表的结构转换成SQL语言的Create Table语句，并保存在文件中。
--  该过程以要导出的表名和保存SQL语句的文件名为参数。
create or replace procedure P_expLogic (tabName in char, fileName in char)
as
    --查询主键
    cursor primKey is
        select cu.COLUMN_NAME from user_cons_columns cu, user_constraints au
        where cu.constraint_name = au.constraint_name and au.constraint_type = 'P' AND cu.table_name = tabName;
    primaryKey varchar(256);
    cnt number := 0;
    --添加check约束
    cursor ConstraintCur is
        select SEARCH_CONDITION from user_constraints c
        where c.table_name=tabName and SEARCH_CONDITION is not null;
    constraint varchar(1024);
    --添加外键约束
    cursor refKeyCur is
        select 'foreign key  '||
           '(' || a1.column_name || ') references ' ||
            t2.table_name || '('
            || a2.column_name || ')'
        from user_constraints t1, user_constraints t2, user_cons_columns a1, user_cons_columns a2
        where t1.r_constraint_name = t2.constraint_name and
              t1.constraint_name = a1.constraint_name and
              t1.r_constraint_name = a2.constraint_name and
              t1.TABLE_NAME = tabName;
    refCnt number := 0;
    --一个模版
    refTemp varchar(32) := ' constraint rf';
    refVal varchar(512)  ;
    --构建create语句所需要的变量
    cursor attriCur is
        select * from USER_TAB_COLUMNS where TABLE_NAME = tabName;
    attris USER_TAB_COLUMNS%rowtype;
    createSQL varchar(2048) := 'create table ' || tabName || '(';
    --构建insert语句所需要的变量
    insertSQL varchar(1024) := 'insert into ' || tabName || '(';
    insertSQLTemp varchar(256);
    insertVal varchar2(1024);
    valCur sys_refcursor;
    val varchar(256);
    sqlline varchar(1024);
    --文件操作
    fileHandle UTL_FILE.file_type;
begin
    --找到主键
    open primKey;
    fetch primKey into primaryKey;
    --文件操作
    fileHandle := UTL_FILE.FOPEN('DIR', fileName, 'a');
    --构建create语句
    open attriCur;
    fetch attriCur into attris;
    while attriCur%found loop
        --构造主键
        if attris.CHAR_LENGTH = 0 then
            createSQL := createSQL || attris.COLUMN_NAME || ' ' || attris.DATA_TYPE;
            else
            createSQL := createSQL || attris.COLUMN_NAME || ' ' || attris.DATA_TYPE || '(' || attris.CHAR_LENGTH || ')';
            end if ;
        if attris.COLUMN_NAME = primaryKey then
            createSQL := createSQL || ' primary key ';
        end if;
        --构造create主体
        insertSQL := insertSQL || attris.COLUMN_NAME;
        insertVal := insertVal || ''''''''' ||' ||attris.COLUMN_NAME || '||''''''''';
        fetch attriCur into attris;
        if attriCur%found then
            createSQL := createSQL || ', ';
            insertSQL := insertSQL || ', ';
            insertVal := insertVal || ' || '','' || ';
        end if;
        end loop;

    --添加外键约束
    open refKeyCur;
    fetch refKeyCur into refVal;
    --完善性构造
    if refKeyCur%found then
        createSQL := createSQL || ',';
    end if;
    while refKeyCur%found loop
        createSQL := createSQL || refTemp || refCnt || ' ' || refVal;
        refCnt := refCnt + 1;
        fetch refKeyCur into refVal;
        if refKeyCur%found then
            createSQL := createSQL || ', ';
        end if;
        end loop;

    --添加constrains约束
    open ConstraintCur;
    fetch ConstraintCur into constraint;
    --完善性构造
    if ConstraintCur%found then
        createSQL := createSQL || ',';
    end if;
    while ConstraintCur%found loop
        createSQL := createSQL || ' constraint ch' || cnt || ' check (' || constraint || ')';
        cnt := cnt + 1;
        fetch ConstraintCur into constraint;
        if ConstraintCur%found then
            createSQL := createSQL || ', ';
        end if;
        end loop;

    --完善create语句
    createSQL := createSQL || ');';
    insertSQL := insertSQL || ') values (';
    close attriCur;
    insertSQLTemp := insertSQL;

    --放入createSQL
    UTL_FILE.PUT_LINE(fileHandle, createSQL);

    --处理插入的语句
    sqlline := 'select ' || insertVal || ' from ' || tabName;
    open valCur for sqlline;
    loop
        fetch valCur into val;
        exit when valCur%notfound;
        insertSQL := insertSQL || val || ');';
        UTL_FILE.PUT_LINE(fileHandle, insertSQL);
        DBMS_OUTPUT.PUT_LINE(insertSQL);
        insertSQL := insertSQLTemp;
    end loop;
    UTL_FILE.FCLOSE(fileHandle);
    close valCur;
end;

--测试
declare
begin
    P_expLogic('T_STUD_W125', 'a');
end;


--查询表的主键
select cu.COLUMN_NAME from user_cons_columns cu, user_constraints au where cu.constraint_name = au.constraint_name and
au.constraint_type = 'P' AND cu.table_name = 'T_MAJOR_W125';

--查询所有约束，很可惜，外键只有R，但是不知道引用的是谁
select * from user_cons_columns cl where cl.constraint_name in
    (select CONSTRAINT_NAME from user_constraints c where c.table_name='T_STUD_W125' and CONSTRAINT_TYPE = 'R');

--查询外键约束，bingo
select t2.table_name as "TABLE_NAME(R)",
       a1.column_name,
       a2.column_name as "COLUMN_NAME(R)"
from user_constraints t1, user_constraints t2, user_cons_columns a1, user_cons_columns a2
where t1.r_constraint_name = t2.constraint_name and
      t1.constraint_name = a1.constraint_name and
      t1.r_constraint_name = a2.constraint_name and
      t1.TABLE_NAME = 'T_STUD_W125';

select
       'T_STUD_W125(' || a1.column_name || ') references ' ||
        t2.table_name || '('
        || a2.column_name || ')'
    from user_constraints t1, user_constraints t2, user_cons_columns a1, user_cons_columns a2
    where t1.r_constraint_name = t2.constraint_name and
          t1.constraint_name = a1.constraint_name and
          t1.r_constraint_name = a2.constraint_name and
          t1.TABLE_NAME = 'T_STUD_W125';

--板子
select * from T_stud_W125;
drop table T_stud_W125;
create table T_stud_W125 (
    Sno varchar(16) primary key ,
    Sname varchar(16),
    Ssex varchar(16),
    Stel varchar(16),
    --对邮箱格式进行正则匹配
    Semail varchar(16) ,
    Sbirthday date ,
    --定义班长的学号是一个外键
    MoniNo varchar(16) references T_stud_W125(Sno),
    --定义专业号是一个外键
    MajorNo varchar(2) references T_major_W125(MajorNo),
    sum_evaluation number,
    constraint ch1 check ( Ssex in ('Male', 'Female', 'Other')),
    constraint ch2 check ( Semail like '%@%.%'),
    constraint ch3 check ( to_char(Sbirthday) >= '19990731' ),
    constraint ch4 check ( "SNAME" IS NOT NULL )
);
insert into T_stud_W125 values ('8208181125', '王灏洋',
                                'Male', '13565759137', '165788297@qq.com', '28-4月-2000', '8208181125', '08', 0);
insert into T_stud_W125 values ('8208181126', '王一',
                                'Male', '13565759138', '165788298@qq.com', '29-4月-2000', '8208181125', '08', 0);
insert into T_stud_W125 values ('8208181127', '王二',
                                'Male', '13565759139', '165788299@qq.com', '30-4月-2000', '8208181125', '08', 0);
insert into T_stud_W125 values ('8208181128', '王三',
                                'Male', '13565759140', '165788300@qq.com', '20-4月-2000', '8208181125', '08', 0);
insert into T_stud_W125 values ('8208181129', '王四',
                                'Male', '13565759141', '165788301@qq.com', '21-4月-2000', '8208181125', '08', 0);


--实验报告导出数据
create table T_MAJOR_W125(MDEAN VARCHAR2(64), MLOC VARCHAR2(64), MNAME VARCHAR2(64), MAJORNO VARCHAR2(2) primary key , constraint ch0 check ( MLOC in ('主校区', '南校区', '新校区', '铁道校区', '湘雅校区') ));
insert into T_MAJOR_W125(MDEAN, MLOC, MNAME, MAJORNO) values ('刘老师','主校区','计科','09');
insert into T_MAJOR_W125(MDEAN, MLOC, MNAME, MAJORNO) values ('张老师','新校区','大数据','07');
insert into T_MAJOR_W125(MDEAN, MLOC, MNAME, MAJORNO) values ('贺老师','南校区','物联网','08');
create table T_STUD_W125(SNO VARCHAR2(16) primary key , SNAME VARCHAR2(16), SSEX VARCHAR2(16), STEL VARCHAR2(16), SEMAIL VARCHAR2(16), SBIRTHDAY DATE, MONINO VARCHAR2(16), MAJORNO VARCHAR2(2), SUM_EVALUATION NUMBER, constraint rf0 foreign key  (MAJORNO) references T_MAJOR_W125(MAJORNO),  constraint rf1 foreign key  (MONINO) references T_STUD_W125(SNO), constraint ch0 check ( "SNAME" IS NOT NULL ),  constraint ch1 check ( to_char(Sbirthday) >= '19990731' ),  constraint ch2 check ( Semail like '%@%.%'),  constraint ch3 check ( Ssex in ('Male', 'Female', 'Other')));
insert into T_STUD_W125(SNO, SNAME, SSEX, STEL, SEMAIL, SBIRTHDAY, MONINO, MAJORNO, SUM_EVALUATION) values ('8208181125','王灏洋','Male','13565759137','165788297@qq.com','28-APR-00','8208181125','08','0');
insert into T_STUD_W125(SNO, SNAME, SSEX, STEL, SEMAIL, SBIRTHDAY, MONINO, MAJORNO, SUM_EVALUATION) values ('8208181126','王一','Male','13565759138','165788298@qq.com','29-APR-00','8208181125','08','0');
insert into T_STUD_W125(SNO, SNAME, SSEX, STEL, SEMAIL, SBIRTHDAY, MONINO, MAJORNO, SUM_EVALUATION) values ('8208181127','王二','Male','13565759139','165788299@qq.com','30-APR-00','8208181125','08','0');
insert into T_STUD_W125(SNO, SNAME, SSEX, STEL, SEMAIL, SBIRTHDAY, MONINO, MAJORNO, SUM_EVALUATION) values ('8208181128','王三','Male','13565759140','165788300@qq.com','20-APR-00','8208181125','08','0');
insert into T_STUD_W125(SNO, SNAME, SSEX, STEL, SEMAIL, SBIRTHDAY, MONINO, MAJORNO, SUM_EVALUATION) values ('8208181129','王四','Male','13565759141','165788301@qq.com','21-APR-00','8208181125','08','0');