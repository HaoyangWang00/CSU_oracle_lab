--1.以常用“名字大全”与“百家姓”数据集为基础，
-- 生成不小于1千万条stud记录，
-- 要求，姓名的重复率不超过10%，学号以ABCD17EFGH为格式模板，即其中17是固定的，
-- AB为从01到80，CD为从01到90，EF为01到50，GH为01到32；
-- 性别中，男、女占比为99%到99.5%。TEL与E-mail不作要求，但不能全空。
-- Birthday要求从‘19940101’到‘19990731’分布。
-- 要求记录ORACLE数据文件的大小变化。（需要编制过程）

--建立精确记录时间过程，方便记录时间
create table T_recordTime_W125(
    things varchar2(128),
    time varchar2(32)
);

create or replace procedure P_recordTime_W125(input varchar2)
as
    temp varchar2(32);
begin
    select to_char(systimestamp, 'yyyy-mm-dd hh24:mi:ss.ff') into temp from dual;
    insert into T_recordTime_W125(things) values (input);
    update T_recordTime_W125 set time = temp where things = input;
end;

show error;
--First execute time recording procedure
col things format a64;
col time format a32;
select * from T_recordTime_W125;

--1 创建基本姓名表
drop table Sname;
create table Sname(Sname varchar(32));

--2 插入基本姓名
--sqlldr why/281612 control = /home/oracle/name.csv
select * from Sname;

--3 制造足够多的姓名，为名字的每个字创造视图
drop view V_name1_W125;
drop view V_name2_W125;
drop view V_name3_W125;
drop view V_name12_W125;
drop view V_name123_W125;
create view V_name1_W125 as select * from (select distinct substr(sname,1,1) na1 from Sname order by dbms_random.VALUE()) where rownum<=500;
create view V_name2_W125 as select * from (select distinct substr(sname,2,1) na2 from Sname order by dbms_random.VALUE()) where rownum<=1200;
create view V_name3_W125 as select * from (select distinct substr(sname,3,1) na3 from Sname order by dbms_random.VALUE()) where rownum<=20;
create view V_name12_W125 as select concat(na1,na2) na12 from V_name1_W125,V_name2_W125;
create view V_name123_W125 as select concat(na12,na3) na123 from V_name12_W125,V_name3_W125;

--4 创建T_studName_W125表
drop table T_studName_W125;
create table T_studName_W125(Sname varchar(16));

--5 为姓名表T_studName_W125插入12600000条学生姓名
insert into T_studName_W125(Sname) select na12 from V_name12_W125;
insert into T_studName_W125(Sname) select na123 from V_name123_W125;
--完成为姓名表生成12600000条记录
select count(*) from V_name123_W125;

--select * from V_name12_W125 where ROWNUM < 100;

--6.生成规范的学号表
--每次生成两位，分四批生成
drop table T_studSno_gh_W125;
drop table T_studSno_ef_W125;
drop table T_studSno_cd_W125;
drop table T_studSno_ab_W125;
create table T_studSno_gh_W125 (Sno number(10));
create table T_studSno_ef_W125 (Sno number(10));
create table T_studSno_cd_W125 (Sno number(10));
create table T_studSno_ab_W125 (Sno varchar2(10));
--建立过程：
declare
i int;
begin
for i in 1..32 loop
	insert into T_studSno_gh_W125 values(i);
end loop;
for i in 1..50 loop
	insert into T_studSno_ef_W125 select 170000 + i * 100 + T_studSno_gh_W125.sno from T_studSno_gh_W125;
	commit;
end loop;
for i in 1..90 loop
	insert into T_studSno_cd_W125 select i * 1000000 + T_studSno_ef_W125.sno from T_studSno_ef_W125;
	commit;
end loop;
for i in 1..80 loop
	insert into T_studSno_ab_W125 select substr(10000000000 + i * 100000000 + T_studSno_cd_W125.sno, 2, 10) from T_studSno_cd_W125;
	commit;
end loop;
end;
--完成11520000条学号ID生成


