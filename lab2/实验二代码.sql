--1．设计与建立上课考勤表Attend_???，能登记每个学生的考勤记录包括正常、迟到、旷课、请假。
-- 能统计以专业为单位的出勤类别并进行打分评价排序，如迟到、旷课、请假分别扣2，5，1分。
-- 可以考虑给一初始的分值，以免负值。

--建立一个表，里面存的是各种情况的分数
create table T_scoreOfAllSituation_W125(
    Status nvarchar2(2) primary key ,
    Score int
);
insert into T_scoreOfAllSituation_W125 values ('正常', 0);
insert into T_scoreOfAllSituation_W125 values ('请假', 1);
insert into T_scoreOfAllSituation_W125 values ('迟到', 2);
insert into T_scoreOfAllSituation_W125 values ('旷课', 5);

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

--噗，好惨，没有做数据持久化，害
--插入数据，并测试完整性约束
insert into T_major_W125 values ('09', '计科', '主校区', '刘老师');
insert into T_major_W125 values ('07', '大数据', '新校区', '张老师');
insert into T_major_W125 values ('08', '物联网', '南校区', '贺老师');

--为每一个专业插入学生
--物联网
insert into T_stud_W125 values ('8208181125', '王灏洋', 'Male', '13565759137', '165788297@qq.com', '28-4月-2000', '8208181125', '08');
insert into T_stud_W125 values ('8208181126', '王一', 'Male', '13565759138', '165788298@qq.com', '29-4月-2000', '8208181125', '08');
insert into T_stud_W125 values ('8208181127', '王二', 'Male', '13565759139', '165788299@qq.com', '30-4月-2000', '8208181125', '08');
insert into T_stud_W125 values ('8208181128', '王三', 'Male', '13565759140', '165788300@qq.com', '20-4月-2000', '8208181125', '08');
insert into T_stud_W125 values ('8208181129', '王四', 'Male', '13565759141', '165788301@qq.com', '21-4月-2000', '8208181125', '08');

insert into T_stud_W125 values ('8208181230', '王五',' Male', '13565759142', '165788302@qq.com', '22-4月-2000', '8208181230', '08');
insert into T_stud_W125 values ('8208181231', '王六', 'Male', '13565759143', '165788303@qq.com', '23-4月-2000', '8208181230', '08');
insert into T_stud_W125 values ('8208181232', '王七', 'Male', '13565759144', '165788304@qq.com', '24-4月-2000', '8208181230', '08');
insert into T_stud_W125 values ('8208181233', '王八', 'Male', '13565759145', '165788305@qq.com', '25-4月-2000', '8208181230', '08');
insert into T_stud_W125 values ('8208181234', '王九', 'Male', '13565759146', '165788306@qq.com', '26-4月-2000', '8208181230', '08');

--计科
insert into T_stud_W125 values ('8209181125', '张零', 'Female', '18139087699', '2359661@qq.com', '21-6月-2000', '8209181125', '09');
insert into T_stud_W125 values ('8209181126', '张一', 'Male', '18139087670', '12359662@qq.com', '22-6月-2000', '8209181125', '09');
insert into T_stud_W125 values ('8209181127', '张二', 'Male', '18139087671', '2359663@qq.com', '23-6月-2000', '8209181125', '09');
insert into T_stud_W125 values ('8209181128', '张三', 'Female', '18139087672', '2359664@qq.com', '24-6月-2000', '8209181125', '09');
insert into T_stud_W125 values ('8209181129', '张四', 'Male', '18139087673', '2359665@qq.com', '25-6月-2000', '8209181125', '09');

insert into T_stud_W125 values ('8209181230', '张五', 'Female', '18139087674', '2359666@qq.com', '26-6月-2000', '8209181230', '09');
insert into T_stud_W125 values ('8209181231', '张六', 'Male', '18139087675', '2359667@qq.com', '27-6月-2000', '8209181230', '09');
insert into T_stud_W125 values ('8209181232', '张七', 'Female', '18139087676', '2359668@qq.com', '28-6月-2000', '8209181230', '09');
insert into T_stud_W125 values ('8209181233', '张八', 'Male', '18139087677', '2359669@qq.com', '29-6月-2000', '8209181230', '09');
insert into T_stud_W125 values ('8209181234', '张九', 'Female', '18139087678', '2359670@qq.com', '30-6月-2000', '8209181230', '09');

