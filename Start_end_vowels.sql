select distinct
city
from station
WHERE
REGEXP_LIKE(city,'^a|^e|^i|^o|^u','i') AND
REGEXP_LIKE(city,'a$|e$|i$|o$|u$','i')
;


select distinct
city
from station
WHERE
city NOT LIKE 'A%'
AND city NOT LIKE 'E%'
AND city NOT LIKE 'I%'
AND city NOT LIKE 'O%'
AND city NOT LIKE 'U%'
--(city,'a$|e$|i$|o$|u$', 'i')
ORDER BY 1 ASC
;

SELECT DISTINCT 
CITY 
FROM STATION 
WHERE CITY NOT REGEXP '^[AEIOUaeiou]' OR CITY NOT REGEXP '[AEIOUaeiou]$';


SELECT DISTINCT 
  CITY 
FROM STATION 
  WHERE NOT RIGHT(CITY, 1) IN('a','e','i','o','u','A','I','O','E','U') 
AND NOT LEFT (CITY, 1) IN('a','e','i','o','u','A','I','O','E','U');
