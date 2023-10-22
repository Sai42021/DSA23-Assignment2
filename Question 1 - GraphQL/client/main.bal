import ballerina/io;
import ballerina/graphql;

public function main() {
    io:println("Welcome to the HR Service Client");
    io:println("Please choose your access level:");
    io:println("1. HoD");
    io:println("2. Supervisor");
    io:println("3. Employee");

    string accessLevel = io:readln("Enter your access level (1/2/3): ");

    string username = io:readln("Enter your username: ");
    string password = io:readln("Enter your password (password for all users is '1234'): ");

    if (password != "1234") {
        io:println("Invalid password. Exiting.");
        return;
    }

    string employeeCode;
    string supervisorCode;
    string hodCode;

    if (accessLevel == "3") {
        employeeCode = io:readln("Enter your employee code: ");
    } else if (accessLevel == "2") {
        supervisorCode = io:readln("Enter your supervisor code: ");
    } else if (accessLevel == "1") {
        hodCode = io:readln("Enter your HoD code: ");
    } else {
        io:println("Invalid access level. Exiting.");
        return;
    }

    // Create a GraphQL client for making queries/mutations.
    graphql:Client graphqlClient = check new("http://localhost:3000/graphql");

    // Create department objectives (for HoD)
    if (accessLevel == "1") {
        string objectiveCode = io:readln("Enter department objectives code: ");
        string objectiveName = io:readln("Enter department objectives name: ");
        var response = graphqlClient->execute(string `
            mutation {
                createObjective(objectives_code: "${objectiveCode}", objectiveName: "${objectiveName}") {
                    message
                }
            }
        `);
    }

    // Handle the response as needed.
    if (response is graphql:Response<json>) {
        json? result = response.data;
        io:println(result.toString());
    } else {
        io:println("Error in GraphQL request: " + response.toString());
    }
}

    // Example 2: Delete department objectives (for HoD)
    if (accessLevel == "1") {
        string objectiveCodeToDelete = io:readln("Enter department objectives code to delete: ");
        request = graphqlClient->execute(string `
            mutation {
                deleteObjective(objectives_code: $objectives_code) {
                    objectives_code
                }
            }
        `, { "objectives_code": objectiveCodeToDelete }, "", {}, []);
    }

    // Example 3: View Employee Scores (for all access levels)
    if (accessLevel == "1" || accessLevel == "2" || accessLevel == "3") {
        string employeeCodeToView = io:readln("Enter employee code to view scores: ");
        request = graphqlClient->execute(string `
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
            }
        `, { "employeeCodeToView": employeeCodeToView }, "", {}, []);
    }

    // Example 4: Assign Employee to Supervisor (for all access levels)
    if (accessLevel == "1" || accessLevel == "2" || accessLevel == "3") {
        string employeeCodeToAssign = io:readln("Enter employee code to assign to a supervisor: ");
        string supervisorCodeToAssign = io:readln("Enter supervisor code: ");
        request = graphqlClient->execute(string `
            mutation {
                assignSupervisor(employeeCode: $employeeCodeToAssign, supervisorCode: $supervisorCodeToAssign)
            }
        `, { "employeeCodeToAssign": employeeCodeToAssign, "supervisorCodeToAssign": supervisorCodeToAssign }, "", {}, []);
    }

    // Send the GraphQL request to the service.
    graphql:Response response = graphqlClient->execute(request);

    // Check the response and handle the result as needed.
    if (response is graphql:Response<json>) {
        json? result = response.data;
        io:println(result.toString());
    } else {
        io:println("Error in GraphQL request: " + response.toString());
    }
}