--大数据
insert into T_stud_W125 values ('8207181125', '李零', 'Female', '13999002010', '416959600@qq.com', '21-6月-2001', '8207181125', '07');
insert into T_stud_W125 values ('8207181126', '李一', 'Male', '13999002011', '416959601@qq.com', '22-6月-2001', '8207181125', '07');
insert into T_stud_W125 values ('8207181127', '李二', 'Male', '13999002012', '416959602@qq.com', '23-6月-2001', '8207181125', '07');
insert into T_stud_W125 values ('8207181128', '李三', 'Female', '13999002013', '416959603@qq.com', '24-6月-2001', '8207181125', '07');
insert into T_stud_W125 values ('8207181129', '李四', 'Male', '13999002014', '416959604@qq.com', '25-6月-2001', '8207181125', '07');

insert into T_stud_W125 values ('8207181230', '李五', 'Female', '13999002015', '416959605@qq.com', '26-6月-2001', '8207181230', '07');
insert into T_stud_W125 values ('8207181231', '李六', 'Male', '13999002016', '416959606@qq.com', '27-6月-2001', '8207181230', '07');
insert into T_stud_W125 values ('8207181232', '李七', 'Female', '13999002017', '416959607@qq.com', '28-6月-2001', '8207181230', '07');
insert into T_stud_W125 values ('8207181233', '李八', 'Male', '13999002018', '416959608@qq.com', '29-6月-2001', '8207181230', '07');
insert into T_stud_W125 values ('8207181234', '李九', 'Female', '13999002019', '416959609@qq.com', '30-6月-2001', '8207181230', '07');

--2. 为major表与stud表增加sum_evaluation 数值字段，
--以记录根据考勤表Attend_???(Attendance)中出勤类别打分汇总的值。
alter table T_STUD_W125 add (sum_evaluation number);
alter table T_MAJOR_W125 add (sum_evaluation number);

-- 3. 建立个人考勤汇总表stud_attend与专业考勤表major_attend，
-- 表示每个学生或每个专业在某时间周期（起始日期，终止日期）
-- 正常、迟到、旷课、请假次数及考勤分值。
create table T_stud_Attend_W125(
    Sno char(16),
    sTime date,
    eTime date,
    normalCnt int,
    leaveCnt int,
    lateCnt int,
    absentCnt int,
    score number,
    constraint pk_T_stud_Attend_time primary key (Sno, sTime, eTime),
    constraint fk_T_stud_Attend_sno foreign key (sno) references  T_STUD_W125(SNO)
);

create table T_major_Attend_W125(
    majorNo char(2),
    sTime date,
    eTime date,
    normalCnt int,
    leaveCnt int,
    lateCnt int,
    absentCnt int,
    score number,
    constraint pk_T_major_Attend_time primary key (MajorNo, sTime, eTime),
    constraint fk_T_major_Attend_W125 foreign key (MajorNo) references T_MAJOR_W125(MAJORNO)
);



--4．根据major表中的值与stud中的值，为考勤表Attend输入足够的样本值，
-- 要求每个专业都要有学生，有部分学生至少要有一周的每天5个单元
-- （12，34，56，78，90，没有课的单元可以没有考勤记录）的考勤完整记录，
-- 其中正常、迟到、旷课、请假可以用数字或字母符号表示。
--物联网
insert into T_Attend_W125 values('8208181125','08','23-11月-2020','12','正常');
insert into T_Attend_W125 values('8208181125','08','23-11月-2020','34','迟到');
insert into T_Attend_W125 values('8208181125','08','24-11月-2020','12','正常');
insert into T_Attend_W125 values('8208181125','08','24-11月-2020','78','正常');
insert into T_Attend_W125 values('8208181125','08','24-11月-2020','90','正常');
insert into T_Attend_W125 values('8208181125','08','25-11月-2020','12','旷课');
insert into T_Attend_W125 values('8208181125','08','25-11月-2020','34','请假');
insert into T_Attend_W125 values('8208181125','08','25-11月-2020','90','旷课');
insert into T_Attend_W125 values('8208181125','08','26-11月-2020','34','正常');
insert into T_Attend_W125 values('8208181125','08','26-11月-2020','56','正常');
insert into T_Attend_W125 values('8208181125','08','26-11月-2020','78','正常');
insert into T_Attend_W125 values('8208181125','08','27-11月-2020','12','请假');
insert into T_Attend_W125 values('8208181125','08','27-11月-2020','34','请假');
insert into T_Attend_W125 values('8208181125','08','27-11月-2020','78','正常');

