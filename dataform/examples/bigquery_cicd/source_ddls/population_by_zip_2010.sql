CREATE TABLE dataform_prod.population_by_zip_2010
(
  geo_id STRING OPTIONS(description="Geo code"),
  zipcode STRING NOT NULL OPTIONS(description="IVE BEEN UPDATED"),
  population STRING OPTIONS(description="The total count of the population for this segment."),
  minimum_age INT64 OPTIONS(description="The minimum age in the age range. If null, this indicates the row as a total for male, female, or overall population."),
  maximum_age INT64 OPTIONS(description="The maximum age in the age range. If null, this indicates the row as having no maximum (such as 85 and over) or the row is a total of the male, female, or overall population."),
  gender STRING OPTIONS(description="male or female. If empty, the row is a total population summary."),
  a_new_date_column DATE NOT NULL,
)
OPTIONS(
  labels=[("freebqcovid", "")]
);