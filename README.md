# 🎬 PVR Theater Management System

## 📌 Project Overview
The PVR Theater Management System is a MySQL-based database project designed to manage theater ticket bookings and cancellations efficiently.

It helps manage ticket availability, booking records, cancellation records, and transaction operations using SQL Stored Procedures.

## 🛠️ Technologies Used
- MySQL
- MySQL Workbench
- SQL

## 🎯 Project Features

### 1. Ticket Booking
- Book tickets based on theater ID and ticket type.
- Checks available theater capacity before confirming bookings.
- Updates available capacity after successful booking.

### 2. Ticket Cancellation
- Cancel previously booked tickets.
- Validates booking ID and cancellation quantity.
- Automatically calculates the refund amount.
- Updates theater capacity after cancellation.

### 3. Automatic Capacity Management
- Reduces available capacity after ticket booking.
- Increases available capacity after ticket cancellation.
- Prevents bookings beyond available capacity.

### 4. Transaction Management
- Uses START TRANSACTION, COMMIT and ROLLBACK.
- Maintains data consistency during booking and cancellation operations.

### 5. Error Handling & Validation
- Validates ticket type.
- Checks valid booking ID.
- Prevents zero or negative ticket quantities.
- Checks available capacity.
- Handles SQL exceptions.

## 🗄️ Database Tables

The project contains three tables:

1. **Theater** – Stores theater details, ticket types, rates, and capacity.
2. **Bookings** – Stores ticket booking transactions.
3. **TicketCancellation** – Stores ticket cancellation and refund details.

## ⚙️ Stored Procedures

Two stored procedures are implemented:

- `SP_BookTicket` – Handles ticket booking operations.
- `sp_TicketCancellation` – Handles ticket cancellation operations.

## ▶️ How to Run the Project

1. Install MySQL Server and MySQL Workbench.
2. Download the SQL file from this repository.
3. Open MySQL Workbench.
4. Open the downloaded `.sql` file.
5. Execute the SQL script.
6. Test the booking and cancellation stored procedures.

## 📚 SQL Concepts Practiced

- Database Creation
- Table Creation
- Primary Key & Foreign Key
- INSERT, UPDATE and SELECT
- Stored Procedures
- Transactions
- COMMIT & ROLLBACK
- Error Handling
- SQL Validation

**Author Name:** Harishchandra    
**Project Name:** PVR Theater Management System  
**Database:** MySQL  
**Project Type:** SQL Database Project     
**LinkedIn:** https://www.linkedin.com/in/harishchandra-patgar-940ba6434?utm_source=share_via&utm_content=profile&utm_medium=member_android   
**E-mail:** harishchandra102005@gmail.com
