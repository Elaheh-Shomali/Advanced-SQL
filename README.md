# Advanced SQL

Welcome to **Advanced SQL** – a repository dedicated to sharpening your intermediate and advanced SQL skills. Here, you will work through a series of challenges designed to deepen your understanding of advanced SQL functionalities, from subqueries and common table expressions to temporary tables and window functions.

## Overview

SQL remains the cornerstone language for interacting with relational databases, the most prevalent system for organizing vast amounts of data. Despite emerging alternatives, SQL's efficiency and consistency continue to make it the go-to tool for data management and analysis. This repository is tailored to equip you with the expertise needed to tackle complex data problems, moving beyond basic data retrieval into sophisticated manipulation and analysis techniques.

## What You'll Learn

- **Subqueries and Common Table Expressions:** Use these techniques to break down complex queries into manageable parts and improve readability.
- **Temporary Tables and Window Functions:** Leverage these tools to perform advanced data analysis, including cumulative calculations and moving averages.
- **Stored Routines:** Develop and apply stored procedures and functions to streamline repetitive tasks and encapsulate business logic.

## Repository Structure

- **1_database/**  
  Contains the `chinook_data.sql` and `northwind_data.sql` files. 

- **2_SQL_Scripts/**  
  A collection of SQL scripts that are organized by challenge level. These scripts includes:
  - **Foundational Puzzles:** Begin with challenges that refresh your core SQL concepts, setting the stage for more complex tasks.
  - **Advanced Challenges:** Each subsequent challenge increases in difficulty, encouraging you to harness your knowledge of joins, aggregations, and other advanced SQL features to solve unique data puzzles.


## Getting Started

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/yourusername/Advanced-SQL-Mastery.git

2. **Unzip and Import the Database:**

- Navigate to the `1_database` folder.
- Unzip the `chinook_data.sql` and `northwind_data.sql` files if necessary.
- Open MySQL Workbench and connect to your local MySQL server instance (you will need the root password set during installation).
- From *Server*, use the *Import* feature by choosing the "Import from Self-Contained File" option and selecting `chinook_data.sql` or `northwind_data.sql` file.
- Refresh your Schemas panel to see your newly imported database.

3. **Explore the SQL Scripts:**

- Move to the `2_SQL_Scripts` folder.
- Start with the simpler scripts in the `2_SQL_Scripts` folder in order to refresh your core SQL concepts.
- Each script includes comments and instructions to help you understand the purpose and solution approach for each challenge.
- Progress to the more advanced scripts as you build confidence in your SQL skills.

