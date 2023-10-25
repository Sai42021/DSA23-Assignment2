import ballerina/io;
import ballerina/graphql;

type Response record {|
    record {|anydata dt;|} data;
|};
type HoD record {
    readonly string HoD_Code;
    string FirstName;
    string LastName;
    string Department;
};

//Department Objectives record
type Department_Objectives record {
    readonly string objectives_code;
    string objectiveName;
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


public function main() returns error? {
    graphql:Client graphqlClient = check new("http://localhost:3000/graphql");

    io:println("Welcome to the HR Service Client");
    io:println("Please choose your access level:");
    io:println("1. HoD");
    io:println("2. Supervisor");
    io:println("3. Employee");

    string accessLevel = io:readln("Enter your access level (1/2/3): ");
    string username = io:readln("Enter your username: ");
    string password = io:readln("Enter your password (password for all users is '1234'): ");

    string employeeCode;
    string supervisorCode;
    string hodCode;
    string document;

    if(password !="1234"){
       io:println("Invalid password. Exiting."); 
    }else{
        match accessLevel{
             "1"=>{
                string choice = io:readln("Enter 1 to create department objectives\n Enter 2 to delete department objectives\n Enter 3 to View Employees Total Scores.\n Enter 4 Assign the Employee to a supervisor. ");
                match choice{
                    "1" =>{
                        string objectiveCode = io:readln("Enter department objectives code: ");
                        string objectiveName = io:readln("Enter department objectives name: ");
                        document = "mutation createObjective($objectives_code:String!,$objectiveName:String!){createObjective(objectives{objectives_code:$objective_Code,objectiveName:$objectiveName})}";
                        Response createObjective = check graphqlClient->execute(document,{"objectives_code":"$objectiveCode","objectiveName":"$objectiveName"});
                        io:println("Response ", createObjective);
                    }
                    "2" =>{
                        string objectiveCodeToDelete = io:readln("Enter department objectives code to delete: ");
                        document = string `mutation deleteObjective($objectives_code:String!){
                            deleteObjective({objective_code:$objective_Code})
                        }`;
                        Response deleteObjective = check graphqlClient->execute(document,{"objective_code":"$objectiveCodeToDelete"});
                        io:println("Response ", deleteObjective);

                    }
                    "3" =>{
                        string employeeCodeToView = io:readln("Enter employee code to view scores: ");
                        document = string `
                        query {
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
                        }`;
                        Response viewEmployeeScore = check graphqlClient->execute(document,{"employeeCode":"$employeeCodeToView"});
                        io:println("Response ", viewEmployeeScore);
                       
                    }
                    "4" =>{
                        string employeeCodeToAssign = io:readln("Enter employee code to assign to a supervisor: ");
                        string supervisorCodeToAssign = io:readln("Enter supervisor code: ");
                         document = string `mutation assignSupervisor($employeeCode:String!,$supervisorCode:String!){
                            assignSupervisor({employeeCode:$employeeCode,supervisorCode:$supervisorCode})
                        }`;
                        Response assignEmployee = check graphqlClient->execute(document,{"employeeCode":"$employeeCodeToAssign","supervisorCode":"$supervisorCodeToAssign"});
                        io:println("Response ", assignEmployee);
                    }

                    _ =>{}
                     }   
                    
                    }
            "2"=> {
                string choice = io:readln(" ");


            }
            _ => {}
        }
    }
}
    //     var response = graphqlClient->execute(string `
                     //          mutation {
                    //         createObjective(objectives_code: "${objectiveCode}", objectiveName: "${objectiveName}") {
                    //         message
                    //     }

                    //     `);


    // if (accessLevel == "3") {
    //     employeeCode = io:readln("Enter your employee code: ");
    // } else if (accessLevel == "2") {
    //     supervisorCode = io:readln("Enter your supervisor code: ");
    // } else if (accessLevel == "1") {
    //     hodCode = io:readln("Enter your HoD code: ");
    // } else {
    //     io:println("Invalid access level. Exiting.");
    //     return;
    // }

    // Create a GraphQL client for making queries/mutations.
    

    // Create department objectives (for HoD)
    // if (accessLevel == "1") {
    //     string objectiveCode = io:readln("Enter department objectives code: ");
    //     string objectiveName = io:readln("Enter department objectives name: ");
    //     var response = graphqlClient->execute(string `
    //         mutation {
    //             createObjective(objectives_code: "${objectiveCode}", objectiveName: "${objectiveName}") {
    //                 message
    //             }
    //         }
    //     `);
    // }

    // Handle the response as needed.
    // if (response is graphql:Response <json>) {
    //     json? result = response.data;
    //     io:println(result.toString());
    // } else {
    //     io:println("Error in GraphQL request: " + response.toString());
    // }


    // Example 2: Delete department objectives (for HoD)
    // if (accessLevel == "1") {
    //     string objectiveCodeToDelete = io:readln("Enter department objectives code to delete: ");
    //     request = graphqlClient->execute(string `
    //         mutation {
    //             deleteObjective(objectives_code: $objectives_code) {
    //                 objectives_code
    //             }
    //         }
    //     `, { "objectives_code": objectiveCodeToDelete }, "", {}, []);
    // }

//     // Example 3: View Employee Scores (for all access levels)
//     if (accessLevel == "1" || accessLevel == "2" || accessLevel == "3") {
//         string employeeCodeToView = io:readln("Enter employee code to view scores: ");
//         request = graphqlClient->execute(string `
//             query {
//                 viewEmployeeScores(employeeCode: $employeeCodeToView) {
                    
//                 }
//             }
//         `, { "employeeCodeToView": employeeCodeToView }, "", {}, []);
//     }

//     // Example 4: Assign Employee to Supervisor (for all access levels)
//     if (accessLevel == "1" || accessLevel == "2" || accessLevel == "3") {
//         string employeeCodeToAssign = io:readln("Enter employee code to assign to a supervisor: ");
//         string supervisorCodeToAssign = io:readln("Enter supervisor code: ");
//         request = graphqlClient->execute(string `
//             mutation {
//                 assignSupervisor(employeeCode: $employeeCodeToAssign, supervisorCode: $supervisorCodeToAssign)
//             }
//         `, { "employeeCodeToAssign": employeeCodeToAssign, "supervisorCodeToAssign": supervisorCodeToAssign }, "", {}, []);
//     }

//     // Send the GraphQL request to the service.
//     graphql:Response response = graphqlClient->execute(request);

//     // Check the response and handle the result as needed.
//     if (response is graphql:Response<json>) {
//         json? result = response.data;
//         io:println(result.toString());
//     } else {
//         io:println("Error in GraphQL request: " + response.toString());
//     }
// }
