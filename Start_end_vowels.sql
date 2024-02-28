select distinct
city
from station
WHERE
REGEXP_LIKE(city,'^a|^e|^i|^o|^u','i') AND
REGEXP_LIKE(city,'a$|e$|i$|o$|u$','i')
;
