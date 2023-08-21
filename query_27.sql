CREATE TABLE [students](
 [studentid] [int] NULL,
 [studentname] [nvarchar](255) NULL,
 [subject] [nvarchar](255) NULL,
 [marks] [int] NULL,
 [testid] [int] NULL,
 [testdate] [date] NULL
)
data:
insert into students values (2,'Max Ruin','Subject1',63,1,'2022-01-02');
insert into students values (3,'Arnold','Subject1',95,1,'2022-01-02');
insert into students values (4,'Krish Star','Subject1',61,1,'2022-01-02');
insert into students values (5,'John Mike','Subject1',91,1,'2022-01-02');
insert into students values (4,'Krish Star','Subject2',71,1,'2022-01-02');
insert into students values (3,'Arnold','Subject2',32,1,'2022-01-02');
insert into students values (5,'John Mike','Subject2',61,2,'2022-11-02');
insert into students values (1,'John Deo','Subject2',60,1,'2022-01-02');
insert into students values (2,'Max Ruin','Subject2',84,1,'2022-01-02');
insert into students values (2,'Max Ruin','Subject3',29,3,'2022-01-03');
insert into students values (5,'John Mike','Subject3',98,2,'2022-11-02');


--select * from students


--Q1 (find the students who scored above the average marks in each subject)
select subject, studentname
from (
select *, 
avg(marks) over(partition by subject) as avg_of_subjects
from students) A
where marks > avg_of_subjects

--Q2 (find the percentage of students who scored more than 90 in any subject amongst the total students.)
--(select count(distinct case when marks > 90 then studentname else null end) * 1.0 / count(distinct studentname) * 100 from students)

--OR
with cte1 as (
select sum(cnt) as more_than_90
from (
select count(distinct studentname) as cnt
from (
select *
from students
where marks > 90) A
group by studentname) B)
, cte2 as (
select sum(cnt_total) as total_students
from (
select count(distinct studentname) cnt_total
from students
group by studentname) C)

select (more_than_90 * 1.0 / total_students) * 100
from cte1, cte2

--Q3 (find the second highest and the second lowest marks for each subject)
with cte as (
select *, 
case when (dense_rank() over(partition by subject order by marks asc)) = 2 then marks else null end as second_lowest, 
case when (dense_rank() over(partition by subject order by marks desc)) = 2 then marks else null end as second_highest
from students)

select subject, max(second_lowest) as second_lowest_marks, max(second_highest) as second_highest_marks
from cte
group by subject

--Q4 (for each student and test, identify if their marks increased or decreased from the previous test)
with cte as (
select *, 
cast(right(subject, 1) as int) as subject_order
from students)
, previous_marks as (
select *, 
lag(marks, 1) over(partition by studentname order by subject_order) as lagged_marks
from cte)

select studentname, subject, marks, 
case when lagged_marks is null then 'first_mark' else (case when marks < lagged_marks then 'dec' else 'inc' end) end as inc_or_dec
from previous_marks