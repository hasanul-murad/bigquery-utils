CREATE TABLE dataform_prod.population_by_zip_2010
(
  geo_id STRING OPTIONS(description="Geo code"),
  zipcode STRING NOT NULL OPTIONS(description="IVE BEEN UPDATED"),
  population STRING OPTIONS(description="The total count of the population for this segment."),
  minimum_age INT64 OPTIONS(description="The minimum age in the age range. If null, this indicates the row as a total for male, female, or overall population."),
  maximum_age INT64 OPTIONS(description="The maximum age in the age range. If null, this indicates the row as having no maximum (such as 85 and over) or the row is a total of the male, female, or overall population."),
  gender STRING OPTIONS(description="male or female. If empty, the row is a total population summary."),
  a_new_string_column STRING NOT NULL,
  a_new_bytes_column BYTES NOT NULL,
  a_new_integer_column INT64 NOT NULL,
  a_new_float_column FLOAT64 NOT NULL,
  a_new_boolean_column BOOL NOT NULL,
  a_new_timestamp_column TIMESTAMP NOT NULL,
  a_new_date_column DATE NOT NULL,
  a_new_time_column TIME NOT NULL,
  a_new_datetime_column DATETIME NOT NULL,
  a_new_numeric_column NUMERIC NOT NULL,
  a_new_bignumeric_column BIGNUMERIC NOT NULL,
)
OPTIONS(
  labels=[("freebqcovid", "")]
);