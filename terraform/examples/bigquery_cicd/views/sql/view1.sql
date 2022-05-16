SELECT
  year,
  zipcode,
  SUM(population) AS population
FROM (
  SELECT zipcode, population, 2000 AS year 
  FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2000`
  UNION ALL
  SELECT zipcode, population, 2010 AS year 
  FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
)
GROUP BY 1,2