--创建用户过程
create user U_W125 identified by U_W125;
grant resource, connect to U_W125;
grant create view to U_W125;

--创建T_major_W125表
create table T_major_W125 (
    MajorNo char(2) primary key,
    Mname varchar(16),
    --为了保证loc在(主校区，南校区，新校区，铁道校区，湘雅校区)，添加check约束
    Mloc varchar(16) check ( Mloc in ('主校区', '南校区', '新校区', '铁道校区', '湘雅校区') ),
    Mdean varchar(16)
);

--创建T_stud_W125表
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
);

--插入数据，并测试完整性约束
insert into T_major_W125 values ('09', '计科', '主校区', '刘老师');
insert into T_major_W125 values ('07', '大数据', '新校区', '张老师');
insert into T_major_W125 values ('08', '物联网', '南校区', '贺老师');

--为每一个专业插入学生
--物联网
insert into T_stud_W125 values ('8208181125', '王灏洋',
                                'Male', '13565759137', '165788297@qq.com', '28-4月-2000', '8208181125', '08');
insert into T_stud_W125 values ('8208181126', '王一',
                                'Male', '13565759138', '165788298@qq.com', '29-4月-2000', '8208181125', '08');
insert into T_stud_W125 values ('8208181127', '王二',
                                'Male', '13565759139', '165788299@qq.com', '30-4月-2000', '8208181125', '08');
insert into T_stud_W125 values ('8208181128', '王三',
                                'Male', '13565759140', '165788300@qq.com', '20-4月-2000', '8208181125', '08');
insert into T_stud_W125 values ('8208181129', '王四',
                                'Male', '13565759141', '165788301@qq.com', '21-4月-2000', '8208181125', '08');

insert into T_stud_W125 values ('8208181230', '王五',
                                'Male', '13565759142', '165788302@qq.com', '22-4月-2000', '8208181230', '08');
insert into T_stud_W125 values ('8208181231', '王六',
                                'Male', '13565759143', '165788303@qq.com', '23-4月-2000', '8208181230', '08');
insert into T_stud_W125 values ('8208181232', '王七',
                                'Male', '13565759144', '165788304@qq.com', '24-4月-2000', '8208181230', '08');
insert into T_stud_W125 values ('8208181233', '王八',
                                'Male', '13565759145', '165788305@qq.com', '25-4月-2000', '8208181230', '08');
insert into T_stud_W125 values ('8208181234', '王九',
                                'Male', '13565759146', '165788306@qq.com', '26-4月-2000', '8208181230', '08');

--计科
insert into T_stud_W125 values ('8209181125', '张零',
                                'Female', '18139087699', '2359661@qq.com', '21-6月-2000', '8209181125', '09');
insert into T_stud_W125 values ('8209181126', '张一',
                                'Male', '18139087670', '12359662@qq.com', '22-6月-2000', '8209181125', '09');
insert into T_stud_W125 values ('8209181127', '张二',
                                'Male', '18139087671', '2359663@qq.com', '23-6月-2000', '8209181125', '09');
insert into T_stud_W125 values ('8209181128', '张三',
                                'Female', '18139087672', '2359664@qq.com', '24-6月-2000', '8209181125', '09');
insert into T_stud_W125 values ('8209181129', '张四',
                                'Male', '18139087673', '2359665@qq.com', '25-6月-2000', '8209181125', '09');

insert into T_stud_W125 values ('8209181230', '张五',
                                'Female', '18139087674', '2359666@qq.com', '26-6月-2000', '8209181230', '09');
insert into T_stud_W125 values ('8209181231', '张六',
                                'Male', '18139087675', '2359667@qq.com', '27-6月-2000', '8209181230', '09');
insert into T_stud_W125 values ('8209181232', '张七',
                                'Female', '18139087676', '2359668@qq.com', '28-6月-2000', '8209181230', '09');
insert into T_stud_W125 values ('8209181233', '张八',
                                'Male', '18139087677', '2359669@qq.com', '29-6月-2000', '8209181230', '09');
insert into T_stud_W125 values ('8209181234', '张九',
                                'Female', '18139087678', '2359670@qq.com', '30-6月-2000', '8209181230', '09');

--大数据
insert into T_stud_W125 values ('8207181125', '李零',
                                'Female', '13999002010', '416959600@qq.com', '21-6月-2001', '8207181125', '07');
insert into T_stud_W125 values ('8207181126', '李一',
                                'Male', '13999002011', '416959601@qq.com', '22-6月-2001', '8207181125', '07');
insert into T_stud_W125 values ('8207181127', '李二',
                                'Male', '13999002012', '416959602@qq.com', '23-6月-2001', '8207181125', '07');
insert into T_stud_W125 values ('8207181128', '李三',
                                'Female', '13999002013', '416959603@qq.com', '24-6月-2001', '8207181125', '07');
insert into T_stud_W125 values ('8207181129', '李四',
                                'Male', '13999002014', '416959604@qq.com', '25-6月-2001', '8207181125', '07');

insert into T_stud_W125 values ('8207181230', '李五',
                                'Female', '13999002015', '416959605@qq.com', '26-6月-2001', '8207181230', '07');
