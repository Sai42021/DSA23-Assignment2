import ballerina/graphql;
import ballerinax/mongodb;
import ballerina/io;

mongodb:ConnectionConfig mongoConfig = {
connection: {
host: "localhost",
port: 27017,
auth: {
username: "",
password: ""
},
options: {
sslEnabled: false,
serverSelectionTimeout: 5000
}
},
databaseName: "Performance-management"
};

mongodb:Client mongoClient = check new (mongoConfig);
configurable string departmentCollection = "Departments";
configurable string objectiveCollection = "Objectives";
configurable string userCollection = "Users";
configurable string kpiCollection = "KPIs";
configurable string databaseName = "performance-management";

type Department record {
    int id;
    string name;
    Objective objectives;
    User employees;
    User headofDepartment;
};

type Objective record {
    int id;
    string description;
    float weight;
    Department Department;
};

type User record {
    int id;
    string username;
    string password;
    string jobTitle;
    string position;
    UserRole userRole;
    Department Department;
    User supervisor;
};

type KPI record {
    int id;
    string description;
    string unit;
    float score;
    User User;
};

enum UserRole {
  HoD,
  Employee,
  Supervisor
};

type UserDetails record {
    string username;
    string? password;
    boolean isAdmin;
};

type UpdatedUserDetails record {
    string username;
    string password;
};

type LoggedUserDetails record {|
    string username;
    boolean isAdmin;
|};