--7.1批量处理sex, tel, email, birthday等数据
--   产生随机性别：男、女占比为99%到99.5%
--   在性别表T_sex_W125中，143人，男女分别71人，一人性别为其它。随机查询一条记录时，可使男、女占比为99.3%
--   函数F_getSex_W125返回值为随机性别
create or replace function F_getSex_W125 return varchar2
is
f_numb number;
f_sex varchar2(8);
begin
    --dual是虚拟表，主要用来借用以调用系统函数
    select trunc(DBMS_RANDOM.VALUE(1, 143)) into f_numb from dual;
    if f_numb <= 71 then
        f_sex := '男';
        elsif f_numb <= 142 then
            f_sex := '女';
        else f_sex := '其他';
    end if;
    return f_sex;
end;

show error

--7.2产生随机电话
--   函数F_getTel_W125会返回一个随机手机号
drop table T_tel_W125;
create table T_tel_W125(tel varchar2(4));
insert into T_tel_W125 values('132');
insert into T_tel_W125 values('135');
insert into T_tel_W125 values('156');
insert into T_tel_W125 values('151');
insert into T_tel_W125 values('138');
insert into T_tel_W125 values('139');
insert into T_tel_W125 values('183');
insert into T_tel_W125 values('187');
insert into T_tel_W125 values('153');
insert into T_tel_W125 values('150');
insert into T_tel_W125 values('186');
insert into T_tel_W125 values('188');
create or replace function F_getTel_W125 return varchar2
is
    getTel varchar2(12);
    numb_head varchar2(4);
    numb_other varchar2(16);
begin
    select tel into numb_head from (select tel from T_tel_W125 order by DBMS_RANDOM.VALUE()) where rownum = 1 ;
    select substr(cast(DBMS_RANDOM.VALUE() as varchar2(32)), 3, 8) into numb_other from dual;
    getTel := numb_head || numb_other;
    return getTel;
end;
show error

--7.3随机产生邮箱
--   函数F_getEmail_W125会返回一个随机邮箱号
drop table T_email_W125;
create table T_email_W125 (email varchar2(16));
insert into T_email_W125 values('126');
insert into T_email_W125 values('139');
insert into T_email_W125 values('sohu');
insert into T_email_W125 values('sina');
insert into T_email_W125 values('163');
insert into T_email_W125 values('foxmail');
insert into T_email_W125 values('qq');
insert into T_email_W125 values('qq');
insert into T_email_W125 values('qq');
insert into T_email_W125 values('qq');
insert into T_email_W125 values('qq');
insert into T_email_W125 values('qq');
insert into T_email_W125 values('qq');
insert into T_email_W125 values('qq');
insert into T_email_W125 values('qq');
insert into T_email_W125 values('qq');
insert into T_email_W125 values('qq');
insert into T_email_W125 values('qq');

create or replace function F_getEmail_W125 return varchar2
is
    getEmail varchar2(32);
    emName varchar2(16);
    emOwn varchar2(16);
begin
    select substr(cast(DBMS_RANDOM.VALUE() as varchar2(32)), 3, 11) into emName from dual;
    select email into emOwn from (select email from T_email_W125 order by DBMS_RANDOM.VALUE()) where rownum = 1;
    getEmail := emName || '@' || emOwn || '.com';
    return getEmail;
end;
show error

--7.4产生随机生日
--   函数f_getBirthday_j432会返回一个在[19940101,19990701]时间内的日期
create or replace function F_getBirthday_W125 return date
is
birthday date;
begin
    select to_date(trunc(DBMS_RANDOM.VALUE(2449354, 2451186)), 'J') into birthday from dual;
    return birthday;
end;
show error
--性别、手机号、邮箱、出生日期等随机函数生成完毕


--7.5生成完整学生表除学号和姓名之外的所有信息
--建立基本信息模板表
create table T_sequenceId(
    id number(10),
    sex varchar2(32),
    tel varchar2(32),
    email varchar2(32),
    birthday date
);

--存储大量的学生其他信息，千万级以上
create table T_studOtherInformation_w125 (
    id number(16),
    sex varchar2(32),
    tel varchar2(32),
    email varchar2(32),
    birthday date
);

