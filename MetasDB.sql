USE zwright;
DROP TABLE IF EXISTS MetasDB;

CREATE TABLE MetasDB (
run_ID int(5),
seed_probability int(5),
divide_probability int(5),
CAFS_toggled int(5),
metastasis_probability int(5),
lsteps int(5),
tumor_count int(5),
CAF_count int(5),
PRIMARY KEY(run_ID, steps)
);
LOCK TABLES MetasDB WRITE;