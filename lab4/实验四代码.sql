--1．建立对应3GB大小的外部文件的tablespace tabspace_????
--2．重建major_????与stud_????，指定存于建立的tabspace_????中，
--3．重新产生样本值，包括千万级数据的stud表，看是否有性能上的提升。
--4．用EXP导出数据与IMP导入数据，请作多种尝试，直到成功！
--5．尝试对系统表空间user及自定义表空间tabspace_????进行备份与恢复。
--6．登录DBA用户system，通过cat字典入口，找到以DBA_开头的相关数据字典，并且每个对象显示5条记录（SQL生成SQL）。
--7．通过查找自己用户下的触发器字典，生成代码将所有触发器的状态改为disable并执行。再生成代码，将状态为disable的触发器的状态改为enable，并执行。

--1．建立对应3GB大小的外部文件的tablespace tabspace_W125
create tablespace tabspace_W125 datafile '\home\oracle\tabspace_W125.dbf' size 3G autoextend on next 100M extent management local ;

--2．重建major_????与stud_????，指定存于建立的tabspace_????中
--创建T_major_W125表
drop table T_major_W125;
create table T_major_W125 (
    MajorNo char(2) primary key,
    Mname varchar(16),
    --为了保证loc在(主校区，南校区，新校区，铁道校区，湘雅校区)，添加check约束
    Mloc varchar(16) check ( Mloc in ('主校区', '南校区', '新校区', '铁道校区', '湘雅校区') ),
    Mdean varchar(16)
) tablespace tabspace_W125;

--创建T_stud_W125表
drop table T_stud_W125;
create table T_stud_W125 (
    Sno char(16) primary key ,
    Sname varchar(16),
    Ssex varchar(16) check ( Ssex in ('Male', 'Female', 'Other') ),
    Stel varchar(16),
    --对邮箱格式进行正则匹配
    Semail varchar(16) check ( Semail like '%@%.%'),
    Sbirthday date check ( to_char(Sbirthday) >= '19990731' ),
    --定义班长的学号是一个外键
    MoniNo char(16) references T_stud_W125(Sno),
    --定义专业号是一个外键
    MajorNo char(2) references T_major_W125(MajorNo)
)tablespace tabspace_W125;

--学生信息表
create table T_student_W125;
create table T_student_W125 (
    Sno varchar2(10) primary key ,
    Sname varchar2(32),
    sex varchar2(32),
    tel varchar2(32),
    email varchar2(32),
    birthday date
) tablespace tabspace_W125;

--3．重新产生样本值，包括千万级数据的stud表，看是否有性能上的提升。
--3.1创建基本姓名表
drop table Sname;
create table Sname(Sname varchar(32));
--3.2 插入基本姓名
--sqlldr why/281612 control = /home/oracle/persons.ctl
select * from Sname;

--3.3 制造足够多的姓名，为名字的每个字创造视图
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

--3.4 创建T_studName_W125表
drop table T_studName_W125;
create table T_studName_W125(Sname varchar(16));

--3.5 为姓名表T_studName_W125插入12600000条学生姓名
insert into T_studName_W125(Sname) select na12 from V_name12_W125;
insert into T_studName_W125(Sname) select na123 from V_name123_W125;
--完成为姓名表生成12600000条记录
select count(*) from V_name123_W125;
select count(*) from V_name12_W125;
select count(*) from T_studName_W125;

--3.6.生成规范的学号表
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

--3.7批量处理sex, tel, email, birthday等数据
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

--3.8产生随机电话
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

--3.9随机产生邮箱
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

--3.10产生随机生日
--   函数f_getBirthday_W125会返回一个在[19940101,19990701]时间内的日期
create or replace function F_getBirthday_W125 return date
is
birthday date;
begin
    select to_date(trunc(DBMS_RANDOM.VALUE(2449354, 2451186)), 'J') into birthday from dual;
    return birthday;
end;
--性别、手机号、邮箱、出生日期等随机函数生成完毕


--3.11生成完整学生表除学号和姓名之外的所有信息
--建立基本信息模板表
drop table T_sequenceId;
create table T_sequenceId(
    id number(10),
    sex varchar2(32),
    tel varchar2(32),
    email varchar2(32),
    birthday date
);

--存储大量的学生其他信息，千万级以上
drop table T_studOtherInformation_w125;
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
select count(*) from T_sequenceId;

--每1w条数据插入一次，得到12000000数据
begin
    delete from T_studOtherInformation_w125;
    for i in 1..1200 loop
        insert into T_studOtherInformation_w125(id, sex, tel, email, birthday) select i * 10000 + T_sequenceId.id as MSISDN, T_sequenceId.sex, T_sequenceId.tel, T_sequenceId.email, T_sequenceId.birthday from T_sequenceId;
        commit;
        end loop;
