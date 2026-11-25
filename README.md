# SQL Portfolio | Data Analysis & Database Design

A collection of four PostgreSQL projects completed as part of my database coursework at **HAW Hamburg**. These projects demonstrate my practical experience in SQL querying, data analysis, data quality assessment and relational database design.

## Projects

| # | Project | Description | Key SQL Skills |
|---|---|---|---|
| 01 | [Flight Data Analytics](./01-flight-analytics/) | Analysis of German flight data from 2024, including routes, passenger numbers, seat capacity and flight connections. | JOINs, aggregations, CTEs, UNION ALL |
| 02 | [UN Country & Energy Data](./02_un_country_energy/) | Analysis of global population and energy statistics, including population rankings, missing data detection and data consistency checks. | Window Functions, RANK, DENSE_RANK, CROSS JOIN, NOT EXISTS, CTEs |
| 03 | [Olympic Games Analysis](./03_olympic_analysis/) | Analysis of Olympic medal statistics, country performance and disciplines, alongside data quality and referential integrity checks. | Aggregations, DISTINCT, FILTER, Window Functions, LEFT JOIN |
| 04 | [Q&A Platform Database Design](./04_database_design/) | Design and implementation of a Stack Overflow-style database, including ER modelling, relational schema and automated answer counting. | Database Design, ER Modelling, 3NF, DDL, Constraints, Foreign Keys, PL/pgSQL Triggers |

## Project Highlights

### 01. Flight Data Analytics

Analysed flight data from and to German airports in 2024.

Key findings:
- Identified Bremen as the shortest direct route from Hamburg (103 km).
- Calculated 71,883 passengers travelling from Hamburg to Brussels.
- Calculated a seat occupancy rate (load factor) of 66.2% for the Hamburg–Brussels route.
- Identified the shortest connection from Hamburg to Cape Town: Hamburg → Munich → Cape Town (9,779 km).

### 02. UN Country & Energy Data

Worked with international population and energy datasets.

Key findings:
- Ranked the 25 most populated countries in 2024, with India ranking first.
- Used window functions to rank countries by population density.
- Checked whether country-level energy figures matched reported world totals.
- Identified missing data combinations across countries, years and energy indicators.

### 03. Olympic Games Analysis

Explored Olympic medal statistics and assessed the quality of the results dataset.

Key findings:
- Identified Michael Phelps as the athlete with the highest medal count in the dataset (16 medals).
- Analysed the countries winning the most medals across Summer Olympic editions from 2000 to 2020.
- Identified the top 10 disciplines by medal count.
- Investigated events with unexpected medal distributions and missing medal records.
- Performed referential integrity checks on athlete IDs.

### 04. Q&A Platform Database Design

Designed and implemented a relational database inspired by Stack Overflow.

The project includes:
- Entity Relationship Model (ERM).
- Relational Model following Third Normal Form (3NF).
- Six relational tables: Users, Skill, Question, Answer, Tag and QuestionTag.
- Primary keys, foreign keys, constraints and relationships.
- A PostgreSQL PL/pgSQL trigger to automatically update the answer count when answers are inserted or deleted.

## Technical Skills Demonstrated

| Category | Skills |
|---|---|
| Database | PostgreSQL, Relational Database Design |
| SQL Querying | SELECT, JOINs, GROUP BY, HAVING, Subqueries |
| Advanced SQL | CTEs, Window Functions, UNION ALL |
| Data Analysis | Aggregations, Rankings, Statistical Comparisons |
| Data Quality | Missing Data Detection, Consistency Checks, Referential Integrity |
| Database Development | DDL, Primary Keys, Foreign Keys, Constraints, Triggers |
| Database Modelling | ER Diagrams, Relational Models, 3NF |

## Tools & Technologies

- **PostgreSQL** – Database management and SQL queries
- **pgAdmin** – Database interaction and query execution
- **SQL** – Data analysis and database implementation

## Repository Structure

```text
SQL-Portfolio/
│
├── README.md
│
├── 01_Flight_Analytics/
│   └── flight_analysis.sql
│
├── 02_UN_Country_Energy/
│   └── energy_analysis.sql
│
├── 03_Olympic_Analysis/
│   └── olympic_analysis.sql
│
└── 04_QA_Database_Design/
    ├── schema.sql
    ├── demo_data.sql
    ├── ER_Diagram.png
    └── Relational_Model.png
```

## About This Portfolio

These projects were developed as part of my database coursework at HAW Hamburg. They represent my practical application of SQL and relational database concepts to analytical and database design problems.