@graphql:ServiceConfig {
    graphiql: {
        enabled: true
    }
}
service / graphql on new graphql:Listener(9090){

    // query

    //get department by ID
    resource function get getDepById() returns Department[]|error{
        stream<Department, error?> getDepertment= check db->find(departmentCollection, "",{});
        return department.toArray();
        //syntax:function find(string collectionName, string? databaseName, map<json>? filter, map<json>? projection, map<json>? sort, int 'limit, int skip, typedesc<record {}> rowType) returns stream<rowType, error?>|Error
    }

    //get User by ID
    resource function get getUserById(string userId) returns User[] | error {
    map<json> filter = { "id": userId };
    stream<User, error?> userStream = mongoClient->find(userCollection, "", filter,{} );
    return userStream.toArray();
}

    //get objective for a department
    resource function get getObjectivesForDepartment(string departmentId) returns Objective[] | error {
    map<json> filter = { "Department.id": departmentId };
    stream<Objective, error?> objectiveStream = mongoClient->find(objectiveCollection, "", filter, {}, -1, -1);
    return objectiveStream.toArray();
}


    //get KPIs for a user
    resource function get getKPIsForUser(string userId) returns KPI[] | error {
    map<json> filter = { "User.id": userId };
    stream<KPI, error?> kpiStream = mongoClient->find(kpiCollection, "", filter, {}, -1, -1);
    return kpiStream.toArray();
}


    //get KPIs for  department's objectives
    resource function get getKPIsForDepartmentObjectives(string departmentId) returns KPI[] | error {
    map<json> objectiveFilter = { "Department.id": departmentId };
    stream<Objective, error?> objectiveStream = mongoClient->find(objectiveCollection, "", objectiveFilter, {}, -1, -1);
    var objectiveIds = objectiveStream.map((Objective obj) => obj.id);
    map<json> kpiFilter = { "Objective.id": objectiveIds };
    stream<KPI, error?> kpiStream = mongoClient->find(kpiCollection, databaseName, kpiFilter, {}, -1, -1);
    
    return kpi.toArray();
}

    //get employees for a supervisor
    resource function get getEmployeesForSupervisor(string supervisorId) returns User[] | error {
    map<json> filter = { "supervisor.id": supervisorId };
    stream<User, error?> employeeStream = mongoClient->find(userCollection, "", filter, {}, -1, -1);
    return employeeStream.toArray();
}


     // query
    resource function get login(User user) returns LoggedUserDetails|error {
        stream<UserDetails, error?> usersDeatils = check db->find(userCollection, "", {username: user.username, password: user.password}, {});

        UserDetails[] users = check from var userInfo in usersDeatils
            select userInfo;
        io:println("Users ", users);
        // If the user is found return a user or return a string user not found
        if users.length() > 0 {
            return {username: users[0].username, isAdmin: users[0].isAdmin};
        }
        return {
            username: "",
            isAdmin: false
        };
    }

    // mutation
    remote function register(User newuser) returns error|string {

        map<json> doc = <map<json>>{isAdmin: false, username: newuser.username, password: newuser.password};
        _ = check db->insert(doc, userCollection, "");
        return string `${newuser.username} added successfully`;
    }

    // Function change the user password by updating the user using mongoDB update function $set
    // Mongo db update function comes with deifferent functions that you can use to modify your data
    // + $push and $pull for arrays inside your document
    // + $set for replace a value for example password.
    remote function changePassword(UpdatedUserDetails updatedUser) returns error|string {

        map<json> newPasswordDoc = <map<json>>{"$set": {"password": updatedUser.password}};

        int updatedCount = check db->update(newPasswordDoc, userCollection, "", {username: updatedUser.username}, true, false);
        io:println("Updated Count ", updatedCount);

        if updatedCount > 0 {
            return string `${updatedUser.username} password changed successfully`;
        }
        return "Failed to updated";
    }
// New

//Create a department objective. createObjective
remote function createObjective(Objective newObjective) returns error |string{
    map<json> obj = <map<json>>newObjective.toJson();
        _ = check db->insert(obj, objectiveCollection, "");
        return string `${newObjective.name} added successfully`;
}

// Delete a department objective. deleteObjective
remote function deleteObjective(int objectiveId) returns error | string {
    mongodb:Error | int deleteItem = db->delete(objectiveCollection, "", { "id": objectiveId }, false);
    if (deleteItem is mongodb:Error) {
        return error("Failed to delete objective");
    } else {
        if (deleteItem > 0) {
            return string `${objectiveId} deleted successfully`;
        } else {
            return "Objective not found";
        }
    }
}


// Assign an employee to a supervisor.  assignEmployeeToSupervisor
remote function assignEmployeeToSupervisor(int employeeId, int supervisorId) returns error | string {
    // Define filters to match the employee and supervisor by their IDs
    map<json> employeeFilter = { "id": employeeId };
    map<json> supervisorFilter = { "id": supervisorId };
    
    // Update the employee document to set the supervisor ID
    map<json> updateEmployeeDoc = <map<json>>{ "$set": { "supervisor": supervisorId } };
    
    // Update the supervisor document to add the employee to their team
    map<json> updateSupervisorDoc = <map<json>>{ "$push": { "employees": employeeId } };
    
    // Perform the update operations on both employee and supervisor documents
    int updatedEmployeeCount = check db->update(updateEmployeeDoc, userCollection, "", employeeFilter, true, false);
    int updatedSupervisorCount = check db->update(updateSupervisorDoc, userCollection, "", supervisorFilter, true, false);
    
    // Check if both updates were successful
    if (updatedEmployeeCount > 0 && updatedSupervisorCount > 0) {
        return "Employee assigned to supervisor successfully";
    }
    
    return "Failed to assign employee to supervisor";
}


// Create a KPI for a user.  createKPI
remote function createKPI(KPI newKPI) returns error | string {
        json doc = newKPI.toJson();
        _ = check mongoClient->insert(<map<json>>doc, kpiCollection, databaseName);
        return string `${newKPI.description} added as a KPI successfully`;
    }


// Approve a user's KPIs (for supervisors).approveUserKPIs
remote function approveUserKPIs(string userId) returns error | string {
    // Define a filter to match KPIs related to the user by their user ID
    map<json> filter = { "User.id": userId };
    
    // Update the KPI documents to set the approval status
    map<json> updateKPIDoc = <map<json>>{ "$set": { "approved": true } };
    
    // Perform the update operation on the KPI documents
    int updatedCount = check db->update(updateKPIDoc, kpiCollection, databaseName, filter, true, false);
    
    if (updatedCount > 0) {
        return "KPIs approved successfully";
    }
    
    return "Failed to approve KPIs";
}

// Delete a user's KPIs (for supervisors).deleteUserKPIs
remote function deleteUserKPIs(string userId) returns error | string {
    // Define a filter to match KPIs related to the user by their user ID
    map<json> filter = { "User.id": userId };
    
    // Delete the KPI documents related to the user
    mongodb:Error | int deleteCount = db->delete(kpiCollection, "", filter, false);
    
    if (deleteCount is mongodb:Error) {
        return error("Failed to delete KPIs");
    } else {
        if (deleteCount > 0) {
            return "KPIs deleted successfully";
        }
        return "No KPIs found for deletion";
    }
}


// Update a user's KPI score. updateUserKPIScore
remote function updateUserKPIScore(int kpiId, float newScore) returns error | string {
    // Define a filter to match the KPI by its ID
    map<json> filter = { "id": kpiId };
    
    // Update the KPI document to set the new score
    map<json> updateKPIDoc = <map<json>>{ "$set": { "score": newScore } };
    
    // Perform the update operation on the KPI document
    int updatedCount = check db->update(updateKPIDoc, kpiCollection, "", filter, true, false);
    
    if (updatedCount > 0) {
        return "KPI score updated successfully";
    }
    
    return "Failed to update KPI score";
}


// Grade a user's KPIs (for supervisors).gradeUserKPIs
remote function gradeUserKPIs(string userId, string grade) returns error | string {
    // Define a filter to match KPIs related to the user by their user ID
    map<json> filter = { "User.id": userId };
    
    // Update the KPI documents to set the grade
    map<json> updateKPIDoc = <map<json>>{ "$set": { "grade": grade } };
    
    // Perform the update operation on the KPI documents
    int updatedCount = check db->update(updateKPIDoc, kpiCollection, "", filter, true, false);
    
    if (updatedCount > 0) {
        return "KPIs graded successfully";
    }
    
    return "Failed to grade KPIs";
}


// Grade a supervisor (for employees). gradeSupervisor
remote function gradeSupervisor(int supervisorId, string grade) returns error | string {
    // Define a filter to match the supervisor by their ID
    map<json> filter = { "id": supervisorId };
    
    // Update the supervisor document to set the grade
    map<json> updateSupervisorDoc = <map<json>>{ "$set": { "grade": grade } };
    
    // Perform the update operation on the supervisor document
    int updatedCount = check db->update(updateSupervisorDoc, userCollection, "", filter, true, false);
    
    if (updatedCount > 0) {
        return "Supervisor graded successfully";
    }
    
    return "Failed to grade supervisor";
}



}

