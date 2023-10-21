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

    // Define the GraphQL client endpoint.
    graphql:ClientEndpoint clientEP = new({
        url: "http://localhost:3000/graphql", 
    });

    // Create a GraphQL client for making queries/mutations.
    graphql:Client graphqlClient = new(clientEP);

    // Use the GraphQL client to send queries/mutations to the service based on the user's input and access level.
    graphql:Request request;

    // Example 1: Create department objectives (for HoD)
    if (accessLevel == "1") {
        string objectiveCode = io:readln("Enter department objectives code: ");
        Department_Objectives objective = { objectives_code: objectiveCode };
        request = graphqlClient.newRequest(`
            mutation CreateObjective($objective: Department_Objectives) {
                createObjective(objectives: $objective) {
                    message
                }
            }
        `);
        request.setVariable("objective", objective);
    }

    // Example 2: Delete department objectives (for HoD)
    if (accessLevel == "1") {
        string objectiveCodeToDelete = io:readln("Enter department objectives code to delete: ");
        request = graphqlClient.newRequest(`
            mutation DeleteObjective($objectives_code: String) {
                deleteObjective(objectives_code: $objectives_code) {
                    objectives_code
                }
            }
        `);
        request.setVariable("objectives_code", objectiveCodeToDelete);
    }

    // Example 3: View Employee Scores (for all access levels)
    if (accessLevel == "1" || accessLevel == "2" || accessLevel == "3") {
        string employeeCodeToView = io:readln("Enter employee code to view scores: ");
        request = graphqlClient.newRequest(`
            query ViewEmployeeScores($employeeCode: String) {
                viewEmployeeScores(employeeCode: $employeeCode) {
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
        `);
        request.setVariable("employeeCode", employeeCodeToView);
    }

    // Example 4: Assign Employee to Supervisor (for all access levels)
    if (accessLevel == "1" || accessLevel == "2" || accessLevel == "3") {
        string employeeCodeToAssign = io:readln("Enter employee code to assign to a supervisor: ");
        string supervisorCodeToAssign = io:readln("Enter supervisor code: ");
        request = graphqlClient.newRequest(`
            mutation AssignSupervisor($employeeCode: String, $supervisorCode: String) {
                assignSupervisor(employeeCode: $employeeCode, supervisorCode: $supervisorCode)
            }
        `);
        request.setVariable("employeeCode", employeeCodeToAssign);
        request.setVariable("supervisorCode", supervisorCodeToAssign);
    }

    // Additional cases for other functions can be added here...

    // Send the GraphQL request to the service.
    graphql:Response response = clientEP->execute(request);

    // Check the response and handle the result as needed.
    if (response is graphql:Response<json>) {
        json? result = response.data;
        io:println(result.toString());
    } else {
        io:println("Error in GraphQL request: " + response.toString());
    }
}
