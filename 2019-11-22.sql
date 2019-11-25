--SQL의 처리순서와     작성순서.
--        ⑤         SELECT 컬럼명
--        ①         FROM 테이블명
--        ②         WHERE 조건식
--        ③         GROUP BY 컬럼이나 (표현식)
--        ④         HAVING 조건식(집계함수 조건)
--        ⑥         ORDER BY 컬럼명(표현식) -- ASC(오름차순 (기본값)), DSEC(내림차순)

SELECT *
FROM emp
WHERE empno = empno
ORDER BY ename DESC;


-----------------------------------------------------------------------------------------------------------

-- deptno로 오름차순정렬하되, sal가 같으면 그 부분은 sal을 내림차순으로 정렬, 둘다 같으면 eanme으로 오름차순 정렬
SELECT *
FROM emp
ORDER BY deptno, sal DESC, ename;

--정렬 컬럼은 ALLAS로 표현이 가능
SELECT *
FROM emp
ORDER BY deptno, sal DESC, ename;


--조회하는 컬럼의 위치 인덱스를 통해
SELECT deptno, sal, ename AS nm
FROM emp
ORDER BY 2; --컬럼위치. (다만 이것은 추천하지 않는다. 컬럼수정시 문제발생가능) 

---------------------------------------------------------------------------------

SELECT *
FROM dept
ORDER BY dname;

SELECT *
FROM dept
ORDER BY loc DESC;

SELECT *
FROM emp
WHERE comm > 0
ORDER BY comm DESC, empno;

SELECT *
FROM emp
WHERE mgr IS NOT NULL
ORDER BY job, empno DESC;

SELECT *
FROM emp
WHERE deptno IN (10,30) 
AND sal > 1500
ORDER BY ename DESC;

---INLINE VIEW를 통해 정렬 먼저 실행하고, 해당 결과에 ROWNUM을 적용 ROWNUM은 ORDER BY전에 작동한다.
SELECT a.*
FROM (
        SELECT ROWNUM AS RN, empno, ename
        FROM emp
     ) a
WHERE RN BETWEEN 11 AND 20;

SELECT RN, empno, ename
FROM (
        SELECT ROWNUM AS RN, a.*
        FROM (
                SELECT ROWNUM, empno, ename
                FROM emp
                ORDER BY ename
             ) a
     )
WHERE RN BETWEEN 11 AND 20;

-- SELECT절에 * 표현하고, 다른 컬럼|표현식을 썻을 경우 *앞에 테이블명이나, 별칭을 적용해야한다. 단 AS를 이용해서 ALLIAS를 사용할수 없다.
SELECT ROWNUM, a.*
FROM ( SELECT empno, ename
       FROM emp
       ORDER BY ename) a;
-------------
SELECT e.*
FROM emp e;


----------------------------------------------------------------------------------

SELECT SUBSTR('Hi Oracle', 3,2)             -- 3번째부터 2글자. (3번째를 포함)
        ,LENGTH('HiOracle')                 -- 문자열의 길이
        ,INSTR('HiOracle','r')              -- 해당 문자열이 처음으로 나오는 위치
        ,LPAD('HiOracle', 2*8-1, '*')       -- 문자열의 길이(2*8-1), 좌측에 채울문자 (*) 
        ,RPAD('HiOracle', 2*8-1, '*')       -- 문자열의 길이(2*8-1), 좌측에 채울문자 (*) 
        ,REPLACE('HiOracle','Hi','Hello')   -- Hi를 Hellow로 변경
        ,TRIM('        HiOracle       ')    -- 문자열 앞뒤 공백 제거
FROM emp;