--生成1万条数据模版
begin
    delete from T_sequenceId;
    for i in 0..9999 loop
        insert into T_sequenceId(id, sex, tel, email, birthday) values (i, F_getSex_W125(), F_getTel_W125(), F_getEmail_W125(), F_getBirthday_W125());
        end loop;
end;
select * from T_sequenceId where ROWNUM < 100;

--每1w条数据插入一次，得到12000000数据
begin
    delete from T_studOtherInformation_w125;
    for i in 1..1200 loop
        insert into T_studOtherInformation_w125(id, sex, tel, email, birthday) select i * 10000 + T_sequenceId.id as MSISDN, T_sequenceId.sex, T_sequenceId.tel, T_sequenceId.email, T_sequenceId.birthday from T_sequenceId;
        commit;
        end loop;
end;
--完成生成12000000条其他信息生成


--学生信息表没有主键，生成11520000条记录，开始时间
create table T_student_W125 (
    Sno varchar2(10),   --学生学号
    Sname varchar2(32),
    sex varchar2(32),
    tel varchar2(32),
    email varchar2(32),
    birthday date
);

--生成完整的学生信息表：将学号，姓名和其他信息，放在一起
insert into T_student_W125(Sno, Sname, sex, tel, email, birthday)
select X.Sno, A.Sname, B.sex, B.tel, B.email, B.birthday
from (select rownum rownum_X, Sno from T_studSno_ab_W125) X, (select rownum rownum_A, Sname from T_studName_W125) A, (select rownum rownum_B, sex, tel, email, birthday from T_studOtherInformation_w125) B
where rownum_A = rownum_B and rownum_A = rownum_X;
--学生信息表没有主键，生成11520000条记录，完成时间


--学生信息表有主键，生成11520000条记录，开始时间
drop table T_student_W125;
create table T_student_W125 (
    Sno varchar2(10) primary key , --学生学号
    Sname varchar2(32),
    sex varchar2(32),
    tel varchar2(32),
    email varchar2(32),
    birthday date
);
insert into T_student_W125(Sno, Sname, sex, tel, email, birthday)
select X.Sno, A.Sname, B.sex, B.tel, B.email, B.birthday
from (select rownum rownum_X, Sno from T_studSno_ab_W125) X, (select rownum rownum_A, Sname from T_studName_W125) A, (select rownum rownum_B, sex, tel, email, birthday from T_studOtherInformation_w125) B
where rownum_A = rownum_B and rownum_A = rownum_X;
--学生信息表有主键，生成11520000条记录，完成时间


--为学生表添加其他约束
alter table T_student_W125 add constraint ck_student_sex check ( sex in ('男', '女', '其他'));
alter table T_student_W125 add constraint ck_student_email check ( email like '%@%.%');
alter table T_student_W125 add constraint ck_student_birthday check ( birthday >= to_date('19940101', 'yyyymmdd') and birthday <= to_date('19990731', 'yyyymmdd'));

--随机查询100名同学信息
set linesize 300;
set pagesize 1000;
col sno format a11;
col sname format a8;
col sex format a6;
col email format a26;
col tel format a12;

alter session set nls_date_format = 'yyyy-mm-dd';
select * from (select * from T_student_W125 order by dbms_random.value()) where rownum <= 100;
select count(*) from T_student_W125;

col things format a64;
col time format a32;
--没有索引时，进行查询
select * from T_recordTime_W125;
exec P_recordTime_W125('没有姓名索引，查询一条姓名的开始时间')
select * from T_student_W125 where sname='辛智';
exec P_recordTime_W125('没有姓名索引，查询一条姓名的结束时间')

exec P_recordTime_W125('没有姓名索引，查询某一姓氏人数的开始时间')
select * from T_student_W125 where sname like '周%';
exec P_recordTime_W125('没有姓名索引，查询某一姓氏人数的结束时间')

exec P_recordTime_W125('没有姓名索引，统计某一姓氏人数的开始时间')
select count(*) from T_student_W125 where sname like '周%';
exec P_recordTime_W125('没有姓名索引，统计某一姓氏人数的结束时间')

