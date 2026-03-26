/*

=================================================================
FINAL PROJECT – RELATIONAL DATABASE DESIGN
Ride-Hailing Platform Simulation (Uber-like Model)
=================================================================

Author: Ginmer Martínez
Course: Databases I – SQL Server
Institution: ICAI
Year: 2026

-----------------------------------------------------------------
DOMAIN DEFINITION
-----------------------------------------------------------------

The system models a ride-hailing platform similar to Uber.
Its purpose is to manage the complete lifecycle of a trip,
including request, driver assignment, execution, payment,
and rating processes.

The system allows the registration of individuals within
the platform, distinguishing between passengers and drivers
through a specialization process.

Trips may initially exist without an assigned driver,
accurately representing the operational flow of real-world
ride-hailing platforms.

The database supports performance analysis, revenue tracking,
user behavior metrics, and operational analytics while ensuring
referential integrity and Third Normal Form (3NF) compliance.

*/

/* =========================================================
   FINAL PROJECT – DATABASES I
   Ride-Hailing Platform
   ========================================================= */

USE master;
GO

IF DB_ID('RideHailingDB') IS NOT NULL
BEGIN
    ALTER DATABASE RideHailingDB 
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE RideHailingDB;
END
GO

CREATE DATABASE RideHailingDB;
GO

USE RideHailingDB;
GO



/* ===================== DDL ===================== */

CREATE TABLE dbo.Person (
    PersonId INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20) NOT NULL,
    RegistrationDate DATE NOT NULL DEFAULT GETDATE(),
    PasswordHash VARBINARY(64) NULL
);
GO

CREATE TABLE dbo.Usuario (
    UsuarioId INT PRIMARY KEY,
    PersonId INT NOT NULL UNIQUE,
    CONSTRAINT FK_Usuario_Person
        FOREIGN KEY (PersonId)
        REFERENCES dbo.Person(PersonId)
);
GO

CREATE TABLE dbo.Driver (
    DriverId INT PRIMARY KEY,
    PersonId INT NOT NULL UNIQUE,
    LicenseNumber VARCHAR(30) NOT NULL,
    LicenseExpirationDate DATE NOT NULL,
    DriverStatus VARCHAR(20) NOT NULL DEFAULT 'Active'
        CHECK (DriverStatus IN ('Active','Inactive')),
    CONSTRAINT FK_Driver_Person
        FOREIGN KEY (PersonId)
        REFERENCES dbo.Person(PersonId)
);
GO

CREATE TABLE dbo.Zone (
    ZoneId INT PRIMARY KEY,
    ZoneName VARCHAR(100) NOT NULL,
    BaseFare DECIMAL(10,2) NOT NULL CHECK (BaseFare >= 0)
);
GO

CREATE TABLE dbo.Trip (
    TripId INT PRIMARY KEY,
    UsuarioId INT NOT NULL,
    DriverId INT NULL,
    ZoneId INT NOT NULL,
    RequestDate DATETIME NOT NULL DEFAULT GETDATE(),
    TotalFare DECIMAL(10,2) NOT NULL CHECK (TotalFare >= 0),
    CONSTRAINT FK_Trip_Usuario
        FOREIGN KEY (UsuarioId)
        REFERENCES dbo.Usuario(UsuarioId),
    CONSTRAINT FK_Trip_Driver
        FOREIGN KEY (DriverId)
        REFERENCES dbo.Driver(DriverId),
    CONSTRAINT FK_Trip_Zone
        FOREIGN KEY (ZoneId)
        REFERENCES dbo.Zone(ZoneId)
);
GO

CREATE TABLE dbo.Payment (
    PaymentId INT PRIMARY KEY,
    TripId INT NOT NULL UNIQUE,
    Amount DECIMAL(10,2) NOT NULL CHECK (Amount >= 0),
    CONSTRAINT FK_Payment_Trip
        FOREIGN KEY (TripId)
        REFERENCES dbo.Trip(TripId)
);
GO