insert into T_Attend_W125 values('8208181126','08','23-11月-2020','12','正常');
insert into T_Attend_W125 values('8208181126','08','23-11月-2020','34','迟到');
insert into T_Attend_W125 values('8208181126','08','24-11月-2020','12','迟到');
insert into T_Attend_W125 values('8208181126','08','24-11月-2020','78','正常');
insert into T_Attend_W125 values('8208181126','08','24-11月-2020','90','旷课');
insert into T_Attend_W125 values('8208181126','08','25-11月-2020','12','旷课');
insert into T_Attend_W125 values('8208181126','08','25-11月-2020','34','请假');
insert into T_Attend_W125 values('8208181126','08','25-11月-2020','90','旷课');
insert into T_Attend_W125 values('8208181126','08','26-11月-2020','34','正常');
insert into T_Attend_W125 values('8208181126','08','26-11月-2020','56','正常');
insert into T_Attend_W125 values('8208181126','08','26-11月-2020','78','正常');
insert into T_Attend_W125 values('8208181126','08','27-11月-2020','12','请假');
insert into T_Attend_W125 values('8208181126','08','27-11月-2020','34','请假');
insert into T_Attend_W125 values('8208181126','08','27-11月-2020','78','正常');

insert into T_Attend_W125 values('8208181127','08','23-11月-2020','12','正常');
insert into T_Attend_W125 values('8208181127','08','23-11月-2020','34','迟到');
insert into T_Attend_W125 values('8208181127','08','24-11月-2020','12','迟到');
insert into T_Attend_W125 values('8208181127','08','24-11月-2020','78','正常');
insert into T_Attend_W125 values('8208181127','08','24-11月-2020','90','正常');
insert into T_Attend_W125 values('8208181127','08','25-11月-2020','12','旷课');
insert into T_Attend_W125 values('8208181127','08','25-11月-2020','34','旷课');
insert into T_Attend_W125 values('8208181127','08','25-11月-2020','90','旷课');
insert into T_Attend_W125 values('8208181127','08','26-11月-2020','34','正常');
insert into T_Attend_W125 values('8208181127','08','26-11月-2020','56','正常');
insert into T_Attend_W125 values('8208181127','08','26-11月-2020','78','正常');
insert into T_Attend_W125 values('8208181127','08','27-11月-2020','12','请假');
insert into T_Attend_W125 values('8208181127','08','27-11月-2020','34','请假');
insert into T_Attend_W125 values('8208181127','08','27-11月-2020','78','正常');

--计科
insert into T_Attend_W125 values('8209181125','09','23-11月-2020','12','正常');
insert into T_Attend_W125 values('8209181125','09','23-11月-2020','34','迟到');
insert into T_Attend_W125 values('8209181125','09','24-11月-2020','12','迟到');
insert into T_Attend_W125 values('8209181125','09','24-11月-2020','78','正常');
insert into T_Attend_W125 values('8209181125','09','24-11月-2020','90','正常');
insert into T_Attend_W125 values('8209181125','09','25-11月-2020','12','旷课');
insert into T_Attend_W125 values('8209181125','09','25-11月-2020','34','请假');
insert into T_Attend_W125 values('8209181125','09','25-11月-2020','90','旷课');
insert into T_Attend_W125 values('8209181125','09','26-11月-2020','34','正常');
insert into T_Attend_W125 values('8209181125','09','26-11月-2020','56','正常');
insert into T_Attend_W125 values('8209181125','09','26-11月-2020','78','正常');
insert into T_Attend_W125 values('8209181125','09','27-11月-2020','12','请假');
insert into T_Attend_W125 values('8209181125','09','27-11月-2020','34','旷课');
insert into T_Attend_W125 values('8209181125','09','27-11月-2020','78','正常');

insert into T_Attend_W125 values('8209181126','09','23-11月-2020','12','正常');
insert into T_Attend_W125 values('8209181126','09','23-11月-2020','34','正常');
insert into T_Attend_W125 values('8209181126','09','24-11月-2020','12','迟到');
insert into T_Attend_W125 values('8209181126','09','24-11月-2020','78','正常');
insert into T_Attend_W125 values('8209181126','09','24-11月-2020','90','旷课');
insert into T_Attend_W125 values('8209181126','09','25-11月-2020','12','旷课');
insert into T_Attend_W125 values('8209181126','09','25-11月-2020','34','请假');
insert into T_Attend_W125 values('8209181126','09','25-11月-2020','90','旷课');
insert into T_Attend_W125 values('8209181126','09','26-11月-2020','34','正常');
insert into T_Attend_W125 values('8209181126','09','26-11月-2020','56','正常');
insert into T_Attend_W125 values('8209181126','09','26-11月-2020','78','正常');
insert into T_Attend_W125 values('8209181126','09','27-11月-2020','12','请假');
insert into T_Attend_W125 values('8209181126','09','27-11月-2020','34','旷课');
insert into T_Attend_W125 values('8209181126','09','27-11月-2020','78','正常');