exec P_recordTime_W125('没有姓名索引，统计某一姓名第二个字相同人数的开始时间')
select count(*) from T_student_W125 where sname like '_平%';
exec P_recordTime_W125('没有姓名索引，统计某一姓名第二个字相同人数的结束时间')
--统计以姓名为区分
select substr(Sname, 1, 1), count(*) from T_student_W125 group by substr(Sname, 1, 1);

--有索引时，进行查询
drop index i_stuSname_W125;
create index indexName on T_student_W125(Sname);
exec P_recordTime_W125('开始创建姓名索引')
create index i_stuSname_W125 on T_student_W125(sname);
exec P_recordTime_W125('完成创建姓名索引')

exec P_recordTime_W125('有姓名索引，查询一条姓名，开始时间')
select * from T_student_W125 where sname='辛智';
exec P_recordTime_W125('有姓名索引，查询一条姓名，结束时间')

exec P_recordTime_W125('有姓名索引，查询某一姓氏人数的开始时间')
select * from T_student_W125 where sname like '周%';
exec P_recordTime_W125('有姓名索引，查询某一姓氏人数的结束时间')

exec P_recordTime_W125('有姓名索引，统计某一姓氏人数的开始时间')
select count(*) from T_student_W125 where sname like '周%';
exec P_recordTime_W125('有姓名索引，统计某一姓氏人数的结束时间')

exec P_recordTime_W125('有姓名索引，统计某一姓名第二个字相同人数的开始时间')
select count(*) from T_student_W125 where sname like '_平%';
exec P_recordTime_W125('有姓名索引，统计某一姓名第二个字相同人数的结束时间')

exec P_recordTime_W125('没有分区，按学号首位ID统计人数的开始时间')
select count(*) from T_student_W125 where sno like '5%';
exec P_recordTime_W125('没有分区，按学号首位ID统计人数的结束时间')

exec P_recordTime_W125('没有分区，按专业统计人数的开始时间')
select count(*) from T_student_W125 where sno like '______01%';
exec P_recordTime_W125('没有分区，按专业统计人数的结束时间')

select substr(Sname, 1, 1), count(*) from T_student_W125 group by substr(Sname, 1, 1);

--重新创建学生表，并分区
drop table T_student_W125;
create table T_student_W125(
	Sno varchar2(10) primary key,--学生学号
	Sname varchar2(32),
	sex varchar2(32),
	tel varchar2(32),
	email varchar2(32),
	birthday date)partition by range(sno)(
partition part_0 values less than ('1000160000'),
partition part_1 values less than ('2000160000'),
partition part_2 values less than ('3000160000'),
partition part_3 values less than ('4000160000'),
partition part_4 values less than ('5000160000'),
partition part_5 values less than ('6000160000'),
partition part_6 values less than ('7000160000'),
partition part_7 values less than ('8000160000'),
partition part_8 values less than ('9000160000'),
partition part_9 values less than (maxvalue));
insert into T_student_W125(sno,sname, sex, tel, email, birthday) select X.sno,A.sname, B.sex, B.tel, B.email, B.birthday from (select rownum rownum_X,sno from t_student_sno_ab_j432) X, (select rownum rownum_A,sname from t_stu_name_j432) A, (select rownum rownum_B,sex,tel,email,birthday from t_stud_other_information_j432) B where rownum_A = rownum_B and rownum_A = rownum_X;

--为学生表添加其他约束
alter table T_student_W125 add constraint ck_student_sex check(sex in('男','女','其它'));
alter table T_student_W125 add constraint ck_student_email check(email like '%@%.%');
alter table T_student_W125 add constraint ck_student_birthday check(birthday>=to_date('19940101','yyyymmdd') and birthday<=to_date('19990731','yyyymmdd'));

exec P_recordTime_W125('有分区，按学号首位ID统计人数的开始时间')
select count(*) from T_student_W125 where sno like '5%';
exec P_recordTime_W125('有分区，按学号首位ID统计人数的结束时间')

exec P_recordTime_W125('有分区，按专业统计人数的开始时间')
select count(*) from T_student_W125 where sno like '______01%';
exec P_recordTime_W125('有分区，按专业统计人数的结束时间')

col things format a64;
col time format a32;
select * from T_student_W125 order by time;
spool off;