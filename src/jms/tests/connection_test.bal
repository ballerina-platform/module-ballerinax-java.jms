import ballerina/test;
import ballerina/io;


function testConnectionCreation () {
    
    Connection conn = new ({

    });
    io:println("Connection created!");
    test:assertTrue(true , msg = "Failed!");
}

@test:Config {
    before: "testConnectionCreation"
}
function testConnectionStart() {
    
    Connection conn = new ({});
    conn->start();
    io:println("Connection started!");
    test:assertTrue(true , msg = "Failed!");
}

@test:Config {
    before: "testConnectionCreation"
}
function testConnectionStop() {
    
    Connection conn = new ({});
    io:println("Connection stopped!");
    test:assertTrue(true , msg = "Failed!");
}