CREATE TABLE dbo.DriverZone (
    DriverZoneId INT PRIMARY KEY,
    DriverId INT NOT NULL,
    ZoneId INT NOT NULL,
    UNIQUE (DriverId, ZoneId),
    CONSTRAINT FK_DZ_Driver
        FOREIGN KEY (DriverId)
        REFERENCES dbo.Driver(DriverId),
    CONSTRAINT FK_DZ_Zone
        FOREIGN KEY (ZoneId)
        REFERENCES dbo.Zone(ZoneId)
);
GO

/* ===================== DML ===================== */

INSERT INTO dbo.Zone VALUES
(1,'San Jose',5.00),
(2,'Heredia',4.50),
(3,'Escazu',6.00);
GO

INSERT INTO dbo.Person VALUES
(1,'Carlos','Lopez','c1@mail.com','88888888','2026-01-01',HASHBYTES('SHA2_256','pass1')),
(2,'Maria','Gomez','m1@mail.com','87777777','2026-01-02',HASHBYTES('SHA2_256','pass2')),
(3,'Jose','Rodriguez','j1@mail.com','86666666','2026-01-03',HASHBYTES('SHA2_256','pass3')),
(4,'Ana','Perez','a1@mail.com','85555555','2026-01-04',HASHBYTES('SHA2_256','pass4')),
(5,'Luis','Mora','l1@mail.com','84444444','2026-01-05',HASHBYTES('SHA2_256','pass5')),
(6,'Sofia','Castro','s1@mail.com','83333333','2026-01-06',HASHBYTES('SHA2_256','pass6'));
GO

INSERT INTO dbo.Usuario VALUES
(1,1),
(2,2),
(3,3);
GO

INSERT INTO dbo.Driver VALUES
(1,4,'LIC4','2027-12-31','Active'),
(2,5,'LIC5','2027-12-31','Active'),
(3,6,'LIC6','2027-12-31','Active');
GO

INSERT INTO dbo.DriverZone VALUES
(1,1,1),
(2,1,2),
(3,2,2),
(4,3,3);
GO

INSERT INTO dbo.Trip VALUES
(1,1,1,1,GETDATE(),20.00),
(2,2,2,2,GETDATE(),15.00),
(3,3,NULL,3,GETDATE(),0.00),
(4,1,1,2,GETDATE(),25.00),
(5,2,3,3,GETDATE(),18.00);
GO

INSERT INTO dbo.Payment VALUES
(1,1,20),
(2,2,15),
(3,4,25);
GO

/* =========================================================
   PART V – CONSULTAS
   ========================================================= */

-- WHERE (5)
SELECT * FROM dbo.Trip WHERE TotalFare > 15;
SELECT * FROM dbo.Driver WHERE DriverStatus = 'Active';
SELECT * FROM dbo.Zone WHERE BaseFare >= 5 AND ZoneName <> 'Heredia';
SELECT * FROM dbo.Trip WHERE (ZoneId = 1 OR ZoneId = 2);
SELECT * FROM dbo.Person WHERE RegistrationDate >= '2026-01-03';

-- INNER JOIN (2)
SELECT t.TripId,p.FirstName
FROM dbo.Trip t
INNER JOIN dbo.Usuario u ON t.UsuarioId=u.UsuarioId
INNER JOIN dbo.Person p ON u.PersonId=p.PersonId;

SELECT d.DriverId,z.ZoneName
FROM dbo.DriverZone dz
INNER JOIN dbo.Driver d ON dz.DriverId=d.DriverId
INNER JOIN dbo.Zone z ON dz.ZoneId=z.ZoneId;

-- LEFT JOIN
SELECT d.DriverId,t.TripId
FROM dbo.Driver d
LEFT JOIN dbo.Trip t ON d.DriverId=t.DriverId;

-- FULL OUTER JOIN
SELECT d.DriverId,t.TripId
FROM dbo.Driver d
FULL OUTER JOIN dbo.Trip t ON d.DriverId=t.DriverId;

