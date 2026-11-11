# Ampla-Sql-Scripts

A collection of SQL scripts useful for working with Ampla projects.

## Ampla Scripts

- [Reporting Point Scripts](src/Reporting-Points)
- [Ampla Project Scripts](src/Ampla-Project)
- [Stream Scripts](src/Streams)
- [Threshold Ranges Information](src/ThresholdRanges)

## Database Scripts

- [Database Scripts](src/Database)

## Data Repository Scripts

- [Integrity Checks](src/Checks)

---

## Reporting Point Scripts

**Location:** [src/Reporting-Points](src/Reporting-Points)

A set of scripts to count the number of records by reporting point type.

### Scripts

- Module.RecordCounts.sql
- Module.FieldCounts.sql

---

## Ampla Project Scripts

**Location:** [src/Ampla-Project](src/Ampla-Project)

A set of scripts for understanding the Ampla Project configuration database.

### Scripts

- Item.FullName.sql
- Item.FullName.Sorted.sql
- Item.FullName.Type.sql

---

## Stream Scripts

**Location:** [src/Streams](src/Streams)

A set of scripts for understanding the streams in the Ampla State Database.

### Scripts

- Streams.Age.sql
- Streams.LastSamples.sql
- Streams.Orphaned.sql
- Streams.SampleCount.sql

---

## Database Scripts

**Location:** [src/Database](src/Database)

A set of scripts that provide general information about SQL Server databases.

### Scripts

- Database.Assembly.VersionTableSizes.sql
- Database.ShrinkFiles.sql

---

## Data Integrity Checks

**Location:** src/Checks

A set of scripts to check the data integrity of the Ampla Data Repository.

### Scripts

- DataRepository.Field.Duplicate.sql
- DataRepository.Field.Deleted.sql
- DataRepository.Field.InfinityNaN.sql
- Database.Trustworthy.sql
