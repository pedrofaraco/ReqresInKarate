Feature: Colors

Background:
    * url apiUrl
    * def colorsDataSchema = {'id': '#number', 'name': '#string', 'year': '#number', 'color': '#string', 'pantone_value': '#string'}

Scenario: Get Colors - Validate Contract
    Given path 'colors'
    When method GET
    Then status 200
    And match response ==
    """
    {
        'page': '#number? _ > 0',
        'per_page': '#number? _ > 0',
        'total': '#number? _ > 0',
        'total_pages': '#number? _ > 0',
        'data': '#[] colorsDataSchema',
        'support': {
            'url': '#string',
            'text': '#string'
        }
    }
    """

Scenario: Get Single Color - Validate Contract
    # First call to get a valid user ID
    Given path 'colors'
    When method GET
    Then status 200
    * def firstColorID = response.data[0].id
    # Second call, to validate schema
    Given path 'colors', firstColorID
    When method GET
    Then status 200
    And match response ==
    """
    {
        "data": {
            "id": #(firstColorID),
            "name": "#string",
            "year": "#number",
            "color": "#string",
            "pantone_value": "#string"
        },
        "support": {
            "url": "#string",
            "text": "#string"
        }
    }    
    """

Scenario: Color not found
    Given path 'colors', 0
    When method GET
    Then status 404
    And match response == {}