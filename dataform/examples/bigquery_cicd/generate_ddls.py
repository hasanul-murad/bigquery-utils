from pathlib import Path

NUM_FILES_TO_GENERATE = 1000

ddl_dir = Path("create_test_env/definitions/ddl_scale_test")
ddl_dir.mkdir(exist_ok=True)
for i in list(range(NUM_FILES_TO_GENERATE)):
    file_name = ddl_dir / f"test_table_{i}.sqlx"
    with open(file_name, 'w') as file:
        file.write("""
        config {{ hasOutput: true }}
        
        CREATE TABLE IF NOT EXISTS ${{self()}}
        (
          zipcode STRING NOT NULL OPTIONS(description="Five digit ZIP Code Tabulation Area Census Code"),
          geo_id STRING OPTIONS(description="Geo code"),
          minimum_age INT64 OPTIONS(description="The minimum age in the age range. If null, this indicates the row as a total for male, female, or overall population."),
          maximum_age INT64 OPTIONS(description="The maximum age in the age range. If null, this indicates the row as having no maximum (such as 85 and over) or the row is a total of the male, female, or overall population."),
          gender STRING OPTIONS(description="male or female. If empty, the row is a total population summary."),
          population INT64 OPTIONS(description="The total count of the population for this segment."),
        )
        OPTIONS(
          labels=[("freebqcovid", "")]
        )
        """)