insert into T_Attend_W125 values('8209181127','09','23-11月-2020','12','正常');
insert into T_Attend_W125 values('8209181127','09','23-11月-2020','34','迟到');
insert into T_Attend_W125 values('8209181127','09','24-11月-2020','12','迟到');
insert into T_Attend_W125 values('8209181127','09','24-11月-2020','78','正常');
insert into T_Attend_W125 values('8209181127','09','24-11月-2020','90','请假');
insert into T_Attend_W125 values('8209181127','09','25-11月-2020','12','迟到');
insert into T_Attend_W125 values('8209181127','09','25-11月-2020','34','请假');
insert into T_Attend_W125 values('8209181127','09','25-11月-2020','90','正常');
insert into T_Attend_W125 values('8209181127','09','26-11月-2020','34','正常');
insert into T_Attend_W125 values('8209181127','09','26-11月-2020','56','正常');
insert into T_Attend_W125 values('8209181127','09','26-11月-2020','78','正常');
insert into T_Attend_W125 values('8209181127','09','27-11月-2020','12','请假');
insert into T_Attend_W125 values('8209181127','09','27-11月-2020','34','旷课');
insert into T_Attend_W125 values('8209181127','09','27-11月-2020','78','正常');

--大数据
insert into T_attend_W125 values('8207181125','07','23-11月-2020','12','请假');
insert into T_attend_W125 values('8207181125','07','23-11月-2020','34','迟到');
insert into T_attend_W125 values('8207181125','07','24-11月-2020','12','正常');
insert into T_attend_W125 values('8207181125','07','24-11月-2020','78','请假');
insert into T_attend_W125 values('8207181125','07','24-11月-2020','90','迟到');
insert into T_attend_W125 values('8207181125','07','25-11月-2020','12','迟到');
insert into T_attend_W125 values('8207181125','07','25-11月-2020','34','请假');
insert into T_attend_W125 values('8207181125','07','25-11月-2020','90','正常');
insert into T_attend_W125 values('8207181125','07','26-11月-2020','34','旷课');
insert into T_attend_W125 values('8207181125','07','26-11月-2020','56','正常');
insert into T_attend_W125 values('8207181125','07','26-11月-2020','78','正常');
insert into T_attend_W125 values('8207181125','07','27-11月-2020','12','迟到');
insert into T_attend_W125 values('8207181125','07','27-11月-2020','34','旷课');
insert into T_attend_W125 values('8207181125','07','27-11月-2020','78','正常');

insert into T_Attend_W125 values('8207181126','07','23-11月-2020','12','正常');
insert into T_Attend_W125 values('8207181126','07','23-11月-2020','34','迟到');
insert into T_Attend_W125 values('8207181126','07','24-11月-2020','12','正常');
insert into T_Attend_W125 values('8207181126','07','24-11月-2020','78','请假');
insert into T_Attend_W125 values('8207181126','07','24-11月-2020','90','迟到');
insert into T_Attend_W125 values('8207181126','07','25-11月-2020','12','请假');
insert into T_Attend_W125 values('8207181126','07','25-11月-2020','34','请假');
insert into T_Attend_W125 values('8207181126','07','25-11月-2020','90','正常');
insert into T_Attend_W125 values('8207181126','07','26-11月-2020','34','正常');
insert into T_Attend_W125 values('8207181126','07','26-11月-2020','56','正常');
insert into T_Attend_W125 values('8207181126','07','26-11月-2020','78','正常');
insert into T_Attend_W125 values('8207181126','07','27-11月-2020','12','迟到');
insert into T_Attend_W125 values('8207181126','07','27-11月-2020','34','旷课');
insert into T_Attend_W125 values('8207181126','07','27-11月-2020','78','正常');

