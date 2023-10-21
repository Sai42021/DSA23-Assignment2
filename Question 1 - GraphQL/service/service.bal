import ballerina/graphql;

//HoD record
type HoD record {
    readonly string HoD_Code;
    string FirstName;
    string LastName;
    string Department;
};

//Department Objectives record
type Department_Objectives record {
    readonly string objectives_code;
};

//Supervisor record
type Supervisor record {
    readonly string supervisorCode;
    string FirstName;
    string LastName;
    string Department;
};

//Employee record
type Employee record {
    readonly string employeeCode;
    string FirstName;
    string LastName;
    string Department;
    string supervisor;
    int supervisorGrade;
    int Professional_Development_KPI;
    int Student_Progress_KPI;
    int Innovative_Teaching_Methods_KPI;
    int TotalScore;
};

//Message declaration
type successMessage record {
    string message = "Operation Successful";
};

//Department objectives table
table<Department_Objectives> key(objectives_code) objectivesTable = table [];

//HoD table
table<HoD> key(HoD_Code) HoD_Table = table [];

//Supervisor table
table<Supervisor> key(supervisorCode) supervisorTable = table [];

//Employee table
table<Employee> key(employeeCode) employeeTable = table [];

@graphql:ServiceConfig {
    graphiql: {
        enabled: true
    }
}

service / on new graphql:Listener(3000) {

    //HoD Functions

    //Create department objectives.
    remote function createObjective(Department_Objectives objectives) returns typedesc<successMessage>|Department_Objectives|error {
        error? addNewObjective = objectivesTable.add(objectives);
        if addNewObjective is error {
            return addNewObjective;
        } else {
            return successMessage;
        }
    }

    //Delete department objectives
    remote function deleteObjective(string objectives_code) returns Department_Objectives? {
        Department_Objectives? deletedObjectives = objectivesTable.remove(objectives_code);
        return deletedObjectives;
    }

    //View Employees Total Scores - Enter employeeCode and get entire employee record from employee table
    remote function viewEmployeeScores(string employeeCode) returns Employee? {
        Employee? employee = employeeTable[employeeCode];
        return employee;
    }

    //Assign the Employee to a supervisor
    remote function assignSupervisor(string employeeCode, string supervisorCode) returns boolean {
        Employee? employee = employeeTable[employeeCode];
        Supervisor? supervisor = supervisorTable[supervisorCode];
        if (employee != null && supervisor != null) {
            employee.supervisor = supervisorCode;
            return true;
        }
        return false;
    }

    //Supervisor Functions

    //Delete Employee's KPIs - Allows you to enter an employees code and delete a specified KPI score
    remote function deleteKPI(string employeeCode, string kpiName) returns boolean {
        Employee? employee = employeeTable[employeeCode];
        if (employee != null) {
            // Assuming kpiName is a field name, you can set it to zero or null.
            employee[kpiName] = 0; // Or null, depending on your data type.
            return true;
        }
        return false;
    }

    //Update Employess's KPIs - Allows you to enter an employess code and update a specified KPI score
    remote function updateKPI(string employeeCode, string kpiName, int newValue) returns boolean {
        Employee? employee = employeeTable[employeeCode];
        if (employee != null) {
            // Assuming kpiName is a field name.
            employee[kpiName] = newValue;
            return true;
        }
        return false;
    }

    //View Employee's scores - Allows the supervisor to enter an employess code and if that employee is indeed assigned to them, they can view the employees record including thier KPIs
    remote function viewEmployeeKPI(string employeeCode, string supervisorCode) returns Employee? {
        Employee? employee = employeeTable[employeeCode];
        Supervisor? supervisor = supervisorTable[supervisorCode];
        if (employee != null && employee.supervisor == supervisorCode) {
            return employee;
        }
        return null;
    }

    //Grade the Employees KPIs - Supervisor can assign a score out of 5 for the TotalScore record in the empoyee table for a specified employee
    remote function gradeEmployeeKPI(string employeeCode, int grade) returns boolean {
        Employee? employee = employeeTable[employeeCode];
        if (employee != null) {
            employee.TotalScore = grade;
            return true;
        }
        return false;
    }

    //Employee Functions

    //Create thier KPI's - Allows an employee to create edit and-or create own KPI scores
    remote function createOwnKPI(string employeeCode, string kpiName, int newValue) returns boolean {
        Employee? employee = employeeTable[employeeCode];
        if (employee != null) {
            // Assuming kpiName is a field name.
            employee[kpiName] = newValue;
            return true;
        }
        return false;
    }

    //Grade their supervisor - lets the employee assign a grade to their supervisors grdae in the employee table
    remote function gradeSupervisor(string employeeCode, int grade) returns boolean {
        Employee? employee = employeeTable[employeeCode];
        if (employee != null) {
            employee.supervisorGrade = grade;
            return true;
        }
        return false;
    }

    //View thier scores - Let's an employee view all thier KPI scores only
    remote function viewOwnKPI(string employeeCode) returns Employee? {
    Employee? employee = employeeTable[employeeCode];
    if (employee != null) {
        return employee;
    }
    return null;
}

}
