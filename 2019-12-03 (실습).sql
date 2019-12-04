-- 도시 발전지수가 높은 순으로 나열
-- 도시발전지수 : (버거킹 + KFC + 맥도날드) / 롯데리아
-- 순위 / 시도 / 시군구 / 도시발전지수

--해당 시도, 시군구별 프렌차이즈별 건수가 필요
SELECT sido, sigungu, gb, COUNT(*) cnt
FROM fastfood
GROUP BY sido, sigungu, gb;

-- 3개 프렌차이즈의 합이 필요한것이므로 gb를 삭제
SELECT sido, sigungu, COUNT(*) cnt
FROM fastfood
WHERE GB IN ('버거킹', '맥도날드', 'KFC')
GROUP BY sido, sigungu;

-- 롯데리아의 건수
SELECT sido, sigungu, COUNT(*) cnt
FROM fastfood
WHERE GB = '롯데리아'
GROUP BY sido, sigungu;

-- 조인시작
SELECT a.sido, a.sigungu, ROUND(a.cnt/b.cnt, 1) 도시발전지수
FROM
    (SELECT sido, sigungu, COUNT(*) cnt
    FROM fastfood
    WHERE GB IN ('버거킹', '맥도날드', 'KFC')
    GROUP BY sido, sigungu) a
    ,(SELECT sido, sigungu, COUNT(*) cnt
    FROM fastfood
    WHERE GB = '롯데리아'
    GROUP BY sido, sigungu) b
WHERE a.sido = b.sido
AND a.sigungu = b.sigungu
ORDER BY 도시발전지수 DESC;


-- 순위 매기기
SELECT ROWNUM RANK, sido, sigungu, 도시발전지수
FROM
    (SELECT a.sido, a.sigungu, ROUND(a.cnt/b.cnt, 1) 도시발전지수
    FROM
        (SELECT sido, sigungu, COUNT(*) cnt
        FROM fastfood
        WHERE GB IN ('버거킹', '맥도날드', 'KFC')
        GROUP BY sido, sigungu) a
        ,(SELECT sido, sigungu, COUNT(*) cnt
        FROM fastfood
        WHERE GB = '롯데리아'
        GROUP BY sido, sigungu) b
    WHERE a.sido = b.sido
    AND a.sigungu = b.sigungu
    ORDER BY 도시발전지수 DESC);


-- 내가한거
SELECT ROWNUM AS 순위, c.sido, c.sigungu AS 시군구, c.도시발전지수
FROM
    (SELECT ROWNUM, a.sido, b.sido, b.sigungu AS sigungu, ROUND(a.cnt/b.cnt, 1) AS 도시발전지수
    FROM
        (SELECT SIDO, SIGUNGU, COUNT(*) AS cnt
        FROM FASTFOOD
        WHERE GB IN ('버거킹', '맥도날드', 'KFC')
        GROUP BY SIDO, SIGUNGU) a
        ,(SELECT SIDO, SIGUNGU, COUNT(*) AS cnt
        FROM FASTFOOD
        WHERE GB = '롯데리아'
        GROUP BY SIDO, SIGUNGU) b
    WHERE a.sido = b.sido
    AND a.sigungu = b.sigungu
    ORDER BY 도시발전지수 DESC) c;



SELECT GB, SIDO, SIGUNGU, COUNT(*) AS cnt
FROM FASTFOOD
WHERE GB IN ('버거킹', 'KFC', '맥도날드')
GROUP BY GB, SIDO, SIGUNGU;



