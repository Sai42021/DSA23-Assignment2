import ballerina/graphql;
import ballerina/io;

type response record {|
    record {|anydata dt;|} data;
|};

public function main() returns error? {
    io:println("Welcome to the HR Service Client");
    io:println("Please choose your access level:");
    io:println("1. HoD");
    io:println("2. Supervisor");
    io:println("3. Employee");

    string accessLevel = io:readln("Enter your access level (1/2/3): ");

    string password = io:readln("Enter your password (password for all users is '1234'): ");

    if (password != "1234") {
        io:println("Invalid password. Exiting.");
        return;
    }

    if (accessLevel == "3") {
        string employeeCode = io:readln("Enter your employee code: ");
    } else if (accessLevel == "2") {
        string supervisorCode = io:readln("Enter your supervisor code: ");
    } else if (accessLevel == "1") {
        string hodCode = io:readln("Enter your HoD code: ");
    } else {
        io:println("Invalid access level. Exiting.");
        return;
    }

    // Create a GraphQL client for making queries/mutations.
    graphql:Client graphqlClient = check new ("http://localhost:3000/graphql");

    // Create department objectives (for HoD)
    if (accessLevel == "1") {
        string objectiveCode = io:readln("Enter department objectives code: ");
        string nameObjective = io:readln("Enter department objectives name: ");

        string createObj = string `
    mutation createObjective($objectives_code:String!,$objectiveName:String!){
        createObjective(newObjective:{objectives_code:$objectives_code,objectiveName:$objectiveName})
    }`;

        response createObjectiveResponse = check graphqlClient->execute(createObj, {"objectives_code": objectiveCode, "objectiveName": nameObjective});

        io:println("Response ", createObjectiveResponse);
    }

    // Delete department objectives (for HoD)
    if (accessLevel == "1") {
        string objectiveCodeToDelete = io:readln("Enter department objectives code to delete: ");

        string deleteObj = string `
    mutation deleteObjective($objectives_code:String!){
        deleteObjective(objectiveToBeDeleted:{objectives_code:$objectives_code})
    }`;

        response deleteObjectiveResponse = check graphqlClient->execute(deleteObj, {"objectives_code": objectiveCodeToDelete});

        io:println("Response ", deleteObjectiveResponse);
    }

    // View Employee Scores (for all access levels)
    if (accessLevel == "1" || accessLevel == "2" || accessLevel == "3") {
        string employeeCodeToView = io:readln("Enter employee code to view scores: ");

        string viewScore = string `
            query {
                viewEmployeeScores(employeeCode: $employeeCodeToView) {
                    employeeCode
                    FirstName
                    LastName
                    Department
                    supervisor
                    supervisorGrade
                    Professional_Development_KPI
                    Student_Progress_KPI
                    Innovative_Teaching_Methods_KPI
                    TotalScore
                }
            }`;

        response viewScoreResponse = check graphqlClient->execute(viewScore, {"employeeCodeToView": employeeCodeToView});
        io:println("Response ", viewScoreResponse);
    }

    // Assign Employee to Supervisor (for all access levels)
    if (accessLevel == "1" || accessLevel == "2" || accessLevel == "3") {
        string employeeCodeToAssign = io:readln("Enter employee code to assign to a supervisor: ");
        string supervisorCodeToAssign = io:readln("Enter supervisor code: ");

        string doc = string `
    mutation assignSupervisor($employeeCode:String!,$supervisorCode:String!){
        assignSupervisor(newSupervisor:{employeeCode:$employeeCode,supervisorCode:$supervisorCode})
    }`;

        response assignSupervisorResponse = check graphqlClient->execute(doc, {"employeeCode": employeeCodeToAssign, "supervisorCode": supervisorCodeToAssign});

        io:println("Response ", assignSupervisorResponse);

    }

}
