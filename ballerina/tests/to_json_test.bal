// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;

@test:Config
function testToJsonWithBasicType() {
    string name = "Kanth";
    json|Error j = toJson(name);
    test:assertTrue(j is json);
    test:assertEquals(j, "Kanth");

    int age = 26;
    json|Error j2 = toJson(age);
    test:assertTrue(j2 is json);
    test:assertEquals(j2, 26);

    float height = 5.6;
    json|Error j3 = toJson(height);
    test:assertTrue(j3 is json);
    test:assertEquals(j3, 5.6);

    boolean isStudent = false;
    json|Error j4 = toJson(isStudent);
    test:assertTrue(j4 is json);
    test:assertEquals(j4, false);

    json|Error j5 = toJson(());
    test:assertTrue(j5 is json);
    test:assertEquals(j5, ());
}

type Student record {
    string name;
    int age;
};

@test:Config
function testToJsonWithRecord1() {
    Student s = {name: "Kanth", age: 26};
    json|Error j = toJson(s);
    test:assertTrue(j is json);
    test:assertEquals(j, {name: "Kanth", age: 26});
}

type Address2 record {|
    string country;
    string city;
    json...;
|};

@test:Config
function testToJsonWithRecord2() {
    Address2 addr1 = {country: "x", city: "y", "street": "z", "no": 3};
    json|Error jsonaddr1 = toJson(addr1);
    test:assertTrue(jsonaddr1 is json);
    test:assertEquals(jsonaddr1, {country: "x", city: "y", "street": "z", "no": 3});
}

@test:Config
function testToJsonWithXML() {
    xml x1 = xml `<movie>
                    <title>Some</title>
                    <writer>Writer</writer>
                  </movie>`;
    json|Error j = toJson(x1);
    test:assertTrue(j is json);
    test:assertEquals(j, x1.toString());
}

type TestRecord3 record {|
    @Name {
        value: "a-o"
    }
    string a;
    @Name {
        value: "b-o"
    }
    string b;
    int c;
|};

type NestedRecord3 record {
    @Name {
        value: "d-o"
    }
    int d\-name;
    @Name {
        value: "e-o"
    }
    string e;
    NestedRecord3 f?;
    record {
        @Name {
            value: "i-o"
        }
        int i;
        @Name {
            value: "k-o"
        }
        NestedRecord3 k?;
    } j;
};

@test:Config
function testToJsonWithNameANnotation() {
    TestRecord3 r = {
        a: "name",
        b: "b name",
        c: 1
    };
    json out = {
        "a-o": "name",
        "b-o": "b name",
        "c": 1
    };
    json|Error j = toJson(r);
    test:assertTrue(j is json);
    test:assertEquals(j, out);

    NestedRecord3 n = {
        d\-name: 2,
        e: "test-e",
        f: {
            d\-name: 45,
            e: "nested-e",
            j: {
                i: 1000,
                k: {
                    d\-name: 4,
                    e: "nest-nest-e",
                    j: {
                        i: 10000
                    }
                }
            }
        },
        j: { i: 100}
    };
    json out2 = {
        "d-o": 2,
        "e-o": "test-e",
        f: {
            "d-o": 45,
            e\-o: "nested-e",
            j: {
                "i-o": 1000, 
                "k-o": {
                    d\-o: 4,
                    "e-o": "nest-nest-e",
                    j: {
                        "i-o": 10000
                    }
                }
            }
        },
        j: { "i-o": 100}
    };
    json|Error j2 = toJson(n);
    test:assertTrue(j2 is json);
    test:assertEquals(j2, out2);
}

type TestRecord4 record {|
    @Name {
        value: "a-o"
    }
    string a;
    @Name {
        value: "b-o"
    }
    string b;
    int c;
    TestRecord4[] d;
|};

@test:Config
function testToJsonWithCyclicValues() {
    json[] v1 = [];
    v1.push(v1);
    json|error r1 = trap toJsonWithCyclicValues(v1);
    test:assertTrue(r1 is error);
    error r1Err = <error> r1;
    test:assertEquals("the value has a cyclic reference", r1Err.message());

    map<json> v2 = {};
    v2["val"] = v2;
    json|error r2 = trap toJsonWithCyclicValues(v2);
    test:assertTrue(r2 is error);
    error r2Err = <error> r2;
    test:assertEquals("the value has a cyclic reference", r2Err.message());

    TestRecord4 v3 = {
        a: "a-v",
        b: "b-v",
        c: 1,
        d: []
    };
    v3.d.push(v3);
    json|error r3 = trap toJsonWithCyclicValues(v3);
    test:assertTrue(r3 is error);
    error r3Err = <error> r3;
    test:assertEquals("the value has a cyclic reference", r3Err.message());
}

function toJsonWithCyclicValues(anydata val) returns json {
    return toJson(val);
}