-- ANTI JOIN
SELECT d.DriverId
FROM dbo.Driver d
LEFT JOIN dbo.Trip t ON d.DriverId=t.DriverId
WHERE t.TripId IS NULL;

-- SUBQUERY IN
SELECT * FROM dbo.Trip
WHERE UsuarioId IN (SELECT UsuarioId FROM dbo.Usuario);

-- UPDATE IN
UPDATE dbo.Driver
SET DriverStatus='Inactive'
WHERE DriverId IN (SELECT DriverId FROM dbo.DriverZone WHERE ZoneId=3);

-- UPDATE SET SELECT
UPDATE dbo.Payment
SET Amount = (SELECT TotalFare FROM dbo.Trip WHERE Trip.TripId = Payment.TripId);

-- TEMP TABLE
/*
IF OBJECT_ID('tempdb..#TempTrips') IS NOT NULL
    DROP TABLE #TempTrips;
GO
*/

SELECT * INTO #TempTrips FROM dbo.Trip WHERE TotalFare > 10;
SELECT * FROM #TempTrips;

-- AGREGACIONES
SELECT COUNT(*) FROM dbo.Trip;
SELECT COUNT(DriverId) FROM dbo.Trip;
SELECT SUM(TotalFare) FROM dbo.Trip;
SELECT AVG(TotalFare) FROM dbo.Trip;
SELECT MIN(TotalFare),MAX(TotalFare) FROM dbo.Trip;

SELECT DriverId,COUNT(*) AS TotalTrips
FROM dbo.Trip
WHERE TotalFare > 10
GROUP BY DriverId
HAVING COUNT(*) >= 1;

-- FUNCIONES
SELECT STRING_AGG(ZoneName,', ') FROM dbo.Zone;

SELECT DriverId,
CASE WHEN DriverStatus='Active' THEN 'Working' ELSE 'Not Working' END
FROM dbo.Driver;

SELECT DATEDIFF(DAY,RegistrationDate,GETDATE()) FROM dbo.Person;

SELECT TRY_CAST('123' AS INT);

/* =========================================================
   PART VI – VIEWS
   ========================================================= */
GO
CREATE VIEW dbo.vw_TripsSummary AS
SELECT t.TripId,p.FirstName,z.ZoneName,t.TotalFare
FROM dbo.Trip t
JOIN dbo.Usuario u ON t.UsuarioId=u.UsuarioId
JOIN dbo.Person p ON u.PersonId=p.PersonId
JOIN dbo.Zone z ON t.ZoneId=z.ZoneId;
GO

CREATE VIEW dbo.vw_ActiveDrivers AS
SELECT DriverId,DriverStatus
FROM dbo.Driver
WHERE DriverStatus='Active';
GO

/* =========================================================
   PART VII – SELECT INTO
   ========================================================= */

SELECT * INTO dbo.TripBackup FROM dbo.Trip;
SELECT * INTO dbo.HighValueTrips FROM dbo.Trip WHERE TotalFare > 20;
GO






/*

=================================================================
PROJECT CONCLUSION
=================================================================

This project demonstrates the complete design and implementation
of a relational database using Microsoft SQL Server, following
a structured approach from conceptual modeling to advanced
query analysis.

The database was designed applying normalization up to Third
Normal Form (3NF), ensuring elimination of partial and transitive
dependencies while preserving data integrity and consistency.

All entities, relationships, constraints, and business rules
were implemented with explicit PRIMARY KEY, FOREIGN KEY,
UNIQUE, CHECK, DEFAULT and NOT NULL constraints to guarantee
referential integrity.

The system supports analytical queries using JOIN operations,
subqueries, aggregations, views, SELECT INTO operations and
business logic expressions, enabling operational and performance
analysis of a ride-hailing platform.

This implementation reflects relational thinking, structured
design principles, and professional SQL Server practices.

*/
-- ===============================================================
-- End of Script
-- ===============================================================
