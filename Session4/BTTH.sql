CREATE DATABASE OnlineLearningDB;
USE OnlineLearningDB;

CREATE TABLE Instructor (
    instructor_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE Student (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    email VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE Course (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(150) NOT NULL,
    short_description VARCHAR(255),
    total_sessions INT NOT NULL CHECK (total_sessions > 0),
    instructor_id INT NOT NULL,
    CONSTRAINT fk_course_instructor
        FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id)
);

CREATE TABLE Enrollment (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (student_id) REFERENCES Student(student_id),
    CONSTRAINT fk_enrollment_course
        FOREIGN KEY (course_id) REFERENCES Course(course_id),
    CONSTRAINT uq_student_course_enrollment UNIQUE (student_id, course_id)
);

CREATE TABLE Result (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    midterm_score DECIMAL(4,2) NOT NULL CHECK (midterm_score >= 0 AND midterm_score <= 10),
    final_score DECIMAL(4,2) NOT NULL CHECK (final_score >= 0 AND final_score <= 10),
    CONSTRAINT fk_result_student
        FOREIGN KEY (student_id) REFERENCES Student(student_id),
    CONSTRAINT fk_result_course
        FOREIGN KEY (course_id) REFERENCES Course(course_id),
    CONSTRAINT uq_student_course_result UNIQUE (student_id, course_id)
);

-- Nhap du lieu ban dau

INSERT INTO Instructor (full_name, email) VALUES
('Nguyen Van A', 'nguyenvana@univ.edu.vn'),
('Tran Thi B', 'tranthib@univ.edu.vn'),
('Le Van C', 'levanc@univ.edu.vn'),
('Pham Thi D', 'phamthid@univ.edu.vn'),
('Hoang Van E', 'hoangvane@univ.edu.vn');

INSERT INTO Student (full_name, birth_date, email) VALUES
('Nguyen Minh Anh', '2004-03-15', 'minhanh@student.edu.vn'),
('Tran Quoc Bao', '2003-11-22', 'quocbao@student.edu.vn'),
('Le Thu Ha', '2004-07-09', 'thuha@student.edu.vn'),
('Pham Duc Huy', '2002-12-30', 'duchuy@student.edu.vn'),
('Vo Ngoc Lan', '2004-01-18', 'ngoclan@student.edu.vn');

INSERT INTO Course (course_name, short_description, total_sessions, instructor_id) VALUES
('Co so du lieu', 'Hoc ve mo hinh quan he va SQL co ban', 20, 1),
('Lap trinh Java', 'Nhap mon lap trinh huong doi tuong voi Java', 24, 2),
('Phat trien Web', 'Xay dung ung dung web full-stack co ban', 22, 3),
('Tri tue nhan tao', 'Tong quan AI va cac mo hinh hoc may', 18, 4),
('Mang may tinh', 'Kien thuc co ban ve mang va giao thuc', 16, 5);

INSERT INTO Enrollment (student_id, course_id, enrollment_date) VALUES
(1, 1, '2026-03-01'),
(1, 2, '2026-03-02'),
(2, 1, '2026-03-03'),
(3, 3, '2026-03-04'),
(4, 4, '2026-03-05'),
(5, 5, '2026-03-06'),
(2, 3, '2026-03-07');

INSERT INTO Result (student_id, course_id, midterm_score, final_score) VALUES
(1, 1, 8.00, 8.50),
(1, 2, 7.50, 8.00),
(2, 1, 6.75, 7.25),
(3, 3, 8.25, 8.75),
(4, 4, 7.00, 7.50),
(5, 5, 9.00, 9.25),
(2, 3, 7.80, 8.10);

-- Cap nhat du lieu
UPDATE Student
SET email = 'minhanh.new@student.edu.vn'
WHERE student_id = 1;

UPDATE Course
SET short_description = 'Cap nhat: hoc SQL tu co ban den nang cao, toi uu truy van'
WHERE course_id = 1;

UPDATE Result
SET final_score = 8.90
WHERE student_id = 3 AND course_id = 3;

-- Xoa mot luot dang ky khong hop le (vi du nhap nham)
DELETE FROM Enrollment
WHERE student_id = 2 AND course_id = 3;

-- Xoa ket qua hoc tap tuong ung neu can
DELETE FROM Result
WHERE student_id = 2 AND course_id = 3;

-- Danh sach tat ca sinh vien
SELECT * FROM Student;

-- Danh sach giang vien
SELECT * FROM Instructor;

-- Danh sach cac khoa hoc
SELECT * FROM Course;

-- Thong tin cac luot dang ky khoa hoc
SELECT * FROM Enrollment;

-- Thong tin cac lan danh gia ket qua
SELECT * FROM Result;
