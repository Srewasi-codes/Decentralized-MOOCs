// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedMOOC {
    struct Course {
        uint id;
        string title;
        string description;
        address payable instructor;
        uint price;
        bool isActive;
    }

    struct Student {
        address studentAddress;
        mapping(uint => bool) enrolledCourses;
        mapping(uint => bool) completedCourses;
    }

    uint public courseCount;
    mapping(uint => Course) public courses;
    mapping(address => Student) public students;
    mapping(uint => mapping(address => bool)) public certifications;

    event CourseCreated(
        uint id,
        string title,
        string description,
        address instructor,
        uint price
    );

    event Enrolled(uint courseId, address student);
    event Certified(uint courseId, address student);

    // Function to create a new course
    function createCourse(
        string memory _title,
        string memory _description,
        uint _price
    ) public {
        courseCount++;
        courses[courseCount] = Course({
            id: courseCount,
            title: _title,
            description: _description,
            instructor: payable(msg.sender),
            price: _price,
            isActive: true
        });

        emit CourseCreated(courseCount, _title, _description, msg.sender, _price);
    }

    // Function to enroll in a course
    function enroll(uint _courseId) public payable {
        Course memory course = courses[_courseId];
        require(course.isActive, "Course is not active");
        require(msg.value == course.price, "Incorrect payment amount");
        require(!students[msg.sender].enrolledCourses[_courseId], "Already enrolled");

        students[msg.sender].enrolledCourses[_courseId] = true;
        course.instructor.transfer(msg.value);

        emit Enrolled(_courseId, msg.sender);
    }

    // Function to certify a student upon course completion
    function certifyStudent(uint _courseId, address _student) public {
        Course memory course = courses[_courseId];
        require(msg.sender == course.instructor, "Only instructor can certify");
        require(students[_student].enrolledCourses[_courseId], "Student not enrolled");

        students[_student].completedCourses[_courseId] = true;
        certifications[_courseId][_student] = true;

        emit Certified(_courseId, _student);
    }

    // Function to verify certification
    function verifyCertification(uint _courseId, address _student) public view returns (bool) {
        return certifications[_courseId][_student];
    }

    // Function to deactivate a course
    function deactivateCourse(uint _courseId) public {
        require(msg.sender == courses[_courseId].instructor, "Only instructor can deactivate");
        courses[_courseId].isActive = false;
    }

    // Function to reactivate a course
    function reactivateCourse(uint _courseId) public {
        require(msg.sender == courses[_courseId].instructor, "Only instructor can reactivate");
        courses[_courseId].isActive = true;
    }
}
