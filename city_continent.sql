/*
all continents, average city population round down
*/
SELECT co.continent,  
FLOOR(AVG(ci.population)) as Avg_population
FROM country co
INNER JOIN city ci
WHERE co.code= ci.countrycode
GROUP BY Co.continent 