insert into T_Attend_W125 values('8207181127','07','23-11月-2020','12','正常');
insert into T_Attend_W125 values('8207181127','07','23-11月-2020','34','迟到');
insert into T_Attend_W125 values('8207181127','07','24-11月-2020','12','正常');
insert into T_Attend_W125 values('8207181127','07','24-11月-2020','78','请假');
insert into T_Attend_W125 values('8207181127','07','24-11月-2020','90','迟到');
insert into T_Attend_W125 values('8207181127','07','25-11月-2020','12','迟到');
insert into T_Attend_W125 values('8207181127','07','25-11月-2020','34','请假');
insert into T_Attend_W125 values('8207181127','07','25-11月-2020','90','正常');
insert into T_Attend_W125 values('8207181127','07','26-11月-2020','34','正常');
insert into T_Attend_W125 values('8207181127','07','26-11月-2020','56','正常');
insert into T_Attend_W125 values('8207181127','07','26-11月-2020','78','正常');
insert into T_Attend_W125 values('8207181127','07','27-11月-2020','12','请假');
insert into T_Attend_W125 values('8207181127','07','27-11月-2020','34','旷课');
insert into T_Attend_W125 values('8207181127','07','27-11月-2020','78','正常');

--单项列出
select T_Attend_W125.Status, marjorNo, sum(Score)
from T_Attend_W125, T_scoreOfAllSituation_W125
where T_Attend_W125.Status = T_scoreOfAllSituation_W125.Status and
      T_Attend_W125.Status<>'正常'
group by marjorNo, T_Attend_W125.Status
order by sum(Score);

--共计
select marjorNo, sum(Score)
from T_Attend_W125, T_scoreOfAllSituation_W125
where T_Attend_W125.Status = T_scoreOfAllSituation_W125.Status and
      T_Attend_W125.Status<>'正常'
group by marjorNo
order by sum(Score);

--5. 建立触发器，当对考勤表Attend表进行相应插入、删除、修改时，
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

--测试一下
select Sno, sum_evaluation from T_stud_W125 where Sno='8208181125';
insert into T_Attend_W125 values('8208181125','08','28-11月-2020','56','请假');
select sno,sum_evaluation from T_stud_W125 where sno='8208181125';

--6．建立过程，生成某专业某时段（起、止日期）的考勤汇总表major_attend中各字段值，
-- 并汇总相应专业，将考勤分值的汇总结果写入到major表中的sum_evaluation中。
create or replace procedure P_Attend_W125 (pMajorNo char, pSTime date, pETime date)
as
    pScore int := 0;
begin
    insert into T_major_Attend_W125 values (pMajorNo, pSTime, pETime, 0, 0, 0, 0, 0);
    for cur in (select T_Attend_W125.Status, count(T_Attend_W125.Status) mStatusCnt, sum(score) pScore
        from T_Attend_W125, T_scoreOfAllSituation_W125
        where T_Attend_W125.Status = T_scoreOfAllSituation_W125.Status
            and T_Attend_W125.marjorNo = pMajorNo
            and sDay >= pSTime and sDay <= pETime
        group by T_Attend_W125.Status)
        loop
            if cur.Status = '正常' then
                update T_major_Attend_W125 set normalCnt = cur.mStatusCnt
                    where majorNo = pMajorNo and stime = pSTime and eTime = pETime;
            elsif cur.Status = '请假' then
                update T_major_Attend_W125 set leaveCnt = cur.mStatusCnt
                    where majorNo = pMajorNo and sTime = pSTime and eTime = pETime;
            elsif cur.Status = '迟到' then
                update T_major_Attend_W125 set lateCnt = cur.mStatusCnt
                    where majorNo = pMajorNo and sTime = pSTime and eTime = pETime;
            elsif cur.Status = '旷课' then
                update T_major_Attend_W125 set absentCnt = cur.mStatusCnt
                    where majorNo = pMajorNo and sTime = pSTime and eTime = pETime;
            end if;
            pScore := pScore + cur.pScore;
        end loop;
    update T_major_Attend_W125 set score = pScore
        where majorNo = pMajorNo and sTime = pSTime and eTime = pETime;
    update T_MAJOR_W125 set sum_evaluation = pScore
        where MAJORNO = pMajorNo;
end;

select * from T_major_Attend_W125;
select * from T_major_W125;
begin
    P_Attend_W125('07','23-11月-2020','27-11月-2020');
    P_Attend_W125('09','23-11月-2020','27-11月-2020');
    P_Attend_W125('08','23-11月-2020','27-11月-2020');
end;
select * from T_major_Attend_W125;
select * from T_major_W125;