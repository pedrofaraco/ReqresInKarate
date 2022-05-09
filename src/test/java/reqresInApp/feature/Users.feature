Feature: Users

Background:
    * url apiUrl
    * def userDataSchema = {'id': '#number', 'email': '#string', 'first_name': '#string', 'last_name': '#string', 'avatar': '#string'}
    * def dataGenerator = Java.type('helpers.DataGenerators')
    * def randomName = dataGenerator.getRandomName()
    * def randomJob = dataGenerator.getRandomJob()
    * def emailValidator = "#regex " + emailRegex


Scenario: Get Users - Validate Contract
    Given path 'users'
    When method GET
    Then status 200
    And match response ==
    """
    {
        'page': '#number? _ > 0',
        'per_page': '#number? _ > 0',
        'total': '#number? _ > 0',
        'total_pages': '#number? _ > 0',
        'data': '#[] userDataSchema',
        'support': {
            'url': '#string',
            'text': '#string'
        }
    }
    """

Scenario: Get Single User - Validate Contract
    # First call to get a valid user ID
    Given path 'users'
    When method GET
    Then status 200
    * def firstUserID = response.data[0].id
    # Second call, to validate schema
    Given path 'users', firstUserID
    When method GET
    Then status 200
    And match response ==
    """
    {
        "data": {
            "id": #(firstUserID),
            "email": #(emailValidator),
            "first_name": "#string",
            "last_name": "#string",
            "avatar": "#string"
        },
        "support": {
            "url": "#string",
            "text": "#string"
        }
    }    
    """

Scenario: User not found
    Given path 'users', 0
    When method GET
    Then status 404
    And match response == {}

Scenario: Create User
    * def timeValidator = read('classpath:helpers/timeValidator.js')
    Given path 'users'
    And request { "name": #(randomName), "job": #(randomJob) }
    When method POST
    Then status 201
    And match response ==
    """
    {
        "name": #(randomName),
        "job": #(randomJob),
        "id": "#string",
        "createdAt": "#? timeValidator(_)"
    }
    """