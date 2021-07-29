config { hasOutput: true }
CREATE TABLE ${self()}
(
  zipcode STRING NOT NULL OPTIONS(description="Five digit ZIP Code Tabulation Area Census Code"),
  geo_id STRING OPTIONS(description="Geo code"),
  minimum_age INT64 OPTIONS(description="The minimum age in the age range. If null, this indicates the row as a total for male, female, or overall population."),
  maximum_age INT64 OPTIONS(description="The maximum age in the age range. If null, this indicates the row as having no maximum (such as 85 and over) or the row is a total of the male, female, or overall population."),
  gender STRING OPTIONS(description="male or female. If empty, the row is a total population summary."),
  population INT64 OPTIONS(description="The total count of the population for this segment."),
  this_is_some_new_column STRING NOT NULL,
  oh_look_another_new_column NUMERIC NOT NULL,
)
OPTIONS(
  labels=[("freebqcovid", "")]
);