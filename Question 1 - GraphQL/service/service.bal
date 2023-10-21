import ballerina/graphql;
import ballerinax/mongodb;

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
    string firstName;
    string lastName;
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



@graphql:ServiceConfig {
    graphiql: {
        enabled: true
    }
}
 

service / on new graphql:Listener(3000) {
    // query

    //get department by ID
    resource function get getDepById() returns Department[]|error{
        stream<Department, error?> getDepertment= mongoclient->find(userCollection, performance-management,{},{},-1,-1);
        return Department.toArray();
        //syntax:function find(string collectionName, string? databaseName, map<json>? filter, map<json>? projection, map<json>? sort, int 'limit, int skip, typedesc<record {}> rowType) returns stream<rowType, error?>|Error
    }

    //get User by ID

    //get objective for a department

    //get KPIs for a user

    //get KPIs for  department's objectives

    //get employees for a supervisor


     // query
    resource function get login(User user) returns string|json|error {
        stream<UserDetails, error?> usersDeatils = check db->find(userCollection, databaseName, {username: user.username, password: user.password}, {});

        UserDetails[] users = check from var userInfo in usersDeatils
            select userInfo;
        io:println("Users ", users);
        // If the user is found return a user or return a string user not found
        if users.length() > 0 {
            return users[0].toJson();

        } 
            return "User not found";
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

        int updatedCount = check db->update(newPasswordDoc, userCollection, databaseName, {username: updatedUser.username}, true, false);
        io:println("Updated Count ", updatedCount);

        if updatedCount > 0 {
            return string `${updatedUser.username} password changed successfully`;
        }
        return "Failed to updated";
    }
// New

//Create a department objective. createObjective
remote function createObjective(object newObject) returns error |string{
    map<json> doc = <map<json>>newObject.toJson();
        _ = check db->insert(doc, productCollection, "");
        return string `${newproduct.name} added successfully`;
}

// Delete a department objective. deleteObjective

// Assign an employee to a supervisor.  assignEmployeeToSupervisor

// Create a KPI for a user.  createKPI

// Approve a user's KPIs (for supervisors).approveUserKPIs

// Delete a user's KPIs (for supervisors).deleteUserKPIs

// Update a user's KPI score. updateUserKPIScore

// Grade a user's KPIs (for supervisors).gradeUserKPIs

// Grade a supervisor (for employees). gradeSupervisor

}