end;
--完成生成12000000条其他信息生成

--插入数据
insert into T_student_W125(Sno, Sname, sex, tel, email, birthday)
select X.Sno, A.Sname, B.sex, B.tel, B.email, B.birthday
from (select rownum rownum_X, Sno from T_studSno_ab_W125) X, (select rownum rownum_A, Sname from T_studName_W125) A, (select rownum rownum_B, sex, tel, email, birthday from T_studOtherInformation_w125) B
where rownum_A = rownum_B and rownum_A = rownum_X;

--4．用EXP导出数据与IMP导入数据，请作多种尝试，直到成功！
--exp why/281612 file=student.dmp full=y
drop table T_student_W125;
--imp why/281612 file=student.dmp full=y commit=y ignore=y
select * from T_student_W125;
select count(*) from T_student_W125;

--5．尝试对系统表空间user及自定义表空间tabspace_????进行备份与恢复。
--exp why/281612 file=tableSpace.dmp tablespaces=(user,tabspace_W125)

--6．登录DBA用户system/oracle，通过cat字典入口，找到以DBA_开头的相关数据字典，并且每个对象显示5条记录（SQL生成SQL）。
/*dba_开头的是查全库所有的，all_开头的是查当前用户可以看到的，user_开头的是查当前用户的，后面可接_users _tables _tablespaces _objects*/
--system执行
select table_name from DBA_CATALOG where table_name like 'DBA_%';
select TABLE_NAME from DICTIONARY where TABLE_NAME like 'DBA_%';
select table_name from DBA_CATALOG;
select TABLE_NAME from DICTIONARY ;


--dba模式下执行
select 'select * from '||table_name||' where rownum<=5;' from DBA_CATALOG;
select 'select * from '||table_name||' where rownum<=5;' from DICTIONARY;


--7．通过查找自己用户下的触发器字典，生成代码将所有触发器的状态改为disable并执行。再生成代码，将状态为disable的触发器的状态改为enable，并执行。
--connect why/281612;

--创建Attend表
create table T_Attend_W125 (
    Sno char(16),
    marjorNo char(2),
    sDay date,
    unit varchar(2) check ( unit in ('12', '34', '56', '78', '90') ),
    Status nvarchar2(2) check ( Status in ('正常', '请假', '迟到', '旷课') ),
    constraint pk_T_Attend primary key(Sno, sDay, unit),
    constraint fk_T_Attend_sno foreign key (Sno) references T_STUD_W125(SNO),
    constraint fk_T_Attend_mno foreign key (marjorNo) references T_MAJOR_W125(MAJORNO)
);
drop table T_Attend_W125;

--建立触发器，当对考勤表Attend表进行相应插入、删除、修改时，
--对stud表的sum_evaluation 数值进行相应的数据更新。
create or replace trigger tg_T_Attend_W125 before insert or update or delete on T_Attend_W125
for each row
declare
    mNewScore binary_integer;
    mOldScore binary_integer;
begin
    if inserting then
        select Score into mNewScore from T_scoreOfAllSituation_W125
            where Status = :new.Status;
        update T_STUD_W125
            set sum_evaluation=nvl(sum_evaluation, 0) + mNewScore
            where Sno = :new.Sno;
    elsif updating then
        select Score into mNewScore from T_scoreOfAllSituation_W125
            where Status = :new.Status;
        select Score into mOldScore from T_scoreOfAllSituation_W125
            where Status = :old.Status;
        update T_STUD_W125
            set sum_evaluation=nvl(sum_evaluation, 0) - mOldScore
            where Sno = :old.Sno;
        update T_STUD_W125
            set sum_evaluation=nvl(sum_evaluation, 0) + mNewScore
            where Sno = :new.Sno;
    else
        --delete
        select Score into mOldScore from T_scoreOfAllSituation_W125
            where Status = :old.Status;
        update T_STUD_W125
            set sum_evaluation = nvl(sum_evaluation, 0) - mOldScore
            where SNO = :old.sno;
    end if;
end;

select 'alter trigger '||object_name||' disable;' from user_objects where OBJECT_type='TRIGGER' ;
select 'alter trigger '||object_name||' enable;' from user_objects where OBJECT_type='TRIGGER';
alter trigger TG_T_ATTEND_W125 disable;
alter trigger TG_T_ATTEND_W125 enable;

--exp why/281612 file=major.dmp tables=T_MAJOR_W125
--imp why/281612 file=major.dmp full=y

