-- RaceDay Database Schema
-- For SQL Server Management Studio (SSMS)

-- Drop tables if they exist 
IF OBJECT_ID('dbo.Result', 'U') IS NOT NULL DROP TABLE dbo.Result;
IF OBJECT_ID('dbo.Enrolment', 'U') IS NOT NULL DROP TABLE dbo.Enrolment;
IF OBJECT_ID('dbo.Category', 'U') IS NOT NULL DROP TABLE dbo.Category;
IF OBJECT_ID('dbo.Event', 'U') IS NOT NULL DROP TABLE dbo.Event;
IF OBJECT_ID('dbo.Organiser', 'U') IS NOT NULL DROP TABLE dbo.Organiser;
IF OBJECT_ID('dbo.User', 'U') IS NOT NULL DROP TABLE dbo.User;
GO

-- Create Organiser table
CREATE TABLE Organiser (
    organiser_id INT IDENTITY(1,1) PRIMARY KEY,
    company_name NVARCHAR(100) NOT NULL,
    registration_number NVARCHAR(50) NOT NULL UNIQUE,
    email NVARCHAR(100) NOT NULL UNIQUE,
    phone NVARCHAR(20) NOT NULL,
    physical_address NVARCHAR(255) NOT NULL,
    password_hash NVARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- Create User table
CREATE TABLE [User] (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    phone NVARCHAR(20) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender NVARCHAR(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    id_number NVARCHAR(20) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    emergency_contact NVARCHAR(100),
    emergency_phone NVARCHAR(20),
    medical_conditions NVARCHAR(500),
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- Create Event table
CREATE TABLE Event (
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    organiser_id INT NOT NULL,
    event_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500),
    event_type NVARCHAR(20) NOT NULL CHECK (event_type IN ('Running', 'Walking', 'Cycling')),
    event_date DATE NOT NULL,
    start_time TIME NOT NULL,
    cut_off_time TIME,
    location NVARCHAR(100) NOT NULL,
    address NVARCHAR(255) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    max_participants INT NOT NULL CHECK (max_participants > 0),
    entry_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    registration_deadline DATETIME NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT 'Draft' CHECK (status IN ('Draft', 'Open', 'Closed', 'Cancelled', 'Completed')),
    route_description NVARCHAR(1000),
    weather_info NVARCHAR(500),
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Event_Organiser FOREIGN KEY (organiser_id) REFERENCES Organiser(organiser_id) ON DELETE CASCADE
);
GO

-- Create Category table
CREATE TABLE Category (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    event_id INT NOT NULL,
    category_name NVARCHAR(50) NOT NULL,
    age_min INT,
    age_max INT,
    gender_restriction NVARCHAR(10) CHECK (gender_restriction IN ('Male', 'Female', 'None')) DEFAULT 'None',
    distance NVARCHAR(20) NOT NULL,
    difficulty_level NVARCHAR(10) CHECK (difficulty_level IN ('Easy', 'Moderate', 'Hard', 'Extreme')),
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Category_Event FOREIGN KEY (event_id) REFERENCES Event(event_id) ON DELETE CASCADE,
    CONSTRAINT CHK_AgeRange CHECK (age_min IS NULL OR age_max IS NULL OR age_min < age_max)
);
GO

-- Create Enrolment table
CREATE TABLE Enrolment (
    enrolment_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    event_id INT NOT NULL,
    category_id INT NOT NULL,
    enrolment_date DATETIME NOT NULL DEFAULT GETDATE(),
    status NVARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Confirmed', 'Paid', 'Cancelled', 'Completed')),
    amount_paid DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    payment_reference NVARCHAR(50),
    race_number NVARCHAR(20),
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Enrolment_User FOREIGN KEY (user_id) REFERENCES [User](user_id) ON DELETE CASCADE,
    CONSTRAINT FK_Enrolment_Event FOREIGN KEY (event_id) REFERENCES Event(event_id) ON DELETE CASCADE,
    CONSTRAINT FK_Enrolment_Category FOREIGN KEY (category_id) REFERENCES Category(category_id),
    CONSTRAINT UQ_Enrolment_Event_User UNIQUE (event_id, user_id)
);
GO

-- Create Result table
CREATE TABLE Result (
    result_id INT IDENTITY(1,1) PRIMARY KEY,
    enrolment_id INT NOT NULL,
    user_id INT NOT NULL,
    event_id INT NOT NULL,
    category_id INT NOT NULL,
    finish_time TIME,
    overall_rank INT,
    category_rank INT,
    official_time NVARCHAR(20),
    chip_time NVARCHAR(20),
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Result_Enrolment FOREIGN KEY (enrolment_id) REFERENCES Enrolment(enrolment_id),
    CONSTRAINT FK_Result_User FOREIGN KEY (user_id) REFERENCES [User](user_id),
    CONSTRAINT FK_Result_Event FOREIGN KEY (event_id) REFERENCES Event(event_id),
    CONSTRAINT FK_Result_Category FOREIGN KEY (category_id) REFERENCES Category(category_id)
);
GO

-- Create indexes for performance
CREATE INDEX IX_Event_Organiser ON Event(organiser_id);
CREATE INDEX IX_Event_Status ON Event(status);
CREATE INDEX IX_Event_EventDate ON Event(event_date);
CREATE INDEX IX_Category_Event ON Category(event_id);
CREATE INDEX IX_Enrolment_User ON Enrolment(user_id);
CREATE INDEX IX_Enrolment_Event ON Enrolment(event_id);
CREATE INDEX IX_Enrolment_Category ON Enrolment(category_id);
CREATE INDEX IX_Enrolment_Status ON Enrolment(status);
CREATE INDEX IX_Result_Event ON Result(event_id);
CREATE INDEX IX_Result_User ON Result(user_id);
CREATE INDEX IX_Result_Category ON Result(category_id);
GO

-- Seed Data
-- Insert Organisers
INSERT INTO Organiser (company_name, registration_number, email, phone, physical_address, password_hash)
VALUES 
    ('Gauteng Sports Events', 'REG2026-001', 'info@gautengsports.co.za', '0825550101', '123 Sports Blvd, Johannesburg, 2000', 'hashed_password_1'),
    ('Cape Town Athletic Club', 'REG2026-002', 'events@ctac.co.za', '0825550102', '456 Stadium Road, Cape Town, 8000', 'hashed_password_2');
GO

-- Insert Users (Participants)
INSERT INTO [User] (first_name, last_name, email, phone, date_of_birth, gender, id_number, password_hash, emergency_contact, emergency_phone, medical_conditions)
VALUES 
    ('Thabo', 'Mokoena', 'thabo.m@email.com', '0821234567', '1985-06-15', 'Male', '8506151234567', 'hashed_password_3', 'Sarah Mokoena', '0827654321', 'Mild asthma - carries inhaler'),
    ('Priya', 'Naidoo', 'priya.n@email.com', '0822345678', '1992-09-22', 'Female', '9209222345678', 'hashed_password_4', 'Ravi Naidoo', '0828765432', NULL);
GO

-- Insert Events
INSERT INTO Event (organiser_id, event_name, description, event_type, event_date, start_time, cut_off_time, location, address, latitude, longitude, max_participants, entry_fee, registration_deadline, status, route_description, weather_info)
VALUES 
    (1, 'Gauteng Marathon 2026', 'Annual marathon through the streets of Johannesburg', 'Running', '2026-11-15', '06:00:00', '12:00:00', 'Johannesburg', 'Johannesburg Stadium, Johannesburg', -26.194927, 28.035862, 5000, 250.00, '2026-11-01 23:59:00', 'Open', 'Route starts at Johannesburg Stadium, goes through Braamfontein, past Nelson Mandela Bridge, and returns to stadium', 'Highveld summer conditions, temperatures 15-25°C, afternoon thunderstorms possible'),
    (1, 'Gauteng Cycle Challenge', 'Premier cycling event in the province', 'Cycling', '2026-10-25', '07:00:00', '14:00:00', 'Pretoria', 'Voortrekker Monument, Pretoria', -25.775184, 28.178519, 2000, 350.00, '2026-10-10 23:59:00', 'Open', 'Challenging route from Voortrekker Monument through the Pretoria hills', 'Spring conditions, mild with light winds'),
    (2, 'Cape Town Two Oceans Trail', 'Scenic trail running event along the Cape coastline', 'Running', '2026-09-20', '05:30:00', '11:30:00', 'Cape Town', 'Hout Bay, Cape Town', -34.032157, 18.340820, 1000, 180.00, '2026-09-05 23:59:00', 'Open', 'Trail route from Hout Bay along Chapman''s Peak with ocean views', 'Spring conditions, cool to mild with coastal winds');
GO

-- Insert Categories
INSERT INTO Category (event_id, category_name, age_min, age_max, gender_restriction, distance, difficulty_level)
VALUES 
    -- Gauteng Marathon Categories
    (1, 'Full Marathon - Open', 18, NULL, 'None', '42.2 km', 'Hard'),
    (1, 'Full Marathon - Masters (40+)', 40, 60, 'None', '42.2 km', 'Hard'),
    (1, 'Half Marathon - Open', 16, NULL, 'None', '21.1 km', 'Moderate'),
    (1, '10km - Open', 14, NULL, 'None', '10 km', 'Moderate'),
    (1, '10km - Veterans (50+)', 50, NULL, 'None', '10 km', 'Easy'),
    
    -- Gauteng Cycle Challenge Categories
    (2, 'Elite Men', 18, NULL, 'Male', '120 km', 'Extreme'),
    (2, 'Elite Women', 18, NULL, 'Female', '120 km', 'Extreme'),
    (2, 'Age Group (30-39)', 30, 39, 'None', '80 km', 'Hard'),
    (2, 'Age Group (40-49)', 40, 49, 'None', '60 km', 'Moderate'),
    (2, 'Social Ride', 16, NULL, 'None', '40 km', 'Easy'),
    
    -- Cape Town Two Oceans Trail Categories
    (3, 'Ultra Trail', 21, NULL, 'None', '56 km', 'Extreme'),
    (3, 'Half Trail', 18, NULL, 'None', '28 km', 'Hard'),
    (3, 'Mini Trail', 12, 17, 'None', '12 km', 'Moderate');
GO

-- Insert Enrolments
INSERT INTO Enrolment (user_id, event_id, category_id, status, amount_paid, payment_reference, race_number)
VALUES 
    (1, 1, 1, 'Confirmed', 250.00, 'PAY-MAR-001', 'R101'),
    (1, 3, 11, 'Confirmed', 180.00, 'PAY-TRA-001', 'T202'),
    (2, 1, 3, 'Paid', 250.00, 'PAY-MAR-002', 'R102'),
    (2, 2, 8, 'Paid', 350.00, 'PAY-CYC-001', 'C305'),
    (1, 2, 9, 'Pending', 0.00, NULL, NULL),
    (2, 3, 12, 'Pending', 0.00, NULL, NULL);
GO

-- Insert Results
INSERT INTO Result (enrolment_id, user_id, event_id, category_id, finish_time, overall_rank, category_rank, official_time, chip_time)
VALUES 
    (1, 1, 1, 1, '03:45:23', 45, 12, '03:45:23', '03:44:56'),
    (3, 2, 1, 3, '02:15:47', 120, 8, '02:15:47', '02:15:12'),
    (2, 1, 3, 11, '06:52:15', 18, 3, '06:52:15', '06:50:33');
GO

-- Verify data
SELECT 'Organisers' AS TableName, COUNT(*) AS RowCount FROM Organiser
UNION ALL
SELECT 'Users', COUNT(*) FROM [User]
UNION ALL
SELECT 'Events', COUNT(*) FROM Event
UNION ALL
SELECT 'Categories', COUNT(*) FROM Category
UNION ALL
SELECT 'Enrolments', COUNT(*) FROM Enrolment
UNION ALL
SELECT 'Results', COUNT(*) FROM Result;
GO