insert into T_stud_W125 values ('8207181231', '李六',
                                'Male', '13999002016', '416959606@qq.com', '27-6月-2001', '8207181230', '07');
insert into T_stud_W125 values ('8207181232', '李七',
                                'Female', '13999002017', '416959607@qq.com', '28-6月-2001', '8207181230', '07');
insert into T_stud_W125 values ('8207181233', '李八',
                                'Male', '13999002018', '416959608@qq.com', '29-6月-2001', '8207181230', '07');
insert into T_stud_W125 values ('8207181234', '李九',
                                'Female', '13999002019', '416959609@qq.com', '30-6月-2001', '8207181230', '07');

select * from T_stud_W125;
--给每个学生建立相关用户，使用查询拼接快速得到语句
select 'create user U'||Sno||'identified by P'||Sno||';' from T_stud_W125;
--之所以会有这么多空格，是因为给Sno的字长是20
create user U8207181125      identified by P8207181125      ;
create user U8207181126      identified by P8207181126      ;
create user U8207181127      identified by P8207181127      ;
create user U8207181128      identified by P8207181128      ;
create user U8207181129      identified by P8207181129      ;

create user U8207181230      identified by P8207181230      ;
create user U8207181231      identified by P8207181231      ;
create user U8207181232      identified by P8207181232      ;
create user U8207181233      identified by P8207181233      ;
create user U8207181234      identified by P8207181234      ;

create user U8208181125      identified by P8208181125      ;
create user U8208181126      identified by P8208181126      ;
create user U8208181127      identified by P8208181127      ;
create user U8208181128      identified by P8208181128      ;
create user U8208181129      identified by P8208181129      ;

create user U8208181230      identified by P8208181230      ;
create user U8208181231      identified by P8208181231      ;
create user U8208181232      identified by P8208181232      ;
create user U8208181233      identified by P8208181233      ;
create user U8208181234      identified by P8208181234      ;

create user U8209181125      identified by P8209181125      ;
create user U8209181126      identified by P8209181126      ;
create user U8209181127      identified by P8209181127      ;
create user U8209181128      identified by P8209181128      ;
create user U8209181129      identified by P8209181129      ;

create user U8209181230      identified by P8209181230      ;
create user U8209181231      identified by P8209181231      ;
create user U8209181232      identified by P8209181232      ;
create user U8209181233      identified by P8209181233      ;
create user U8209181234      identified by P8209181234      ;

--删除所有用户
select 'drop user '||username||';' from DBA_USERS;
drop user U8207181128;
drop user U8209181128;
drop user U8208181127;
drop user U8208181128;
drop user U8207181125;
drop user U8208181133;
drop user U8207181130;
drop user U8209181129;
drop user U8209181133;
drop user U8209181132;
drop user U07;
drop user U8207181133;
drop user U09;
drop user U8208181126;
drop user U8208181134;
drop user U8208181125;
drop user U8209181127;
drop user U8208181132;
drop user U8207181131;
drop user U8208181131;
drop user U8209181134;
drop user U8208181129;
drop user U8207181126;
drop user U8209181126;
drop user U8209181130;
drop user U8209181125;
drop user U08;

drop user U8207181127;
drop user U8207181129;
drop user U8207181132;
drop user U8207181134;
drop user U8208181130;
drop user U8209181131;

--给链接权
select 'grant connect to U'||Sno||';' from T_stud_W125;
grant connect to U8207181125      ;
grant connect to U8207181126      ;
grant connect to U8207181127      ;
grant connect to U8207181128      ;
grant connect to U8207181129      ;

grant connect to U8207181230      ;
grant connect to U8207181231      ;
grant connect to U8207181232      ;
grant connect to U8207181233      ;
grant connect to U8207181234      ;

grant connect to U8208181125      ;
grant connect to U8208181126      ;
grant connect to U8208181127      ;
grant connect to U8208181128      ;
grant connect to U8208181129      ;

grant connect to U8208181230      ;
grant connect to U8208181231      ;
grant connect to U8208181232      ;
grant connect to U8208181233      ;
grant connect to U8208181234      ;

grant connect to U8209181125      ;
grant connect to U8209181126      ;
grant connect to U8209181127      ;
grant connect to U8209181128      ;
grant connect to U8209181129      ;

grant connect to U8209181230      ;
grant connect to U8209181231      ;
grant connect to U8209181232      ;
grant connect to U8209181233      ;
grant connect to U8209181234      ;

--为每个专业负责人建立相关用户并授予权限
select unique 'create user U'||MajorNo||' identified by P'||MajorNo||';' from T_stud_W125;
create user U07 identified by P07;
create user U08 identified by P08;
create user U09 identified by P09;

select 'grant connect to U'||MajorNo||';' from T_major_W125;
grant connect to U07;
grant connect to U08;
grant connect to U09;

--查看所用用户
select * from all_users;

--通过视图进行权限控制，为每个用户分别建立
create view V_viewToShow_W125
as
select * from T_stud_W125
where 'U'||Sno = user or 'U'||MoniNo = user or 'U'||MajorNo = user;

--然后登陆每一个用户进行查看即可

grant select on V_viewToShow_W125 to public ;

select * from WHY.V_VIEWTOSHOW_W125;

