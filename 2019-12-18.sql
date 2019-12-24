SELECT dept_h.*, LEVEL, LPAD(' ', 3*(LEVEL-1)) || deptnm  -- LPAD를 사용해서 계층을 표현한다
FROM dept_h
START WITH deptcd = 'dept0' --시작점은 deptcd = 'dept0' --> XX회사 (최상위 조직)
CONNECT BY PRIOR deptcd = p_deptcd   -- PRIOR은 이미 읽은 데이터를 의미  /% RRIOR deptcd %/는 deptcd를 PRIOR로 사용한다 그러므로 PRIOR는 컬럼에 붙는것
;

SELECT LPAD('XX회사', 15, '*')
FROM dual;

-- LEVEL은 CONNECT BY가 들어가는 계층쿼리 개념에서 사용한다.
/*  계층을 따라서 이동하는 쿼리
    dept0(XX회사)
        dept0_00(디자인 부)
            dept0_00_0 (디자인 팀)
        dept0_01 (정보기획부)
            dept0_01_0 (기획팀)
                dept0_00_0_0 (기획파트)
        dept0_02 (정보시스템부)
            dept0_02_0 (개발 1팀)
            dept0_02_1 (개발 2팀)
*/
SELECT * FROM dept_h;

-- 실습2. 정보시스템부 (하향식) 
SELECT deptcd, LPAD(' ', 3*(LEVEL-1)) || deptnm AS deptnm, p_deptcd
FROM dept_h
START WITH deptcd = 'dept0_02'
CONNECT BY PRIOR deptcd = p_deptcd;

-- 실습3. 디자인팀 (상향식)
SELECT deptcd, LPAD(' ',3*(LEVEL-1)) || deptnm, p_deptcd
FROM dept_h
START WITH deptcd = 'dept0_00_0'
CONNECT BY  deptcd = PRIOR p_deptcd;
--AND deptnm LIKE '디자인%' --AND col = PRIOR col2 -- WHERE절마냥 조건이 담기는것이므로 둘다 해당되는것을 찾는다


-- 계층형 쿼리 복습
SELECT *
FROM h_sum;

-- 실습 4.
SELECT LPAD(' ', 3*(level-1)) || s_id, VALUE
FROM h_sum
START WITH s_id = '0'
CONNECT BY PRIOR s_id = ps_id;

-- 실습 5.
SELECT *
FROM no_emp;

SELECT LPAD(' ', 2*(LEVEL-1)) || org_cd, no_emp
FROM no_emp
START WITH org_cd = 'XX회사'
CONNECT BY parent_org_cd = PRIOR org_cd;


-- pruning branch (가지치기)
-- 계층 쿼리의 실행순서
-- FROM -> START WITH - CONNECT BY  -> WHERE
-- 조건을 CONNECT BY 에 기술한 경우
-- , 조건에 따라 다음 ROW로 연결이 안되고 종료
-- 조건을 WHERE절에 기술한 경우
-- , START WITH - CONNECT BY 절에 의해 계층형으로 나온 결과에 WHERE 절에 기술한 결과 값에 해당하는 데이터만 표현

-- 최상위 노드에서 하향식으로 탐색

-- CONNECT BY 절에 deptnm != '정보기획부'을 기술한 경우
SELECT *
FROM dept_h
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = p_deptcd AND deptnm != '정보기획부';

-- WHERE절의 경우
SELECT *
FROM dept_h
WHERE deptnm != '정보기획부'
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = p_deptcd;

-- 계층 쿼리에서 사용 가능한 특수 함수 ----------------------------------------------------------------------------------------------
--1. CONNECT_BY_ROOT(col) : 가장 최상위 row의 col 정보 값 조회
SELECT deptcd, LPAD(' ', 2*(LEVEL-1)) || deptnm
        ,CONNECT_BY_ROOT(deptnm) c_root
FROM dept_h
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = p_deptcd;

--2. SYS_CONNECT_BY_PATH(col, 구분자) : 최상위 row에서 현재 row까지 col값을 구분자로 연결해준 문자열
-- 구분자로 연결해준 문자열 (EX : XX회사 - 디자인부 - 디자인팀) 
-- LTRIM을 통해서 가장왼쪽의 구준자를 없애도록한다.
SELECT deptcd, LPAD(' ', 2*(LEVEL-1)) || deptnm
        ,LTRIM(SYS_CONNECT_BY_PATH(deptnm, '-'), '-') sys_path
FROM dept_h
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = p_deptcd;

--3. CONNECT_BY_ISLEAF : 해당 ROW가 마지막 노드인지(leaf node)  --트리구조의 root leaf개념
-- leaf node : 1, node : 0
SELECT deptcd, LPAD(' ', 2*(LEVEL-1)) || deptnm
        ,CONNECT_BY_ISLEAF
FROM dept_h
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = p_deptcd;
--------------------------------------------------------------------------------------------------------------------------------

-- 실습4.
SELECT *
FROM board_test;
DESC BOARD_TEST;

--실습 5. Pre - order 형식의 트리구조로 진행되므로  seq가 하나씩 진행되면서 자식노드를 보고 다음 seq노드로 이동.
SELECT seq, LPAD(' ', 3*(level-1)) || title
FROM board_test
START WITH SEQ = 1 OR SEQ = 2 OR SEQ = 4
CONNECT BY PRIOR seq = parent_seq;

-- 실습 7. ORDER SIBLINGS BY 계층 구조를 유지하면서 정렬하는법
SELECT seq, LPAD(' ', 3*(level-1)) || title
FROM board_test
START WITH SEQ = 1 OR SEQ = 2 OR SEQ = 4
CONNECT BY PRIOR seq = parent_seq
ORDER SIBLINGS BY seq DESC;


----------------------------------------------------------------------
SELECT seq, LPAD(' ', 3*(level-1)) || title
FROM board_test
START WITH SEQ = 1 OR SEQ = 2 OR SEQ = 4
CONNECT BY PRIOR seq = parent_seq
ORDER BY CONNECT_BY_ROOT(seq) DESC, seq;

SELECT seq, LPAD(' ', 3*(level-1)) || title
FROM board_test
START WITH SEQ = 1 OR SEQ = 2 OR SEQ = 4
CONNECT BY PRIOR seq = parent_seq
ORDER SIBLINGS BY NVL(parent_seq,seq )DESC;





